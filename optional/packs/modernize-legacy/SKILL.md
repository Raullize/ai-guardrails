---
name: "modernize-legacy"
description: "Safely updates outdated code to modern standards (e.g., JS to TS, Class to Hooks). Invoke when the user asks to modernize, update, or convert old code."
---

# Legacy Code Modernizer

<instructions>
When converting or modernizing legacy code, you MUST ensure that the logic and behavior remain strictly identical while upgrading the syntax and architecture:

1. **React Class Components to Hooks:**
   - Convert `componentDidMount`, `componentDidUpdate`, and `componentWillUnmount` carefully into appropriate `useEffect` hooks, paying extreme attention to dependency arrays.
   - Convert `this.state` to multiple `useState` hooks or a single `useReducer` if the state is complex.

2. **JavaScript to TypeScript:**
   - Infer types from the existing usage. Do not just use `any`.
   - Create clear `interface` or `type` definitions for objects and function parameters.
   - If a library lacks types, suggest installing `@types/library-name`.

3. **Promises / Callbacks to Async/Await:**
   - Convert `.then().catch()` chains into clean `try/catch` blocks using `async/await`.
   - Avoid nesting `try/catch` blocks excessively.

4. **Safety First:**
   - Before rewriting, summarize the core business logic you identified to ensure you haven't missed any edge cases.
   - NEVER change the names of exported functions or components, to avoid breaking imports elsewhere in the project.
</instructions>