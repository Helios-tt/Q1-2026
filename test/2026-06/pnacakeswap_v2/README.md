# pnacakeswap_v2 Incident Report

## Summary

- **Protocol**: pnacakeswap_v2
- **Chain**: bsc (chain_id=56)
- **Tx hash**: [`0x8dabb60a94e5124462e5f494a25c14bcd52f6f4d1f7c665a249496f4c6c24764`](https://bscscan.com/tx/0x8dabb60a94e5124462e5f494a25c14bcd52f6f4d1f7c665a249496f4c6c24764)
- **Block**: 105326393
- **Economic reproduction**: exact — PoC reproduces 99–101% of incident net loss.
- **Elapsed analysis time**: 611.02s (611024 ms)

## Impact

- **Estimated loss**: unknown
- **Main affected assets**: LABUBU, OLPC
- **Attacker gain reproduced**: $1114815.78 (USD ratio: 1.000x)

## Reproduction

- **PoC status**: `verified`
- **Forge test**: `pass`
- **Proof kind**: `economic_proof`

## Root Cause

- **Finding**: OLPC pair-out transfer branch lets skim trigger amplified pair-balance burns
- **In short**: The vulnerable path is the `OLPCToken.transfer -> PancakePair.skim -> PancakePair.sync` flow; it violated the value/accounting invariant below.
- **Severity**: `critical`
- **Confidence**: `high`
- **Violated invariant**: A token transfer initiated by an AMM pair must not debit the pair by more than the actual transfer amount, and external skim recipients must not be able to trigger amplified pair-balance destruction.

OLPCToken._update treats any transfer from its Pancake swap pair to a non-exempt address as a buy and debits value * decimalsValue from the pair to 0xdead, then sets the actual transfer value to zero. Because PancakePair.skim transfers only the balance-reserve excess, the attacker can create a tiny excess and make OLPC destroy a massively amplified amount fr...

Mechanism:

- The attacker reached the victim through the `OLPCToken.transfer -> PancakePair.skim -> PancakePair.sync` flow during the exploit.
- OLPCToken._update treats any transfer from its Pancake swap pair to a non-exempt address as a buy and debits value * decimalsValue from the pair to 0xdead, then sets the actual transfer value to zero.
- The accounting update violated the invariant: A token transfer initiated by an AMM pair must not debit the pair by more than the actual transfer amount, and external skim recipients must not be able to trigger amplified pair-balance destruction.

Key evidence:

- PoC execution, economic proof, forge build, and forge test all passed.
- The OLPC/LABUBU pair lost OLPC and LABUBU while the attacker gained 1115903663412131721557252 raw USDT.
- The PoC primes the OLPC pair, repeatedly transfers small OLPC amounts, calls skim and sync, then swaps OLPC for USDT.

## Affected Contracts

| Address | Name | Role |
|---|---|---|
| `0x58815cdf9955121a6274680ab396a36fc9e00000` | `OLPCToken` | `primary vulnerable contract` |
| `0xedb7dcb4cdfec957f8df5cbf5e94229a6cc9f365` | `PancakePair` | `impacted OLPC/LABUBU AMM pair` |

## Limitations

_No material limitations were recorded in the final RCA output._
