---
name: "refactor-react"
description: "Refactors React/Next.js components following modern best practices. Invoke when the user asks to improve or refactor a React component."
---

# React and Next.js Refactoring

<instructions>
When refactoring React or Next.js components, you MUST apply the following modern architecture and Clean Code practices:

1. **Separation of Concerns:**
   - Extract complex logic, API calls, and state management into Custom Hooks (e.g., `useUser`, `useForm`).
   - Keep the visual component focused solely on rendering.

2. **Typing (TypeScript):**
   - Avoid `any` at all costs.
   - Use `interface` or `type` for `props` and export them if they are useful outside the file.

3. **Performance and Hooks:**
   - Avoid "premature optimization". Use `useCallback` and `useMemo` only when the prop is passed to a child component wrapped in `React.memo` or if there is a truly heavy calculation.
   - Avoid recreating complex functions or objects in the render scope if they don't depend on state.

4. **Next.js Specific (App Router):**
   - Explicitly mark with `"use client"` ONLY the components at the "leaf" of the tree that require interactivity (state, React hooks, events like onClick).
   - Keep Server Components as default in roots and layouts.

5. **Clarity (Clean Code):**
   - Avoid excessive "prop drilling". Consider Context API or Zustand if the prop goes down more than 3 levels.
   - Use "Early Returns" to simplify conditional flow (e.g., `if (loading) return <Skeleton />;`).
   - Destructure `props` directly in the component's function signature.
   - Name boolean variables with clear prefixes (e.g., `is`, `has`, `should`).
</instructions>
