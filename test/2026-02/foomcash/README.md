# FOOMCASH Incident Report

## Summary

- **Protocol**: FOOMCASH
- **Chain**: ethereum (chain_id=1)
- **Tx hash**: [`0xce20448233f5ea6b6d7209cc40b4dc27b65e07728f2cbbfeb29fc0814e275e48`](https://etherscan.io/tx/0xce20448233f5ea6b6d7209cc40b4dc27b65e07728f2cbbfeb29fc0814e275e48)
- **Block**: 24539650
- **Economic reproduction**: exact — PoC reproduces 99–101% of incident net loss.
- **Elapsed analysis time**: 681.24s (681243 ms)
- **Detected at**: 2026-02-26T00:00:00Z

## Impact

- **Estimated loss**: $1800175.72
- **Funds valued at**: 2026-02-26T07:38:59Z (price as of block N-1, pre-hack)
- **Main affected assets**: FOOM
- **Attacker gain reproduced**: $1800175.72 (USD ratio: 1.000x)

## Reproduction

- **PoC status**: `verified`
- **Forge test**: `pass`
- **Proof kind**: `economic_proof`

## Root Cause

- **Finding**: Broken Groth16 verifier key lets attackers malleate withdrawal public inputs and claim maximum FOOM lottery rewards
- **In short**: The vulnerable path is the `FoomLottery.collect` flow; it violated the value/accounting invariant below.
- **Severity**: `critical`
- **Confidence**: `high`
- **Violated invariant**: A withdrawal proof must bind root, nullifier, reward bits, recipient, relayer, fee, and refund to exactly one valid ticket/witness; public inputs must not be malleable after proof generation.

FoomLottery.collect computes reward entitlement from caller-supplied _rewardbits and relies on WithdrawG16Verifier.verifyProof to bind those bits, the nullifier, and recipient to a valid winning ticket. WithdrawG16Verifier's verification key has gamma2 equal to delta2, so the public-input accumulator and proof C are paired against the same G2 point and publi...

Mechanism:

- The attacker reached the victim through the `FoomLottery.collect` flow during the exploit.
- FoomLottery.collect computes reward entitlement from caller-supplied _rewardbits and relies on WithdrawG16Verifier.verifyProof to bind those bits, the nullifier, and recipient to a valid winning ticket.
- The accounting update violated the invariant: A withdrawal proof must bind root, nullifier, reward bits, recipient, relayer, fee, and refund to exactly one valid ticket/witness; public inputs must not be malleable after proof generation.

Key evidence:

- PoC, forge build/test, and economic proof all passed.
- Verified replay reproduces the incident drain from FoomLottery to attacker.
- Top frames are repeated attacker-controlled calls to FoomLottery.collect with accounting/impact evidence and child verifier/token calls.

## Affected Contracts

| Address | Name | Role |
|---|---|---|
| `0xc043865fb4d542e2bc5ed5ed9a2f0939965671a6` | `WithdrawG16Verifier` | `primary vulnerable contract` |
| `0x239af915abcd0a5dcb8566e863088423831951f8` | `FoomLottery` | `payout contract relying on flawed verifier` |

## Limitations

- The underlying circuit source is not present under victim_sources; the RCA relies on the deployed verifier source, lottery source, trace frames, RPC observations, and verified PoC.
- Exact original winning ticket/witness provenance is not needed for the selected cause and was not determined.
