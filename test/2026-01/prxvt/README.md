# PRXVT Incident Report

## Summary

- **Protocol**: PRXVT
- **Chain**: base (chain_id=8453)
- **Tx hash**: [`0xf42a8fe556d5e4ab59b0b7675ccbcd1425e7e2a6a8e0c9775fc6cd7c48ff55a1`](https://basescan.org/tx/0xf42a8fe556d5e4ab59b0b7675ccbcd1425e7e2a6a8e0c9775fc6cd7c48ff55a1)
- **Block**: 40230107
- **Economic reproduction**: unpriced — raw PoC proof passed, but USD comparison is incomplete.
- **Elapsed analysis time**: 892.58s (892579 ms)
- **Detected at**: 2026-01-01T00:00:00Z

## Impact

- **Estimated loss**: 
- **Funds valued at**: 2026-01-01T06:39:19Z (price as of block N-1, pre-hack)
- **Main affected assets**: PRXVT
- **Attacker gain reproduced**: unknown
- **USD incomplete**: 1 unpriced leg(s); estimated loss is a lower bound

## Reproduction

- **PoC status**: `verified`
- **Forge test**: `pass`
- **Proof kind**: `economic_proof`

## Root Cause

- **Finding**: Transferable stPRXVT receipts let the same stake claim the same reward interval through many helper addresses
- **In short**: The vulnerable path is the `claimReward()` flow; it violated the value/accounting invariant below.
- **Severity**: `high`
- **Confidence**: `high`
- **Violated invariant**: Each unit of stPRXVT principal may accrue a reward-per-token interval only once across all holders, and reward debt must move or settle when the receipt token moves.

PRXVTStaking computes claimable rewards from the caller's current stPRXVT balance in earned() during updateReward(msg.sender), then claimReward() pays that stored amount. The stPRXVT receipt token remains transferable through inherited ERC20 transfer/_update logic, but transfers do not checkpoint rewards or userRewardPerTokenPaid for sender and recipient.

Mechanism:

- The attacker reached the victim through the `claimReward()` flow during the exploit.
- PRXVTStaking computes claimable rewards from the caller's current stPRXVT balance in earned() during updateReward(msg.sender), then claimReward() pays that stored amount.
- The accounting update violated the invariant: Each unit of stPRXVT principal may accrue a reward-per-token interval only once across all holders, and reward debt must move or settle when the receipt token moves.

Key evidence:

- PoC result reports status=pass, forge_build_status=pass, forge_test_status=pass, and economic_status=pass.
- Attack flow verifies execution/economic pass and shows repeated tx-created child execute calls into PRXVTStaking claimReward frames.
- PRXVTStaking loses 2187637096571285920000 PRXVT while the attacker entry gains 1968873386914157328000 PRXVT.

## Affected Contracts

| Address | Name | Role |
|---|---|---|
| `0xdac30a5e2612206e2756836ed6764ec5817e6fff` | `PRXVTStaking` | `primary vulnerable contract` |

## Limitations

- The incident economic effect is unpriced in attack_flow.md and result.json has null profit_token fields; asset_deltas and RPC observations identify PRXVT balance impact, so this does not affect the causal finding.
