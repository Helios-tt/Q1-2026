# LumosKit Run Report — ethereum 0x31e56b47…27664a

_Deterministic final report assembled from existing LumosKit outputs; this finalize step does not call an agent._

## Case overview

- **Chain**: ethereum (chain_id=1)
- **Tx hash**: `0x31e56b4737649e0acdb0ebb4eca44d16aeca25f60c022cbde85f092bde27664a`
- **Block**: 25137572
- **Status**: `pass`
- **Elapsed**: 1068.85s (1068852 ms)
- **Finding**: Bridge retry execution consumed a pre-existing failed-message hash and dispatched a MAPO cross-chain mint payload

## Pipeline timing

- **Orchestrator wall time**: 674.36s (674355 ms)

- **Current stage-duration sum**: 1068.85s (1068852 ms)

| Stage | Artifact | Duration | Status |
|---|---|---:|---|
| `1` | `cefg` | 169.72s (169723 ms) | `success` |
| `2` | `localize` | 11 ms | `success` |
| `3` | `lift` | 28 ms | `success` |
| `4` | `flow_context` | 1.66s (1662 ms) | `success` |
| `5` | `enrich` | 2.36s (2357 ms) | `success` |
| `6` | `context_pack` | 1 ms | `success` |
| `7` | `asset_delta` | 22 ms | `success` |
| `8` | `poc_sketch` | 10 ms | `success` |
| `9` | `semantic` | 34 ms | `success` |
| `agent_poc` | `agent_poc` | 220.65s (220649 ms) | `success` |
| `rca` | `rca` | 674.36s (674355 ms) | `success` |

## Reproduction quality

- **PoC status**: `verified`
- **Forge build**: `pass`
- **Forge test**: `pass`
- **Proof kind**: `economic_proof`
- **RCA status**: `blocked` / `blocked`
- **RCA confidence**: `medium`

## Economic reproduction

- **Basis**: incident profit oracle usd
- **Verdict**: exact — PoC reproduces 99–101% of incident net loss.
- **Incident net loss**: unknown
- **PoC net reproduced**: $3053553500000.00
- **USD ratio**: 1.000x

## Attack narrative

_No standalone `attack_flow.md` was available; this section is assembled from RCA `attack_summary` fields._

| Field | Value |
|---|---|
| Entry function | retryMessageIn(uint256,bytes32,address,uint256,bytes,bytes,bytes) |
| Callback is root cause | false |

## Multi-leg reconciliation

_No asset legs were recorded._

## Root cause analysis

- **Title**: Bridge retry execution consumed a pre-existing failed-message hash and dispatched a MAPO cross-chain mint payload
- **Severity**: `critical`
- **Confidence**: `medium`
- **Violated invariant**: A retried cross-chain mint must be bound to an authenticated, non-replayed, source-backed failed-message record before dispatching mapoExecute and minting destination-chain tokens.

### Final root cause

OmniServiceProxy/Bridge retryMessageIn calls _getStoredMessage, accepts caller-supplied retry calldata when its computed hash equals a pre-existing orderList entry, marks the order consumed, and dispatches _transferIn to MAPO mapoExecute. MAPO then executes MORC20Core._execute INTERCHAIN_TRANSFER and MORC20Token._createTokenTo, minting the decoded amount to the decoded receiver. The failed invariant under investigation is that a retry should only execute a cross-chain mint when the stored failed-message record is proven to correspond to a valid, non-replayed, source-backed cross-chain entitlement. The current artifacts prove the stored retry hash was consumed and the mint occurred, but not the prior provenance or validity of that stored hash, so the exact invalid prior setup remains partial.

### Affected contracts

| Address | Name | Role | Implementation |
|---|---|---|---|
| `0x0000317bec33af037b5fab2028f52d14658f6a56` | `OmniServiceProxy / Bridge` | `primary retry authorization contract` | `0x12bfb3b58ad02a0df40ee7186d26266c52d0109c` |
| `0x66d79b8f60ec93bfce0b56f5ac14a2714e509a99` | `MORC20PermitToken` | `minted asset contract` | `—` |

### Recommended fixes

- Bind retryMessageIn to full authenticated failed-message metadata, including original proof/order provenance, immutable payload fields, source chain/address, target, amount, and replay status, instead of accepting only a caller-recomputed hash match.
- Reject retries unless the stored failed-message record was created by a verified messageIn execution path and has not already been consumed.
- Add MAPO receive-side mint limits or supply/cap checks before MORC20Token._createTokenTo mints decoded cross-chain amounts.

### Limitations

- prior_state_provenance_gap: the artifacts prove Bridge consumed a pre-existing orderList hash but do not include the prior transaction or decoded provenance that created that hash.
- invalid_precondition: without the prior writer/provenance, the stored hash cannot be responsibly labeled forged, unauthorized, replayed, or legitimate from the supplied closed-world artifacts.
- The exact reason the stored retry record was economically invalid cannot be proven closed-world from the supplied artifacts, so analysis_status is partial rather than complete.
- artifacts/agent_poc/attack_flow.md was not present/readable; the analysis used verified PoC result, PoC.t.sol, rca_frontier, trace facts, RPC observations, and victim source instead.

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
