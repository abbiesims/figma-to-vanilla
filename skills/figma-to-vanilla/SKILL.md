---
name: figma-to-vanilla
description: Implement UI from a Figma design using Canonical's Vanilla Framework and @canonical/react-components. Use when given a Figma URL or asked to implement, build, or convert a design for snapcraft.io or charmhub.io. Produces Jinja2/HTML templates for server-rendered pages and React components for SPA sections.
---

# Figma → Vanilla Framework

Translate Figma designs into production code for snapcraft.io and charmhub.io using Canonical's Vanilla Framework CSS and `@canonical/react-components`. Never invent custom CSS when a Vanilla class or react-component exists for the job.

## TL;DR checklist

1. **Confirm Figma access** (`figma_parse_url` exists; else install `pi-mono-figma` / a Figma MCP server).
2. **Render the node once** (`figma_render_nodes`) and keep that image as your reference — don't re-render repeatedly.
3. **Get structured context** (`figma_get_implementation_context`, `figma_get_node_summary`). Use the compact Figma tools only — never dump raw `figma_get_file` / `figma_get_nodes` JSON into context.
4. **Name every element** against the Vanilla Core Figma library, then map it down the component-source ladder: store-components → react-components → Vanilla class → (last resort) custom CSS.
5. **Read the installed library API** in `node_modules/@canonical/*/dist` (`.d.ts` for props, `dist/index.d.ts` for exports) — that's the version the app actually ships. Read only the component folder you need.
6. **Write code** reusing components; use the Vanilla grid for all layout and spacing utilities for all spacing.
7. **Validate in a loop** against the design (headless-Chrome harness or SPA build screenshot) until it matches or the only gaps are explicitly flagged shared-library gaps.
8. **Custom CSS is a failure mode to justify, not a tool.** For every rule you write, state the store-components / react-components / Vanilla alternative you ruled out first.

## Component source priority

When building any front-end visual, reach for components in this strict order. Only drop to the next level when the current level genuinely has no fit:

1. **`@canonical/store-components`** (highest priority) — domain components for the storefront (cards, filters, footer). Use these first for anything store-related.
2. **`@canonical/react-components`** — the general Canonical component library.
3. **Vanilla Framework classes** (`p-*`, `u-*`, `l-*`, grid) — for HTML/Jinja2 output or anything not covered by a React component.
4. **Custom CSS** — last resort only, for a genuinely bespoke element with no equivalent anywhere (see step 6).

### Read the installed library API as the source of truth

The authoritative API is the **version the app actually ships**, installed under `node_modules/@canonical/*`. Inspect it directly rather than guessing — props drift between versions and from any documentation.

These packages ship **compiled `dist/` only** (no `.tsx` source), so read:

- **Props / types:** `node_modules/@canonical/react-components/dist/components/<Name>/<Name>.d.ts` and the equivalent under `@canonical/store-components/dist/`.
- **What's actually exported:** `node_modules/@canonical/<pkg>/dist/index.d.ts` (or the `exports` map in its `package.json`). If a component isn't exported there, you can't import it — pick another.
- **Usage examples:** the compiled `*.stories.js` / `*.stories.d.ts` next to the component.

Store-components ships domain components (`CharmCard`, `BundleCard`, `PackageCard`, `RockCard`, `TopicCard`, `IntegrationCard`, `InterfaceCard`, `DefaultCard`, `Filters`, `LoadingCard`, `Footer`). React-components ships the general library. **Read only the specific component folder you need** — do not read whole packages or repos into context. Before using a component, confirm its prop names, required props, and that it's exported.

> Context discipline: prefer targeted `grep`/`rg` and a single-file `read` over broad directory reads. Open one component's `.d.ts`, not the package.

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

Ensure both the Figma tooling **and** authentication are in place *before* starting the workflow. Don't begin step 1 until both checks pass — otherwise the run will fail partway through on the first Figma call.

1. **Tooling.** Confirm the Figma tools are available by checking that `figma_parse_url` is a known tool. If it is not, tell the user to install them and stop until they have:

   ```
   pi install npm:pi-mono-figma
   ```

   (Other agents: connect the Figma MCP server, which exposes the equivalent `figma_*` capabilities.)

2. **Authentication.** Each user needs their **own** Figma personal access token (per-person; nothing about auth is stored in this skill or repo). Verify auth up front rather than waiting for a mid-task failure:
   - Do a lightweight auth probe — e.g. call `figma_parse_url` on the user's URL, then attempt a minimal `figma_get_design_context` / `figma_render_nodes` call.
   - If any Figma call reports missing, expired, or invalid credentials, trigger the secure auth prompt (`figma_configure_auth`, or tell the user to run `/figma-auth --force` in pi) and wait for them to store a token before continuing.
   - The token needs read access to file content, and the user must have at least view access to the target Figma file. Never ask the user to paste a token into the chat — always use the secure auth prompt.

Only once tooling and auth are confirmed, proceed to the workflow.

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

**Context discipline:** the compact tools above (`figma_render_nodes`, `figma_get_implementation_context`, `figma_get_node_summary`) are the only Figma calls you should normally need. **Never** dump raw `figma_get_file` / `figma_get_nodes` JSON into context — it's huge and low-signal. Scope every call by `nodeId` (and `depth` where supported), and render each node **once**, reusing that image as your reference throughout.

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

**Always check the installed library API first, then the reference files:**
- Read the component's type defs under `node_modules/@canonical/store-components/dist/` and `node_modules/@canonical/react-components/dist/` (see "Read the installed library API as the source of truth" above) — this is authoritative for the shipping version.
- See `./references/vanilla-components.md` for HTML class patterns
- See `./references/react-components.md` for React component API

**Mapping rules (apply the component source priority above):**
- **Store listings (`charmhub.io` / `snapcraft.io` store SPA):** always reuse `@canonical/store-components` first — it ships fully-styled domain cards (`CharmCard`, `BundleCard`, `PackageCard`, `RockCard`, `TopicCard`, `IntegrationCard`, `InterfaceCard`, `DefaultCard`), plus `Filters` and `LoadingCard`. Read the matching folder under `node_modules/@canonical/store-components/dist/` for exact props. These already match the storefront look and bring their own styles. If the design differs from a shared card by a small detail (e.g. a category chip the card doesn't render), **do not reimplement the card in custom CSS** — use the shared card and flag the missing detail as a shared-library gap. Reimplementing to chase pixels is the exact anti-pattern this skill exists to prevent.
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

**Custom CSS is the last resort, not the first.** The whole point of this skill is to reuse existing components. **Gate:** before writing *any* CSS rule, state in your reasoning which store-components component, react-components component, and Vanilla class/utility you ruled out and why none fit. If you can't articulate that for a rule, you're not ready to write it. Before writing a single line of CSS, exhaust these in order:

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

When you finish, list every custom CSS rule you added, each with the alternative you ruled out. Custom CSS that touches **layout or spacing** is almost always a mistake — the grid and spacing utilities cover those, so treat any such rule as a red flag and re-check it. If the list is long, you did it wrong.

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
- The stores repos wrap each partial in a mixin: `@mixin <name> { ... }` in `static/sass/_<name>.scss`, then `@import "<name>"; @include <name>;` in `static/sass/styles.scss`. Follow that pattern; don't add bare rules.
- Use the repo's bespoke prefix (charmhub `sc-`, snapcraft `snapcraft-`), reuse Vanilla variables (`$spv--*`, `$sph--*`) and utilities (`u-line-clamp`, `u-align--right`), and run `npx stylelint` on the new partial.

### 8. Validate against the design (iterate until it matches)

Do not consider the work done after the first pass. Compare what you built back against the Figma design and iterate:

1. **Render the implementation.** For React, run/build the SPA (or its Storybook) and capture a screenshot; for Jinja2/HTML, render the page or the isolated fragment and screenshot it. If you cannot run it, at minimum re-read your markup against the design data.

   **Headless-Chrome harness (works even when the full app/backend can't run).** This is a reliable way to actually *see* your output in these repos. Use a temp dir (referred to below as `$TMP`):
   - Compile the repo's real CSS: `npx sass-embedded static/sass/styles.scss $TMP/out.css --load-path=node_modules --quiet`.
   - Write a tiny static `$TMP/index.html` that links `out.css` and contains the *exact* markup/classes your React component emits (copy the JSX class names verbatim), with a couple of representative records.
   - Screenshot it: `google-chrome --headless --disable-gpu --no-sandbox --hide-scrollbars --window-size=1440,1400 --screenshot=$TMP/shot.png $TMP/index.html`, then read the PNG.
   - Remote images (icons from charmhub.io etc.) render blank without network — that's expected; layout, spacing, borders, chips, badges, and the grid still validate. Check for a browser with `which google-chrome chromium chromium-browser`.
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

## Stores monorepo cheat-sheet

Non-obvious facts about the stores monorepo, where `charmhub`, `snapcraft`, `store-components`, and `react-components` are sibling checkouts. Check these before exploring from scratch. Patterns are shared across the monorepo unless a per-repo difference is called out.

**Where the storefront actually lives (charmhub).** The charmhub landing page `/` is a *server-rendered shell that mounts a React SPA*, not a Jinja page edited directly: `templates/store.html` → `{{ vite_import('static/js/src/store/index.tsx') }}` → `App` → `pages/Packages` → `components/PackageList`. The tab bar, filters sidebar, search box, results, and pagination all live in this SPA — edit the React components, not the template. Snapcraft's JS is organised differently (no `static/js/src/store` tree); confirm the entry point per repo before assuming this layout.

**Component/file conventions (React SPA).**
- Each component is a folder under `static/js/src/<app>/components/<Name>/` with `<Name>.tsx` + an `index.ts` barrel (`export { Name } from "./Name"` and/or `export { default }`). Tests live in `__tests__/`.
- Mock/static data goes in a `data/*.ts` module.

**SCSS conventions (shared pattern, per-repo prefix).** Each partial wraps its rules in a mixin: `@mixin <name> { ... }` in `static/sass/_<name>.scss`, then `@import "<name>"; @include <name>;` in `static/sass/styles.scss`. Don't add bare top-level rules. Bespoke class prefix is **repo-specific**: charmhub uses `sc-`, snapcraft uses `snapcraft-` (or `p-`). Reuse Vanilla variables and utilities, and run `npx stylelint` on the new partial.

**Query-param collisions (important).** The store JSON endpoint (`/store.json` → `get_packages`) already uses `type` for *package type* (`charm`/`bundle`). Do not overload `type` (or existing filter params like `categories`, `platforms`, `q`, `page`) for new UI state without stripping it before the fetch. Working pattern: build a cleaned `URLSearchParams`, `delete` your UI-only param, then fetch `/store.json?<cleaned>`.

**Vanilla components that map 1:1 to common storefront patterns (use them, don't rebuild):**
- Tab count pills (e.g. `Solutions 18`) → `<Badge value={n}>`. `p-badge` is a *dark* pill with white text by default (`background: var(--vf-color-text-default)`), which matches the common design treatment — no override needed.
- Tabs → `<Tabs links=[{ label, active, onClick }]>`; `label` accepts a ReactNode, so a `<Badge>` can be embedded in the label.
- Checkbox filter lists → `<CheckboxInput>` + `<h2 className="p-muted-heading">` (uppercase section headings). Wrap in the existing `p-filter-panel` markup (copy from an existing filter component) to keep the mobile filter-toggle behaviour for free.

**store-components ships only *vertical* cards** (`CharmCard`, `BundleCard`, etc.). A horizontal/list-style card (icon left, content right, footer rule) has no equivalent — it is a legitimate bespoke component. Build the smallest custom card with Vanilla variables and flag it as a shared-library gap; don't try to coerce a vertical card into a horizontal layout.

**Flexbox layout note.** In a `display: flex` row, a child that should fill the remaining width needs `flex: 1 1 auto`. Without it the child only takes its content width, so a `justify-content: space-between` *inside* that child won't push a trailing element (e.g. a category chip) to the container's right edge — it stops short. Add `flex: 1 1 auto` to the growing column.

**Lint/build/test commands (run these before declaring done):**
- `npx tsc --noEmit -p tsconfig.json` — the repos may have *pre-existing* unrelated TS errors; grep the output for your own files only.
- `npx eslint <paths>` — eslint enforces Prettier; `npx eslint --fix` resolves formatting nits.
- `npx stylelint static/sass/_your_partial.scss` — enforces **alphabetical property order ignoring vendor prefixes** (so `-webkit-box-orient` sorts as `box-orient`, before `color`/`display`).
- `npx vitest run --coverage=false <path>` — the `coverage/` dir can throw `EACCES` on rmdir; disable coverage or `rm -rf coverage` first.
- `npx vite build` — full SPA build; confirms imports resolve.
- Verified-to-exist Vanilla SCSS vars: `$spv--{x-small..x-large}`, `$sph--{small,large}`, `$color-light`, `$color-dark`, `$color-mid-light`, `$colors--theme--text-muted`, `$color-accent`.

**Tests assume current defaults.** Changing the default tab/route or removing an always-rendered child (e.g. a topics strip) will break existing tests. Update them by targeting the relevant state via `<MemoryRouter initialEntries={["/?type=charms"]}>` rather than deleting assertions.

## Using this skill in other agents

This skill is a plain folder (`SKILL.md` + `references/`) and is agent-agnostic. Install it by copying/symlinking into the target agent's skills directory: pi → `~/.agents/skills/`; Claude Code → `~/.claude/skills/` (or a project `.claude/skills/`); agents without skill support → paste `SKILL.md` as context. The only external dependency is Figma access: in pi that's the `pi-mono-figma` package (`figma_*` tools); in other agents it's the **Figma MCP server**, which exposes equivalent capabilities. Where this file names a specific `figma_*` tool, read it as "the corresponding Figma tool in your agent."
