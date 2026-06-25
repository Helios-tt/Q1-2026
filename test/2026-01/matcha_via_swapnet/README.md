# Matcha (via SwapNet) Incident Report

## Summary

- **Protocol**: Matcha (via SwapNet)
- **Chain**: base (chain_id=8453)
- **Tx hash**: [`0xc15df1d131e98d24aa0f107a67e33e66cf2ea27903338cc437a3665b6404dd57`](https://basescan.org/tx/0xc15df1d131e98d24aa0f107a67e33e66cf2ea27903338cc437a3665b6404dd57)
- **Block**: 41289841
- **Economic reproduction**: exact — PoC reproduces 99–101% of incident net loss.
- **Elapsed analysis time**: 537.09s (537092 ms)
- **Detected at**: 2026-01-25T00:00:00Z

## Impact

- **Estimated loss**: $13337446.14
- **Funds valued at**: 2026-01-25T19:23:47Z (price as of block N-1, pre-hack)
- **Main affected assets**: USDC
- **Attacker gain reproduced**: $13337446.14 (USD ratio: 1.000x)

## Reproduction

- **PoC status**: `verified`
- **Forge test**: `pass`
- **Proof kind**: `economic_proof`

## Root Cause

- **Finding**: Executor accepted attacker-supplied calldata that spent a third party's USDC allowance
- **In short**: The vulnerable path is the `0x87395540 on 0x616000e384ef1c2b52f5f3a88d57a3b64f23757e` flow; it violated the value/accounting invariant below.
- **Severity**: `critical`
- **Confidence**: `medium`
- **Violated invariant**: An executor with user token allowance must only spend that allowance for calls authorized by the token owner or a valid order owner, and must not let an arbitrary caller choose a third-party from address, recipient, token, and amount.

The trace-backed causal frame is executor 0x616000e384ef1c2b52f5f3a88d57a3b64f23757e selector 0x87395540, which accepted attacker-supplied calldata embedding USDC.transferFrom(0xba15...78ed, attacker, 13342433169249). USDC then honored the pre-existing allowance from 0xba15...78ed to the executor and transferred the full amount to the attacker.

Mechanism:

- The attacker reached the victim through the `0x87395540 on 0x616000e384ef1c2b52f5f3a88d57a3b64f23757e` flow during the exploit.
- The trace-backed causal frame is executor 0x616000e384ef1c2b52f5f3a88d57a3b64f23757e selector 0x87395540, which accepted attacker-supplied calldata embedding USDC.transferFrom(0xba15...78ed, attacker, 13342433169249).
- The accounting update violated the invariant: An executor with user token allowance must only spend that allowance for calls authorized by the token owner or a valid order owner, and must not let an arbitrary caller choose a third-party from address, recipient, token, and amount.

Key evidence:

- PoC status, forge build/test, and economic reproduction all passed with exact USDC profit.
- The verified flow invokes attacker entry, calls 0x6160...757e, and reproduces the USDC drain.
- Frame 7 executes selector 0x87395540 on the executor and child frames 10/11 perform USDC transferFrom.

## Affected Contracts

| Address | Name | Role |
|---|---|---|
| `0x616000e384ef1c2b52f5f3a88d57a3b64f23757e` | `unknown executor` | `primary vulnerable contract` |
| `0x833589fcd6edb6e08f4c7c32d4f71b54bda02913` | `FiatTokenProxy / USDC` | `downstream asset token` |

## Limitations

- missing_executor_source_branch: source for 0x616000e384ef1c2b52f5f3a88d57a3b64f23757e [internal path redacted] 0xdc3914ca7b18a2bf41b43a263258b71e32296d7d is not present under [internal artifact], so the exact branch/line for selector 0x87395540 cannot be named.
- selector_semantics_gap: selector 0x87395540 is unresolved in [internal artifact].
