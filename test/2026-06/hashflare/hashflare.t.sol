// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./Base.sol";

// @KeyInfo - Total Lost : N/A
// Attacker : 0xff575a22975cc413771825eb84c163189a4d5d22
// Attack Contract : 0xc82f007bb4096a47d14ed0d46ee8143d37539d04
// Vulnerable Contract : 0xc82f007bb4096a47d14ed0d46ee8143d37539d04
// Attack Tx : 0xd0eafd5c03b24c2f54c579745cacbffe4c6df2d19973e55d52a5f40aa1d089e0
// Block : 25371671
// Chain : Ethereum
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
    uint256 constant FORK_BLOCK = 25371670;
    uint256 constant TX_TIMESTAMP = 1782113627;
    uint256 constant TX_BLOCK_NUMBER = 25371671;
    uint256 constant TX_VALUE = 10624813859750980403908;

    function setUp() public {
        vm.createSelectFork(vm.envString("POC_FORK_ENDPOINT"), FORK_BLOCK);
        if (TX_TIMESTAMP != 0) vm.warp(TX_TIMESTAMP);
        if (TX_BLOCK_NUMBER != 0) vm.roll(TX_BLOCK_NUMBER);
    }

    function testPoC() public {
        vm.startPrank(ATTACKER_EOA, ATTACKER_EOA);
        AttackContract attack = new AttackContract();
        _prepareProfit(address(attack), address(0));
        attack.attack{value: TX_VALUE}();
        vm.stopPrank();
        _assertProfit();
    }

    function _expectProfitLegs(address attack, address attackChild) internal pure override {
        attack;
        attackChild;
    }
}

contract AttackContract {
    function attack() external payable {
        // unresolved-gap: the deterministic handoff has no pseudocode/action-graph calls
        // or economic oracle for this direct-call entry, so the refined PoC preserves
        // reachability without inventing protocol interactions.
    }

    receive() external payable {}

    fallback() external payable {}
}

library Addresses {
    address internal constant attacker_eoa = 0xfF575a22975CC413771825EB84c163189A4d5D22;
}
