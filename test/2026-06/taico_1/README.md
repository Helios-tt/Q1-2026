# taico_1 Incident Report

## Summary

- **Protocol**: taico_1
- **Chain**: ethereum (chain_id=1)
- **Tx hash**: [`0xb8befb015a67de8f40890b1f8667c597c3b66a52b388ec1c6cd28637fd65dd13`](https://etherscan.io/tx/0xb8befb015a67de8f40890b1f8667c597c3b66a52b388ec1c6cd28637fd65dd13)
- **Block**: 25368908
- **Economic reproduction**: exact — PoC reproduces 99–101% of incident net loss.
- **Elapsed analysis time**: 599.27s (599269 ms)

## Impact

- **Estimated loss**: unknown
- **Main affected assets**: unknown
- **Attacker gain reproduced**: $223255.73 (USD ratio: 1.000x)

## Reproduction

- **PoC status**: `verified`
- **Forge test**: `pass`
- **Proof kind**: `economic_proof`

## Root Cause

- **Finding**: Bridge message execution released 130 ETH from a prior remote-signal entitlement that is not proven in the supplied transaction scope
- **In short**: The current transaction calls MainnetBridge.processMessage with a message whose hash is proven through SignalService, then the bridge consumes ETH quota and releases _message.value to the recipient.
- **Severity**: `high`
- **Confidence**: `medium`
- **Violated invariant**: A destination-chain bridge release must be backed by a source-chain message signal that was created by a value-escrowing sendMessage for the exact message hash and amount.

The current transaction calls MainnetBridge.processMessage with a message whose hash is proven through SignalService, then the bridge consumes ETH quota and releases _message.value to the recipient. The in-transaction branch and 130 ETH effect are proven, but the supplied artifacts do not include the source-chain sendMessage or checkpoint-authoring provenanc...

Mechanism:

- The exploit entered through `processMessage((uint64,uint64,uint32,address,uint64,address,uint64,address,address,uint256,bytes),bytes)` before reaching the vulnerable accounting path.
- The current transaction calls MainnetBridge.processMessage with a message whose hash is proven through SignalService, then the bridge consumes ETH quota and releases _message.value to the recipient.
- The accounting update violated the invariant: A destination-chain bridge release must be backed by a source-chain message signal that was created by a value-escrowing sendMessage for the exact message hash and amount.

Key evidence:

- PoC result reports status pass with forge build and test passing.
- Attack flow identifies the replayed transaction, processMessage entrypoint, and 130 ETH economic payout.
- Trace frontier links processMessage to proveSignalReceived, consumeQuota, and the final 130 ETH recipient call.

## Affected Contracts

| Address | Name | Role |
|---|---|---|
| `0xd60247c6848b7ca29eddf63aa924e53db6ddd8ec` | `ERC1967Proxy / MainnetBridge` | `primary bridge contract executing the payout branch` |
| `0x9e0a24964e5397b566c1ed39258e21ab5e35c77c` | `ERC1967Proxy / SignalService` | `remote-signal proof gate consumed before payout` |
| `0x91f67118dd47d502b1f0c354d0611997b022f29e` | `ERC1967Proxy / QuotaManager` | `secondary quota accounting gate` |

## Limitations

- tx_scope_gap: the decisive source-chain sendMessage or prior setup transaction that created the proven signal is not included in the supplied artifacts.
- prior_state_provenance_gap: the transaction consumes a prior checkpoint/remote signal state, but the artifacts do not prove who authored that checkpoint or whether the remote signal was economically backed.
