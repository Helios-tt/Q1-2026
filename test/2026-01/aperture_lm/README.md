# Aperture LM Incident Report

## Summary

- **Protocol**: Aperture LM
- **Chain**: ethereum (chain_id=1)
- **Tx hash**: [`0x8f28a7f604f1b3890c2275eec54cd7deb40935183a856074c0a06e4b5f72f25a`](https://etherscan.io/tx/0x8f28a7f604f1b3890c2275eec54cd7deb40935183a856074c0a06e4b5f72f25a)
- **Block**: 24313234
- **Economic reproduction**: exact — PoC reproduces 99–101% of incident net loss.
- **Elapsed analysis time**: 516.92s (516924 ms)
- **Detected at**: 2026-01-25T00:00:00Z

## Impact

- **Estimated loss**: $3240710.71
- **Funds valued at**: 2026-01-25T17:10:23Z (price as of block N-1, pre-hack)
- **Main affected assets**: WBTC
- **Attacker gain reproduced**: $3240710.71 (USD ratio: 1.000x)

## Reproduction

- **PoC status**: `verified`
- **Forge test**: `pass`
- **Proof kind**: `economic_proof`

## Root Cause

- **Finding**: Opaque executor consumed a third-party WBTC allowance through attacker-supplied transferFrom calldata
- **In short**: The direct loss occurred when contract 0xd83d960debec397fb149b51f8f37dd3b5cfa8913 selector 0x67b34120 executed attacker-supplied calldata that called WBTC transferFrom from 0x5240b03be5bc101a0082074666dd89ad883e1f9d to t...
- **Severity**: `critical`
- **Confidence**: `medium`
- **Violated invariant**: An executor must not let an arbitrary caller consume a third party's ERC20 allowance unless the token, from address, recipient, and amount are authorized by that third party's intent.

The direct loss occurred when contract 0xd83d960debec397fb149b51f8f37dd3b5cfa8913 selector 0x67b34120 executed attacker-supplied calldata that called WBTC transferFrom from 0x5240b03be5bc101a0082074666dd89ad883e1f9d to the attacker for 3691897652 raw WBTC. WBTC accepted the call because 0xd83d...8913 had sufficient allowance and the victim holder had suffici...

Mechanism:

- The exploit entered through `0x67b34120` before reaching the vulnerable accounting path.
- The direct loss occurred when contract 0xd83d960debec397fb149b51f8f37dd3b5cfa8913 selector 0x67b34120 executed attacker-supplied calldata that called WBTC transferFrom from 0x5240b03be5bc101a0082074666dd89ad883e1f9d to t...
- The accounting update violated the invariant: An executor must not let an arbitrary caller consume a third party's ERC20 allowance unless the token, from address, recipient, and amount are authorized by that third party's intent.

Key evidence:

- PoC gate passed with economic proof and reports exact WBTC loss of 36.91897652 from 0x5240...1f9d.
- PoC calls 0xd83d...8913 selector 0x67b34120 with calldata containing embedded WBTC transferFrom from the victim holder to the attacker.
- Frame 17 is WBTC transferFrom called by 0xd83d...8913, with direct WBTC asset relevance and transfer log to attacker.

## Affected Contracts

| Address | Name | Role |
|---|---|---|
| `0xd83d960debec397fb149b51f8f37dd3b5cfa8913` | `unknown` | `primary vulnerable contract` |
| `0x2260fac5e5542a773aa44fbcfedf7c193bc2c599` | `WBTC` | `asset token / downstream allowance primitive` |

## Limitations

- source and decoded pseudocode for 0xd83d960debec397fb149b51f8f37dd3b5cfa8913 selector 0x67b34120 are absent, so the exact vulnerable branch and internal authorization check cannot be pinpointed.
- selector_decoding_gap: selector 0x67b34120 and the Uniswap-related selectors 0x88316456/0x3c8a7d8d/0xd3487997 are not labeled in selector_db.json.
