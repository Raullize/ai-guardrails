---
name: clean-code-readable-names
description: Requires clear, intention-revealing names and domain language over technical labels.
document_type: rule
severity: strongly-recommended
applies_when:
  - naming variables, functions, types, modules, endpoints or database fields
max_lines: 55
---

# Clean Code and Readable Names

## Intent

The code must read like the problem, not like the plumbing. A name is the first
unit of documentation and costs zero runtime.

## Obligations

1. Name things by what they mean in the domain, not by their type or
   implementation (`getUserById` over `getById`, `isActive` over `flag1`).
2. Use precise, consistent terms; avoid synonyms for the same concept.
3. Booleans use affirmative prefixes when it reads naturally (`is`, `has`,
   `should`, `can`).
4. Keep functions small and with a single responsibility expressed by the name.
5. Follow the naming conventions already used in the project.

## How to verify

- A new reader understands the intent without reading the body.
- The same concept always maps to the same name.
- No abbreviations or technical labels leak into the domain API.

## Signs of violation

- Names like `data`, `temp`, `obj`, `flag`, `utils`.
- Type names in variable names (`userObject`, `arrUsers`).
- A function name that describes the implementation instead of the behavior.