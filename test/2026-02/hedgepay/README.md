# HedgePay Incident Report

## Summary

- **Protocol**: HedgePay
- **Chain**: bsc (chain_id=56)
- **Tx hash**: [`0x5f2ea6cb43d14986188fa2f474d9e22502fa95cc76cab72cd6ba1ba146ed137f`](https://bscscan.com/tx/0x5f2ea6cb43d14986188fa2f474d9e22502fa95cc76cab72cd6ba1ba146ed137f)
- **Block**: 83268463
- **Economic reproduction**: exact — PoC reproduces 99–101% of incident net loss.
- **Elapsed analysis time**: 724.57s (724574 ms)
- **Detected at**: 2026-02-25T00:00:00Z

## Impact

- **Estimated loss**: 15700
- **Funds valued at**: 2026-02-25T10:50:42Z (price as of block N-1, pre-hack)
- **Main affected assets**: HPAY
- **Attacker gain reproduced**: $15682.22 (USD ratio: 1.000x)
- **USD incomplete**: 1 unpriced leg(s); estimated loss is a lower bound

## Reproduction

- **PoC status**: `verified`
- **Forge test**: `pass`
- **Proof kind**: `economic_proof`

## Root Cause

- **Finding**: Repeatable forceExit payout drains HPAY staking proxy balance
- **In short**: The vulnerable path is the `forceExit()` flow; it violated the value/accounting invariant below.
- **Severity**: `high`
- **Confidence**: `medium`
- **Violated invariant**: A staked balance or exit entitlement must be paid out at most once and must be cleared or decremented before or during the HPAY transfer.

The staking proxy 0x6e30c17d2554dca5a1ac178939764c6bf61ab95a delegates to implementation 0xbe189fe9f84ca531cd979630e1f14757b88dd80d. After one stake(uint256) call credits or records 1173986082679038090893617 raw HPAY, repeated forceExit() calls in the same callback each transfer that same HPAY amount from the proxy to the attacker without trace-visible consu...

Mechanism:

- The attacker reached the victim through the `forceExit()` flow during the exploit.
- The staking proxy 0x6e30c17d2554dca5a1ac178939764c6bf61ab95a delegates to implementation 0xbe189fe9f84ca531cd979630e1f14757b88dd80d.
- The accounting update violated the invariant: A staked balance or exit entitlement must be paid out at most once and must be cleared or decremented before or during the HPAY transfer.

Key evidence:

- PoC status, build, test, and economic reproduction all pass.
- Trace flow enters Pancake callback, then calls HPAY/proxy frames before the final attacker BNB gain.
- PancakePair.swap performs post-callback balance checks and K invariant enforcement, making the pair a settlement frame rather than the root cause.

## Affected Contracts

| Address | Name | Role |
|---|---|---|
| `0x6e30c17d2554dca5a1ac178939764c6bf61ab95a` | `TransparentUpgradeableProxy` | `primary vulnerable staking proxy` |
| `0xbe189fe9f84ca531cd979630e1f14757b88dd80d` | `unknown` | `staking implementation containing stake/forceExit logic` |

## Limitations

- source_branch_gap: no verified source for implementation 0xbe189fe9f84ca531cd979630e1f14757b88dd80d exists under [internal artifact], so the exact vulnerable line and storage layout cannot be identified.
- the trace proves repeated payout behavior but not the implementation-level reason the entitlement is not consumed.
