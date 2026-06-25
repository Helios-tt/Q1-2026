# PRXVT Incident Report

## Summary

- **Protocol**: PRXVT
- **Chain**: base (chain_id=8453)
- **Tx hash**: [`0xf42a8fe556d5e4ab59b0b7675ccbcd1425e7e2a6a8e0c9775fc6cd7c48ff55a1`](https://basescan.org/tx/0xf42a8fe556d5e4ab59b0b7675ccbcd1425e7e2a6a8e0c9775fc6cd7c48ff55a1)
- **Block**: 40230107
- **Economic reproduction**: unpriced — raw PoC proof passed, but USD comparison is incomplete.
- **Elapsed analysis time**: 863.77s (863771 ms)
- **Detected at**: 2026-06-25T13:07:18Z
- **Original alert**: https://github.com/BackwardLabs/report/tree/main/exports/lumoskit-555581b0312b492da5ea4a161b2ae63b78c96c9b-partial-20260616T111006Z/cases/001_prxvt

## Impact

- **Estimated loss**: unknown
- **Funds valued at**: 2026-01-01T06:39:19Z (price as of block N-1, pre-hack)
- **Main affected assets**: PRXVT
- **Attacker gain reproduced**: unknown
- **USD incomplete**: 1 unpriced leg(s); estimated loss is a lower bound

## Reproduction

- **PoC status**: `verified`
- **Forge test**: `pass`
- **Proof kind**: `economic_proof`

## Root Cause

- **Finding**: Transferable stPRXVT receipt tokens allow historical reward replay across fresh addresses
- **In short**: The vulnerable path is the `claimReward()` flow; it violated the value/accounting invariant below.
- **Severity**: `high`
- **Confidence**: `high`
- **Violated invariant**: A unit of staked principal must not be able to claim the same historical reward-per-token accrual more than once, even if the receipt token is transferred.

PRXVTStaking calculates reward entitlement from the caller's current stPRXVT balance and that caller's per-address reward debt. Because stPRXVT is transferable and PRXVTStaking does not update reward debt in a transfer hook, the same staked principal can be moved to a fresh address with userRewardPerTokenPaid equal to zero and claim historical rewards again.

Mechanism:

- The attacker reached the victim through the `claimReward()` flow during the exploit.
- PRXVTStaking calculates reward entitlement from the caller's current stPRXVT balance and that caller's per-address reward debt.
- The accounting update violated the invariant: A unit of staked principal must not be able to claim the same historical reward-per-token accrual more than once, even if the receipt token is transferred.

Key evidence:

- PoC, forge build, forge test, and economic status are pass.
- Attack flow records verified execution and repeated dynamic helper surfaces, with PRXVT loss from PRXVTStaking.
- Frontier shows direct PRXVT loss/profit, no giant mint, and top ranked repeated claimReward() accounting/impact frames on PRXVTStaking.

## Affected Contracts

| Address | Name | Role |
|---|---|---|
| `0xdac30a5e2612206e2756836ed6764ec5817e6fff` | `PRXVTStaking` | `primary vulnerable contract` |

## Limitations

- USD value is unavailable in the supplied economic artifact, but raw PRXVT loss/profit and source-level root cause are present.
- The artifacts show the exploit transaction and verified PoC, not a full historical accounting of how the initial stPRXVT balance was acquired; this does not affect the selected in-transaction reward replay cause.
