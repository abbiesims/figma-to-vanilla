# Vanilla Framework Component Reference

Canonical docs: https://vanillaframework.io/docs  
Source: https://github.com/canonical/vanilla-framework

All patterns use the `p-` prefix. Layouts use `l-`. Utilities use `u-`.

---

## Grid

```html
<!-- 12-column row -->
<div class="row">
  <div class="col-12">Full width</div>
</div>

<!-- Two halves -->
<div class="row">
  <div class="col-6">Left</div>
  <div class="col-6">Right</div>
</div>

<!-- Responsive: 4/8 large, 2/4 medium, stacked small -->
<div class="row">
  <div class="col-4 col-medium-2">Sidebar</div>
  <div class="col-8 col-medium-4">Main</div>
</div>
```

Breakpoints: large (≥1036px, 12 cols), medium (≥772px, 6 cols), small (<772px, 4 cols).

---

## Buttons

```html
<!-- Default -->
<button class="p-button">Default</button>

<!-- Appearances -->
<button class="p-button--positive">Save</button>
<button class="p-button--negative">Delete</button>
<button class="p-button--brand">Brand</button>
<button class="p-button--base">Base</button>
<button class="p-button--link">Link style</button>

<!-- Modifiers -->
<button class="p-button is-dense">Dense</button>
<button class="p-button" disabled>Disabled</button>
<button class="p-button is-processing">
  <i class="p-icon--spinner u-animation--spin"></i>
  <span>Processing...</span>
</button>

<!-- Inline group -->
<div class="p-button-group">
  <button class="p-button">Cancel</button>
  <button class="p-button--positive">Confirm</button>
</div>
```

---

## Notifications

```html
<!-- Information -->
<div class="p-notification--information">
  <div class="p-notification__content">
    <h5 class="p-notification__title">Title</h5>
    <p class="p-notification__message">Message text.</p>
  </div>
</div>

<!-- Positive / Success -->
<div class="p-notification--positive">
  <div class="p-notification__content">
    <h5 class="p-notification__title">Success</h5>
    <p class="p-notification__message">Changes saved.</p>
  </div>
</div>

<!-- Negative / Error -->
<div class="p-notification--negative">
  <div class="p-notification__content">
    <h5 class="p-notification__title">Error</h5>
    <p class="p-notification__message">Something went wrong.</p>
  </div>
</div>

<!-- Caution / Warning -->
<div class="p-notification--caution">
  <div class="p-notification__content">
    <h5 class="p-notification__title">Warning</h5>
    <p class="p-notification__message">Proceed with care.</p>
  </div>
</div>

<!-- Dismissible (add button) -->
<div class="p-notification--information">
  <div class="p-notification__content">
    <h5 class="p-notification__title">Info</h5>
    <p class="p-notification__message">Message.</p>
  </div>
  <div class="p-notification__actions">
    <button class="p-notification__action u-no-margin--bottom" aria-label="Dismiss notification">
      <i class="p-icon--close">Dismiss</i>
    </button>
  </div>
</div>
```

---

## Cards

```html
<!-- Basic card -->
<div class="p-card">
  <h3>Card title</h3>
  <p class="p-card__content">Card body content.</p>
</div>

<!-- Card with header image -->
<div class="p-card">
  <div class="p-card__header">
    <img src="..." alt="" />
  </div>
  <h3>Title</h3>
  <p class="p-card__content">Content.</p>
  <div class="p-card__footer">
    <button class="p-button--positive">Action</button>
  </div>
</div>

<!-- Highlighted card -->
<div class="p-card--highlighted">
  <h3>Highlighted</h3>
  <p class="p-card__content">Stands out visually.</p>
</div>

<!-- Overlay card -->
<div class="p-card--overlay">
  <h3>Overlay</h3>
  <p class="p-card__content">Used on image backgrounds.</p>
</div>
```

---

## Forms

```html
<form class="p-form">
  <!-- Text input -->
  <div class="p-form__group">
    <label for="name">Name</label>
    <input type="text" id="name" class="p-form-validation__input" name="name" />
    <p class="p-form-help-text">Help text here.</p>
  </div>

  <!-- Select -->
  <div class="p-form__group">
    <label for="status">Status</label>
    <select id="status" name="status">
      <option value="" disabled selected>Select an option</option>
      <option value="active">Active</option>
    </select>
  </div>

  <!-- Textarea -->
  <div class="p-form__group">
    <label for="description">Description</label>
    <textarea id="description" name="description"></textarea>
  </div>

  <!-- Checkbox -->
  <label class="p-checkbox">
    <input type="checkbox" class="p-checkbox__input" id="agree" />
    <span class="p-checkbox__label" id="agree-label">I agree</span>
  </label>

  <!-- Radio -->
  <label class="p-radio">
    <input type="radio" class="p-radio__input" name="choice" value="a" />
    <span class="p-radio__label">Option A</span>
  </label>

  <!-- Validation error state -->
  <div class="p-form-validation is-error">
    <label for="email">Email</label>
    <div class="p-form-validation__field">
      <input type="email" id="email" class="p-form-validation__input" />
    </div>
    <p class="p-form-validation__message">
      <i class="p-icon--error">Error:</i> Please enter a valid email.
    </p>
  </div>
</form>
```

---

## Tables

```html
<!-- Basic table -->
<table class="p-table">
  <thead>
    <tr>
      <th>Name</th>
      <th>Status</th>
      <th class="u-align--right">Actions</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>my-snap</td>
      <td><span class="p-status-label--positive">Published</span></td>
      <td class="u-align--right">
        <button class="p-button is-dense">Edit</button>
      </td>
    </tr>
  </tbody>
</table>

<!-- Sortable: add aria-sort to th -->
<th aria-sort="ascending">Name</th>
```

---

## Navigation

```html
<header id="navigation" class="p-navigation is-dark">
  <div class="p-navigation__row--25-75">
    <div class="p-navigation__banner">
      <div class="p-navigation__tagged-logo">
        <a class="p-navigation__link" href="/">
          <div class="p-navigation__logo-tag">
            <img class="p-navigation__logo-icon" src="..." alt="" />
          </div>
          <span class="p-navigation__logo-title">Snapcraft</span>
        </a>
      </div>
      <!-- Mobile toggle -->
      <ul class="p-navigation__items">
        <li class="p-navigation__item">
          <button class="js-menu-button p-navigation__link">Menu</button>
        </li>
      </ul>
    </div>
    <nav class="p-navigation__nav" aria-label="Main navigation">
      <ul class="p-navigation__items">
        <li class="p-navigation__item is-selected">
          <a class="p-navigation__link" href="/store">Store</a>
        </li>
        <li class="p-navigation__item">
          <a class="p-navigation__link" href="/publish">Publish</a>
        </li>
      </ul>
    </nav>
  </div>
</header>
```

---

## Side Navigation

```html
<nav class="p-side-navigation" id="drawer">
  <a href="#drawer" class="p-side-navigation__toggle js-drawer-toggle" aria-controls="drawer">
    Toggle menu
  </a>
  <div class="p-side-navigation__overlay js-drawer-toggle" aria-controls="drawer"></div>
  <div class="p-side-navigation__drawer">
    <div class="p-side-navigation__drawer-header">
      <a href="#" class="p-side-navigation__toggle--in-drawer js-drawer-toggle" aria-controls="drawer">
        Toggle menu
      </a>
    </div>
    <ul class="p-side-navigation__list">
      <li class="p-side-navigation__item">
        <a class="p-side-navigation__link is-active" aria-current="page" href="#">Overview</a>
      </li>
      <li class="p-side-navigation__item">
        <a class="p-side-navigation__link" href="#">Releases</a>
      </li>
      <li class="p-side-navigation__item--title">Section heading</li>
      <li class="p-side-navigation__item">
        <a class="p-side-navigation__link" href="#">Settings</a>
      </li>
    </ul>
  </div>
</nav>
```

---

## Tabs

```html
<div class="p-tabs">
  <div class="p-tabs__list" role="tablist" aria-label="Section label">
    <div class="p-tabs__item">
      <button class="p-tabs__link" role="tab" aria-selected="true"
              aria-controls="panel-1" id="tab-1">Tab one</button>
    </div>
    <div class="p-tabs__item">
      <button class="p-tabs__link" role="tab" aria-selected="false"
              aria-controls="panel-2" id="tab-2" tabindex="-1">Tab two</button>
    </div>
  </div>
  <div role="tabpanel" id="panel-1" aria-labelledby="tab-1">
    <p>Content for tab one.</p>
  </div>
  <div role="tabpanel" id="panel-2" aria-labelledby="tab-2" hidden>
    <p>Content for tab two.</p>
  </div>
</div>
```

---

## Modal

```html
<button aria-controls="my-modal">Open modal</button>

<div class="p-modal" id="my-modal">
  <section class="p-modal__dialog" role="dialog" aria-modal="true"
           aria-labelledby="modal-title" aria-describedby="modal-desc">
    <header class="p-modal__header">
      <h2 class="p-modal__title" id="modal-title">Modal title</h2>
      <button class="p-modal__close" aria-label="Close modal" aria-controls="my-modal">
        Close
      </button>
    </header>
    <p id="modal-desc">Description or body content.</p>
    <footer class="p-modal__footer">
      <button class="p-button" aria-controls="my-modal">Cancel</button>
      <button class="p-button--positive">Confirm</button>
    </footer>
  </section>
</div>
```

---

## Accordion

```html
<aside class="p-accordion">
  <ul class="p-accordion__list">
    <li class="p-accordion__group">
      <div role="heading" aria-level="3" class="p-accordion__heading">
        <button type="button" class="p-accordion__tab"
                id="acc-tab-1" aria-controls="acc-panel-1" aria-expanded="true">
          Section one
        </button>
      </div>
      <section class="p-accordion__panel" id="acc-panel-1"
               aria-hidden="false" aria-labelledby="acc-tab-1">
        <p>Panel content.</p>
      </section>
    </li>
    <li class="p-accordion__group">
      <div role="heading" aria-level="3" class="p-accordion__heading">
        <button type="button" class="p-accordion__tab"
                id="acc-tab-2" aria-controls="acc-panel-2" aria-expanded="false">
          Section two
        </button>
      </div>
      <section class="p-accordion__panel" id="acc-panel-2"
               aria-hidden="true" aria-labelledby="acc-tab-2">
        <p>Panel content.</p>
      </section>
    </li>
  </ul>
</aside>
```

---

## Search Box

```html
<form class="p-search-box">
  <label class="u-off-screen" for="search">Search</label>
  <input type="search" id="search" class="p-search-box__input"
         name="search" placeholder="Search" required autocomplete="on" />
  <button type="reset" class="p-search-box__reset">
    <i class="p-icon--close">Clear</i>
  </button>
  <button type="submit" class="p-search-box__button">
    <i class="p-icon--search">Search</i>
  </button>
</form>
```

---

## Chips

```html
<!-- Default chip -->
<button class="p-chip" aria-pressed="false">
  <span class="p-chip__value">Label</span>
</button>

<!-- Selected -->
<button class="p-chip" aria-pressed="true">
  <span class="p-chip__value">Active</span>
</button>

<!-- With dismiss -->
<span class="p-chip">
  <span class="p-chip__value">Filter</span>
  <button class="p-chip__dismiss" aria-label="Remove filter">
    <i class="p-icon--close">Remove</i>
  </button>
</span>

<!-- Chip group -->
<div class="p-chip-group">
  <button class="p-chip">One</button>
  <button class="p-chip">Two</button>
  <button class="p-chip">Three</button>
</div>
```

---

## Badge

```html
<span class="p-badge" aria-label="9 items">9</span>
<span class="p-badge" aria-label="more than 999 items">999+</span>
```

---

## Status Labels

```html
<div class="p-status-label">Default</div>
<div class="p-status-label--positive">Published</div>
<div class="p-status-label--caution">Pending</div>
<div class="p-status-label--negative">Rejected</div>
<div class="p-status-label--information">In review</div>
```

---

## Contextual Menu

```html
<span class="p-contextual-menu">
  <button class="p-button--base u-no-margin" aria-controls="menu-id">
    <i class="p-icon--menu">Options</i>
  </button>
  <span class="p-contextual-menu__dropdown" id="menu-id" aria-hidden="true">
    <span class="p-contextual-menu__group">
      <button class="p-contextual-menu__link">Edit</button>
      <button class="p-contextual-menu__link">Duplicate</button>
    </span>
    <span class="p-contextual-menu__group">
      <button class="p-contextual-menu__link u-text--negative">Delete</button>
    </span>
  </span>
</span>
```

---

## Tooltip

```html
<!-- Tooltip positions: top, btm, left, right -->
<span class="p-tooltip--top" aria-describedby="tip-1">
  Hover me
  <span class="p-tooltip__message" role="tooltip" id="tip-1">
    Tooltip text
  </span>
</span>
```

---

## Pagination

```html
<nav aria-label="Pagination">
  <ol class="p-pagination">
    <li class="p-pagination__item">
      <a href="#" class="p-pagination__link--previous" aria-label="Previous page">
        <i class="p-icon--chevron-up u-rotate-270">Previous</i>
      </a>
    </li>
    <li class="p-pagination__item">
      <a href="#" class="p-pagination__link" aria-label="Page 1">1</a>
    </li>
    <li class="p-pagination__item">
      <a href="#" class="p-pagination__link is-active" aria-label="Page 2 (current)" aria-current="page">2</a>
    </li>
    <li class="p-pagination__item">
      <a href="#" class="p-pagination__link--next" aria-label="Next page">
        <i class="p-icon--chevron-up u-rotate-90">Next</i>
      </a>
    </li>
  </ol>
</nav>
```

---

## Strips (page sections)

```html
<!-- Default strip -->
<section class="p-strip">
  <div class="row">
    <div class="col-12">...</div>
  </div>
</section>

<!-- Variants -->
<section class="p-strip--light">...</section>
<section class="p-strip--dark">...</section>
<section class="p-strip--deep">...</section>
<section class="p-strip--accent">...</section>
<section class="p-strip--suru">...</section>

<!-- Shallow (reduced padding) -->
<section class="p-strip is-shallow">...</section>

<!-- Bordered top -->
<section class="p-strip is-bordered">...</section>
```

---

## Icons

All icons use `<i class="p-icon--{name}">Accessible text</i>`.

Common icon names:
`plus`, `minus`, `close`, `search`, `menu`, `chevron-up`, `chevron-down`, `external-link`, `information`, `warning`, `error`, `success`, `edit`, `delete`, `copy`, `settings`, `user`, `spinner`, `arrow-right`, `arrow-left`, `refresh`

Animated spinner:
```html
<i class="p-icon--spinner u-animation--spin">Loading...</i>
```

---

## Lists

```html
<!-- Default list (no style) -->
<ul class="p-list">
  <li class="p-list__item">Item</li>
</ul>

<!-- Ticked list -->
<ul class="p-list--divided">
  <li class="p-list__item is-ticked">Done</li>
  <li class="p-list__item is-crossed">Not done</li>
</ul>

<!-- Inline list -->
<ul class="p-inline-list">
  <li class="p-inline-list__item">One</li>
  <li class="p-inline-list__item">Two</li>
</ul>
```

---

## Heading Icon

```html
<div class="p-heading-icon">
  <div class="p-heading-icon__header">
    <img class="p-heading-icon__img" src="..." alt="" />
    <h4 class="p-heading-icon__title">Title with icon</h4>
  </div>
  <p>Description text.</p>
</div>

<!-- Small variant -->
<div class="p-heading-icon--small">
  <div class="p-heading-icon__header">
    <img class="p-heading-icon__img" src="..." alt="" />
    <p class="p-heading-icon__title">Small heading</p>
  </div>
</div>
```

---

## Code Snippet

```html
<div class="p-code-snippet">
  <div class="p-code-snippet__header">
    <h5 class="p-code-snippet__title">filename.py</h5>
  </div>
  <pre class="p-code-snippet__block"><code>print("hello")</code></pre>
</div>

<!-- Numbered lines -->
<div class="p-code-snippet">
  <pre class="p-code-snippet__block--numbered"><code>line one
line two</code></pre>
</div>
```

---

## Switch (toggle)

```html
<label class="p-switch">
  <input type="checkbox" class="p-switch__input" role="switch" id="toggle-1" />
  <span class="p-switch__slider"></span>
  <span class="p-switch__label" id="toggle-label-1">Enable feature</span>
</label>
```

---

## Segmented Control

```html
<div class="p-segmented-control">
  <div class="p-segmented-control__list" role="tablist">
    <button class="p-segmented-control__button" role="tab" aria-selected="true">List</button>
    <button class="p-segmented-control__button" role="tab" aria-selected="false">Grid</button>
  </div>
</div>
```

---

## Key Utility Classes

| Class | Purpose |
|---|---|
| `u-off-screen` | Visually hidden but accessible |
| `u-no-margin` | Remove all margins |
| `u-no-padding` | Remove all padding |
| `u-align--right` | Text/content right-aligned |
| `u-align--center` | Text/content centred |
| `u-text--muted` | Muted/dimmed text |
| `u-text--small` | Small text |
| `u-vertically-center` | Flexbox vertical centering |
| `u-equal-height` | Equal-height children |
| `u-hide` | `display: none` |
| `u-show` | Override hide |
| `u-animation--spin` | Spin animation (for spinners) |
| `u-rotate-90` / `u-rotate-270` | Rotate icon |
| `u-truncate` | Truncate text with ellipsis |
| `u-sv1`–`u-sv6` | Vertical spacing separator |
