# Vault4626 Incident Report

## Summary

- **Protocol**: Vault4626
- **Chain**: base (chain_id=8453)
- **Tx hash**: [`0x2f2e12fbdf541c28f3667153e5338f73a313096338dc5ca592453566debcd790`](https://basescan.org/tx/0x2f2e12fbdf541c28f3667153e5338f73a313096338dc5ca592453566debcd790)
- **Block**: 47958575
- **Economic reproduction**: close — PoC reproduces the incident within the 80–110% net-loss band.
- **Elapsed analysis time**: 988.25s (988250 ms)
- **Detected at**: 2026-06-29T07:25:46+00:00
- **Original alert**: https://t.me/c/2360854548/3125

## Impact

- **Estimated loss**: $21894.16
- **Funds valued at**: 2026-06-29T04:14:55Z (price as of block N-1, pre-hack)
- **Main affected assets**: WETH, USDC
- **Attacker gain reproduced**: $21369.00 (USD ratio: 0.976x)

## Reproduction

- **PoC status**: `verified`
- **Forge test**: `pass`
- **Proof kind**: `economic_proof`

## Root Cause

- **Finding**: Vault redeem double-counts non-asset value by paying USDC-equivalent TVL and WETH separately
- **In short**: Vault4626.redeem computes assets = convertToAssets(shares), where totalAssets already includes quoted WETH held by the vault and in the Uniswap V3 LP position.
- **Severity**: `critical`
- **Confidence**: `high`
- **Violated invariant**: A share redemption must pay at most the share's proportional vault value once, either as one asset-denominated amount or as pro-rata token balances, not both.

Vault4626.redeem computes assets = convertToAssets(shares), where totalAssets already includes quoted WETH held by the vault and in the Uniswap V3 LP position. The same redeem branch then separately sends nonAssetToSend WETH after withdrawing proportional LP liquidity, so a redeemer can receive USDC value that includes WETH plus the WETH itself.

Mechanism:

- The exploit entered through `redeem(uint256,address,address)` before reaching the vulnerable accounting path.
- Vault4626.redeem computes assets = convertToAssets(shares), where totalAssets already includes quoted WETH held by the vault and in the Uniswap V3 LP position.
- The accounting update violated the invariant: A share redemption must pay at most the share's proportional vault value once, either as one asset-denominated amount or as pro-rata token balances, not both.

Key evidence:

- PoC replay, build, test, and economic proof all passed.
- The exploit deposits USDC, transfers 12.92 WETH into the vault, redeems the minted shares, performs the Uniswap callback/swap path, and repays the WETH flash loan.
- Frontier frames correlate the PoC sequence to vault deposit, WETH transfer into vault, vault redeem, and Uniswap V3/NFPM liquidity withdrawal frames.

## Affected Contracts

| Address | Name | Role |
|---|---|---|
| `0x72dbaa8a09d71d09c6de0de439968e1e7c122020` | `ERC1967Proxy / Vault4626` | `primary vulnerable vault proxy` |
| `0xe6644ae61eca940b1201e0fe2c0574b3be60cf9f` | `ERC1967Proxy / StrategyUniswapV3` | `strategy liquidity source used by redeem` |

## Limitations

_No material limitations were recorded in the final RCA output._
