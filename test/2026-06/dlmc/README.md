# DLMC Incident Report

## Summary

- **Protocol**: DLMC
- **Chain**: bsc (chain_id=56)
- **Tx hash**: [`0x151025d3f0a782340a74d30ef33a5fad044b838e74437a803f0652e70c231306`](https://bscscan.com/tx/0x151025d3f0a782340a74d30ef33a5fad044b838e74437a803f0652e70c231306)
- **Block**: 106091607
- **Economic reproduction**: unpriced — raw PoC proof passed, but USD comparison is incomplete.
- **Elapsed analysis time**: 623.55s (623552 ms)
- **Detected at**: 2026-06-25T01:35:10+00:00
- **Original alert**: https://x.com/TenArmorAlert/status/2069957542109958498

## Impact

- **Estimated loss**: $222600.00
- **Funds valued at**: 2026-06-24T11:15:10Z (price as of block N-1, pre-hack)
- **Main affected assets**: unknown
- **Attacker gain reproduced**: unknown

## Reproduction

- **PoC status**: `verified`
- **Forge test**: `pass`
- **Proof kind**: `economic_proof`

## Root Cause

- **Finding**: DLMC spot-balance price update lets flash-borrowed USDT inflate sell payouts
- **In short**: The vulnerable path is the `buy(uint256)` flow; it violated the value/accounting invariant below.
- **Severity**: `critical`
- **Confidence**: `high`
- **Violated invariant**: DLMC livePrice and sell payouts must be based on durable, manipulation-resistant backing, not a same-transaction attacker-controllable USDT balance.

DLMCToken.buy(uint256) accepts caller-supplied USDT and then calls _updatePrice(), whose branch computes livePrice from quoteToken.balanceOf(address(this)) minus only daoUsdtBalance. Flash-borrowed USDT sent through buy() is therefore counted as durable reserve backing, and DLMCToken.sell(uint256) uses the inflated livePrice to calculate sellValueUsdt18 and ...

Mechanism:

- The attacker reached the victim through the `buy(uint256)` flow during the exploit.
- DLMCToken.buy(uint256) accepts caller-supplied USDT and then calls _updatePrice(), whose branch computes livePrice from quoteToken.balanceOf(address(this)) minus only daoUsdtBalance.
- The accounting update violated the invariant: DLMC livePrice and sell payouts must be based on durable, manipulation-resistant backing, not a same-transaction attacker-controllable USDT balance.

Key evidence:

- PoC passed with forge build/test pass and economic proof status.
- PoC performs Pancake flash swap, two DLMC buy calls using 420000e18 and 1000000e18 USDT amounts, reads livePrice/balances, sells DLMC, repays the pair, and routes USDT profit.
- Frontier places the flash swap before two DLMC buy frames and the later DLMC sell frame; USDT approval/transfer frames are child or sibling mechanics.

## Affected Contracts

| Address | Name | Role |
|---|---|---|
| `0xf2ca2a3572b26ae7c479dc7ae36d922113b1bdf2` | `DLMCToken` | `primary vulnerable contract` |

## Limitations

- The closed-world artifacts do not provide decoded event data for every DLMC bonus transfer, so exact per-bonus token attribution is inferred from source path plus frame/log correlation rather than full event decoding.
- PoC result profit_token fields are null even though attack_flow and RPC/fund-flow artifacts identify USDT gains; the report uses RPC/fund-flow deltas for impact.
