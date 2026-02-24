# SynapLogic Incident

| Field | Value |
|-------|-------|
| Date | 2026-01-19 |
| Chain | 8453 |
| Block | 41038634 |
| Tx | `0xc54c00046364b6e889db18c73beee9b81df6b5ca822b6d262b3d30cdf376c4b1` |
| Attacker | `0x3Aa8bb3A19EECD229Cb33fbc03Ff549473e30F38` |
| Target | `0x39F36e2E58f36F7E5c17784847fd07Da1fEE1a32` |
| Gas Used | 1223958 |
| Logs | 37 |

## Auditors
- [ ] @2hyuk

## Status
- [x] Workspace initialized
- [x] Analysis complete
- [x] PoC complete

## Vulnerability Summary
- The vulnerable path is `0x670a3267` (`swapExactTokensForETHSupportingFeeOnTransferTokens`).
- Critical input validation was missing for whitelist-like payout parameters.
- Native token payout accounting did not enforce `total_payout <= msg.value`.
- The attacker used long address/boolean arrays to over-distribute native token while still minting SYP.

## PoC Strategy
- Fork Base at block `41038633`.
- Replay PoC embeds exact exploit tx init code in-file and executes it via `create(...)`.
- This reproduces the full real attack sequence (flash -> callback -> vulnerable call -> withdraw).
- A separate step-by-step PoC reproduces the same attack path with explicit phases and crafted arrays.

## Reproduction
```bash
forge test --match-path test/2026-01-19_SynapLogic/SynapLogic.t.sol -vvvv
forge test --match-path test/2026-01-19_SynapLogic/SynapLogicStepByStep.t.sol -vvvv
```

Expected key output:
```text
[PASS] testExploit()
Before Balance (ETH): 0.000000000000000000
After Balance (ETH): 27.639653402053937499
Profit (ETH): 27.639653402053937499
```

## Trace Highlights
```text
1) attacker helper :: drainAll()
   - Entry point that orchestrates flash + vulnerable swap + final cashout in one flow.
2) SideShift wallet :: flash(recipient=helper, amount0=13.830195892125000001 WETH)
   - Provides temporary liquidity so attacker does not need initial capital.
3) helper :: uniswapV3FlashCallback(...)
   - Callback is where the attacker controls execution order before repayment.
4) helper -> WETH :: withdraw(13.830195892125000001 WETH)
   - Converts WETH to native ETH because the vulnerable function consumes `msg.value`.
5) helper -> target(0x39F3...) :: 0x670a3267{value: 13.82328425 ETH}(crafted long arrays)
   - Core exploit: manipulated whitelist-like arrays trigger over-distribution of native token while minting SYP.
6) helper :: withdraw(attacker) -> receives 27.639653402053937499 ETH
   - After repaying flash costs, net native token remains and is transferred out as profit.
```

## 공격 흐름 요약 (KR)
- 공격자는 `drainAll()` 진입점에서 플래시 대출, 취약 함수 호출, 출금까지 한 번에 실행한다.
- `flash(...)`로 13.83 WETH를 빌려 초기 자본 없이 공격을 시작한다.
- `uniswapV3FlashCallback(...)` 구간에서 실행 순서를 공격자 의도대로 제어한다.
- `WETH.withdraw(...)`로 WETH를 ETH로 바꿔, `msg.value` 기반 취약 경로를 통과시킨다.
- `0x670a3267` 호출 시 긴 주소/불리언 배열을 주입해 native token을 과분배받고 SYP 민팅도 동시에 획득한다.
- 플래시 비용을 정산한 뒤 `withdraw(attacker)`로 순이익 `27.639653402053937499 ETH`를 회수한다.

## Workspace
```bash
git fetch origin && git checkout incident/2026-01-19_SynapLogic
forge test -vvv
```
