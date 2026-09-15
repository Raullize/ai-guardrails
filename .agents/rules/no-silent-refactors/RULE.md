---
name: no-silent-refactors
description: Forbids modifying code that was not requested, even if the model knows a "better" way.
document_type: rule
severity: blocking
applies_when:
  - making any change to existing code
max_lines: 45
---

# No Silent Refactors

## Intent

Change only what was requested. Unrequested reformatting, renaming or
"improvements" add review noise, increase merge risk and violate the user's
intent.

## Obligations

1. Only modify the code requested by the user.
2. Never rewrite, reformat or "improve" surrounding code (`let` → `const`,
   standard functions → arrows, whitespace) unless explicitly asked to
   refactor.
3. Respect the existing code style, even if you know a "better" way.
4. If you spot a real problem in surrounding code, report it, do not change it.

## How to verify

- Diff contains only the lines required by the request.
- No formatting-only or rename-only hunks outside the scope.

## Signs of violation

- Diff has more unrelated lines than requested lines.
- Renaming variables in the same commit as a fix.
- "While I was here, I..." refactors without authorization.