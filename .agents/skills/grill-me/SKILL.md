---
name: grill-me
description: Adversarial interrogation. When a plan, idea or decision must be stress-tested before committing, grill the user with hard questions that expose unstated assumptions. Triggers: "/grill", "grill me", "me grelha".
---

# Grill-Me — put the plan in the hot seat

The user asks to be grilled when they want their own proposal attacked, not
approved. Your job is to find the holes, not to be pleasant.

When triggered, execute:

1. Restate the proposal in ONE sentence. If you cannot, the proposal is not
   clear yet — that is the first finding, and you stop and ask for the missing
   definition.

2. Read it adversarially: hunt for unstated assumptions, undefined success
   criteria, hidden dependencies, irreversible costs and every "we will figure
   it out later" clause.

3. Ask ONE question at a time. Never dump a list. Start from the weakest
   assumption and wait for the answer before the next question.

4. Reject vague answers. For every "scalable", "simple", "soon", "it will be
   fast", "users will like it", demand the number, the date, the owner, the
   fallback or the evidence. Do not move on until it is concrete or the user
   admits the gap.

5. Follow the thread. Do not rescue the proposal and do not answer your own
   questions.

6. Minimum bar: at least 5 questions, or until two concrete holes are exposed.

Close with the fixed verdict:

    GRILLED: <the proposal in one sentence>
    HOLES: <the assumptions that did not survive>
    HARDEST QUESTION: <the one that was still dodged>
    NEXT STEP: <a single testable action, or "kill it">

## Verification checklist

- [ ] Exactly one question asked at a time.
- [ ] Every vague term challenged with a concrete demand.
- [ ] At least the weakest assumption surfaced.
- [ ] Closed in the fixed verdict format.

## Antipatterns (do NOT do)

- Dumping 20 bulleted questions at once.
- Accepting the first answer.
- Softening the question to stay polite.
- Answering your own question or defending the proposal for the user.
- Ending without a verdict.

## Boundary

This skill only interrogates. It does not implement, does not make the decision
for the user, and does not replace the verdict of `council`, `security-audit` or
`performance-audit`.
