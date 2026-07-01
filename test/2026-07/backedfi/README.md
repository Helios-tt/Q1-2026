# BackedFi Incident Report

## Summary

- **Protocol**: BackedFi
- **Chain**: ethereum (chain_id=1)
- **Tx hash**: [`0xe2320086b2815d21b0927839bd0e306466c29a68d38d5361e99dd21ec5472612`](https://etherscan.io/tx/0xe2320086b2815d21b0927839bd0e306466c29a68d38d5361e99dd21ec5472612)
- **Block**: 25434062
- **Economic reproduction**: exact — PoC reproduces 99–101% of incident net loss.
- **Elapsed analysis time**: 1064.75s (1064751 ms)
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

- **Finding**: Pool borrow validation accepted ERC4626 wrapper collateral whose spot share value was manipulable in the same transaction
- **In short**: The vulnerable path is the `borrow wGOOGLx, transfer to helper, helper supplies wGOOGLx collateral` flow; it violated the value/accounting invariant below.
- **Severity**: `critical`
- **Confidence**: `medium`
- **Violated invariant**: Borrow authorization must use collateral values that cannot be inflated within the same transaction by direct ERC4626 underlying-balance manipulation or recursive borrow-supply loops.

The attacker looped borrow and supply operations around wGOOGLx, then manipulated the wrapper's ERC4626 spot exchange rate by changing the wrapper's underlying balance. The Pool at 0x3eeeb3cd20f844a578807fc457388ceb9a67faa6 appears to have accepted that inflated wrapper collateral value during borrow validation and allowed final borrows of USDC and wrapped s...

Mechanism:

- The attacker reached the victim through the `borrow wGOOGLx, transfer to helper, helper supplies wGOOGLx collateral` flow during the exploit.
- The attacker looped borrow and supply operations around wGOOGLx, then manipulated the wrapper's ERC4626 spot exchange rate by changing the wrapper's underlying balance.
- The accounting update violated the invariant: Borrow authorization must use collateral values that cannot be inflated within the same transaction by direct ERC4626 underlying-balance manipulation or recursive borrow-supply loops.

Key evidence:

- The reproduction passed build, test, and economic verification.
- The PoC supplies flash-loaned USDC, loops borrow/supply of wGOOGLx, redeems and transfers underlying into the wrapper, then executes final borrow/drain helper calls.
- The frontier identifies direct loss plus entitlement/accounting anomalies; representative frame 55 is a variable debt mint called from Pool frame 37.

## Affected Contracts

| Address | Name | Role |
|---|---|---|
| `0x3eeeb3cd20f844a578807fc457388ceb9a67faa6` | `Pool proxy / unknown implementation` | `primary vulnerable contract` |
| `0x14f37168ab9eafcd94d5b142a00e6e9b261bad48` | `WrappedBackedTokenImplementation` | `manipulable ERC4626 wrapper valuation source` |
| `0xc84577a366bdc6ace161388dace77ff0a8958b9a` | `VariableDebtToken` | `downstream debt accounting contract` |

## Limitations

- source_branch_gap: Pool implementation source for 0xf7ba2c2b2e3b8c3c327b632e6bdff77840f06b34 is not present under [internal artifact], so the exact vulnerable Pool validation line cannot be cited.
- the exact oracle/health/solvency branch that consumed the manipulated wrapper value is inferred from trace shape and exploit effects, not directly source-inspected.
