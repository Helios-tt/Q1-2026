# PearlDriver Incident Report

## Summary

- **Protocol**: PearlDriver
- **Chain**: bsc (chain_id=56)
- **Tx hash**: [`0xb4a29409cbd018956746f90d285f427175070c735c36ff3bc2f3c4a4bbaae705`](https://bscscan.com/tx/0xb4a29409cbd018956746f90d285f427175070c735c36ff3bc2f3c4a4bbaae705)
- **Block**: 82115373
- **Economic reproduction**: unpriced — raw PoC proof passed, but USD comparison is incomplete.
- **Elapsed analysis time**: 868.67s (868670 ms)
- **Detected at**: 2026-02-19T00:00:00Z

## Impact

- **Estimated loss**: 40300
- **Funds valued at**: 2026-02-19T10:41:06Z (price as of block N-1, pre-hack)
- **Main affected assets**: unknown
- **Attacker gain reproduced**: unknown

## Reproduction

- **PoC status**: `verified`
- **Forge test**: `pass`
- **Proof kind**: `economic_proof`

## Root Cause

- **Finding**: Unbounded NLAMM buy amount caused wrapped payment/mint arithmetic and giant resource-token entitlement
- **In short**: The vulnerable path is the `PearlMarket.buy(resourceToken, 0, hugeAmount)` flow; it violated the value/accounting invariant below.
- **Severity**: `critical`
- **Confidence**: `medium`
- **Violated invariant**: A buy must charge a non-overflowing amount * currentPrice and mint no more than the paid, bounded amount; overflow or configured purchase/supply bound violations must revert before minting.

The root cause is attacker-controlled state reaching protected accounting updates.

Mechanism:

- The attacker reached the victim through the `PearlMarket.buy(resourceToken, 0, hugeAmount)` flow during the exploit.
- That path trusted attacker-controlled state while performing protected accounting updates.
- The accounting update violated the invariant: A buy must charge a non-overflowing amount * currentPrice and mint no more than the paid, bounded amount; overflow or configured purchase/supply bound violations must revert before minting.

Key evidence:

- PoC, build, test, and economic reproduction all passed.
- PoC repeatedly calls PearlMarket.buy with huge resource-token amounts, then approves and swaps resource tokens to USDT.
- Market buy frame 16 invokes token mint frame 19; frame 19 writes totalSupply and attacker balance slots and emits a mint Transfer log.

## Affected Contracts

| Address | Name | Role |
|---|---|---|
| `0x5340a7278848ee51d35c30693d6fbff06d1a0d73` | `PearlMarket / NLAMM proxy` | `primary vulnerable contract` |
| `0x26c97005af332f0d8f6ca30451195e14fbdd8d41` | `IRON ORE CraftToken proxy` | `minted entitlement token` |
| `0x40037b7503ee21ffa7747dfddedcb89805c9273e` | `COAL CraftToken proxy` | `minted entitlement token` |

## Limitations

- live_market_implementation_source_gap: RPC q36 identifies 0x1903d672c821bdf7cabfde1fb4dc9ebff0494563 as the live market implementation, but source for that address is not present under [internal artifact].
- the fetched NLAMM source under 0x851d38c1ec18669fb94ddb21bbc389c3dc9b0063 matches selector and branch shape but cannot prove exact live line numbers for 0x1903d672c821bdf7cabfde1fb4dc9ebff0494563.
