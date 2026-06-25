# XPlayer Incident Report

## Summary

- **Protocol**: XPlayer
- **Chain**: bsc (chain_id=56)
- **Tx hash**: [`0x9779341b2b80ba679c83423c93ecfc2ebcec82f9f94c02624f83d8a647ee2e49`](https://bscscan.com/tx/0x9779341b2b80ba679c83423c93ecfc2ebcec82f9f94c02624f83d8a647ee2e49)
- **Block**: 77915282
- **Economic reproduction**: exact — PoC reproduces 99–101% of incident net loss.
- **Elapsed analysis time**: 839.52s (839519 ms)
- **Detected at**: 2026-01-28T00:00:00Z

## Impact

- **Estimated loss**: $963354.16
- **Funds valued at**: 2026-01-28T13:33:47Z (price as of block N-1, pre-hack)
- **Main affected assets**: USDT, XPL
- **Attacker gain reproduced**: $717924.38 (USD ratio: 1.000x)
- **USD incomplete**: 1 unpriced leg(s); estimated loss is a lower bound

## Reproduction

- **PoC status**: `verified`
- **Forge test**: `pass`
- **Proof kind**: `economic_proof`

## Root Cause

- **Finding**: Externally triggerable XPL pool burn repriced the XPL/USDT AMM and enabled USDT extraction
- **In short**: XPL's DynamicBurnPool(uint256) branch burns arbitrary _amount from address(uniswapV2Pair) and immediately syncs the pair when called by configured privileged addresses.
- **Severity**: `critical`
- **Confidence**: `medium`
- **Violated invariant**: External callers must not be able to trigger arbitrary burns of AMM pair reserves and sync the pair unless the caller and burn amount are strictly authorized and bounded by pool-safety rules.

XPL's DynamicBurnPool(uint256) branch burns arbitrary _amount from address(uniswapV2Pair) and immediately syncs the pair when called by configured privileged addresses. In this transaction, the attacker called the source-gapped controller 0xb413271b84902c95f01015d58326dda59a747854.DynamicBurnPool(string,uint256), which invoked XPL and burned 3078000000000000...

Mechanism:

- The exploit entered through `unknown root selector; controller call DynamicBurnPool(string,uint256) selector 0xd9ccae68` before reaching the vulnerable accounting path.
- XPL's DynamicBurnPool(uint256) branch burns arbitrary _amount from address(uniswapV2Pair) and immediately syncs the pair when called by configured privileged addresses.
- The accounting update violated the invariant: External callers must not be able to trigger arbitrary burns of AMM pair reserves and sync the pair unless the caller and burn amount are strictly authorized and bounded by pool-safety rules.

Key evidence:

- PoC, forge build/test, and economic proof passed; reproduced direct attacker USDT gain.
- The XPL/USDT pair was the primary loss holder, with large USDT and XPL negative deltas.
- Attacker-called controller 0xb413...7854 invoked XPL frame 284, which burned 3078 XPL from the pair to 0xdead and changed XPL balances.

## Affected Contracts

| Address | Name | Role |
|---|---|---|
| `0xc2c4ccde8948c693d0b04f8bad461e35a12f20b8` | `XPL` | `primary vulnerable token contract that burns AMM reserves` |
| `0xb413271b84902c95f01015d58326dda59a747854` | `unknown` | `source-gapped burn controller called by attacker` |
| `0x9b0ff36de2fc477cda8e4468e0067322ae18ce70` | `PancakePair` | `impacted XPL/USDT AMM pair` |

## Limitations

- source for controller 0xb413271b84902c95f01015d58326dda59a747854 [internal path redacted] implementation 0x15b1879ff6acc145300f7a204809473a9e158917 is absent under [internal artifact], so the exact controller authorization or amount-bound branch is unresolved.
- The RCA does not assign semantic meaning to controller storage slots written in frame 283 because source/layout evidence for the controller is missing.
