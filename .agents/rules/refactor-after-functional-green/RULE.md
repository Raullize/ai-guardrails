---
name: refactor-after-functional-green
description: Requires cleanup and refactoring only after the functional/behavioral tests are green.
document_type: rule
severity: blocking
applies_when:
  - the functional tests pass and the code still has duplication, dead code, or unclear names
  - before closing a story that touched production code
max_lines: 55
---

# Refactor After Functional Green

## Intent

Keep the order: make it work, then make it clean. Refactoring before the
behavior is proven makes debugging ambiguous.

## Obligations

1. Only refactor code whose functional/behavioral tests are green.
2. Refactor in small, safe steps: run the suite after each step.
3. After refactoring, the suite must still be green and behavior unchanged.
4. Record that the refactoring step happened and that tests passed after it.

## How to verify

- The history shows tests green before the refactoring commits.
- No refactoring commit contains a behavioral change.
- The suite is green at the end of the refactoring sequence.

## Signs of violation

- Refactoring mixed with the behavior change in the same commit.
- Refactoring performed while tests were already failing.
- "I'll fix it later" duplicated code shipped with a green suite.