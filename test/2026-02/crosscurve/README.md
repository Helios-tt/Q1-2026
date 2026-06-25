# CrossCurve Incident Report

## Summary

- **Protocol**: CrossCurve
- **Chain**: ethereum (chain_id=1)
- **Tx hash**: [`0x37d9b911ef710be851a2e08e1cfc61c2544db0f208faeade29ee98cc7506ccc2`](https://etherscan.io/tx/0x37d9b911ef710be851a2e08e1cfc61c2544db0f208faeade29ee98cc7506ccc2)
- **Block**: 24363854
- **Economic reproduction**: unpriced — raw PoC proof passed, but USD comparison is incomplete.
- **Elapsed analysis time**: 881.55s (881548 ms)
- **Detected at**: 2026-02-01T00:00:00Z

## Impact

- **Estimated loss**: 2800000
- **Funds valued at**: 2026-02-01T18:38:11Z (price as of block N-1, pre-hack)
- **Main affected assets**: EYWA
- **Attacker gain reproduced**: unknown
- **USD incomplete**: 1 unpriced leg(s); estimated loss is a lower bound

## Reproduction

- **PoC status**: `verified`
- **Forge test**: `pass`
- **Proof kind**: `economic_proof`

## Root Cause

- **Finding**: Command-id-only cross-chain execution let an attacker forge a BU unlock and drain PortalV2 EYWA
- **In short**: The vulnerable path is the `expressExecute(bytes32,string,string,bytes)` flow; it violated the value/accounting invariant below.
- **Severity**: `critical`
- **Confidence**: `medium`
- **Violated invariant**: A destination unlock must be authorized by an authenticated cross-chain message binding commandId, source chain/address, requestId, operation params, amount, and recipient before PortalV2 releases locked token balance.

The transaction target 0xb2185950f5a0a46687ac331916508aada202e063 exposed expressExecute(bytes32,string,string,bytes) as the attack entry. The accepted payload executed CoreFacet.resume with a forged BU operation, and verified downstream source shows CrosschainFacet forwarded the supplied amount and attacker recipient to PortalV2.unlock, releasing EYWA from ...

Mechanism:

- The attacker reached the victim through the `expressExecute(bytes32,string,string,bytes)` flow during the exploit.
- The transaction target 0xb2185950f5a0a46687ac331916508aada202e063 exposed expressExecute(bytes32,string,string,bytes) as the attack entry.
- The accounting update violated the invariant: A destination unlock must be authorized by an authenticated cross-chain message binding commandId, source chain/address, requestId, operation params, amount, and recipient before PortalV2 releases locked token balance.

Key evidence:

- PoC status, forge build, forge test, and economic reproduction all passed; pricing was unpriced, not failed.
- Trace flow identifies frame 1 expressExecute on 0xb218...e063 and the call into Receiver.receiveData.
- Frame chain runs from expressExecute to Receiver.receiveData, CoreFacet.resume, CrosschainFacet BU, PortalV2.unlock, and EYWA transfers.

## Affected Contracts

| Address | Name | Role |
|---|---|---|
| `0xb2185950f5a0a46687ac331916508aada202e063` | `unknown` | `primary vulnerable cross-chain execution entry` |
| `0x0f00f1a6a32e644815c5686ad7dc305a54b11200` | `Receiver` | `trusted receiver that executed supplied check/data` |
| `0xf3792bae7f35dcde2916c6e6a72ccd3a5330d565` | `Diamond` | `router/diamond executing resume and BU operation` |
| `0xac8f44ceca92b2a4b30360e5bd3043850a0ffcbe` | `PortalV2` | `drained token escrow` |

## Limitations

- missing_assumption
- missing_source_for_entry_contract
