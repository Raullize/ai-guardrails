---
name: "ui-to-code"
description: "Converts UI mockups, screenshots, or visual descriptions into clean, production-ready code. Invoke when the user asks to build a component from an image or visual specs."
---

# UI to Code Expert

<instructions>
When converting visual mockups or images into frontend code, you MUST follow these strict guidelines to ensure pixel-perfect and maintainable results:

1. **Styling Engine:**
   - Always default to Tailwind CSS unless the user specifies another framework.
   - NEVER write custom CSS/SCSS unless it's impossible to achieve with Tailwind utility classes.
   - Use arbitrary values in Tailwind `-[value]` ONLY as a last resort.

2. **Layout & Spacing:**
   - Use Flexbox (`flex`) or CSS Grid (`grid`) for all alignments. Do not use absolute positioning for layout structure.
   - Estimate paddings and margins using Tailwind's 4px scale (e.g., `p-4` for 16px, `gap-6` for 24px).
   - Ensure the layout is responsive by default using mobile-first breakpoints (`sm:`, `md:`, `lg:`).

3. **Typography & Colors:**
   - Extract semantic colors from the image and map them to Tailwind's neutral palette (e.g., `text-zinc-900`, `bg-slate-50`).
   - Maintain visual hierarchy: use `font-semibold` or `font-bold` for titles, and `text-sm text-gray-500` for secondary text.

4. **Structure:**
   - Break down complex interfaces into smaller, semantic HTML tags (`<header>`, `<main>`, `<section>`, `<article>`).
   - Do not wrap everything in `<div>`.
</instructions>