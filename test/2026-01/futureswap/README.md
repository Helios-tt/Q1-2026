# futureswap Incident Report

## Summary

- **Protocol**: futureswap
- **Chain**: arbitrum (chain_id=42161)
- **Tx hash**: [`0xe1e6aa5332deaf0fa0a3584113c17bedc906148730cbbc73efae16306121687b`](https://arbiscan.io/tx/0xe1e6aa5332deaf0fa0a3584113c17bedc906148730cbbc73efae16306121687b)
- **Block**: 419829771
- **Economic reproduction**: usd_pricing_unavailable — historical USD pricing was unavailable.
- **Elapsed analysis time**: 764.62s (764620 ms)
- **Detected at**: 2026-01-15T00:00:00Z

## Impact

- **Estimated loss**: 
- **Main affected assets**: unknown
- **Attacker gain reproduced**: unknown

## Reproduction

- **PoC status**: `verified`
- **Forge test**: `pass`
- **Proof kind**: `economic_proof`

## Root Cause

- **Finding**: Futureswap proxy accepted an over-withdrawal through changePosition after attacker-controlled position setup
- **In short**: The vulnerable path is the `longPosition() followed by approve(USDC) and changePosition(...) from helper contracts` flow; it violated the value/accounting invariant below.
- **Severity**: `high`
- **Confidence**: `medium`
- **Violated invariant**: A position account must not be able to withdraw more collateral/value than its solvent, price-validated position permits, and a negative collateral delta must not drain protocol reserves.

The trace-proven vulnerable decision is `changePosition(int256,int256,int256)` on proxy `0xf7ca7384cc6619866749955065f17bedd3ed80bc`, implemented by `0x010659727ad7716c239e206acd3ebee0fdc9e207`. After attacker helper contracts made positive collateral/position setup calls, a final `changePosition(0,-894992852305,0)` caused the contract to transfer `894992852...

Mechanism:

- The attacker reached the victim through the `longPosition() followed by approve(USDC) and changePosition(...) from helper contracts` flow during the exploit.
- The trace-proven vulnerable decision is `changePosition(int256,int256,int256)` on proxy `0xf7ca7384cc6619866749955065f17bedd3ed80bc`, implemented by `0x010659727ad7716c239e206acd3ebee0fdc9e207`.
- The accounting update violated the invariant: A position account must not be able to withdraw more collateral/value than its solvent, price-validated position permits, and a negative collateral delta must not drain protocol reserves.

Key evidence:

- PoC status, forge build/test, and economic proof all pass.
- Observed flow enters Aave flash-loan callback, then repeatedly calls 0xf7ca...80bc and USDC transfer/approval frames from attacker helper contracts.
- Frontier candidates are mostly USDC transfer/approval path frames plus one protocol longPosition frame; no giant mint or deterministic asset-delta impact is reported.

## Affected Contracts

| Address | Name | Role |
|---|---|---|
| `0xf7ca7384cc6619866749955065f17bedd3ed80bc` | `unknown proxy / Futureswap-like position contract` | `primary vulnerable contract` |

## Limitations

- the implementation source/decompiled branch for 0x010659727ad7716c239e206acd3ebee0fdc9e207 is absent, so oracle/price/solvency validation logic cannot be inspected.
- source_branch_gap: the exact failed formula, line number, and guard inside changePosition are not available in the supplied artifacts.
