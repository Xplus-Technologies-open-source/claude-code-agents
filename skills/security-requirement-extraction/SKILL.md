---
name: security-requirement-extraction
description: Extract security requirements from threat models and business context — used by CyberSentinel to define what security controls a project MUST have
---

# Security Requirement Extraction

## Data Classification Framework

Classify every data type the application handles:

| Level | Examples | Required Controls |
|-------|---------|-------------------|
| PUBLIC | Marketing content, public profiles | Integrity checks |
| INTERNAL | Internal docs, non-sensitive configs | Access control, audit logging |
| CONFIDENTIAL | PII, email, phone, address | Encryption at rest + transit, access control, audit, retention limits |
| RESTRICTED | Passwords, financial data, health records, SSN | All of CONFIDENTIAL + MFA, field-level encryption, strict access, DLP |

## Threat Model (STRIDE)

For each entry point, assess:

| Threat | Question | Control |
|--------|----------|---------|
| **S**poofing | Can someone impersonate a user? | Strong authentication, MFA |
| **T**ampering | Can someone modify data in transit/rest? | Input validation, integrity checks, TLS |
| **R**epudiation | Can someone deny performing an action? | Audit logging, non-repudiation |
| **I**nformation Disclosure | Can someone access unauthorized data? | Authorization, encryption, data classification |
| **D**enial of Service | Can someone make the system unavailable? | Rate limiting, resource limits, CDN |
| **E**levation of Privilege | Can someone gain higher permissions? | RBAC, least privilege, input validation |

## Requirement Extraction Process

1. List all data types and classify them
2. Map each data type to entry points (where it enters/exits the system)
3. Apply STRIDE to each entry point
4. For each identified threat, define a testable security requirement
5. Prioritize by: data sensitivity x likelihood x impact

## Output Format

Each requirement should be:
```
REQ-SEC-{NNN}: {Title}
Data: {what data this protects}
Threat: {STRIDE category}
Control: {specific implementation requirement}
Test: {how to verify this is implemented correctly}
Priority: {CRITICAL | HIGH | MEDIUM | LOW}
```
