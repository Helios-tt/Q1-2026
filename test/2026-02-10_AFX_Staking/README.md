# AFX Staking Incident

| Field | Value |
|-------|-------|
| Date | 2026-02-10 |
| Chain | 56 |
| Block | 80395411 |
| Tx | `0x380cd298a607d4422edc640b7f5a907ec0792841ee5fc963d265b1189397c905` |
| Attacker | `0x236f08d8962e1F29700e3D91009bfa8D37D71e53` |
| Target | `0x146933F2692F5fF3b62441AB3C2a65dDCAca753c` |
| Gas Used | 1090943 |
| Logs | 64 |

## Auditors
- [ ] @n4mchun

## Status
- [x] Workspace initialized
- [x] Analysis complete
- [x] PoC complete

## PoC Strategy
- Fork base at block `80395410`.

## 공격 흐름 요약 (KR)
---
공격자는 취약한 컨트랙트의 addLiquidityUsdt라는 숨겨진 함수를 호출하여 해당 컨트랙트에 미리 approve되어있던 Target의 AHT를 가져와 AFX-AHT 풀에 유동성을 공급한 후 상승한 AHT의 가치를 이용해 자신의 AHT를 AFX로 스왑하여 이득을 얻어냄.

## Workspace
```bash
git fetch origin && git checkout incident/2026-02-10_AFX-Staking
forge test -vvv
```

## Expected key output:
```
[PASS] testExploit() (gas: 1179121)
Logs:
  Before Balance (BNB): 0.000000000000000000
  After Balance (BNB): 17.003192604590205356
  Profit (BNB): 17.003192604590205356
```