# MTToken Incident Report

## Summary

- **Protocol**: MTToken
- **Chain**: arbitrum (chain_id=42161)
- **Tx hash**: [`0xe1e6aa5332deaf0fa0a3584113c17bedc906148730cbbc73efae16306121687b`](https://arbiscan.io/tx/0xe1e6aa5332deaf0fa0a3584113c17bedc906148730cbbc73efae16306121687b)
- **Block**: 419829771
- **Economic reproduction**: close — PoC reproduces the incident within the 80–110% net-loss band.
- **Elapsed analysis time**: 848.75s (848751 ms)
- **Detected at**: 2026-06-25T13:07:18Z
- **Original alert**: https://x.com/Wi11y010/status/2070383892016857245

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

- **Finding**: changePosition allowed an under-collateralized negative margin withdrawal after attacker-controlled position accounting changes
- **In short**: The victim proxy 0xf7ca7384cc6619866749955065f17bedd3ed80bc delegates changePosition(int256,int256,int256) to implementation 0x010659727ad7716c239e206acd3ebee0fdc9e207.
- **Severity**: `critical`
- **Confidence**: `medium`
- **Violated invariant**: A margin withdrawal must not exceed the account's verified withdrawable equity after current position size, PnL, funding, fees, and price/solvency checks are applied.

The victim proxy 0xf7ca7384cc6619866749955065f17bedd3ed80bc delegates changePosition(int256,int256,int256) to implementation 0x010659727ad7716c239e206acd3ebee0fdc9e207. After attacker-controlled position setup and a large position/accounting change, the final drain frame calls changePosition(0, -894992852305, 0), and the victim accepts the negative margin wi...

Mechanism:

- The exploit entered through `changePosition(int256,int256,int256)` before reaching the vulnerable accounting path.
- That path trusted attacker-controlled state while performing protected accounting updates.
- The accounting update violated the invariant: A margin withdrawal must not exceed the account's verified withdrawable equity after current position size, PnL, funding, fees, and price/solvency checks are applied.

Key evidence:

- PoC, forge build/test, and economic proof status are pass.
- Trace flow enters the attacker callback, performs victim calls, then final drain; economic effect records victim WETH and USDC losses.
- Verified PoC sequence shows setup changePosition calls, a large position/accounting change, then drain() calling changePosition(0, -894992852305, 0).

## Affected Contracts

| Address | Name | Role |
|---|---|---|
| `0xf7ca7384cc6619866749955065f17bedd3ed80bc` | `unknown proxy` | `primary vulnerable contract` |
| `0x010659727ad7716c239e206acd3ebee0fdc9e207` | `unknown implementation` | `primary vulnerable implementation` |

## Limitations

- source_branch_gap: verified source for implementation 0x010659727ad7716c239e206acd3ebee0fdc9e207 is not present under [internal artifact].
- the exact internal price/oracle/solvency or margin formula that should have rejected the withdrawal cannot be inspected in the supplied artifacts.
