# IoTeX (ioTube bridge) Incident Report

## Summary

- **Protocol**: IoTeX (ioTube bridge)
- **Chain**: ethereum (chain_id=1)
- **Tx hash**: [`0xe9e7f33ebfe2230c147e6e0321f5f2c7de1b89fe9fc08830fc3f8ac5845bc9f0`](https://etherscan.io/tx/0xe9e7f33ebfe2230c147e6e0321f5f2c7de1b89fe9fc08830fc3f8ac5845bc9f0)
- **Block**: 24501847
- **Economic reproduction**: usd_pricing_unavailable — historical USD pricing was unavailable.
- **Elapsed analysis time**: 552.38s (552378 ms)
- **Detected at**: 2026-02-21T00:00:00Z

## Impact

- **Estimated loss**: 4400000
- **Main affected assets**: unknown
- **Attacker gain reproduced**: unknown

## Reproduction

- **PoC status**: `verified`
- **Forge test**: `pass`
- **Proof kind**: `economic_proof`

## Root Cause

- **Finding**: Owner-slot transfer executed by pre-state owner; contract bug not proven
- **In short**: The current transaction invokes transferOwnership(address) on TransferValidatorWithPayload and the visible pseudocode reads slot 0, observes tx.from as the pre-state owner, then writes the calldata address as the new own...
- **Severity**: `medium`
- **Confidence**: `medium`
- **Violated invariant**: Only the legitimate owner authority should be able to change the slot-0 owner; the current artifacts show the caller already matched the slot-0 owner, so a contract-level authorization invariant failure is not proven.

That evidence does not prove an unauthorized caller or missing owner check in this transaction. If the transaction is malicious, the causal failure lies in prior control of the owner key or owner slot, which is outside the supplied artifacts.

Mechanism:

- The exploit entered through `transferOwnership(address)` before reaching the vulnerable accounting path.
- The current transaction invokes transferOwnership(address) on TransferValidatorWithPayload and the visible pseudocode reads slot 0, observes tx.from as the pre-state owner, then writes the calldata address as the new own...
- The accounting update violated the invariant: Only the legitimate owner authority should be able to change the slot-0 owner; the current artifacts show the caller already matched the slot-0 owner, so a contract-level authorization invariant failure is not proven.

Key evidence:

- The PoC replay passed and the only listed surface is transferOwnership(address) on 0xe7eba1cea51ec9b3accc16728e3b8786560c59d5.
- The transaction sender is 0x6dd31a526ee3ddbc7be888b729a445695c03148e and the calldata invokes selector 0xf2fde38b with new owner 0xe6a191a894dd3c85e3c89926e9f476f818ee55d9.
- The compact pseudocode reads slot 0 with old value 0x6dd31a526ee3ddbc7be888b729a445695c03148e, writes the calldata address into slot 0, and emits an ownership-transfer style event.

## Affected Contracts

| Address | Name | Role |
|---|---|---|
| `0xe7eba1cea51ec9b3accc16728e3b8786560c59d5` | `TransferValidatorWithPayload` | `authority state contract and current transaction target` |

## Limitations

- tx_scope_gap: the supplied current transaction begins with tx.from already equal to the observed slot-0 owner; prior owner/key provenance is outside the supplied artifacts.
- source_gap: [internal artifact] contains no verified source for TransferValidatorWithPayload, so the exact Solidity authorization branch cannot be inspected.
