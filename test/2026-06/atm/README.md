# ATM Incident Report

## Summary

- **Protocol**: ATM
- **Chain**: bsc (chain_id=56)
- **Tx hash**: [`0x5c27edc326e38641d8ce6093cd7f15ae5fca039f5fb988b7f10cb432e6e3a056`](https://bscscan.com/tx/0x5c27edc326e38641d8ce6093cd7f15ae5fca039f5fb988b7f10cb432e6e3a056)
- **Block**: 105692847
- **Economic reproduction**: unpriced — raw PoC proof passed, but USD comparison is incomplete.
- **Elapsed analysis time**: 468.91s (468909 ms)
- **Detected at**: 2026-06-22T09:45:24+00:00
- **Original alert**: https://x.com/TenArmorAlert/status/2068993748936151209

## Impact

- **Estimated loss**: $949900.00
- **Funds valued at**: 2026-06-22T09:23:38Z (price as of block N-1, pre-hack)
- **Main affected assets**: unknown
- **Attacker gain reproduced**: unknown

## Reproduction

- **PoC status**: `verified`
- **Forge test**: `pass`
- **Proof kind**: `economic_proof`

## Root Cause

- **Finding**: No patchable vulnerability identified from transfer-only supplied artifacts
- **In short**: The supplied artifacts show a single PancakePair/PancakeERC20 transfer(address,uint256) that moves 400498341357466415661652 Cake-LP units from EOA 0xbe8351c14e5108a57a545dfa8669fa31aa6adc68 to the LP token contract itsel...
- **Severity**: `low`
- **Confidence**: `low`
- **Violated invariant**: No violated invariant was identified in the supplied artifacts.

The supplied artifacts show a single PancakePair/PancakeERC20 transfer(address,uint256) that moves 400498341357466415661652 Cake-LP units from EOA 0xbe8351c14e5108a57a545dfa8669fa31aa6adc68 to the LP token contract itself. Source and trace evidence show standard SafeMath-backed balanceOf debit/credit behavior, with no executed mint, burn, swap, reserve, orac...

Mechanism:

- The exploit entered through `transfer(address,uint256) / 0xa9059cbb` before reaching the vulnerable accounting path.
- The supplied artifacts show a single PancakePair/PancakeERC20 transfer(address,uint256) that moves 400498341357466415661652 Cake-LP units from EOA 0xbe8351c14e5108a57a545dfa8669fa31aa6adc68 to the LP token contract itsel...
- The accounting update violated the invariant: No violated invariant was identified in the supplied artifacts.

Key evidence:

- PoC execution, economics, forge build, and forge test are marked pass.
- Frontier reports one positive Cake-LP delta, no negative deltas, no giant mint tokens, no authority/state anomalies, no candidate frames, and no RPC questions.
- Transaction input is selector 0xa9059cbb with recipient equal to the pair contract, amount 400498341357466415661652, and zero native value.

## Affected Contracts

| Address | Name | Role |
|---|---|---|
| `0x9753a64fb7c233fdc43f04dab9cca88e1e229eba` | `PancakePair` | `observed transfer target and LP token contract; no proven vulnerable contract role` |

## Limitations

- tx_scope_gap: the supplied artifacts cover only a single transfer frame and cannot prove whether any prior setup or later execution transaction was relevant.
- no_candidate_root_cause_gap: rca_frontier.json contains no candidate_frames, candidate_addresses, frame_io entries, analysis_questions, or rpc_questions.
