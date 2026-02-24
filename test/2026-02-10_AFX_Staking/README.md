# AFX Staking Incident

| Field | Value |
|-------|-------|
| Date | 2026-02-10 |
| Chain | 56 |
| Block | 80395411 |
| Tx | `0x380cd298a607d4422edc640b7f5a907ec0792841ee5fc963d265b1189397c905` |
| Attacker | `0x236f08d8962e1F29700e3D91009bfa8D37D71e53` |
| Target | `0x129b803F5E8e36e2d6e705D84BBe7995b02FC0CB` |
| Gas Used | 1090943 |
| Logs | 64 |

## Auditors
- [ ] @n4mchun

## Status
- [x] Workspace initialized
- [ ] Analysis complete

## Workspace
```bash
git fetch origin && git checkout incident/2026-02-10_AFX-Staking
forge test -vvv
```
