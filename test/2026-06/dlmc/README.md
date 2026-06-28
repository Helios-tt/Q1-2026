# DLMC Incident Report

## Summary

- **Protocol**: DLMC
- **Chain**: bsc (chain_id=56)
- **Tx hash**: [`0x151025d3f0a782340a74d30ef33a5fad044b838e74437a803f0652e70c231306`](https://bscscan.com/tx/0x151025d3f0a782340a74d30ef33a5fad044b838e74437a803f0652e70c231306)
- **Block**: 106091607
- **Economic reproduction**: unpriced — raw PoC proof passed, but USD comparison is incomplete.
- **Elapsed analysis time**: 779.67s (779674 ms)
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

- **Finding**: DLMC internal price formula excludes contract-held buy-minted supply while counting the matching USDT reserve
- **In short**: DLMCToken.buy(uint256) turns attacker-controlled amountQuote into normalizedQuote, buyAmount, tokensToUser, and _mint(address(this), tokensToUser), expanding supply while the paid USDT remains in the contract reserve.
- **Severity**: `critical`
- **Confidence**: `high`
- **Violated invariant**: The livePrice denominator used to redeem DLMC must include the supply created by the reserve inflow being counted, or the corresponding reserve must be excluded; sell caps must not treat same-transaction flash-funded deposits as settled economic backing.

DLMCToken.buy(uint256) turns attacker-controlled amountQuote into normalizedQuote, buyAmount, tokensToUser, and _mint(address(this), tokensToUser), expanding supply while the paid USDT remains in the contract reserve. _updatePrice then counts that USDT reserve but subtracts contract-held DLMC from the denominator, so flash-loan-funded buys can inflate livePr...

Mechanism:

- The exploit entered through `buy(uint256) / sell(uint256) via Pancake flash-swap callback` before reaching the vulnerable accounting path.
- That path trusted attacker-controlled state while performing protected accounting updates.
- The accounting update violated the invariant: The livePrice denominator used to redeem DLMC must include the supply created by the reserve inflow being counted, or the corresponding reserve must be excluded; sell caps must not treat same-transaction flash-funded deposits as settled economic backing.

Key evidence:

- PoC status, execution, economic reproduction, forge build, and forge test all passed.
- The flash callback registers affiliates, approves USDT, executes two DLMC buys, reads price/balances, sells DLMC, repays the flash swap, and routes USDT profit.
- Selected DLMC affiliate registration, buy, price, and sell frames are the source-backed accounting/entitlement path; approval and transfer frames are downstream.

## Affected Contracts

| Address | Name | Role |
|---|---|---|
| `0xf2ca2a3572b26ae7c479dc7ae36d922113b1bdf2` | `DLMCToken` | `primary vulnerable contract` |

## Limitations

- The result.json top-level profit_token and profit_delta fields are null, so profit values are taken from attack_flow.md and asset/RPC deltas.
- No historical prior transactions were used by design; the selected root cause is in-transaction and source-visible.
