---
name: no-hallucination
description: Forbids inventing libraries, APIs, endpoints or behaviors; requires verification when unsure.
document_type: rule
severity: blocking
applies_when:
  - writing code that references libraries, methods, endpoints or configurations
max_lines: 45
---

# No Hallucination

## Intent

The model must never fabricate reality. A wrong library name or API signature
compiles into a broken build or, worse, a silent bug.

## Obligations

1. Never invent library names, package versions, API endpoints or function
   signatures.
2. If unsure whether a library or method exists in the current stack, verify
   with the browser/search tool or by reading the installed code before writing.
3. If the answer is unknown, state "I don't know" or "I need more context".
4. Prefer reading the project's lockfile and type definitions over memory.

## How to verify

- Every referenced symbol exists in the project or its dependencies.
- Package versions cited are real and present in the lockfile.

## Signs of violation

- A method that does not exist on the library's API.
- Invented config keys or environment variable names.
- Confidently wrong version numbers.