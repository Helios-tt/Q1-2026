# SynapLogic Incident Report

## Summary

- **Protocol**: SynapLogic
- **Chain**: base (chain_id=8453)
- **Tx hash**: [`0xc54c00046364b6e889db18c73beee9b81df6b5ca822b6d262b3d30cdf376c4b1`](https://basescan.org/tx/0xc54c00046364b6e889db18c73beee9b81df6b5ca822b6d262b3d30cdf376c4b1)
- **Block**: 41038634
- **Economic reproduction**: exact — PoC reproduces 99–101% of incident net loss.
- **Elapsed analysis time**: 801.50s (801502 ms)
- **Detected at**: 2026-06-25T13:07:18Z
- **Original alert**: https://github.com/BackwardLabs/report/tree/main/exports/lumoskit-555581b0312b492da5ea4a161b2ae63b78c96c9b-partial-20260616T111006Z/cases/008_synaplogic

## Impact

- **Estimated loss**: $88183.77
- **Funds valued at**: 2026-01-19T23:50:13Z (price as of block N-1, pre-hack)
- **Main affected assets**: ETH
- **Attacker gain reproduced**: $88161.71 (USD ratio: 1.000x)

## Reproduction

- **PoC status**: `verified`
- **Forge test**: `pass`
- **Proof kind**: `economic_proof`

## Root Cause

- **Finding**: Authorized router path can create unbacked SYP balances through SynapLogicErc20 relayer mint branch
- **In short**: The vulnerable path is the `SynapLogicErc20.mint(3, attacker_helper, amount, 1, false)` flow; it violated the value/accounting invariant below.
- **Severity**: `critical`
- **Confidence**: `medium`
- **Violated invariant**: A user's ERC20-reported balance must not increase unless totalSupply increases through a controlled mint or an existing holder's balance decreases by the same amount.

SynapLogicErc20.mint(uint256,address,uint256,uint256,bool) uses the _ac == 3 and _set_mode == 1 branch to add caller-supplied _am directly to _vesting[_u] when msg.sender is relayer222O. In this transaction, the authorized router/proxy 0x39f36e...1a32 repeatedly called that branch for the attacker helper, creating 442345096000000000000000 SYP of balance enti...

Mechanism:

- The attacker reached the victim through the `SynapLogicErc20.mint(3, attacker_helper, amount, 1, false)` flow during the exploit.
- SynapLogicErc20.mint(uint256,address,uint256,uint256,bool) uses the _ac == 3 and _set_mode == 1 branch to add caller-supplied _am directly to _vesting[_u] when msg.sender is relayer222O.
- The accounting update violated the invariant: A user's ERC20-reported balance must not increase unless totalSupply increases through a controlled mint or an existing holder's balance decreases by the same amount.

Key evidence:

- PoC status, forge build, forge test, and economic proof all pass.
- Shows transaction, attacker, callback flow, repeated router/SYP path, and economic loss basis.
- balanceOf sums _vesting and _exchange; mint branch _ac==3/_set_mode==1 requires relayer222O[msg.sender] and adds _am to _vesting[_u] without updating _totalSupply.

## Affected Contracts

| Address | Name | Role |
|---|---|---|
| `0x2bdd3602fc526aa5cc677cd708375dd2f7c4256f` | `SynapLogicErc20` | `primary vulnerable contract` |
| `0x39f36e2e58f36f7e5c17784847fd07da1fee1a32` | `feeSwapRouter proxy` | `authorized router trigger and ETH loss holder` |

## Limitations

- amount_formula_source_gap: router implementation 0xc859ac8429fb4a5e24f24a7bed3fe3a8db4fb371 source is absent from [internal artifact], so the exact loop/formula that produced the SYP _am values is trace-supported but not source-supported.
- prior_state_provenance_gap: artifacts show the SYP relayer check was satisfied by 0x39f36e... but do not prove when or why that relayer authorization was granted.
