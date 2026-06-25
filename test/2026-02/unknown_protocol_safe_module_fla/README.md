# Unknown Protocol (Safe module flashloan callback) Incident Report

## Summary

- **Protocol**: Unknown Protocol (Safe module flashloan callback)
- **Chain**: bsc (chain_id=56)
- **Tx hash**: [`0x380cd298a607d4422edc640b7f5a907ec0792841ee5fc963d265b1189397c905`](https://bscscan.com/tx/0x380cd298a607d4422edc640b7f5a907ec0792841ee5fc963d265b1189397c905)
- **Block**: 80395411
- **Economic reproduction**: exact — PoC reproduces 99–101% of incident net loss.
- **Elapsed analysis time**: 769.46s (769457 ms)
- **Detected at**: 2026-02-08T00:00:00Z

## Impact

- **Estimated loss**: 63000
- **Funds valued at**: 2026-02-10T11:39:22Z (price as of block N-1, pre-hack)
- **Main affected assets**: AFX, AHT
- **Attacker gain reproduced**: $10691.59 (USD ratio: 1.000x)
- **USD incomplete**: 2 unpriced leg(s); estimated loss is a lower bound

## Reproduction

- **PoC status**: `verified`
- **Forge test**: `pass`
- **Proof kind**: `economic_proof`

## Root Cause

- **Finding**: Public add-liquidity path allowed attacker-driven AFX/AHT LP entitlement from live pair balances
- **In short**: The attacker reached 0x560d3973ee82a318d381c49fcbf3ce9d6CF1250B.addLiquidityUsdt(uint256), which invoked PancakeRouter addLiquidity for AFX/AHT and led to a large Cake-LP mint.
- **Severity**: `high`
- **Confidence**: `medium`
- **Violated invariant**: LP entitlement and pair minting must be bounded by the caller's verified proportional deposit, not by mutable live pair balances or protocol-held assets reachable through an unverified external entrypoint.

The attacker reached 0x560d3973ee82a318d381c49fcbf3ce9d6CF1250B.addLiquidityUsdt(uint256), which invoked PancakeRouter addLiquidity for AFX/AHT and led to a large Cake-LP mint. In the source-backed AHT leg, transferFrom into the main pair treated the router transfer as add-liquidity and computed user LP entitlement from the pair's live AFX balance and reserv...

Mechanism:

- The exploit entered through `0x98552476 attacker entry; callback 0x84800812; addLiquidityUsdt(uint256) on 0x560d3973ee82a318d381c49fcbf3ce9d6cf1250b` before reaching the vulnerable accounting path.
- The attacker reached 0x560d3973ee82a318d381c49fcbf3ce9d6CF1250B.addLiquidityUsdt(uint256), which invoked PancakeRouter addLiquidity for AFX/AHT and led to a large Cake-LP mint.
- The accounting update violated the invariant: LP entitlement and pair minting must be bounded by the caller's verified proportional deposit, not by mutable live pair balances or protocol-held assets reachable through an unverified external entrypoint.

Key evidence:

- PoC replay, build, test, and economic reproduction all pass.
- PoC executes flash-swap callback, approves tokens, swaps AFX/AHT, calls addLiquidityUsdt(100), and routes final AFX to USDT.
- Closed-world pseudocode confirms the callback sequence and addLiquidityUsdt call.

## Affected Contracts

| Address | Name | Role |
|---|---|---|
| `0x560d3973ee82a318d381c49fcbf3ce9d6cf1250b` | `unknown addLiquidityUsdt contract` | `unsourced entrypoint and router liquidity caller` |
| `0xcd1ec887b081cfba30c8003e8ad1b67f92236c7b` | `AHT` | `source-backed token with add-liquidity accounting branch` |
| `0x63e97b4f292b6cd059fc5f7621291c7ad5b94ce0` | `PancakePair` | `LP token/pair that minted the inflated entitlement` |

## Limitations

- source_gap: verified source for 0x560d3973ee82a318d381c49fcbf3ce9d6CF1250B.addLiquidityUsdt(uint256) is not present under [internal artifact], so the exact authorization/amount-validation branch cannot be pinned.
- the possible competing validation mechanism inside the unsourced addLiquidityUsdt contract could not be inspected.
