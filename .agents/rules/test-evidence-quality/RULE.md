---
name: test-evidence-quality
description: Requires tests to prove a business rule or behavior, not just to exercise the pipeline.
document_type: rule
severity: blocking
applies_when:
  - closing any story or feature that claims to be tested
  - evaluating whether a test is meaningful
max_lines: 60
---

# Test Evidence Quality

## Intent

A test is valid evidence only when it would fail if the business rule were
violated. Coverage percentages are not proof.

## Obligations

1. Each test asserts a behavior, a boundary, or an error case that the business
   depends on.
2. Avoid tests that only check framework plumbing, rendering trivia, or
   implementation internals.
3. Prefer a few high-value tests over many shallow ones. Five meaningful tests
   beat forty that always pass.
4. Before closing, run the suite and record the result (pass count, failures,
   coverage relevant to the changed code).

## How to verify

- For each new test: "if I delete the implementation, does this test fail?" If
  no, the test does not prove the rule.
- Mutation check: introduce a deliberate bug, the suite must catch it.

## Signs of violation

- 100% coverage with zero assertion on the core rule.
- Tests that assert trivial rendering ("button exists").
- Tests written to satisfy a coverage gate, not to protect behavior.