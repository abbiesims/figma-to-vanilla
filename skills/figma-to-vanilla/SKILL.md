---
name: figma-to-vanilla
description: Implement UI from a Figma design using Canonical's Vanilla Framework and @canonical/react-components. Use when given a Figma URL or asked to implement, build, or convert a design for snapcraft.io or charmhub.io. Produces Jinja2/HTML templates for server-rendered pages and React components for SPA sections.
---

# Figma → Vanilla Framework

Translate Figma designs into production code for snapcraft.io and charmhub.io using Canonical's Vanilla Framework CSS and `@canonical/react-components`. Never invent custom CSS when a Vanilla class or react-component exists for the job.

## Component source priority

When building any front-end visual, reach for components in this strict order. Only drop to the next level when the current level genuinely has no fit:

1. **`@canonical/store-components`** (highest priority) — domain components for the storefront (cards, filters, footer). Use these first for anything store-related.
2. **`@canonical/react-components`** — the general Canonical component library.
3. **Vanilla Framework classes** (`p-*`, `u-*`, `l-*`, grid) — for HTML/Jinja2 output or anything not covered by a React component.
4. **Custom CSS** — last resort only, for a genuinely bespoke element with no equivalent anywhere (see step 6).

### Use the local repos as the source of truth

This working directory contains the actual source for both libraries. **Inspect them directly** rather than guessing at APIs — versions and props drift from any documentation:

- `./store-components/src/components/` — one folder per component (`CharmCard`, `BundleCard`, `PackageCard`, `RockCard`, `TopicCard`, `IntegrationCard`, `InterfaceCard`, `DefaultCard`, `Filters`, `LoadingCard`, `Footer`). Read the component's `.tsx` and `.stories.mdx` for exact props, and check `./store-components/src/index.ts` to confirm it is actually exported.
- `./react-components/src/components/` — one folder per component. Read the `.tsx`/`.d.ts` for prop types and the `.stories.*` for usage examples.

Before using a component, open its source in the relevant repo and confirm the prop names, required props, and import path. Prefer a component that already exists in these repos over reimplementing the same UI.

### Identify components from the design with the Vanilla Figma library

Designs are typically built from the official **Vanilla Core component library** in Figma. Use it to put a name to each element you see in the design — if a region in the design is an instance of a library component, you should implement it with that component, not from scratch.

- File: `💠 Vanilla - Core component library`
- `fileKey`: `Y0cqKbTG4rejU9xm2oh5pR`
- URL: https://www.figma.com/design/Y0cqKbTG4rejU9xm2oh5pR/%F0%9F%92%A0-Vanilla---Core-component-library
- Community version (fallback): https://www.figma.com/community/file/1435297834108003391 — use this if the team file above is not accessible. Community URLs cannot be queried by the Figma API directly; **duplicate it into your own drafts first**, then use the new file's `fileKey` (from the `.../design/<fileKey>/...` URL) with the `figma_*` tools.

How to use it:

1. In the target design, note the **component/instance names** (`figma_get_implementation_context` and `figma_get_node_summary` expose the underlying component name for each instance). A node named e.g. `Button`, `Notification`, `Card`, `Chip`, `Search box`, `Tabs`, `Side navigation`, `Search and filter` is almost certainly an instance of the matching library component.
2. Match that name to the library: each component lives on its own canvas (e.g. `Button` → node `2067:672`, `Notification`, `Card`, `Chip`, `Tabs`, `Table`, `Search and filter`, `Navigation - Desktop`/`Navigation - Mobile`, `Side navigation`, etc.). Call `figma_find_nodes_by_name` / `figma_get_node_summary` on `fileKey` `Y0cqKbTG4rejU9xm2oh5pR` to inspect the canonical component and its variants/props when you need to confirm a match or read the available variants.
3. Translate the library component name to code via the component-source priority ladder above and the mapping table in step 5 (e.g. Figma `Button` → `<Button>` / `p-button`; Figma `Search and filter` → `<SearchAndFilter>`; Figma `Card` → store-components card or `<Card>` / `p-card`).

If a design element is **not** an instance of a Vanilla library component, that is a strong signal it is either a domain component (check `store-components`) or genuinely bespoke — do not assume custom CSS until you have ruled out all three component levels.

## Prerequisites

Before starting, confirm `pi-mono-figma` is available by checking that `figma_parse_url` is a known tool. If it is not, tell the user to run:

```
pi install npm:pi-mono-figma
```

Then ask them to run `/figma-auth --force` to store their Figma personal access token.

## Workflow

### 1. Parse the URL

Call `figma_parse_url` with the Figma URL the user provided. Extract `fileKey` and `nodeId`.

### 2. Preview the design

Call `figma_render_nodes` with the `fileKey` and `nodeId`. Show the rendered image so you can see the design before reading any structured data.

### 3. Get implementation context

Call `figma_get_implementation_context` with:
```json
{
  "fileKey": "...",
  "nodeId": "...",
  "framework": "html",
  "styling": "css",
  "resolveTokens": true,
  "includeCodeSnippets": false
}
```

Read `sections`, `fields`, `buttons`, `typography`, `colors`, `spacing`, and `layout` from the response. Do **not** use any auto-generated code snippets from this tool — they won't know Vanilla Framework. Use the structured data to inform your own implementation.

Note the **component/instance names** in the response and match them against the Vanilla Core component library (see "Identify components from the design with the Vanilla Figma library" above) — this tells you which Vanilla/react-component each element maps to.

If the response is truncated or a sub-component needs detail, call `figma_get_node_summary` on that child node.

### 4. Determine output type

Decide what to produce based on where the design will live:

| Context | Output |
|---|---|
| Public storefront pages (`snapcraft.io`, `charmhub.io`) | Jinja2 template + Vanilla HTML |
| Publisher dashboard, SPAs (React) | `@canonical/react-components` |
| Shared UI fragment used in both | Jinja2 template (server) + React equivalent |

If unsure, ask the user which part of the site the design is for.

### 5. Map design elements to Vanilla / react-components

**Always check the local repo source first, then the reference files:**
- Read the component source in `./store-components/src/components/` and `./react-components/src/components/` (see "Use the local repos as the source of truth" above) — this is authoritative.
- See `./references/vanilla-components.md` for HTML class patterns
- See `./references/react-components.md` for React component API

**Mapping rules (apply the component source priority above):**
- **Store listings (`charmhub.io` / `snapcraft.io` store SPA):** always reuse `@canonical/store-components` first — it ships fully-styled domain cards (`CharmCard`, `BundleCard`, `PackageCard`, `RockCard`, `TopicCard`, `IntegrationCard`, `InterfaceCard`, `DefaultCard`), plus `Filters` and `LoadingCard`. Read the matching folder in `./store-components/src/components/` for exact props. These already match the storefront look and bring their own styles. If the design differs from a shared card by a small detail (e.g. a category chip the card doesn't render), **do not reimplement the card in custom CSS** — use the shared card and flag the missing detail as a shared-library gap. Reimplementing to chase pixels is the exact anti-pattern this skill exists to prevent.
- Buttons → `p-button`, `p-button--positive`, `p-button--negative`, `p-button--base`, `p-button--brand` (HTML) or `<Button appearance="...">` (React)
- Cards → `p-card` with `p-card__content` (HTML) or `<Card>` (React)
- Notifications / alerts → `p-notification--{information|positive|negative|caution}` (HTML) or `<Notification>` (React)
- Forms → `p-form`, `p-form-validation`, `p-form-help-text` (HTML) or `<Form>`, `<Input>`, `<Select>`, `<CheckboxInput>` (React)
- Tables → `p-table` with modifiers (HTML) or `<MainTable>` / `<ModularTable>` (React)
- Navigation → `p-navigation` (HTML) or `<Navigation>` (React)
- Side navigation → `p-side-navigation` (HTML) or `<SideNavigation>` (React)
- Tabs → `p-tabs` (HTML) or `<Tabs>` (React)
- Modal → `p-modal` (HTML) or `<Modal>` (React)
- Search → `p-search-box` (HTML) or `<SearchBox>` (React)
- Chips/tags → `p-chip` (HTML) or `<Chip>` (React)
- Badges → `p-badge` (HTML) or `<Badge>` (React)
- Status labels → `p-status-label--{positive|caution|negative|information}` (HTML) or `<StatusLabel>` (React)
- Accordion → `p-accordion` (HTML) or `<Accordion>` (React)
- Tooltips → `p-tooltip--{top|btm|left|right}` (HTML) or `<Tooltip>` (React)
- Pagination → `p-pagination` (HTML) or `<Pagination>` (React)
- Contextual menu → `p-contextual-menu` (HTML) or `<ContextualMenu>` (React)
- Strips / page sections → `p-strip`, `p-strip--light`, `p-strip--dark` (HTML) or `<Strip>` (React)
- Spinner/loading → `p-icon--spinner` (HTML) or `<Spinner>` / `<Loader>` (React)
- Icons → `p-icon--{name}` (HTML) or `<Icon name="...">` (React)
- Empty states → `<EmptyState>` (React only)

**Layout — always use the Vanilla grid:**
```html
<div class="row">
  <div class="col-6">...</div>
  <div class="col-6">...</div>
</div>
```
- 12 columns on large, 6 on medium (`col-medium-N`), 4 on small (`col-small-N`)
- Nest with `row` inside a column if needed
- **Nested-grid gotcha (Vanilla ≠ Bootstrap):** columns inside a nested `row` sum to the **parent column's width**, not to 12. So 3 cards inside a `col-9` are each `col-3` (3+3+3 = 9), not `col-4`. Getting this wrong silently changes the column count.
- Never write custom flexbox or grid CSS for layout — use the grid

**Spacing — use Vanilla spacing utilities:**
- `u-no-margin`, `u-no-padding`
- `u-sv1` through `u-sv6` for vertical spacing separators
- `u-nudge-left`, `u-nudge-right` for minor adjustments

**Typography:**
- Headings: `<h1>` through `<h6>` — Vanilla styles them automatically
- For display headings: `p-heading--1` through `p-heading--6` classes on any element
- Muted text: `u-text--muted`
- Small text: `<small>` or `u-text--small`

### 6. Flag gaps

**Custom CSS is the last resort, not the first.** The whole point of this skill is to reuse existing components. Before writing a single line of CSS, exhaust these in order:

1. An existing domain component (`@canonical/store-components` for store cards/filters; check the repo's own components first).
2. A `@canonical/react-components` component.
3. A Vanilla class/pattern (`p-*`) — e.g. `p-card`, `p-media-object`, `p-chip`, `p-search-box`.
4. The Vanilla grid + spacing/utility classes (`row`/`col-N`, `u-align--right`, `u-line-clamp`, `u-no-margin`) for layout — **never** hand-written flexbox/grid for a row of items.

Do **not** reimplement a component that already exists just to add or tweak one element (e.g. don't rebuild a charm card in custom CSS to add a category chip the shared card lacks). Instead, reuse the existing component and **flag the missing piece** — propose adding it to the shared library (`@canonical/store-components`) or accepting the small visual difference. Pixel-perfection is lower priority than reuse.

If the design genuinely has an element with **no** equivalent anywhere (e.g. a novel horizontal card layout):
- Say so explicitly: "No existing component covers [X]. Options: ..."
- Option A: closest existing component with adaptations via utility classes
- Option B: the *smallest possible* custom CSS, following Vanilla naming (`p-`/`u-`/`l-`/repo `sc-` prefix), reusing Vanilla SCSS variables (`$spv--*`, `$sph--*`) and utilities (`u-line-clamp`, etc.) — only for the bespoke part, never for layout the grid can do
- Do **not** silently generate Bootstrap classes, Tailwind utilities, or arbitrary CSS class names

When you finish, list every custom CSS rule you added and justify why no existing component/class covered it. If the list is long, you did it wrong.

### 7. Write the code

**For Jinja2 templates:**
- Extend the appropriate base template (`_layouts/base.html` or equivalent in the repo)
- Use `{% block content %}` for the page body
- Reference static assets with `{{ static('path') }}` or the repo's equivalent helper
- Keep Python logic out of templates — pass data from the view

**For React components:**
- Import from `@canonical/react-components`
- Use TypeScript (`.tsx`) — check the component's `.d.ts` for prop types
- Follow the existing file structure in `static/js/src/`
- Use the existing state management pattern in the relevant SPA (check the repo before inventing a new pattern)

**For both:**
- Match the indentation style in the target file (2 spaces in the stores repos)
- Don't add comments explaining Vanilla classes — the class names are self-documenting

**Repo-level SCSS (only for a genuinely bespoke component — see step 6):**
- First confirm the styles can't come from an existing component or Vanilla utilities. Custom SCSS for a *grid of cards*, a *tabs row*, or *spacing* is almost always wrong — the grid and utilities cover those.
- The stores repos wrap each partial in a mixin: `@mixin charmhub-thing { ... }` in `static/sass/_charmhub_thing.scss`, then `@import "charmhub_thing"; @include charmhub-thing;` in `static/sass/styles.scss`. Follow that pattern; don't add bare rules.
- Prefix classes `sc-`, reuse Vanilla variables (`$spv--*`, `$sph--*`) and utilities (`u-line-clamp`, `u-align--right`), and run `npx stylelint` on the new partial.

### 8. Validate against the design (iterate until it matches)

Do not consider the work done after the first pass. Compare what you built back against the Figma design and iterate:

1. **Render the implementation.** For React, run/build the SPA (or its Storybook) and capture a screenshot; for Jinja2/HTML, render the page or the isolated fragment and screenshot it. If you cannot run it, at minimum re-read your markup against the design data.

   **Headless-Chrome harness (works even when the full app/backend can't run).** This is the most reliable way to actually *see* your output in these repos:
   - Compile the repo's real CSS: `npx sass-embedded static/sass/styles.scss /tmp/h/out.css --load-path=node_modules --quiet`.
   - Write a tiny static `/tmp/h/index.html` that links `out.css` and contains the *exact* markup/classes your React component emits (copy the JSX class names verbatim), with a couple of representative records.
   - Screenshot it: `google-chrome --headless --disable-gpu --no-sandbox --hide-scrollbars --window-size=1440,1400 --screenshot=/tmp/h/shot.png /tmp/h/index.html`, then read the PNG.
   - Remote images (icons from charmhub.io etc.) render blank in the sandbox — that's expected; layout, spacing, borders, chips, badges, and the grid still validate. Check for `chromium`/`google-chrome` with `which google-chrome`.
2. **Re-fetch the design as the reference.** Call `figma_render_nodes` again for the same `nodeId` and place the two images side by side. Re-read the structured data from `figma_get_implementation_context` for any region in doubt.
3. **Diff visually and structurally.** Check, in order: overall layout and column structure, presence/absence of every section and element, component variants (button appearance, card type, status colours), spacing rhythm, typography (size/weight/hierarchy), and colours. Note every mismatch.
4. **Fix mismatches by climbing the component priority ladder, not by adding CSS.** For each difference, ask:
   - Is there a `@canonical/store-components` component/prop that produces this? (check the local source)
   - Else a `@canonical/react-components` component/prop?
   - Else a Vanilla class or grid/utility?
   - Only if none of the above can express it, consider the smallest custom CSS (see step 6) — or flag it as a shared-library gap if the difference is a minor detail on an otherwise-correct shared component.
5. **Repeat steps 1–4** until the implementation visually matches the design or the only remaining differences are intentional shared-library gaps you have explicitly flagged.
6. **Stop conditions.** Treat a small detail on an otherwise-correct shared component as a flagged gap, not a reason to fork the component into custom CSS. If you find yourself adding CSS to chase the last few pixels, stop and re-read step 6 — reuse beats pixel-perfection.

Report the final comparison: what matches, what differs and why (flagged gaps), and any custom CSS added with its justification.

### 9. Verify

After writing code, check:
- Every layout element uses the Vanilla grid (`row` / `col-N`), not custom flex/grid
- Every interactive element maps to an existing component or Vanilla class
- **Audit custom CSS: list every rule you added. Each must be for a bespoke element with no existing component/class. If you added CSS for cards, grids, tabs, search, or spacing, delete it and use the existing component/grid/utility instead.**
- Spacing between sections uses `p-strip` or `u-sv*` utilities, not inline styles
- `aria-*` attributes are present on interactive elements (modals, tabs, accordions)
- If React: all imports are from `@canonical/react-components`, not invented components
- The validation loop (step 8) has been run and the implementation matches the design, with any remaining differences explicitly flagged as shared-library gaps

## charmhub.io / snapcraft.io stores cheat-sheet

Hard-won, non-obvious facts about the stores repos (`charmhub/`, `snapcraft/`). Check these before exploring from scratch.

**Where the storefront actually lives.** The landing page `/` is a *server-rendered shell that mounts a React SPA*, not a Jinja page you edit directly. For charmhub: `templates/store.html` → `{{ vite_import('static/js/src/store/index.tsx') }}` → `App` → `pages/Packages` → `components/PackageList`. The tab bar, filters sidebar, search box, results, and pagination all live in this SPA. To change the landing UI, edit the React components, not the template.

**Component/file conventions.**
- Each component is a folder under `static/js/src/store/components/<Name>/` with `<Name>.tsx` + an `index.ts` barrel (`export { Name } from "./Name"` and/or `export { default }`). Tests live in `__tests__/`.
- Mock/static data goes in `static/js/src/store/data/*.ts`.
- Repo SCSS: one mixin per partial — `@mixin charmhub-thing { ... }` in `static/sass/_charmhub_thing.scss`, then `@import "charmhub_thing"; @include charmhub-thing;` in `static/sass/styles.scss`. Prefix bespoke classes `sc-`.

**Query-param collisions (important).** `/store.json` → `get_packages` already uses `type` for *package type* (`charm`/`bundle`). Do not overload `type` (or any existing store filter param like `categories`, `platforms`, `q`, `page`) for new UI state without stripping it before the fetch. Pattern that works: build a cleaned `URLSearchParams`, `delete` your UI-only param, then fetch `/store.json?<cleaned>`.

**Vanilla components that matched this design 1:1 (use them, don't rebuild):**
- Tab count pills (e.g. `Solutions 18`) → `<Badge value={n}>`. `p-badge` is a *dark* pill with white text by default (`background: var(--vf-color-text-default)`), which is exactly the common design treatment — no override needed.
- Tabs → `<Tabs links=[{ label, active, onClick }]>`; `label` accepts a ReactNode so you can embed a `<Badge>`.
- Checkbox filter lists → `<CheckboxInput>` + `<h2 className="p-muted-heading">` (uppercase section headings). Wrap in the existing `p-filter-panel` markup (copy from `PackageFilter`) to keep the mobile filter toggle behaviour for free.

**store-components only has *vertical* cards** (`CharmCard`, `BundleCard`, etc.). A horizontal/list-style card (icon left, content right, footer rule) has no equivalent — it's a legitimate bespoke `sc-` component. Build the smallest custom card with Vanilla vars and flag it as a shared-library gap; don't try to coerce a vertical card.

**Flexbox gotcha that bit me:** in a `display:flex` row, a child that should fill the remaining width needs `flex: 1 1 auto`. Without it the child only takes its content width, so a `justify-content: space-between` *inside* that child won't push a trailing element (e.g. a category chip) to the card's right edge — it stops short. Add `flex: 1 1 auto` to the growing column.

**Lint/build/test commands (run these before declaring done):**
- `npx tsc --noEmit -p tsconfig.json` — note the repos have *pre-existing* unrelated TS errors; grep the output for your own files only.
- `npx eslint <paths>` — eslint enforces Prettier; `npx eslint --fix` resolves formatting nits.
- `npx stylelint static/sass/_your_partial.scss` — enforces **alphabetical property order ignoring vendor prefixes** (so `-webkit-box-orient` sorts as `box-orient`, before `color`/`display`).
- `npx vitest run --coverage=false <path>` — the `coverage/` dir can throw `EACCES` on rmdir; disable coverage or `rm -rf coverage` first.
- `npx vite build` — full SPA build; confirms imports resolve.
- Verified-to-exist Vanilla SCSS vars: `$spv--{x-small..x-large}`, `$sph--{small,large}`, `$color-light`, `$color-dark`, `$color-mid-light`, `$colors--theme--text-muted`, `$color-accent`.

**Tests assume current defaults.** Changing the default tab/route or removing a always-rendered child (e.g. a Topics strip) will break existing tests. Update them by targeting the relevant state via `<MemoryRouter initialEntries={["/?type=charms"]}>` rather than deleting assertions.
