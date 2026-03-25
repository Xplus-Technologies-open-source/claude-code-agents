---
name: solidity-security
description: Smart contract security audit checklist — used by CyberSentinel when reviewing Solidity/blockchain projects
---

# Solidity Security Audit

Load this skill ONLY when `.sol` files are detected in the project.

## Critical Vulnerabilities

### Reentrancy
- [ ] External calls are made AFTER state changes (checks-effects-interactions)
- [ ] `ReentrancyGuard` (OpenZeppelin) used on functions with external calls
- [ ] No cross-function reentrancy via shared state

### Access Control
- [ ] `onlyOwner` / role-based modifiers on sensitive functions
- [ ] No unprotected `selfdestruct`, `delegatecall`, or proxy upgrade functions
- [ ] Multi-sig for critical operations (treasury, upgrades)

### Integer Overflow/Underflow
- [ ] Solidity 0.8+ used (built-in overflow checks) OR SafeMath library
- [ ] Unchecked blocks justified and reviewed

### Flash Loan Attacks
- [ ] Price oracles use TWAP (time-weighted) not spot prices
- [ ] No single-block price manipulation possible
- [ ] Liquidity checks before large operations

### Front-Running
- [ ] Commit-reveal for sensitive operations
- [ ] Slippage protection on swaps
- [ ] No MEV-exploitable transaction ordering dependencies

## Gas Optimization (Secondary)
- Avoid storage reads in loops (cache in memory)
- Use `calldata` instead of `memory` for read-only function parameters
- Pack struct fields to minimize storage slots
- Use `custom errors` instead of `require` strings (Solidity 0.8.4+)

## Testing Requirements
- 100% branch coverage for financial functions
- Fuzz testing with Foundry or Echidna
- Formal verification for core invariants
- Fork testing against mainnet state
