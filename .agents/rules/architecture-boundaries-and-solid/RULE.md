---
name: architecture-boundaries-and-solid
description: Protects module boundaries, SOLID principles and dependency direction regardless of stack.
document_type: rule
severity: blocking
applies_when:
  - introducing a new module, contract, dependency or package
  - evaluating a code review with architectural impact
max_lines: 60
---

# Architecture Boundaries and SOLID

## Intent

The architecture is the set of rules that are hard to change later. Protect the
boundaries before they rot; do not fix them after the fact.

## Obligations

1. Dependencies point inward: domain/use-cases do not depend on
   frameworks, drivers or infrastructure details.
2. One module, one responsibility. Do not create god classes or all-purpose
   folders (`utils/`, `helpers/` as a dump).
3. Communicate across boundaries through contracts (interfaces, ports, types),
   not through concrete implementations.
4. Do not let a new framework/package reach every layer. Contain it.
5. Keep changes local: a change in one boundary should not ripple through the
   codebase.

## How to verify

- Dependency graph has no cycles.
- Infrastructure modules can be replaced without touching the domain.
- New code lives in the module that owns the responsibility.

## Signs of violation

- A domain entity importing a framework/DTO/ORM type.
- Circular imports between modules.
- One file mixing HTTP, business rules and persistence.
- A change in a library forcing edits in unrelated modules.