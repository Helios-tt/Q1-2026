# LumosKit Run Report — ethereum 0x31e56b47…27664a

_Deterministic final report assembled from existing LumosKit outputs; this finalize step does not call an agent._

## Case overview

- **Chain**: ethereum (chain_id=1)
- **Tx hash**: `0x31e56b4737649e0acdb0ebb4eca44d16aeca25f60c022cbde85f092bde27664a`
- **Block**: unknown
- **Status**: `pass`
- **Elapsed**: 827.95s (827951 ms)
- **Finding**: RCA blocked

## Pipeline timing

- **Orchestrator wall time**: 148 ms

- **Current stage-duration sum**: 827.95s (827951 ms)

| Stage | Artifact | Duration | Status |
|---|---|---:|---|
| `1` | `cefg` | 171.03s (171028 ms) | `success` |
| `2` | `localize` | 12 ms | `success` |
| `3` | `lift` | 28 ms | `success` |
| `4` | `flow_context` | 1.63s (1632 ms) | `success` |
| `5` | `enrich` | 2.10s (2104 ms) | `success` |
| `6` | `context_pack` | 1 ms | `success` |
| `7` | `asset_delta` | 22 ms | `success` |
| `8` | `poc_sketch` | 10 ms | `success` |
| `9` | `semantic` | 33 ms | `success` |
| `agent_poc` | `agent_poc` | 652.93s (652933 ms) | `success` |
| `rca` | `rca` | 148 ms | `success` |

## Reproduction quality

- **PoC status**: `verified`
- **Forge build**: `pass`
- **Forge test**: `pass`
- **Proof kind**: `economic_proof`
- **RCA status**: `blocked` / `blocked`
- **RCA confidence**: `unknown`

## Economic reproduction

- **Basis**: incident profit oracle usd
- **Verdict**: exact — PoC reproduces 99–101% of incident net loss.
- **Incident net loss**: unknown
- **PoC net reproduced**: $3053553500000.00
- **USD ratio**: 1.000x

## Attack narrative

_No attack-flow narrative artifact was available; see the PoC and RCA artifacts for raw evidence._

## Multi-leg reconciliation

_No asset legs were recorded._

## Root cause analysis

# RCA blocked

- stage: `rca`
- status: `blocked`
- validation: `blocked`
- blocker: PoC did not pass; RCA requires a passing reproduction

Internal artifacts are available under `artifacts/rca/`.

## Artifacts

| Artifact | Bundle path | Status |
|---|---|---|
| Bundle index | `README.md` | generated |
| Machine run summary | `report/run_summary.json` | generated |
| Final integrated report | `report/REPORT.md` | generated |
| RCA | `report/RCA.md` | generated fallback |
| RCA structured report | `report/report.json` | missing optional |
| PoC | `poc/PoC.t.sol` | included |
| PoC base support | `poc/LumosPoCBase.sol` | included |
| Asset deltas | `evidence/asset_deltas.json` | included |
| Fund flows | `evidence/fund_flows.json` | included |
| Asset delta graph | `visuals/asset_deltas.png` | included |
| Fund-flow graph | `visuals/fund_flows.png` | included |
