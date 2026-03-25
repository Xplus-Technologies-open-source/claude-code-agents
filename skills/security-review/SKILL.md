---
name: security-review
description: Security review methodology and checklist — primary knowledge base for CyberSentinel agent when auditing application security
---

# Security Review Methodology

## Pre-Audit Checklist

Before reviewing any code, determine:
1. What data does this application handle? (PII, financial, health, credentials)
2. Who are the users? (public, authenticated, admin, API consumers)
3. What are the trust boundaries? (client/server, server/DB, microservice boundaries)
4. What compliance requirements apply? (GDPR, CCPA, HIPAA, PCI-DSS, SOC2)

## Authentication Review

- [ ] Passwords hashed with bcrypt/argon2/scrypt (cost >= 10 for bcrypt)
- [ ] JWT: RS256 or ES256 algorithm enforced (not HS256 with weak secret)
- [ ] JWT expiration < 1 hour, refresh token rotation implemented
- [ ] Session tokens: httpOnly + Secure + SameSite=Strict
- [ ] Sessions regenerated after login/privilege change
- [ ] Sessions invalidated server-side on logout (not just client-side token deletion)
- [ ] Account lockout or exponential backoff after failed attempts
- [ ] MFA available for admin and sensitive operations
- [ ] No account enumeration (login/register responses are identical for existing/non-existing users)
- [ ] Password reset tokens are single-use, time-limited (< 1 hour), and cryptographically random

## Authorization Review

- [ ] Every endpoint has explicit permission checks (not just auth presence)
- [ ] IDOR testing: change resource IDs in requests to access other users' data
- [ ] Horizontal privilege: user A cannot access user B's resources
- [ ] Vertical privilege: regular user cannot access admin endpoints
- [ ] CORS: specific origins, not `*` for authenticated APIs
- [ ] CSRF: state-changing requests protected with tokens or SameSite cookies

## Input Validation Review

- [ ] All user input validated at the server boundary (never trust client validation alone)
- [ ] SQL queries fully parameterized (including dynamic ORDER BY, LIMIT, table names)
- [ ] No `eval()`, `exec()`, `Function()`, `pickle.loads()` with user-controlled input
- [ ] File upload: type validation by magic bytes (not just extension), size limits, stored outside webroot
- [ ] Path parameters: no directory traversal (`../` stripped or rejected)
- [ ] HTML output: all user content escaped (no raw HTML rendering without sanitization)
- [ ] URL parameters: validated against allowlist for redirect endpoints (open redirect prevention)

## Secrets Management Review

- [ ] No hardcoded secrets in source code (API keys, passwords, connection strings)
- [ ] `.env` files listed in `.gitignore`
- [ ] Git history checked for accidentally committed secrets
- [ ] Secrets loaded from environment variables or vault, never from config files in repo
- [ ] Different secrets for development, staging, and production environments
- [ ] Secret rotation mechanism exists (keys can be changed without code deployment)

## Dependency Review

- [ ] `npm audit` / `pip audit` / `cargo audit` reports zero critical/high vulnerabilities
- [ ] Lock file (package-lock.json, poetry.lock, Cargo.lock) committed and up to date
- [ ] No deprecated packages with known vulnerabilities
- [ ] No packages with suspicious postinstall scripts
- [ ] Dependencies pinned to exact versions (not floating ranges) in production

## Infrastructure Review

- [ ] TLS 1.2+ enforced, weak cipher suites disabled
- [ ] Security headers present: HSTS, CSP, X-Content-Type-Options, X-Frame-Options
- [ ] Error responses do not expose stack traces, SQL queries, or internal paths
- [ ] Debug mode disabled in production
- [ ] Rate limiting on authentication endpoints, API endpoints, and file upload
- [ ] Docker containers running as non-root user
- [ ] Database connections use SSL
