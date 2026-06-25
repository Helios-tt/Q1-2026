# Gyroscope Incident Report

## Summary

- **Protocol**: Gyroscope
- **Chain**: arbitrum (chain_id=42161)
- **Tx hash**: [`0x51c22898a9b9f519a10b0a0be89b9d51c0248adb80cc0f89e57437e15e6c60c7`](https://arbiscan.io/tx/0x51c22898a9b9f519a10b0a0be89b9d51c0248adb80cc0f89e57437e15e6c60c7)
- **Block**: 426912214
- **Economic reproduction**: usd_pricing_unavailable — historical USD pricing was unavailable.
- **Elapsed analysis time**: 780.46s (780461 ms)
- **Detected at**: 2026-01-30T00:00:00Z

## Impact

- **Estimated loss**: 700000
- **Main affected assets**: unknown
- **Attacker gain reproduced**: unknown

## Reproduction

- **PoC status**: `verified`
- **Forge test**: `pass`
- **Proof kind**: `economic_proof`

## Root Cause

- **Finding**: L2Gyd bridge permits arbitrary post-mint destination callbacks from caller-supplied bridge data
- **In short**: L2Gyd.bridgeToken(uint64,address,uint256,bytes) accepts arbitrary caller-supplied bytes and embeds them into CCIP message.data as abi.encode(recipient, amount, data).
- **Severity**: `high`
- **Confidence**: `medium`
- **Violated invariant**: A bridge receive handler must not execute arbitrary caller-supplied calldata as bridge-originated authority after minting; any post-mint callback must be restricted to safe targets and selectors.

L2Gyd.bridgeToken(uint64,address,uint256,bytes) accepts arbitrary caller-supplied bytes and embeds them into CCIP message.data as abi.encode(recipient, amount, data). The matching L2Gyd._ccipReceive branch decodes that payload, mints to recipient, then executes recipient.functionCall(data) without target or selector restrictions.

Mechanism:

- The exploit entered through `bridgeToken(uint64,address,uint256,bytes)` before reaching the vulnerable accounting path.
- L2Gyd.bridgeToken(uint64,address,uint256,bytes) accepts arbitrary caller-supplied bytes and embeds them into CCIP message.data as abi.encode(recipient, amount, data).
- The accounting update violated the invariant: A bridge receive handler must not execute arbitrary caller-supplied calldata as bridge-originated authority after minting; any post-mint callback must be restricted to safe targets and selectors.

Key evidence:

- PoC artifact is non-failing and forge build/test passed; economic proof is unpriced/reachability-oriented.
- Identifies the replay target transaction, attacker, and bridgeToken attacker entry surface.
- PoC calls bridgeToken with amount 1 and data equal to approve(attacker, uint256.max).

## Affected Contracts

| Address | Name | Role |
|---|---|---|
| `0xca5d8f8a8d49439357d3cf46ca2e720702f132b8` | `L2Gyd proxy` | `primary vulnerable contract` |
| `0xe8ab4550dfa163753023da3154234a525c8ef863` | `L2Gyd` | `primary vulnerable implementation` |
| `0x67761742ac8a21ec4d76ca18cbd701e5a6f3bef3` | `EVM2EVMOnRamp` | `message commit and fee accounting transport` |

## Limitations

- tx_scope_gap: the supplied Arbitrum transaction commits the malicious CCIP message but does not include destination execution or final asset drain.
- destination_recipient_identity_gap: local artifacts do not resolve `0xe07f9d810a48ab5c3c914ba3ca53af14e4491e8a`, so the final destination asset inventory is not identified here.
