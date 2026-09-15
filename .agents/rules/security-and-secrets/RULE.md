---
name: security-and-secrets
description: Forbids committing secrets or introducing known vulnerabilities; requires sensitive data handling.
document_type: rule
severity: blocking
applies_when:
  - writing code that handles credentials, tokens, keys or user data
  - reviewing any diff before commit
max_lines: 55
---

# Security and Secrets

## Intent

Secrets in the repository are a permanent leak: git history never forgets. The
model must never introduce, log or expose credentials.

## Obligations

1. Never commit API keys, tokens, passwords, database URIs or private keys.
   They belong in environment variables or a secret manager.
2. Never log credentials, personal data or sensitive payloads, even in debug.
3. Use parameterized queries/ORMs. Never concatenate user input into SQL.
4. Validate and sanitize all incoming data before processing.
5. Check cookies/tokens for secure flags (`HttpOnly`, `Secure`,
   `SameSite=Strict`) when relevant.
6. If a diff contains a secret, block it and report it before commit.

## How to verify

- `git grep` for the known secret formats finds nothing.
- `.env*` files are gitignored; only `.env.example` is committed.
- No sensitive value in debug or error logs.

## Signs of violation

- Hardcoded keys/tokens visible in a diff.
- `.env` committed to the repository.
- Secrets printed in logs or stack traces.