# MEV Incident Report

## Summary

- **Protocol**: MEV
- **Chain**: ethereum (chain_id=1)
- **Tx hash**: [`0x2be8704f5a59b69e0b71f64aefdb99eb0e8ae9fb3926147c581910d71bcf3e65`](https://etherscan.io/tx/0x2be8704f5a59b69e0b71f64aefdb99eb0e8ae9fb3926147c581910d71bcf3e65)
- **Block**: 25360696
- **Economic reproduction**: exact — PoC reproduces 99–101% of incident net loss.
- **Elapsed analysis time**: 677.90s (677902 ms)

## Impact

- **Estimated loss**: $7450017.78
- **Main affected assets**: USDC, WETH, USDT
- **Attacker gain reproduced**: $17.27 (USD ratio: 1.000x)

## Reproduction

- **PoC status**: `verified`
- **Forge test**: `pass`
- **Proof kind**: `economic_proof`

## Root Cause

- **Finding**: Attacker-triggered third-party withdraw calls drained a victim account through pre-approved redeemer contracts
- **In short**: The vulnerable path is the `withdraw(address)` flow; it violated the value/accounting invariant below.
- **Severity**: `critical`
- **Confidence**: `medium`
- **Violated invariant**: A withdraw/redeem function must not let an arbitrary third-party caller withdraw from account unless that caller is the account or has explicit account-level authorization for the withdrawal.

The root cause is attacker-controlled state reaching protected accounting updates.

Mechanism:

- The attacker reached the victim through the `withdraw(address)` flow during the exploit.
- That path trusted attacker-controlled state while performing protected accounting updates.
- The accounting update violated the invariant: A withdraw/redeem function must not let an arbitrary third-party caller withdraw from account unless that caller is the account or has explicit account-level authorization for the withdrawal.

Key evidence:

- PoC execution, economic reproduction, forge build, and forge test passed for the target transaction.
- Verified PoC calls withdraw(address) on 66 yield/redeemer contracts using victim account 0x1f2f10...f387.
- Top candidate parent frames are attacker-called withdraw(address) calls into helper contracts.

## Affected Contracts

| Address | Name | Role |
|---|---|---|
| `0x4ee0b6e9f9c4886beeef2ebd7fc27223169531ce` | `unknown redeemer/helper` | `primary vulnerable contract candidate` |
| `0x757230bd24489b8d8817f4ff8e5a35ebeb3dde39` | `unknown redeemer/helper` | `primary vulnerable contract candidate` |
| `0xa61d15479e0aee1fca32fb0f4f9865102d13b7c8` | `unknown redeemer/helper` | `primary vulnerable contract candidate` |
| `0x68ca6a0c6db92bf2d4424c7c9fba8655992187c6` | `unknown redeemer/helper` | `primary vulnerable contract candidate` |
| `0x4db09fdce399f331775187bd81e9ecdfe179454a` | `unknown redeemer/helper` | `primary vulnerable contract candidate` |

## Limitations

- Helper/redeemer source for withdraw(address) is missing under [internal artifact], so the exact source line and branch cannot be pinpointed.
- The provenance and intended semantics of the pre-existing token allowances consumed by transferFrom are not established in the current transaction artifacts.
