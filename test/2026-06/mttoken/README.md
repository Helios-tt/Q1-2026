# MTToken Incident Report

## Summary

- **Protocol**: MTToken
- **Chain**: arbitrum (chain_id=42161)
- **Tx hash**: [`0xe1e6aa5332deaf0fa0a3584113c17bedc906148730cbbc73efae16306121687b`](https://arbiscan.io/tx/0xe1e6aa5332deaf0fa0a3584113c17bedc906148730cbbc73efae16306121687b)
- **Block**: 419829771
- **Economic reproduction**: close — PoC reproduces the incident within the 80–110% net-loss band.
- **Elapsed analysis time**: 888.41s (888411 ms)
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

- **Finding**: Position accounting accepted an over-withdrawal through changePosition after attacker-controlled setup
- **In short**: The victim proxy 0xf7ca7384cc6619866749955065f17bedd3ed80bc delegated changePosition(int256,int256,int256) to implementation 0x010659727ad7716c239e206acd3ebee0fdc9e207.
- **Severity**: `critical`
- **Confidence**: `medium`
- **Violated invariant**: A position owner must not be able to withdraw or settle more base/quote asset value than their post-action collateralized equity supports after funding, price, and solvency checks.

The victim proxy 0xf7ca7384cc6619866749955065f17bedd3ed80bc delegated changePosition(int256,int256,int256) to implementation 0x010659727ad7716c239e206acd3ebee0fdc9e207. The attacker opened and manipulated positions, then called changePosition(0, -894992852305, 0), which the protocol accepted as valid and settled value out of the victim.

Mechanism:

- The exploit entered through `changePosition(int256,int256,int256) / selector 0xa442c8be` before reaching the vulnerable accounting path.
- The victim proxy 0xf7ca7384cc6619866749955065f17bedd3ed80bc delegated changePosition(int256,int256,int256) to implementation 0x010659727ad7716c239e206acd3ebee0fdc9e207.
- The accounting update violated the invariant: A position owner must not be able to withdraw or settle more base/quote asset value than their post-action collateralized equity supports after funding, price, and solvency checks.

Key evidence:

- Foundry build/test and economic proof passed.
- Places the flash-loan callback, helper calls, victim calls, and realized victim losses.
- Shows the callback sequence, helper position setup, and final drain via changePosition(0, -894992852305, 0).

## Affected Contracts

| Address | Name | Role |
|---|---|---|
| `0xf7ca7384cc6619866749955065f17bedd3ed80bc` | `unknown` | `primary vulnerable proxy/storage contract` |
| `0x010659727ad7716c239e206acd3ebee0fdc9e207` | `unknown` | `implementation containing changePosition logic` |

## Limitations

- source_gap: no verified source directory exists for 0xf7ca7384cc6619866749955065f17bedd3ed80bc or implementation 0x010659727ad7716c239e206acd3ebee0fdc9e207 under [internal artifact]
- missing_branch_formula_gap: the exact changePosition branch, formula, and missing guard are not present in source or implementation pseudocode.
