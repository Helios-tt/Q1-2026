# OriginTrail Incident Report

## Summary

- **Protocol**: OriginTrail
- **Chain**: base (chain_id=8453)
- **Tx hash**: [`0x18ccaa7baba166fa45bbd75cc01d58f60f6b6ac2ad1425a6d93295ccff096533`](https://basescan.org/tx/0x18ccaa7baba166fa45bbd75cc01d58f60f6b6ac2ad1425a6d93295ccff096533)
- **Block**: 47682240
- **Economic reproduction**: usd_pricing_unavailable — historical USD pricing was unavailable.
- **Elapsed analysis time**: 1060.03s (1060031 ms)
- **Detected at**: 2026-06-23T08:38:54+00:00
- **Original alert**: https://t.me/c/1794535570/1220

## Impact

- **Estimated loss**: unknown
- **Main affected assets**: unknown
- **Attacker gain reproduced**: unknown

## Reproduction

- **PoC status**: `verified`
- **Forge test**: `pass`
- **Proof kind**: `economic_proof`

## Root Cause

- **Finding**: Hub setup entry mutates OriginTrail module state without source-proven authorization
- **In short**: Hub 0x99aa571fd5e681c2d27ee08a7b7989db02541d13 selector 0x46e46a09 [internal path redacted] fn_46e46a09() executes a setup branch that drives setStatus(bool) and initialize() calls across pre-existing OriginTrail/DKG mod...
- **Severity**: `high`
- **Confidence**: `medium`
- **Violated invariant**: Only authorized governance/deployment control may toggle module status or initialize core module dependency storage.

Hub 0x99aa571fd5e681c2d27ee08a7b7989db02541d13 selector 0x46e46a09 [internal path redacted] fn_46e46a09() executes a setup branch that drives setStatus(bool) and initialize() calls across pre-existing OriginTrail/DKG modules when reached by attacker EOA 0xbb31f31480cf4bcf70d0e1ff0df7f09218f8d2a3. The observed effect is loss-enabling mutation of module status...

Mechanism:

- The exploit entered through `0x46e46a09 / fn_46e46a09()` before reaching the vulnerable accounting path.
- Hub 0x99aa571fd5e681c2d27ee08a7b7989db02541d13 selector 0x46e46a09 [internal path redacted] fn_46e46a09() executes a setup branch that drives setStatus(bool) and initialize() calls across pre-existing OriginTrail/DKG mod...
- The accounting update violated the invariant: Only authorized governance/deployment control may toggle module status or initialize core module dependency storage.

Key evidence:

- PoC, forge build, forge test, and economic reproduction are marked pass.
- Readable PoC drives the same setup flow by toggling module status and initializing modules from the Hub address.
- Root frame 1 calls the module setStatus and initialize frames that perform the observed storage writes.

## Affected Contracts

| Address | Name | Role |
|---|---|---|
| `0x99aa571fd5e681c2d27ee08a7b7989db02541d13` | `Hub` | `primary vulnerable contract / setup dispatcher` |
| `0xa4f4f1e61f2be32e92fd1d07558a3db5b519d288` | `ShardingTable` | `state-mutated module` |
| `0x80f6d2673689c3b7495942101137f741405a74ae` | `AskStorage` | `state-mutated module` |
| `0xffc349c8deb8d88dc8a99d379413359ca92deb44` | `Identity` | `state-mutated module` |

## Limitations

- source_gap: [internal artifact] is absent, so no verified Solidity source or modifier body is available.
- the exact source-level authorization branch for selector 0x46e46a09 is not visible; the RCA infers insufficient authorization from trace/pseudocode reachability and attacker-driven state writes.
