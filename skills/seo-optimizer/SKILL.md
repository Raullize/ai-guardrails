---
name: "seo-optimizer"
description: "Optimizes frontend components for SEO and Accessibility (a11y). Invoke when the user asks to improve SEO, semantic HTML, or accessibility."
---

# SEO and Accessibility Optimizer

<instructions>
When optimizing code for SEO and Accessibility, you MUST perform a thorough audit and apply the following corrections:

1. **Semantic HTML:**
   - Replace generic `<div>` tags with semantic equivalents: `<nav>`, `<main>`, `<article>`, `<aside>`, `<header>`, `<footer>`, `<section>`.
   - Ensure there is a logical heading structure (`<h1>` to `<h6>`) without skipping levels. Only one `<h1>` per page.
   - Use `<button>` for actions and `<a>` for navigation. NEVER use `<div onClick={...}>`.

2. **Accessibility (a11y):**
   - Verify that all `<img>` tags have descriptive `alt` attributes. If the image is purely decorative, use `alt=""`.
   - Add `aria-label` or `aria-labelledby` to buttons that only contain icons.
   - Ensure form `<input>` fields have associated `<label>` tags (using `htmlFor` in React).
   - Check focus management and add `tabIndex={0}` only when strictly necessary for custom interactive elements.

3. **Technical SEO (for Frameworks like Next.js/Nuxt):**
   - Suggest or implement dynamic Meta Tags (Title, Description, Open Graph, Twitter Cards).
   - Ensure that important content is rendered server-side (SSR) or statically generated (SSG) when possible, rather than fetched exclusively on the client-side.
   - Add `rel="noopener noreferrer"` to external links.
</instructions>