# BackedFi Incident Report

## Summary

- **Protocol**: BackedFi
- **Chain**: ethereum (chain_id=1)
- **Tx hash**: [`0xe2320086b2815d21b0927839bd0e306466c29a68d38d5361e99dd21ec5472612`](https://etherscan.io/tx/0xe2320086b2815d21b0927839bd0e306466c29a68d38d5361e99dd21ec5472612)
- **Block**: 25434062
- **Economic reproduction**: exact — PoC reproduces 99–101% of incident net loss.
- **Elapsed analysis time**: 891.40s (891404 ms)
- **Detected at**: 2026-07-01T01:30:57+00:00
- **Original alert**: https://x.com/TenArmorAlert/status/2072130807356129726

## Impact

- **Estimated loss**: $204137.47
- **Funds valued at**: 2026-07-01T00:24:35Z (price as of block N-1, pre-hack)
- **Main affected assets**: USDC, wSPYx, wQQQx, wNVDAx, wMSTRx
- **Attacker gain reproduced**: $204137.47 (USD ratio: 1.000x)
- **USD incomplete**: 5 unpriced leg(s); estimated loss is a lower bound

## Reproduction

- **PoC status**: `verified`
- **Forge test**: `pass`
- **Proof kind**: `economic_proof`

## Root Cause

- **Finding**: Pool borrow accounting allowed repeated wrapped-token debt expansion against insufficient current collateral
- **In short**: The vulnerable path is the `borrow(wGOOGLx,1414889025557658614,2,0,attacker)` flow; it violated the value/accounting invariant below.
- **Severity**: `critical`
- **Confidence**: `medium`
- **Violated invariant**: Every borrow must be bounded by the borrower's current collateral value and health after prior borrows and collateral-equivalent token movements in the same transaction.

The Backed/Aave-style pool proxy at 0x3eeeb3cd20f844a578807fc457388ceb9a67faa6 accepted repeated borrow calls after a USDC supply while the attacker recycled borrowed wGOOGLx through another attacker contract. The transaction minted large variable-debt balances and transferred wrapped assets/USDC to the attacker, indicating the borrow path accepted an invali...

Mechanism:

- The attacker reached the victim through the `borrow(wGOOGLx,1414889025557658614,2,0,attacker)` flow during the exploit.
- The Backed/Aave-style pool proxy at 0x3eeeb3cd20f844a578807fc457388ceb9a67faa6 accepted repeated borrow calls after a USDC supply while the attacker recycled borrowed wGOOGLx through another attacker contract.
- The accounting update violated the invariant: Every borrow must be bounded by the borrower's current collateral value and health after prior borrows and collateral-equivalent token movements in the same transaction.

Key evidence:

- PoC verification gate passed for status, execution, economic reproduction, forge build, and forge test.
- Lists realized losses of wSPYx, wQQQx, wNVDAx, wMSTRx, USDC, and wTSLAx.
- Shows protocol/storage holder losses and matching attacker/helper gains, including debt-token positive deltas.

## Affected Contracts

| Address | Name | Role |
|---|---|---|
| `0x3eeeb3cd20f844a578807fc457388ceb9a67faa6` | `InitializableImmutableAdminUpgradeabilityProxy` | `primary vulnerable pool proxy` |
| `0x41d25b8918d3dc4de807d56fd43a82854036714b` | `variableDebtwGOOGLx` | `debt-token entitlement/effect contract` |
| `0x0ec96784aa6f47e456e0ce4eb2a8b00f1a6c9b74` | `ewGOOGLx` | `wrapped/debt-token effect contract in repeated borrow path` |

## Limitations

- missing_pool_implementation_source: victim_sources contains only the proxy source for 0x3eeeb3cd20f844a578807fc457388ceb9a67faa6, while the implementation 0xf7ba2c2b2e3b8c3c327b632e6bdff77840f06b34 is absent.
- source_or_pseudocode_branch_gap: the exact borrow validation/account-data/oracle/health-factor branch is not present in supplied source or pseudocode.
