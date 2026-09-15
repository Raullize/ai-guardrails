---
name: packs-indice
description: Index of the optional stack-specific skill packs. They are NOT part of the core; install them only when relevant to the project's stack.
document_type: index
applies_when:
  - deciding which packs to install in a project
  - adding a new stack-specific pack
max_lines: 80
---

# Optional Packs

Stack-specific skills live here, outside the generic core. The init script
(`scripts/init.sh`) copies the selected packs into `.agents/skills/` of the
target project.

| Pack | Stack | When to install |
| --- | --- | --- |
| [docker-expert](./docker-expert/SKILL.md) | Docker / containers | Project uses Docker, compose, or needs image optimization |
| [humanize-frontend](./humanize-frontend/SKILL.md) | Frontend (React, Vue, HTML) | Project has a UI layer and wants to avoid generic AI visuals |
| [modernize-legacy](./modernize-legacy/SKILL.md) | Any legacy code | Converting old code (JS→TS, Class→Hooks, callbacks→async) |
| [refactor-react](./refactor-react/SKILL.md) | React / Next.js | Refactoring React/Next components |
| [seo-optimizer](./seo-optimizer/SKILL.md) | Frontend / SEO | SEO and accessibility optimization |
| [ui-to-code](./ui-to-code/SKILL.md) | Frontend / Tailwind | Converting mockups into frontend code |

## Mandatory structure of a pack

```
optional/packs/<pack-name-kebab-case>/
└── SKILL.md                  ← main file, ALWAYS with this name
```

Same skill requirements as the core: frontmatter with `name` and `description`,
single responsibility, verifiable criteria, explicit boundary.

## How to add a new pack

1. Create `optional/packs/<name>/SKILL.md` with the required frontmatter.
2. Add it to the index table above.
3. No change needed in `init.sh` unless the pack requires extra files.