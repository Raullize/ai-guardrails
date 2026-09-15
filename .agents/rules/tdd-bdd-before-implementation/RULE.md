---
name: tdd-bdd-before-implementation
description: Requires a failing test (unit or behavioral/BDD) before production code when the behavior is testable.
document_type: rule
severity: blocking
applies_when:
  - implementing any behavior that can be verified by a test
  - fixing a bug with a reproducible case
max_lines: 60
---

# TDD / BDD Before Implementation

## Intent

Guarantee that every piece of behavior is specified by a test before the
production code exists. The test is the executable specification of the
requirement.

## Obligations

1. Write a test that fails for the right reason before writing the production
   code for that behavior.
2. Use the testing framework already present in the project. Do not invent a
   second test stack.
3. Run the test and confirm it fails before implementing. Record the failure.
4. Implement the minimum code that makes the test pass.
5. Run the full suite to prove no regression.

## How to verify

- There is a commit sequence where a failing test appears before the
  implementation commit.
- `git log --oneline` of the feature shows test-first ordering.
- The test fails when the implementation is removed.

## Signs of violation

- Production code exists with no test covering it.
- A test was added after the implementation to "make coverage numbers go up".
- The suite was skipped or ignored to merge.