# MTToken Incident Report

## Summary

- **Protocol**: MTToken
- **Chain**: arbitrum (chain_id=42161)
- **Tx hash**: [`0xe1e6aa5332deaf0fa0a3584113c17bedc906148730cbbc73efae16306121687b`](https://arbiscan.io/tx/0xe1e6aa5332deaf0fa0a3584113c17bedc906148730cbbc73efae16306121687b)
- **Block**: 419829771
- **Economic reproduction**: close — PoC reproduces the incident within the 80–110% net-loss band.
- **Elapsed analysis time**: 987.73s (987731 ms)
- **Detected at**: 2026-06-25T13:07:18Z
- **Original alert**: https://github.com/BackwardLabs/report/tree/main/exports/lumoskit-555581b0312b492da5ea4a161b2ae63b78c96c9b-partial-20260616T111006Z/cases/009_futureswap

## Impact

- **Estimated loss**: $406220.61
- **Funds valued at**: 2026-01-10T08:30:35Z (price as of block N-1, pre-hack)
- **Main affected assets**: WETH, USDC
- **Attacker gain reproduced**: $395149.66 (USD ratio: 0.973x)

## Reproduction

- **PoC status**: `verified`
- **Forge test**: `pass`
- **Proof kind**: `economic_proof`

## Root Cause

- **Finding**: F7CA position accounting accepted an under-backed negative changePosition adjustment
- **In short**: The causal frame is an in-transaction changePosition(int256,int256,int256) accounting decision on 0xf7ca7384cc6619866749955065f17bedd3ed80bc delegated to implementation 0x010659727ad7716c239e206acd3ebee0fdc9e207.
- **Severity**: `critical`
- **Confidence**: `medium`
- **Violated invariant**: A position-size reduction or negative position change must not make more assets withdrawable than the caller's backed equity/position entitlement after price, funding, solvency, and reserve checks.

The causal frame is an in-transaction changePosition(int256,int256,int256) accounting decision on 0xf7ca7384cc6619866749955065f17bedd3ed80bc delegated to implementation 0x010659727ad7716c239e206acd3ebee0fdc9e207. The attacker sequence opened/adjusted positions and then called changePosition(0, -894992852305, 0), after which 894992852305 USDC was transferred ...

Mechanism:

- The exploit entered through `changePosition(int256,int256,int256)` before reaching the vulnerable accounting path.
- The causal frame is an in-transaction changePosition(int256,int256,int256) accounting decision on 0xf7ca7384cc6619866749955065f17bedd3ed80bc delegated to implementation 0x010659727ad7716c239e206acd3ebee0fdc9e207.
- The accounting update violated the invariant: A position-size reduction or negative position change must not make more assets withdrawable than the caller's backed equity/position entitlement after price, funding, solvency, and reserve checks.

Key evidence:

- PoC status, economic status, forge build, and forge test all passed.
- The victim holder 0xf7ca...80bc lost WETH and USDC while the attacker EOA gained 394742852305 USDC.
- Rank-1 accounting/impact frame is changePosition(int256,int256,int256) delegated from 0xf7ca...80bc to implementation 0x0106...e207 with large storage writes and logs.

## Affected Contracts

| Address | Name | Role |
|---|---|---|
| `0xf7ca7384cc6619866749955065f17bedd3ed80bc` | `unknown` | `primary vulnerable contract / proxy storage` |

## Limitations

- source_branch_gap: verified source for implementation 0x010659727ad7716c239e206acd3ebee0fdc9e207 is not present under [internal artifact].
- competing_mechanism_source_gap: the supplied artifacts do not expose the victim's oracle, price, funding, solvency, or health-check branch.
