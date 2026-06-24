# Royalties Incident Report

## Summary

- **Protocol**: Royalties
- **Chain**: polygon (chain_id=137)
- **Tx hash**: [`0x7a92106f145045b7a2bdce60a22109739f9b0cd0185bf16ff83fd1fac98cb42e`](https://polygonscan.com/tx/0x7a92106f145045b7a2bdce60a22109739f9b0cd0185bf16ff83fd1fac98cb42e)
- **Block**: 89018051
- **Economic reproduction**: exact — PoC reproduces 99–101% of incident net loss.
- **Elapsed analysis time**: 1043.39s (1043394 ms)
- **Detected at**: 2026-06-24T01:41:43+00:00
- **Original alert**: https://x.com/TenArmorAlert/status/2069596801725002121

## Impact

- **Estimated loss**: $261092.07
- **Funds valued at**: 2026-06-23T16:27:50Z (price as of block N-1, pre-hack)
- **Main affected assets**: USDC
- **Attacker gain reproduced**: $261084.14 (USD ratio: 1.000x)

## Reproduction

- **PoC status**: `verified`
- **Forge test**: `pass`
- **Proof kind**: `economic_proof`

## Root Cause

- **Finding**: Batch LDA transfer inflates royalty UCR entitlement before claim
- **In short**: The vulnerable path is the `Royal1155LDA.safeBatchTransferFrom same-tier batch` flow; it violated the value/accounting invariant below.
- **Severity**: `critical`
- **Confidence**: `high`
- **Violated invariant**: A royalty UCR settlement for a transfer must use each account's balance from before the entire transfer batch for the historical TCR interval; intra-batch balance changes must not earn prior deposits.

Royal1155LDA._beforeTokenTransfer calls Royalties.beforeLdaTransfer once per LDA id and updates tier balances inside the same per-id loop. For a same-tier batch, later hook calls see the recipient balance already increased by earlier ids in the same batch, violating Royalties._settleUcr's assumption that tierBalanceOf represents the old balance for historica...

Mechanism:

- The attacker reached the victim through the `Royal1155LDA.safeBatchTransferFrom same-tier batch` flow during the exploit.
- Royal1155LDA._beforeTokenTransfer calls Royalties.beforeLdaTransfer once per LDA id and updates tier balances inside the same per-id loop.
- The accounting update violated the invariant: A royalty UCR settlement for a transfer must use each account's balance from before the entire transfer batch for the historical TCR interval; intra-batch balance changes must not earn prior deposits.

Key evidence:

- PoC build, test, and economic reproduction all passed.
- PoC executes flash swap, LDA batch transfer, royalty deposit to tier 42, and child claim to attacker.
- Trace connects the batch transfer, repeated royalty hook settlement, later deposit, and final claim/USDC payout.

## Affected Contracts

| Address | Name | Role |
|---|---|---|
| `0xfe16ee78828672e86cf8e42d8a5119ab79877ec7` | `Royalties via TransparentUpgradeableProxy` | `primary vulnerable royalty accounting contract` |
| `0x7c885c4bfd179fb59f1056fbea319d579a278075` | `Royal1155LDA via TransparentUpgradeableProxy` | `batch-transfer hook and tier-balance source` |

## Limitations

_No material limitations were recorded in the final RCA output._
