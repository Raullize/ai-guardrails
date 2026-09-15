---
name: ralph-loop
description: Operational prompt for the Perceive, Orient, Decide, Act and Record cycle applied to a story of the official kanban.
document_type: prompt
applies_when:
  - starting or resuming the execution of a story
  - deciding which skill triggers the next action
max_lines: 100
---

# Ralph Loop

Execution cycle of a story. One pass per relevant action; never skip `Record` —
it is what makes the next pass possible.

```
PERCEIVE -> ORIENT -> DECIDE -> ACT -> RECORD
    ^                                        |
    +----------------------------------------+
```

## 1. Perceive

Read, in this order, without assuming memory:

- the official kanban (`docs/backlog/KANBAN.md`) — what the next
  demand is
- the story file
- `docs/tasks/[KEY]/progress.txt` — what has already been done
- related deliveries in `docs/deliveries/`
- rules cited by the current stage

Output: one sentence about the real state, not the expected state.

## 2. Orient

Compare:

| Dimension | Question |
| --- | --- |
| Acceptance criteria | What is still not proven? |
| Rules | Which constraint applies to the next action? |
| Risks | What can go wrong and at what cost? |
| Dependencies | Is something outside my reach missing? |

## 3. Decide

Choose **one** next action and the responsible skill from `.agents/skills/`.
One action per pass. Two simultaneous fronts violate the WIP rule.

## 4. Act

Execute the action with the smallest possible unit of change. If new work
emerges during the action, it is not done now: it becomes a story in the
`Backlog`.

## 5. Record

Always, and at the same moment:

- a line in `docs/tasks/[KEY]/progress.txt` with phase, action and evidence;
- an update of the implementation plan if it changed;
- an update of the official kanban if the state changed;
- a document in `docs/deliveries/` at closing;
- a semantic commit and a tag on the same hash at closing.

## Loop exit criteria

The loop ends when the story is in `Done` with evidence, or when it has been
returned to `Ready` with the reason recorded. It does not end out of tiredness
nor because it "looks ready".