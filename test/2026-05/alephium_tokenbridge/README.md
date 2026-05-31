# LumosKit Run Report — ethereum 0x06cc0f36…24c6b4

_Deterministic final report assembled from existing LumosKit outputs; this finalize step does not call an agent._

## Case overview

- **Chain**: ethereum (chain_id=1)
- **Tx hash**: `0x06cc0f36159d7094359d88fe1d43cda601e8644282ba305c5ffbd013b524c6b4`
- **Block**: 25207242
- **Status**: `pass`
- **Elapsed**: 303.06s (303059 ms)
- **Finding**: Root cause blocked by failed PoC static validation gate

## Signal context

- **Protocol claim**: Alephium TokenBridge
- **Detector source**: hack-detector:twitter:BlackHartInc
- **Detected at**: 2026-05-30T15:04:45Z
- **Published at**: 2026-05-30T15:04:45Z
- **Original alert**: https://x.com/BlackHartInc/status/2060739195883139458
- **Source id**: tw:2060739195883139458
- **Lumos signal id**: manual-blackhart-2060739195883139458
- **Incident group id**: manual-alephium-tokenbridge-2026-05-30
- **Claimed loss**: 815000

Detector summary:

> Alephium TokenBridge on Ethereum was drained for approximately $815K. The incident minted 13.76M unbacked wrapped ALPH and unlocked USDT, USDC, WBTC, and WETH custody reserves through forged bridge approvals attributed to compromised guardian authority.


## Pipeline timing

- **Orchestrator wall time**: 173.51s (173509 ms)

- **Current stage-duration sum**: 303.06s (303059 ms)

| Stage | Artifact | Duration | Status |
|---|---|---:|---|
| `1` | `cefg` | 119.84s (119842 ms) | `success` |
| `2` | `localize` | 19 ms | `success` |
| `3` | `lift` | 52 ms | `success` |
| `4` | `flow_context` | 1.71s (1706 ms) | `success` |
| `5` | `enrich` | 2.01s (2007 ms) | `success` |
| `6` | `context_pack` | 2 ms | `success` |
| `7` | `asset_delta` | 22 ms | `success` |
| `8` | `poc_sketch` | 19 ms | `success` |
| `9` | `semantic` | 63 ms | `success` |
| `agent_poc` | `agent_poc` | 5.82s (5818 ms) | `success` |
| `rca` | `rca` | 173.51s (173509 ms) | `success` |

## Reproduction quality

- **PoC status**: `verified`
- **Forge fmt**: `pass`
- **Forge build**: `pass`
- **Forge test**: `pass`
- **Proof kind**: `economic_proof`
- **RCA status**: `blocked` / `blocked`
- **RCA confidence**: `low`

## Economic reproduction

- **Basis**: incident profit oracle usd
- **Verdict**: exact — PoC reproduces 99–101% of incident net loss.
- **Incident net loss**: unknown
- **PoC net reproduced**: $547644.05
- **USD ratio**: 1.000x

## Attack narrative

_No standalone `attack_flow.md` was available; this section is assembled from RCA `attack_summary` fields._

| Field | Value |
|---|---|
| Callback is root cause | false |

## Multi-leg reconciliation

_No asset legs were recorded._

## Root cause analysis

- **Title**: Root cause blocked by failed PoC static validation gate
- **Severity**: `low`
- **Confidence**: `low`
- **Violated invariant**: unknown; not analyzed because the verified-PoC gate failed

### Final root cause

No root-cause claim is made. The economic PoC run reports pass statuses for execution, build, test, economic reproduction, and proof_kind, but artifacts/agent_poc/result.json has static_validation.status=fail. Under the required LumosKit gate, treating this as a verified economic proof would be invalid and RCA would be speculation.

### Recommended fixes

- Resolve the PoC static-validation failure and rerun RCA; no contract patch recommendation is responsible until the economic proof gate is satisfied.

### Limitations

- PoC unverified — root cause analysis would be speculation
- static_validation.status is fail in artifacts/agent_poc/result.json
- No source or pseudocode branch was selected as root cause because analysis was blocked before frame-level reasoning

## Artifacts

| Artifact | Bundle path | Status |
|---|---|---|
| Bundle index | `README.md` | generated |
| Machine run summary | `report/run_summary.json` | generated |
| Final integrated report | `report/REPORT.md` | generated |
| RCA | `report/RCA.md` | included |
| RCA structured report | `report/report.json` | included |
| PoC | `poc/PoC.t.sol` | included |
| PoC base support | `poc/LumosPoCBase.sol` | included |
| Asset deltas | `evidence/asset_deltas.json` | included |
| Fund flows | `evidence/fund_flows.json` | included |
| Asset delta graph | `visuals/asset_deltas.png` | included |
| Fund-flow graph | `visuals/fund_flows.png` | included |
