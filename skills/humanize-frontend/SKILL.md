---
name: "humanize-frontend"
description: "Remove generic AI visual patterns when generating frontend components. Invoke when creating new UI pages or components."
---

# Humanize Frontend

<instructions>
When generating or refactoring frontend components and pages (React, Vue, HTML, etc.), you MUST avoid generic design patterns that "scream" they were made by an AI.

**What to AVOID (Generic AI Patterns):**
- Excessive use of blue/purple gradients (e.g., `bg-gradient-to-r from-blue-500 to-purple-500`).
- Exaggerated shadows on all cards (`shadow-xl` or `shadow-2xl` without necessity).
- Centered texts in very wide blocks.
- Gigantic and overly rounded buttons (`rounded-full` in corporate buttons).
- NEVER use Emojis (🚀, ✨, 💬, etc.) in the UI to represent actions or decorations. This screams "AI-generated".
- Placeholder texts like "Lorem ipsum" or "Welcome to our innovative platform".

**What to DO (Professional and Clean Design):**
- Use a minimalist design, inspired by clean interfaces like "Linear" or "Vercel".
- Prefer neutral backgrounds (`bg-white` or `bg-zinc-900`) and subtle borders (`border border-zinc-200`).
- Use subtle shadows only for modals or dropdowns elevation (`shadow-sm` or `shadow-md`).
- Left alignment is generally more elegant and readable for long content.
- ALWAYS use professional icon libraries (like `lucide-react`, `lucide-vue-next`, or `heroicons`) instead of Emojis.
- Use real placeholders focused on the application context (e.g., "Search customers...").
- Maintain consistent spacing (use multiples of 4px/8px, e.g., `gap-4`, `p-6`).
</instructions>
