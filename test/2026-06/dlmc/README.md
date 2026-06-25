# DLMC Incident Report

## Summary

- **Protocol**: DLMC
- **Chain**: bsc (chain_id=56)
- **Tx hash**: [`0x151025d3f0a782340a74d30ef33a5fad044b838e74437a803f0652e70c231306`](https://bscscan.com/tx/0x151025d3f0a782340a74d30ef33a5fad044b838e74437a803f0652e70c231306)
- **Block**: 106091607
- **Economic reproduction**: unpriced — raw PoC proof passed, but USD comparison is incomplete.
- **Elapsed analysis time**: 623.19s (623191 ms)
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

- **Finding**: DLMC buy/referral accounting inflated livePrice and allowed same-transaction redemption of referral DLMC for USDT
- **In short**: The vulnerable path is the `registerAffiliate(address) -> approve(address,uint256) -> buy(uint256)` flow; it violated the value/accounting invariant below.
- **Severity**: `high`
- **Confidence**: `high`
- **Violated invariant**: A DLMC balance redeemable through sell() must not be priced using a reserve/supply formula that includes temporary buy liquidity while excluding newly minted redeemable supply or relying on same-transaction investment to satisfy payout limits.

DLMCToken buy(uint256) mints DLMC to address(this), records the buyer's same-transaction investment, and may grant the referrer sellable DLMC via _distributeReferralBonusOnBuy and _applyBurnAndDaoSplit. _updatePrice then includes the flash-borrowed USDT deposit in reserve but subtracts balanceOf(address(this)) from the circulating-supply denominator, so the ...

Mechanism:

- The attacker reached the victim through the `registerAffiliate(address) -> approve(address,uint256) -> buy(uint256)` flow during the exploit.
- DLMCToken buy(uint256) mints DLMC to address(this), records the buyer's same-transaction investment, and may grant the referrer sellable DLMC via _distributeReferralBonusOnBuy and _applyBurnAndDaoSplit.
- The accounting update violated the invariant: A DLMC balance redeemable through sell() must not be priced using a reserve/supply formula that includes temporary buy liquidity while excluding newly minted redeemable supply or relying on same-transaction investment to satisfy payout limits.

Key evidence:

- PoC status, forge build, forge test, and economic proof all passed.
- Trace flow shows Pancake swap callback into attacker, DLMC registerAffiliate/buy calls, child buy, DLMC sell, and USDT profit routing.
- PoC reproduces the flash swap, parent and child DLMC buys, final sell, repayment, and USDT profit transfer.

## Affected Contracts

| Address | Name | Role |
|---|---|---|
| `0xf2ca2a3572b26ae7c479dc7ae36d922113b1bdf2` | `DLMCToken` | `primary vulnerable contract` |

## Limitations

_No material limitations were recorded in the final RCA output._
