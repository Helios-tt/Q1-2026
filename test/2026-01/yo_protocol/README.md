# YO Protocol Incident Report

## Summary

- **Protocol**: YO Protocol
- **Chain**: ethereum (chain_id=1)
- **Tx hash**: [`0x6aff59e800dc219ff0d1614b3dc512e7a07159197b2a6a26969a9ca25c3e33b4`](https://etherscan.io/tx/0x6aff59e800dc219ff0d1614b3dc512e7a07159197b2a6a26969a9ca25c3e33b4)
- **Block**: 24218806
- **Economic reproduction**: exact — PoC reproduces 99–101% of incident net loss.
- **Elapsed analysis time**: 747.95s (747952 ms)
- **Detected at**: 2026-01-12T00:00:00Z

## Impact

- **Estimated loss**: 
- **Funds valued at**: 2026-01-12T13:02:47Z (price as of block N-1, pre-hack)
- **Main affected assets**: unknown
- **Attacker gain reproduced**: $112009.25 (USD ratio: 1.000x)

## Reproduction

- **PoC status**: `verified`
- **Forge test**: `pass`
- **Proof kind**: `economic_proof`

## Root Cause

- **Finding**: YoVault manage allowed selector-authorized arbitrary vault-context calls to approve and route vault assets
- **In short**: YoVault_V2 manage(address[],bytes[],uint256[]) accepted attacker-supplied targets and calldata, checked only RolesAuthority.canCall for each target selector, and then executed the calls from the vault context.
- **Severity**: `critical`
- **Confidence**: `medium`
- **Violated invariant**: Vault management execution must bind authorized calls to approved asset, spender, receiver, amount, and value-preservation constraints; selector-level permission alone must not allow arbitrary approvals or router calldata over vault-held assets.

YoVault_V2 manage(address[],bytes[],uint256[]) accepted attacker-supplied targets and calldata, checked only RolesAuthority.canCall for each target selector, and then executed the calls from the vault context. That let the attacker-authorized EOA make the vault approve Odos for a large stkGHO amount and execute arbitrary compact swap calldata.

Mechanism:

- The exploit entered through `manage(address[],bytes[],uint256[]) / 0x224d8703` before reaching the vulnerable accounting path.
- YoVault_V2 manage(address[],bytes[],uint256[]) accepted attacker-supplied targets and calldata, checked only RolesAuthority.canCall for each target selector, and then executed the calls from the vault context.
- The accounting update violated the invariant: Vault management execution must bind authorized calls to approved asset, spender, receiver, amount, and value-preservation constraints; selector-level permission alone must not allow arbitrary approvals or router calldata over vault-held assets.

Key evidence:

- PoC status, execution, economics, forge build, and forge test all passed.
- Incident entry was manage(address[],bytes[],uint256[]) on 0x0000000f... by attacker EOA, with USDC and stkGHO attacker-controlled gains.
- Foundry PoC calls selector 0x224d8703 with preserved artifact-backed calldata and asserts USDC and stkGHO profit legs.

## Affected Contracts

| Address | Name | Role |
|---|---|---|
| `0x0000000f2eb9f69274678c76222b35eec7588a65` | `YoVault_V2 / TransparentUpgradeableProxy_000000` | `primary vulnerable contract` |
| `0x9524e25079b1b04d904865704783a5aa0202d44d` | `RolesAuthority` | `authorization dependency` |

## Limitations

- source_gap: the YoVault manage implementation source was not present under [internal artifact], so the selected branch is supported by pseudocode rather than verified Solidity source
- prior_state_provenance_gap: the artifacts show RolesAuthority.canCall passing but do not prove when or why the attacker EOA obtained the relevant role/capabilities
