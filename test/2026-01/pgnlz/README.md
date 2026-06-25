# PGNLZ Incident Report

## Summary

- **Protocol**: PGNLZ
- **Chain**: bsc (chain_id=56)
- **Tx hash**: [`0xc7270212846136f3d103d1802a30cdaa6f8f280c4bce02240e99806101e08121`](https://bscscan.com/tx/0xc7270212846136f3d103d1802a30cdaa6f8f280c4bce02240e99806101e08121)
- **Block**: 77721027
- **Economic reproduction**: exact — PoC reproduces 99–101% of incident net loss.
- **Elapsed analysis time**: 1084.77s (1084772 ms)
- **Detected at**: 2026-01-27T00:00:00Z

## Impact

- **Estimated loss**: $100769.40
- **Funds valued at**: 2026-01-27T13:16:36Z (price as of block N-1, pre-hack)
- **Main affected assets**: USDT, PGNLZ
- **Attacker gain reproduced**: $100769.40 (USD ratio: 1.000x)
- **USD incomplete**: 1 unpriced leg(s); estimated loss is a lower bound

## Reproduction

- **PoC status**: `verified`
- **Forge test**: `pass`
- **Proof kind**: `economic_proof`

## Root Cause

- **Finding**: PGNLZ sell tax burns and syncs AMM reserves during transfer, letting a small sell drain the PGNLZ-USDT pair
- **In short**: PGNLZ routes transfers to the Pancake pair through `_handleSellTax`.
- **Severity**: `critical`
- **Confidence**: `high`
- **Violated invariant**: An ERC20 transfer into an AMM pair must not alter and sync the pair's reserves before the router computes swap input and output for that transfer.

PGNLZ routes transfers to the Pancake pair through `_handleSellTax`. In the pre-trading branch, `_handleSellTax` calls `_executeBurnFromLP` before completing the seller's transfer, and `_executeBurnFromLP` burns PGNLZ directly from the pair and calls `sync()`.

Mechanism:

- The exploit entered through `PGNLZ.transferFrom(address,address,uint256) via PancakeRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens` before reaching the vulnerable accounting path.
- PGNLZ routes transfers to the Pancake pair through `_handleSellTax`.
- The accounting update violated the invariant: An ERC20 transfer into an AMM pair must not alter and sync the pair's reserves before the router computes swap input and output for that transfer.

Key evidence:

- PoC build, test, and economic reproduction passed.
- Identifies the transaction, attacker, pass gate, and the Pancake pair USDT/PGNLZ loss.
- Verified callback borrows temporary capital, withdraws a small PGNLZ amount, buys PGNLZ, sells PGNLZ through PancakeRouter, repays, and transfers USDT profit.

## Affected Contracts

| Address | Name | Role |
|---|---|---|
| `0x6b923cf1d592e6aa07ea7249d817a843c30ac69e` | `PGNLZ` | `primary vulnerable contract` |
| `0x8cd8e57bcd00857bebe891a2349f32738cb7e658` | `PancakePair` | `drained PGNLZ-USDT liquidity pair` |

## Limitations

- Source for auxiliary contract 0xf909e413bc5c505dc89244345ff95ff3c811000d was not present; it only supplies the small PGNLZ input in the selected exploit path.
- PGNLZ loss leg was unpriced in the PoC economics, though the USDT profit/loss leg was exact and priced.
