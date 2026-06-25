# Makina Incident Report

## Summary

- **Protocol**: Makina
- **Chain**: ethereum (chain_id=1)
- **Tx hash**: [`0x569733b8016ef9418f0b6bde8c14224d9e759e79301499908ecbcd956a0651f5`](https://etherscan.io/tx/0x569733b8016ef9418f0b6bde8c14224d9e759e79301499908ecbcd956a0651f5)
- **Block**: 24273362
- **Economic reproduction**: exact — PoC reproduces 99–101% of incident net loss.
- **Elapsed analysis time**: 1203.87s (1203867 ms)
- **Detected at**: 2026-01-19T00:00:00Z

## Impact

- **Estimated loss**: $5107775.33
- **Funds valued at**: 2026-01-20T03:40:23Z (price as of block N-1, pre-hack)
- **Main affected assets**: USDC
- **Attacker gain reproduced**: $414.39 (USD ratio: 1.001x)

## Reproduction

- **PoC status**: `verified`
- **Forge test**: `pass`
- **Proof kind**: `economic_proof`

## Root Cause

- **Finding**: Manipulable position accounting accepted transient Curve pool state before AUM update
- **In short**: The vulnerable path is the `Curve pool operations, accountForPosition, updateTotalAum` flow; it violated the value/accounting invariant below.
- **Severity**: `high`
- **Confidence**: `medium`
- **Violated invariant**: Position and AUM accounting must not be updated from same-transaction-manipulable external pool balances or prices without an independent trusted valuation or bounded value-change check.

Makina/Caliber accountForPosition accepts an allowed Weiroll accounting instruction and stores the returned position value after Merkle and affected-token checks, but without a source-visible guard that the amounts and prices are independent of same-transaction Curve pool manipulation. In the verified transaction, the attacker changed DUSD/USDC and MIM/3Crv ...

Mechanism:

- The attacker reached the victim through the `Curve pool operations, accountForPosition, updateTotalAum` flow during the exploit.
- Makina/Caliber accountForPosition accepts an allowed Weiroll accounting instruction and stores the returned position value after Merkle and affected-token checks, but without a source-visible guard that the amounts and p...
- The accounting update violated the invariant: Position and AUM accounting must not be updated from same-transaction-manipulable external pool balances or prices without an independent trusted valuation or bounded value-change check.

Key evidence:

- PoC status, forge build, and forge test passed, so RCA is not blocked by reproduction failure.
- Shows the target transaction, attacker callbacks, verified replay, and direct attacker ETH gain.
- Frames identify direct asset loss, accounting/entitlement anomalies, DUSD/USDC Curve pool operations, and the Caliber accounting proxy candidate.

## Affected Contracts

| Address | Name | Role |
|---|---|---|
| `0xd1a1c248b253f1fc60eacd90777b9a63f8c8c1bc` | `BeaconProxy / Caliber` | `primary vulnerable accounting proxy` |
| `0x6b006870c83b1cd49e766ac9209f8d68763df721` | `BeaconProxy` | `downstream AUM publisher called after accounting update` |
| `0x32e616f4f17d43f9a5cd9be0e294727187064cb3` | `CurveStableSwapNG` | `manipulated external DUSD/USDC pool used in exploit path` |
| `0x5a6a4d54456819380173272a5e8e9b9904bdf41b` | `Vyper_contract` | `MIM/3Crv metapool and downstream LP accounting path` |

## Limitations

- missing_assumption
- The implementation source for 0x6b006870c83b1cd49e766ac9209f8d68763df721.updateTotalAum was not present, so the downstream AUM publication branch could not be pinned.
