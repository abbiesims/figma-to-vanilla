---
name: figma-to-vanilla
description: Implement UI from a Figma design using Vanilla Framework as the preferred default, with Canonical React component libraries for React pages. Use when given a Figma URL or asked to implement, build, or convert a design for snapcraft.io or charmhub.io. Produces Jinja2/HTML templates for server-rendered pages and React components for SPA sections.
---

# Figma → Vanilla Framework

Translate Figma designs into production code for snapcraft.io and charmhub.io using **Vanilla Framework as the preferred default**. Use Vanilla patterns directly for HTML/Jinja2 and existing `@canonical/react-components` or `@canonical/store-components` wrappers for React. Never invent custom CSS when a shared component or Vanilla class exists for the job.

**Default to zero new CSS. Use existing Vanilla components and Canonical React components, not lookalikes built from custom styles.** This includes SCSS, inline `style` props, CSS modules, CSS-in-JS, and overrides of shared component internals. Prefer a small, explicitly reported design difference over duplicating a shared component. Reusing Vanilla tokens in custom CSS does not make that CSS a Vanilla component.

Installation and OpenCode setup: see [README.md](README.md). Installing this skill and connecting Figma are separate steps; do not install tools or change agent configuration if the existing connection already works.

## TL;DR checklist

1. **Confirm Figma access** with the tools actually available in this agent; probe access to the target node, not merely URL parsing. See Prerequisites for tool mappings.
2. **Render or export the node once** and keep that image as your reference; don't re-render repeatedly unless the design changes.
3. **Get node-scoped structured context** using the available context/data tool. Never dump an entire raw Figma file into context.
4. **Name every element** against the Vanilla Core Figma library, then use the matching Vanilla pattern or existing Canonical React wrapper. Reuse domain components for storefront-specific UI before composing a replacement.
5. **Read the installed library API** in `node_modules/@canonical/*/dist` (`.d.ts` for props and package barrel files for exports) and the installed Vanilla patterns — that's the version the app actually ships. Read only the component folder you need.
6. **Write code** reusing components; use the Vanilla grid for all layout and spacing utilities for all spacing.
7. **Validate in a loop** against the design (headless-Chrome harness or SPA build screenshot) until it matches or the only gaps are explicitly flagged shared-library gaps.
8. **Custom CSS requires an explicit gap and user approval.** Report the applicable component/pattern alternatives ruled out before adding any rule.

## Component source priority

**Vanilla is the design-system default, not a fallback.** First inspect and reuse the target repo's existing Vanilla-based components and composition patterns. Choose the implementation appropriate to the output type:

1. **HTML/Jinja2:** use Vanilla Framework patterns and classes (`p-*`, `u-*`, `l-*`, grid) directly. React packages are not prerequisites.
2. **React storefront domain UI:** reuse installed `@canonical/store-components` cards, filters, and footer before composing replacements.
3. **React general UI:** use installed `@canonical/react-components`, the shared React wrappers for Vanilla patterns.
4. **React gaps:** compose documented Vanilla markup, grid, and utilities when no shared React component fits; reuse the repo's interaction logic where needed.
5. **Custom CSS:** last resort only, for a genuinely unmet requirement after checking Vanilla patterns and shared components (see step 6).

Preserve the existing framework and global Vanilla stylesheet setup. Do not introduce another design system, migrate unrelated components, or upgrade dependencies as a side effect of implementing a design.

### Read the installed library API as the source of truth

The authoritative API is the **version the app actually ships**, installed under `node_modules/@canonical/*`. Inspect it directly rather than guessing — props drift between versions and from any documentation.

These packages ship **compiled `dist/` only** (no `.tsx` source), so read:

- **React props / types:** `node_modules/@canonical/react-components/dist/components/<Name>/<Name>.d.ts` and the equivalent under `@canonical/store-components/dist/`.
- **What's actually exported:** `node_modules/@canonical/<pkg>/dist/index.d.ts` (or the `exports` map in its `package.json`). If a component isn't exported there, you can't import it — pick another.
- **Usage examples:** the compiled `*.stories.js` / `*.stories.d.ts` next to the component.

Store-components ships domain components (`CharmCard`, `BundleCard`, `PackageCard`, `RockCard`, `TopicCard`, `IntegrationCard`, `InterfaceCard`, `DefaultCard`, `Filters`, `LoadingCard`, `Footer`). React-components provides general Vanilla-based UI. **Read only the specific component folder you need** — do not read whole packages or repos into context. Before using a component, confirm its prop names, required props, and that it is exported.

> Context discipline: prefer targeted `grep`/`rg` and a single-file `read` over broad directory reads. Open one component's `.d.ts`, not the package.

### Identify components from the design with the Vanilla Figma library

Designs are typically built from the official **Vanilla Core component library** in Figma. Use it to put a name to each element you see in the design — if a region in the design is an instance of a library component, you should implement it with that component, not from scratch.

- File: `💠 Vanilla - Core component library`
- `fileKey`: `Y0cqKbTG4rejU9xm2oh5pR`
- URL: https://www.figma.com/design/Y0cqKbTG4rejU9xm2oh5pR/%F0%9F%92%A0-Vanilla---Core-component-library
- Community version (fallback): https://www.figma.com/community/file/1435297834108003391 — use this if the team file above is not accessible. Community URLs cannot be queried by the Figma API directly; **duplicate it into your own drafts first**, then use the new file's `fileKey` (from the `.../design/<fileKey>/...` URL) with the `figma_*` tools.

How to use it:

1. In the target design, note the **component/instance names** exposed by the available context/data tool. Names such as `Button`, `Notification`, `Card`, `Chip`, `Search box`, `Tabs`, `Side navigation`, and `Search and filter` are clues; confirm instance metadata and variants rather than relying on names alone.
2. Match the name to the library's corresponding component. If available, use `figma_find_nodes_by_name` / `figma_get_node_summary` on `fileKey` `Y0cqKbTG4rejU9xm2oh5pR` to locate and inspect it. Otherwise request the known component node with the available context/data tool. Do not fetch the entire library just because name-search tooling is missing; use the Vanilla docs and installed API, and report any unresolved mapping.
3. Translate the library component name to code via the component-source priority ladder above and the mapping table in step 5 (e.g. Figma `Button` → `<Button>` / `p-button`; Figma `Search and filter` → `<SearchAndFilter>`; Figma `Card` → store-components card or `<Card>` / `p-card`).

If a design element is **not** an instance of a Vanilla library component, still check existing components and compositions. Detached instances and plain frames can represent standard patterns; a node name or missing instance link alone does not prove that custom CSS is needed.

## Prerequisites

Confirm working Figma tooling and authentication before implementation. Use the current tool schemas; names and capabilities differ between providers. The pi tools named in the workflow are examples, not required tools.

| Task | pi tools | Official Figma MCP | Data/download MCP (including Framelink) |
|---|---|---|---|
| Parse URL | `figma_parse_url` | Extract file key and node ID from URL | Extract file key and node ID from URL |
| Preview | `figma_render_nodes` | `get_screenshot` | `download_figma_images` (export frame as PNG) |
| Design context | `figma_get_implementation_context` | `get_design_context` | `get_figma_data` scoped to the node |
| Child detail | `figma_get_node_summary` | `get_metadata`, then child context | `get_figma_data` on the child node |

OpenCode may prefix tool names with the MCP server name (for example, `figma_get_figma_data`). Do not call a tool unless it is actually available, and do not pass pi parameters to a different provider.

1. **Tooling:** if a usable context/data tool already exists, use it. If no Figma tooling exists, follow [README.md](README.md) for OpenCode or the appropriate agent's setup. `pi install` and `/figma-auth` are pi-only.
2. **Authentication:** make one small, node-scoped data or screenshot request against the user's design. Parsing a URL does not verify credentials. Official MCP uses OAuth; local API servers typically use a personal access token with `file_content:read`. The authenticated user must have view access to the file. For errors, use the provider's secure authentication flow or the README's secure terminal prompt, never chat or committed credentials.
3. **Access limits:** if credentials, file permissions, client restrictions, or rate limits block access, explain the specific blocker and ask for access or an exported design image. Do not fabricate design details or silently claim visual verification.

## Workflow

### 1. Parse the URL

Use `figma_parse_url` if available; otherwise extract `fileKey` from `/design/<fileKey>/...` or `/file/<fileKey>/...` and `nodeId` from the `node-id` query parameter. Convert URL IDs such as `123-456` to `123:456` when the tool schema requires it. If the URL lacks a node ID and the target is unclear, ask for the specific frame link rather than fetching the entire file.

### 2. Preview the design

Use the available screenshot/render tool or export the target frame as PNG with the image-download tool. For `figma_download_figma_images`, use the frame's `nodeId` and a `.png` filename; omit `imageRef` when exporting a frame without an image fill. Inspect the saved image, not just the download result. Keep it as the reference for later comparisons. If no preview is available, request an export and report the visual-verification limitation.

### 3. Get implementation context

If available, call `figma_get_implementation_context` with:
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

Otherwise use `get_design_context` or node-scoped `figma_get_figma_data` with the parameters supported by that tool. Read the hierarchy, component names, variants, text, assets, typography, colors, spacing, and layout. Do **not** copy auto-generated React/Tailwind/custom-CSS snippets into the app; treat them only as design evidence and map the result to Canonical/Vanilla components.

**Context discipline:** scope calls by the supplied `nodeId`, read child nodes only as needed, and avoid raw full-file JSON. Use `depth` only when explicitly requested by the user and supported by the tool schema. Render each node once, reusing that image unless the design changes.

Note the **component/instance names** in the response and match them against the Vanilla Core component library (see "Identify components from the design with the Vanilla Figma library" above) — this tells you which Vanilla/react-component each element maps to.

If the response is truncated or a sub-component needs detail, request that child node with the available summary/context/data tool instead of repeatedly fetching the parent.

### 4. Determine output type

Trace the existing route, template, and JavaScript entry point before choosing the output. A public storefront can mount a React SPA; the domain name alone does not determine the renderer.

| Context | Output |
|---|---|
| Server-rendered pages (`snapcraft.io`, `charmhub.io`) | Jinja2 template + Vanilla HTML |
| Publisher dashboard, SPAs (React) | Vanilla-based `@canonical/react-components`; `@canonical/store-components` for domain UI |
| Shared UI fragment used in both | Jinja2 template (server) + React equivalent |

If unsure, ask the user which part of the site the design is for.

### 5. Map design elements to Vanilla / react-components

**Always check the installed library API first, then the reference files:**
- Read the component's type defs under `node_modules/@canonical/store-components/dist/` and `node_modules/@canonical/react-components/dist/` (see "Read the installed library API as the source of truth" above) — this is authoritative for the shipping version.
- See `./references/vanilla-components.md` for HTML class patterns
- See `./references/react-components.md` for React component API

**Mapping rules (apply the component source priority above):**
- **Common React primitives:** use the matching installed `@canonical/react-components` component for the Vanilla pattern. Confirm exports and supported props before importing; use documented Vanilla markup for uncovered patterns rather than introducing a different design system.
- **Store listings (`charmhub.io` / `snapcraft.io` store SPA):** always reuse `@canonical/store-components` first — it ships fully-styled domain cards (`CharmCard`, `BundleCard`, `PackageCard`, `RockCard`, `TopicCard`, `IntegrationCard`, `InterfaceCard`, `DefaultCard`), plus `Filters` and `LoadingCard`. Read the matching folder under `node_modules/@canonical/store-components/dist/` for exact props. These already match the storefront look and bring their own styles. If the design differs from a shared card by a small detail (e.g. a category chip the card doesn't render), **do not reimplement the card in custom CSS** — use the shared card and flag the missing detail as a shared-library gap. Reimplementing to chase pixels is the exact anti-pattern this skill exists to prevent.
- Buttons → `p-button`, `p-button--positive`, `p-button--negative`, `p-button--base`, `p-button--brand` (HTML) or `<Button>` (React; confirm appearance names against the installed props)
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

**Custom CSS is the last resort, not the first.** Before writing any rule, briefly report the unmet design requirement and the applicable existing components, composition options, and Vanilla patterns/utilities you checked. Ask the user to choose the closest reusable pattern, a shared-library enhancement, or a minimal custom exception. Until they approve an exception, implement the reusable parts and flag the gap, without adding CSS. Exhaust these applicable options first:

1. An existing domain component (`@canonical/store-components` for store cards/filters; check the repo's own components first).
2. A `@canonical/react-components` component for React output.
3. A Vanilla class/pattern (`p-*`) — e.g. `p-card`, `p-media-object`, `p-chip`, `p-search-box`.
4. The Vanilla grid + spacing/utility classes (`row`/`col-N`, `u-align--right`, `u-line-clamp`, `u-no-margin`) for layout — **never** hand-written flexbox/grid for a row of items.

Do **not** reimplement a component that already exists just to add or tweak one element (e.g. don't rebuild a charm card in custom CSS to add a category chip the shared card lacks). Instead, reuse the existing component and **flag the missing piece** — propose adding it to the shared library (`@canonical/store-components`) or accepting the small visual difference. Pixel-perfection is lower priority than reuse.

If the design genuinely has an element with **no** equivalent anywhere, after checking composition as well as individual components:
- Say so explicitly: "No existing component covers [X]. Options: ..."
- Option A: closest existing component with adaptations via utility classes
- Option B (only after user approval): the *smallest possible* custom CSS with the repo's established bespoke prefix and installed Vanilla tokens, only for the unmet requirement, never for layout the grid can do. Do not invent new `p-*` or `u-*` classes that look like upstream Vanilla APIs.
- Do **not** silently generate Bootstrap classes, Tailwind utilities, or arbitrary CSS class names

When you finish, list every custom CSS rule you added, each with the alternative you ruled out. Custom CSS that touches **layout or spacing** is almost always a mistake — the grid and spacing utilities cover those, so treat any such rule as a red flag and re-check it. If the list is long, you did it wrong.

### 7. Write the code

**For Jinja2 templates:**
- Extend the appropriate base template (`_layouts/base.html` or equivalent in the repo)
- Use `{% block content %}` for the page body
- Reference static assets with `{{ static('path') }}` or the repo's equivalent helper
- Keep Python logic out of templates — pass data from the view

**For React components:**
- Import general Vanilla-based components from `@canonical/react-components` and storefront domain components from `@canonical/store-components`
- Preserve the repo's existing global Vanilla stylesheet and icon setup; do not add duplicate global style imports inside leaf components
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

   **Headless-Chrome harness (fallback when the full app/backend can't run).** This checks isolated markup and CSS, not React behavior, routing, data integration, or the actual rendered application. Report that limitation. Use a verified temporary directory under `/tmp/opencode` (referred to below as `$TMP`):
   - Compile the repo's real CSS: `npx sass-embedded static/sass/styles.scss $TMP/out.css --load-path=node_modules --quiet`.
   - Write a tiny static `$TMP/index.html` that links `out.css` and contains the *exact* markup/classes your React component emits (copy the JSX class names verbatim), with a couple of representative records.
   - Screenshot it: `google-chrome --headless --disable-gpu --no-sandbox --hide-scrollbars --window-size=1440,1400 --screenshot=$TMP/shot.png $TMP/index.html`, then read the PNG.
   - Remote images (icons from charmhub.io etc.) render blank without network — that's expected; layout, spacing, borders, chips, badges, and the grid still validate. Check for a browser with `which google-chrome chromium chromium-browser`.
2. **Reuse the saved design reference.** Compare it with the implementation screenshot. Request child-node context only for regions in doubt; re-render Figma only if the design has changed.
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
- Keyboard behavior, focus management, accessible names, and required ARIA states work, not merely exist in markup. Vanilla HTML classes supply styling, not interaction logic; reuse the repo's existing behavior or implement the documented interaction.
- Desktop and mobile layouts work without clipping; check loading, empty, error, and active states where applicable
- If React: reuse existing domain components and Vanilla-based shared UI, not invented lookalikes; installed package types and the production build pass
- Vanilla styles are loaded globally without duplicate imports, and icons load in the built app
- The validation loop (step 8) has been run and the implementation matches the design, with any remaining differences explicitly flagged as shared-library gaps

## Stores monorepo cheat-sheet

Non-obvious facts about the stores monorepo, where `charmhub`, `snapcraft`, `store-components`, and `react-components` are sibling checkouts. Check these before exploring from scratch. Patterns are shared across the monorepo unless a per-repo difference is called out.

**Where the storefront actually lives (charmhub).** The charmhub landing page `/` is a *server-rendered shell that mounts a React SPA*, not a Jinja page edited directly: `templates/store.html` → `{{ vite_import('static/js/src/store/index.tsx') }}` → `App` → `pages/Packages` → `components/PackageList`. The tab bar, filters sidebar, search box, results, and pagination all live in this SPA — edit the React components, not the template. Snapcraft's JS is organised differently (no `static/js/src/store` tree); confirm the entry point per repo before assuming this layout.

**Installed versions and setup differ by repo.** Inspect the target repo's `package.json`, installed Vanilla and React component versions, global stylesheet, and static asset handling rather than assuming sibling repos match. Use the existing Vanilla setup; do not add a new design system for one feature.

**Component/file conventions (React SPA).**
- Each component is a folder under `static/js/src/<app>/components/<Name>/` with `<Name>.tsx` + an `index.ts` barrel (`export { Name } from "./Name"` and/or `export { default }`). Tests live in `__tests__/`.
- Mock/static data goes in a `data/*.ts` module.

**SCSS conventions (approved exceptions only).** Each partial wraps its rules in a mixin: `@mixin <name> { ... }` in `static/sass/_<name>.scss`, then `@import "<name>"; @include <name>;` in `static/sass/styles.scss`. Don't add bare top-level rules. Confirm the repo's bespoke prefix (for example, charmhub `sc-` or snapcraft `snapcraft-`); do not invent upstream-looking Vanilla classes. Reuse installed Vanilla variables and utilities, and run `npx stylelint` on the new partial.

**Query-param collisions (important).** The store JSON endpoint (`/store.json` → `get_packages`) already uses `type` for *package type* (`charm`/`bundle`). Do not overload `type` (or existing filter params like `categories`, `platforms`, `q`, `page`) for new UI state without stripping it before the fetch. Working pattern: build a cleaned `URLSearchParams`, `delete` your UI-only param, then fetch `/store.json?<cleaned>`.

**Vanilla components that map 1:1 to common storefront patterns (use them, don't rebuild):**
- Tab count pills (e.g. `Solutions 18`) → `<Badge value={n}>`. `p-badge` is a *dark* pill with white text by default (`background: var(--vf-color-text-default)`), which matches the common design treatment — no override needed.
- Tabs → `<Tabs links=[{ label, active, onClick }]>`; `label` accepts a ReactNode, so a `<Badge>` can be embedded in the label.
- Checkbox filter lists → `<CheckboxInput>` + `<h2 className="p-muted-heading">` (uppercase section headings). Wrap in the existing `p-filter-panel` markup (copy from an existing filter component) to keep the mobile filter-toggle behaviour for free.

**Horizontal/list cards are not automatically bespoke.** Check the installed store-components version for supported variants, then existing repo compositions, Vanilla `p-media-object`, lists, cards, and the grid. A missing horizontal variant in one package does not justify custom CSS. If no reusable composition fits, flag a shared-library gap and ask before adding an exception (step 6).

**Lint/build/test commands (run these before declaring done):**
- `npx tsc --noEmit -p tsconfig.json` — distinguish new errors from pre-existing failures and report both; do not claim the check passed just because your files are absent from the errors.
- `npx eslint <paths>` — eslint enforces Prettier; `npx eslint --fix` resolves formatting nits.
- `npx stylelint static/sass/_your_partial.scss` — enforces **alphabetical property order ignoring vendor prefixes** (so `-webkit-box-orient` sorts as `box-orient`, before `color`/`display`).
- `npx vitest run --coverage=false <path>` — disable coverage if the existing `coverage/` directory has permission errors; do not delete unrelated artifacts to make the run pass.
- `npx vite build` — full SPA build; confirms imports resolve.
- Verified-to-exist Vanilla SCSS vars: `$spv--{x-small..x-large}`, `$sph--{small,large}`, `$color-light`, `$color-dark`, `$color-mid-light`, `$colors--theme--text-muted`, `$color-accent`.

**Tests assume current defaults.** Changing the default tab/route or removing an always-rendered child (e.g. a topics strip) will break existing tests. Update them by targeting the relevant state via `<MemoryRouter initialEntries={["/?type=charms"]}>` rather than deleting assertions.

## Using this skill in other agents

See [README.md](README.md) for installation, including OpenCode, Figma MCP setup, secure authentication, and troubleshooting. Keep `SKILL.md` and `references/` together. Tool capabilities are provider-specific: use the Prerequisites mapping and current schemas, not guessed equivalent names. Restart OpenCode after installing or updating the skill or its configuration.
