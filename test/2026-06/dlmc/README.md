# DLMC Incident Report

## Summary

- **Protocol**: DLMC
- **Chain**: bsc (chain_id=56)
- **Tx hash**: [`0x151025d3f0a782340a74d30ef33a5fad044b838e74437a803f0652e70c231306`](https://bscscan.com/tx/0x151025d3f0a782340a74d30ef33a5fad044b838e74437a803f0652e70c231306)
- **Block**: 106091607
- **Economic reproduction**: unpriced — raw PoC proof passed, but USD comparison is incomplete.
- **Elapsed analysis time**: 679.91s (679908 ms)
- **Detected at**: 2026-06-25T01:35:10+00:00
- **Original alert**: https://x.com/TenArmorAlert/status/2069957542109958498

## Impact

- **Estimated loss**: $222600.00
- **Funds valued at**: 2026-06-24T11:15:10Z (price as of block N-1, pre-hack)
- **Main affected assets**: unknown
- **Attacker gain reproduced**: unknown

## Reproduction

- **PoC status**: `verified`
- **Forge test**: `pass`
- **Proof kind**: `economic_proof`

## Root Cause

- **Finding**: DLMC buy/referral accounting inflated DLMC entitlement that was sold for the contract's USDT reserve
- **In short**: The vulnerable path is the `DLMCToken.buy(uint256)` flow; it violated the value/accounting invariant below.
- **Severity**: `critical`
- **Confidence**: `medium`
- **Violated invariant**: DLMC buy/referral accounting must not mint or credit DLMC entitlement beyond the amount justified by the paid USDT amount under the token's pricing and affiliate formula.

The root cause is attacker-controlled state reaching protected accounting updates.

Mechanism:

- The attacker reached the victim through the `DLMCToken.buy(uint256)` flow during the exploit.
- That path trusted attacker-controlled state while performing protected accounting updates.
- The accounting update violated the invariant: DLMC buy/referral accounting must not mint or credit DLMC entitlement beyond the amount justified by the paid USDT amount under the token's pricing and affiliate formula.

Key evidence:

- PoC status, execution, economic reproduction, forge build, and forge test all passed.
- Flash callback registers affiliate, approves USDT, performs two DLMC buys, sells DLMC, repays PancakePair, and transfers remaining USDT to the profit recipient.
- DLMC buy(uint256) frames contain child USDT transferFrom calls, DLMC mint-like Transfer logs from zero address to DLMC, and large DLMC storage writes.

## Affected Contracts

| Address | Name | Role |
|---|---|---|
| `0xf2ca2a3572b26ae7c479dc7ae36d922113b1bdf2` | `DLMCToken` | `primary vulnerable contract` |
| `0x16b9a82891338f9ba80e2d6970fdda79d1eb0dae` | `PancakePair` | `flash-swap liquidity and callback surface, not selected root cause` |

## Limitations

- DLMC verified source is missing under [internal artifact], so the exact vulnerable branch, storage layout, and amount-computing helper cannot be named.
- [internal artifact] is compact replay pseudocode and does not include the DLMC internal pricing/referral formula.
