# LumosKit Run Report — ethereum 0x06cc0f36…24c6b4

_Deterministic final report assembled from existing LumosKit outputs; this finalize step does not call an agent._

## Case overview

- **Chain**: ethereum (chain_id=1)
- **Tx hash**: `0x06cc0f36159d7094359d88fe1d43cda601e8644282ba305c5ffbd013b524c6b4`
- **Block**: 25207242
- **Status**: `pass`
- **Elapsed**: 379.34s (379337 ms)
- **Finding**: Bridge message verification allowed TokenBridge to mint unbacked ALPH to the attacker

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

- **Orchestrator wall time**: 248.45s (248448 ms)

- **Current stage-duration sum**: 379.34s (379337 ms)

| Stage | Artifact | Duration | Status |
|---|---|---:|---|
| `1` | `cefg` | 120.33s (120329 ms) | `success` |
| `2` | `localize` | 22 ms | `success` |
| `3` | `lift` | 57 ms | `success` |
| `4` | `flow_context` | 1.66s (1663 ms) | `success` |
| `5` | `enrich` | 2.68s (2683 ms) | `success` |
| `6` | `context_pack` | 2 ms | `success` |
| `7` | `asset_delta` | 22 ms | `success` |
| `8` | `poc_sketch` | 19 ms | `success` |
| `9` | `semantic` | 65 ms | `success` |
| `agent_poc` | `agent_poc` | 6.03s (6027 ms) | `success` |
| `rca` | `rca` | 248.45s (248448 ms) | `success` |

## Reproduction quality

- **PoC status**: `verified`
- **Forge fmt**: `pass`
- **Forge build**: `pass`
- **Forge test**: `pass`
- **Proof kind**: `economic_proof`
- **RCA status**: `partial` / `partial`
- **RCA confidence**: `medium`

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
| Entry function | completeTransfer(bytes) / selector 0xc6878519 |
| Attacker callbacks | implementation() callback observed in frames 9 and 13 |
| Callback is root cause | false |

## Multi-leg reconciliation

_No asset legs were recorded._

## Root cause analysis

- **Title**: Bridge message verification allowed TokenBridge to mint unbacked ALPH to the attacker
- **Severity**: `critical`
- **Confidence**: `medium`
- **Violated invariant**: Wrapped ALPH may be minted only after a valid guardian-approved, authorized-emitter, exact-recipient/amount, non-replayed cross-chain transfer message has been verified.

### Final root cause

TokenBridge.completeTransfer(bytes) accepted attacker-supplied VM bytes as a valid cross-chain transfer entitlement after Wormhole.parseAndVerifyVM(bytes), then used its owner authority over BridgeToken to mint ALPH to the attacker. The ERC20 mint primitive is owner-gated and matches the observed totalSupply/balance increase, so the root issue is upstream message validation/entitlement rather than transferFrom, allowance, flash loan, or profit routing. The exact failed verifier branch is not source-visible because Wormhole implementation 0x092d8e03f672300359e035ba174a922ed414123e is missing from victim_sources, so this RCA is partial.

### Affected contracts

| Address | Name | Role | Implementation |
|---|---|---|---|
| `0x01e82b67367de9f805e55de730d5007a752912a8` | `Wormhole` | `primary message verifier proxy` | `0x092d8e03f672300359e035ba174a922ed414123e` |
| `0x579a3bde631c3d8068cbfe3dc45b0f14ec18dd43` | `TokenBridge` | `bridge consumer that called verification and minted ALPH` | `0x0f843945075df4ea9c8a21f0e0ccfd5eb073eeab` |
| `0x590f820444fa3638e022776752c5eef34e2f89a6` | `BridgeToken ALPH` | `downstream owner-gated token mint effect` | `0xdeb8c2c57c7de48d3ad5a980be3dd23868262b6a` |

### Recommended fixes

- In Wormhole.parseAndVerifyVM and TokenBridge.completeTransfer, require valid guardian quorum/signatures, authorized emitter chain/contract, exact recipient and amount binding, and non-replay before calling BridgeToken.mint.
- Keep BridgeToken.mint restricted to the bridge owner, but add consumer-side invariant checks that fail closed if message verification returns malformed, stale, duplicate, or unauthorized payloads.

### Limitations

- missing_assumption: exact Wormhole signature/quorum/payload-validation branch is not source-visible in supplied victim_sources.
- The RCA cannot responsibly name the precise line-level verifier bug in implementation 0x092d8e03f672300359e035ba174a922ed414123e.
- artifacts/agent_poc/attack_flow.md is absent from the manifest; PoC flow evidence is taken from PoC.t.sol and pseudocode instead.
- No semantic label is assigned to the post-verification storage write because source/layout evidence is unavailable.

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
