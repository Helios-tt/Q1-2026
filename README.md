# Q1-2026 DeFi Incident PoC Archive

<p align="center">
  <a href="https://x.com/backwardlabs">
    <img src="https://img.shields.io/badge/Follow%20on%20X-%40backwardlabs-000000?style=for-the-badge&logo=x&logoColor=white" alt="Follow @backwardlabs on X">
  </a>
</p>

This is a DeFi security incident PoC archive generated and verified by BackwardLabs using Bakclight and AI-assisted analysis.

The repository reproduces on-chain security incidents as Foundry tests and documents each case with an executable PoC, economic reproduction result, attack flow, and RCA(root cause analysis). Each incident directory contains a Solidity test file and its own incident README.

## What Is Inside

- **Foundry PoC**: Solidity tests that reproduce the observed transaction flow in a forked environment.
- **Incident report**: A summary of the chain, transaction, PoC status, reproduced loss, and key root cause.
- **Attack flow**: A step-by-step description of the main calls and value movement.
- **RCA**: A root cause analysis covering the violated invariant, impact scope, and patch points where the evidence supports them.
- **Shared test utilities**: Common fork helpers, balance tracking, and interface definitions under `src/shared/`.

## PoC List

| Date | PoC | Chain | Status | Reproduction | Summary |
|---|---|---|---|---:|---|
| 2025-07 | [fpc](test/2025-07/fpc/) | BSC | verified | unknown | Reproduces the interaction between a token transfer hook and AMM pair sync. |
| 2026-01 | [prxvt](test/2026-01/prxvt/) | Base | verified | unknown | Covers staking receipt transfers that carry prior reward entitlement. |
| 2026-04 | [ethtornado](test/2026-04/ethtornado/) | Arbitrum | verified | $0.31 | Covers Tornado-style note proofs and withdrawal entitlement checks. |
| 2026-05 | [alephium_tokenbridge](test/2026-05/alephium_tokenbridge/) | Ethereum | verified | $547,644.05 | Reviews cross-chain wrapped-token mint authorization and guardian message assumptions. |
| 2026-05 | [omniserviceproxy](test/2026-05/omniserviceproxy/) | Ethereum | verified | $3,053,553,500,000.00 | Reproduces retryable bridge message handling and an unbacked token mint path. |
| 2026-05 | [vault_proxy](test/2026-05/vault_proxy/) | Arbitrum | verified | unknown | Covers missing vault epoch/token-price catch-up before receipt minting. |
| 2026-06 | [ambient_finance](test/2026-06/ambient_finance/) | Ethereum | verified | $110,693.47 | Reproduces concentrated LP fee collection before time-priority eligibility. |
| 2026-06 | [atm](test/2026-06/atm/) | BSC | verified | unknown | Reproduces LP token transfer behavior; the RCA is marked low-confidence. |
| 2026-06 | [auto](test/2026-06/auto/) | BSC | verified | $35,007.23 | Covers LP or withdrawal-right minting from contract-held DTXT inventory. |
| 2026-06 | [axelar](test/2026-06/axelar/) | Ethereum | verified | $364,151.05 | Reproduces Axelar call-with-token approval consumption by a destination contract. |
| 2026-06 | [aztec](test/2026-06/aztec/) | Ethereum | verified | $2,042,126.11 | Covers the escape-hatch proof path and public withdrawal binding. |
| 2026-06 | [aztec_connect](test/2026-06/aztec_connect/) | Ethereum | verified | $2,184,482.17 | Reproduces rollup state transition access control and public withdrawal execution. |
| 2026-06 | [aztec_network](test/2026-06/aztec_network/) | Ethereum | unverified | unknown | A candidate renBTC PoC where the execution gate is incomplete. |
| 2026-06 | [by](test/2026-06/by/) | BSC | verified | $84,315.85 | Covers a public token-maintenance function that can burn AMM-owned inventory. |
| 2026-06 | [by_token](test/2026-06/by_token/) | BSC | verified | $84,315.85 | Reproduces AMM reserve manipulation through unauthorized token balance reduction. |
| 2026-06 | [dip](test/2026-06/dip/) | BSC | verified | $111,064.25 | Covers a double transfer in a fee-exempt branch that inflates AMM input. |
| 2026-06 | [drlvaultv3](test/2026-06/drlvaultv3/) | Ethereum | verified | $94,074.52 | Reproduces vault principal swap manipulation through spot-path pricing assumptions. |
| 2026-06 | [hashflare](test/2026-06/hashflare/) | Ethereum | verified | unknown | A verified execution case with incomplete pricing and RCA. |
| 2026-06 | [jb_token](test/2026-06/jb_token/) | BSC | verified | $49,943.94 | Covers fee, burn, and reward side effects that distort LP reserve accounting. |
| 2026-06 | [little_boy_plus](test/2026-06/little_boy_plus/) | BSC | verified | $364,489.25 | Reproduces same-block spot-reserve manipulation affecting POL and LP/hashrate crediting. |
| 2026-06 | [mev](test/2026-06/mev/) | Ethereum | verified | exact | Reproduces third-party withdraw calls against victim yield/redeemer contracts. |
| 2026-06 | [origintrail](test/2026-06/origintrail/) | Base | verified | pricing unavailable | Covers a Hub setup path that mutates module status and initialization state. |
| 2026-06 | [pancakeswap_v2](test/2026-06/pancakeswap_v2/) | BSC | verified | $1,114,815.78 | Reproduces an AMM pair transfer path that debits more token balance than authorized. |
| 2026-06 | [pnacakeswap_v2](test/2026-06/pnacakeswap_v2/) | BSC | verified | exact | Covers an OLPC skim/sync loop that reduces pair balance before swapping to USDT. |
| 2026-06 | [taico](test/2026-06/taico/) | Ethereum | verified | $649,723.84 | Reproduces a retried bridge message releasing canonical tokens from an L1 vault. |
| 2026-06 | [taico_1](test/2026-06/taico_1/) | Ethereum | verified | exact | Covers a destination-chain bridge release that requires source-chain escrow backing. |

## Repository Structure

```text
.
├── src/shared/                 # Shared Foundry helpers and interfaces
├── test/
│   ├── 2026-01/{incident}/      # Incident-specific PoC and report
│   ├── 2026-04/{incident}/
│   ├── 2026-05/{incident}/
│   └── 2026-06/{incident}/
├── foundry.toml                # Foundry configuration
└── README.md
```

## Notes

- `verified` means the included report marks the PoC as passing its execution gate.
- `unverified` means the candidate PoC exists but did not pass the full execution gate.
- `unknown` or `pricing unavailable` means raw execution may be verified, but USD reconciliation is incomplete or unavailable.
