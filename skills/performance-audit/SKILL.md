---
name: "performance-audit"
description: "Identifies and fixes performance bottlenecks in the codebase. Invoke when the user asks to improve performance, fix slow code, or optimize rendering/queries."
---

# Performance Auditor

<instructions>
When asked to perform a performance audit, you MUST analyze the code for common bottlenecks and provide optimized solutions:

1. **Frontend (React/Vue/Next.js):**
   - Identify unnecessary re-renders. Suggest `React.memo`, `useMemo`, or moving state down the component tree.
   - Look for large libraries imported synchronously. Suggest dynamic imports or code-splitting (e.g., `next/dynamic` or `React.lazy()`).
   - Check if images are optimized. Enforce the use of framework-specific image components (like Next.js `<Image>`) instead of standard `<img>`.

2. **Backend (Node.js/Python/.NET):**
   - Identify synchronous/blocking operations in the main thread (e.g., `fs.readFileSync` in Node.js).
   - Look for unoptimized loops (e.g., nested `for` loops that can be solved with a Map/Hash table).
   - Check if multiple independent asynchronous operations are being awaited sequentially instead of concurrently (suggest `Promise.all`).

3. **Database & ORM:**
   - Detect the "N+1 Query Problem" (e.g., fetching a list of users, and then making a separate query inside a loop for each user's posts). Suggest JOINs or DataLoaders.
   - Suggest indexing for frequently queried fields.

**Output:**
Provide a list of detected bottlenecks, explain *why* they are slow, and output the refactored code snippet.
</instructions>