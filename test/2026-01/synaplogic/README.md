# SynapLogic Incident Report

## Summary

- **Protocol**: SynapLogic
- **Chain**: base (chain_id=8453)
- **Tx hash**: [`0xc54c00046364b6e889db18c73beee9b81df6b5ca822b6d262b3d30cdf376c4b1`](https://basescan.org/tx/0xc54c00046364b6e889db18c73beee9b81df6b5ca822b6d262b3d30cdf376c4b1)
- **Block**: 41038634
- **Economic reproduction**: exact — PoC reproduces 99–101% of incident net loss.
- **Elapsed analysis time**: 846.61s (846607 ms)
- **Detected at**: 2026-01-15T00:00:00Z

## Impact

- **Estimated loss**: $88183.77
- **Funds valued at**: 2026-01-19T23:50:13Z (price as of block N-1, pre-hack)
- **Main affected assets**: ETH
- **Attacker gain reproduced**: $88161.71 (USD ratio: 1.000x)

## Reproduction

- **PoC status**: `verified`
- **Forge test**: `pass`
- **Proof kind**: `economic_proof`

## Root Cause

- **Finding**: Relayer-gated SYP credit branch allowed repeated unbounded attacker balance credits through a swap proxy loop
- **In short**: The vulnerable path is the `mint(uint256,address,uint256,uint256,bool)` flow; it violated the value/accounting invariant below.
- **Severity**: `critical`
- **Confidence**: `medium`
- **Violated invariant**: Privileged settlement must not credit user token balances unless the credited amount is bounded by validated consideration and reflected in supply/reserve accounting.

The source-backed branch is SynapLogicErc20.mint(uint256,address,uint256,uint256,bool), selector 0x1402dcf2, with _ac == 3 and _set_mode == 2. That branch only checks relayer111O[msg.sender] before adding arbitrary _am to _exchange[_u], so the 0x39f36e..

Mechanism:

- The attacker reached the victim through the `mint(uint256,address,uint256,uint256,bool)` flow during the exploit.
- The source-backed branch is SynapLogicErc20.mint(uint256,address,uint256,uint256,bool), selector 0x1402dcf2, with _ac == 3 and _set_mode == 2.
- The accounting update violated the invariant: Privileged settlement must not credit user token balances unless the credited amount is bounded by validated consideration and reflected in supply/reserve accounting.

Key evidence:

- PoC, forge build, forge test, and economic proof all passed.
- Attack flow places the exploit inside a Uniswap flash callback and records ETH loss from 0x39f36e...1a32.
- SYP mint branch checks relayer111O[msg.sender] and credits _exchange[_u] by arbitrary _am for _ac == 3 and _set_mode == 2.

## Affected Contracts

| Address | Name | Role |
|---|---|---|
| `0x2bdd3602fc526aa5cc677cd708375dd2f7c4256f` | `SynapLogicErc20` | `primary source-backed vulnerable token accounting branch` |
| `0x39f36e2e58f36f7e5c17784847fd07da1fee1a32` | `unknown proxy` | `source-gapped swap proxy that triggered repeated SYP credits and lost ETH` |

## Limitations

- verified source for proxy implementation 0xc859ac8429fb4a5e24f24a7bed3fe3a8db4fb371 is absent, so the exact parent swap formula/branch that computed repeated SYP amounts and ETH payouts could not be audited.
- source_gap: artifacts show 0x39f36e... successfully called the SYP relayer-gated mint branch, but do not prove when or why that address obtained relayer status.
