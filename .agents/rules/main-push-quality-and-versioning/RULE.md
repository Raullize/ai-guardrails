---
name: main-push-quality-and-versioning
description: Blocks pushing to main without green tests/gates and requires semantic commit and tag on the same hash.
document_type: rule
severity: blocking
applies_when:
  - merging to the main branch
  - creating a release or delivery
  - pushing after a story is closed
max_lines: 60
---

# Main Push Quality and Versioning

## Intent

`main` (or the protected trunk) is the release state. Nothing enters it without
evidence, and every release is uniquely identified.

## Obligations

1. No push to `main` while tests or gates are failing.
2. A delivery commit is selective: stage only the files that belong to the
   story. `git add -A` and `git commit -am` are forbidden for delivery commits.
3. Commit messages follow the project convention (see `commit-conventions`).
4. Every release receives a semantic version tag pointing to the exact closing
   commit.
5. Push, tag and release only with explicit human authorization. Never
   automatically.

## How to verify

- CI runs green on the merge commit.
- `git tag --points-at HEAD` matches the closing commit of the story.
- Commit content maps to exactly one story.

## Signs of violation

- Red CI merged or force-pushed past.
- Tag pointing to a different commit than the delivered code.
- Mixed-file commits ("misc fixes").
- Unauthorized automatic push or tag.