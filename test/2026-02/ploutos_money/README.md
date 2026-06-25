# Ploutos Money Incident Report

## Summary

- **Protocol**: Ploutos Money
- **Chain**: ethereum (chain_id=1)
- **Tx hash**: [`0xa17dc37e1b65c65d20042212fb834974f7faaa961442e3fc05393778705f8474`](https://etherscan.io/tx/0xa17dc37e1b65c65d20042212fb834974f7faaa961442e3fc05393778705f8474)
- **Block**: 24538897
- **Economic reproduction**: close — PoC reproduces the incident within the 80–110% net-loss band.
- **Elapsed analysis time**: 634.16s (634161 ms)
- **Detected at**: 2026-02-26T00:00:00Z

## Impact

- **Estimated loss**: $388395.38
- **Funds valued at**: 2026-02-26T05:07:47Z (price as of block N-1, pre-hack)
- **Main affected assets**: WETH
- **Attacker gain reproduced**: $376751.40 (USD ratio: 0.970x)

## Reproduction

- **PoC status**: `verified`
- **Forge test**: `pass`
- **Proof kind**: `economic_proof`

## Root Cause

- **Finding**: Pool borrow validation accepted an undercollateralized WETH borrow after a small USDC supply
- **In short**: The attacker supplied 8879192 units of USDC and then called Pool borrow for 187366746326704993556 WETH.
- **Severity**: `critical`
- **Confidence**: `medium`
- **Violated invariant**: A Pool borrow must not mint debt or release underlying unless trusted oracle/config/accounting inputs prove the user's collateral value covers the requested debt under the configured LTV.

The attacker supplied 8879192 units of USDC and then called Pool borrow for 187366746326704993556 WETH. The borrow reached BorrowLogic.executeBorrow and passed ValidationLogic.validateBorrow, whose enforceable invariant is that collateralNeededInBaseCurrency for the requested borrow must be less than or equal to userCollateralInBaseCurrency.

Mechanism:

- The exploit entered through `approve(address,uint256) on attacker contract, then UniswapV2 callback calls Pool deposit and borrow` before reaching the vulnerable accounting path.
- The attacker supplied 8879192 units of USDC and then called Pool borrow for 187366746326704993556 WETH.
- The accounting update violated the invariant: A Pool borrow must not mint debt or release underlying unless trusted oracle/config/accounting inputs prove the user's collateral value covers the requested debt under the configured LTV.

Key evidence:

- PoC, forge build/test, and economic reproduction passed.
- Verified transaction, attacker, and 187.366746326704993556 WETH loss.
- Deposit, borrow, debt mint, and WETH release frames connect the Pool borrow to the asset loss.

## Affected Contracts

| Address | Name | Role |
|---|---|---|
| `0x7398e7e3603119d9241e45f688734436fd7b1540` | `InitializableImmutableAdminUpgradeabilityProxy / Pool` | `primary vulnerable pool proxy` |
| `0x07b50419ff228453e5c4ffb0671ebec8bdc3f7d2` | `BorrowLogic` | `borrow validation and debt-release logic` |
| `0x9dce7a180c34203fee8ce8ca62f244feeb67bd30` | `unknown oracle` | `price oracle used by borrow validation` |

## Limitations

- oracle/config/account-data return values that made validateBorrow pass are not decoded in the supplied artifacts.
- source_oracle_return_gap: source for oracle 0x9dce7a180c34203fee8ce8ca62f244feeb67bd30 is absent under victim_sources.
