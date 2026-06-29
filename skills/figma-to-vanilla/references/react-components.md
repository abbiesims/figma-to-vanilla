# @canonical/react-components Reference

Package: `@canonical/react-components`  
Storybook: https://canonical.github.io/react-components  
Source: https://github.com/canonical/react-components

All components are imported from `@canonical/react-components`:
```tsx
import { Button, Card, Notification } from "@canonical/react-components";
```

---

## Button

```tsx
import { Button, ButtonAppearance } from "@canonical/react-components";

<Button>Default</Button>
<Button appearance={ButtonAppearance.POSITIVE}>Save</Button>
<Button appearance={ButtonAppearance.NEGATIVE}>Delete</Button>
<Button appearance={ButtonAppearance.BRAND}>Brand</Button>
<Button appearance={ButtonAppearance.BASE}>Base</Button>
<Button appearance={ButtonAppearance.LINK}>Link</Button>
<Button dense>Dense</Button>
<Button disabled>Disabled</Button>
<Button element="a" href="/path">Link button</Button>
```

`ButtonAppearance` values: `BASE`, `BRAND`, `DEFAULT` (`""`), `LINK`, `NEGATIVE`, `POSITIVE`

---

## ActionButton

Button with built-in loading/success/error state handling:

```tsx
import { ActionButton } from "@canonical/react-components";

<ActionButton
  appearance="positive"
  loading={isLoading}
  success={isSuccess}
  onClick={handleClick}
>
  Save changes
</ActionButton>
```

---

## ConfirmationButton / ConfirmationModal

```tsx
import { ConfirmationButton } from "@canonical/react-components";

<ConfirmationButton
  onConfirm={handleDelete}
  confirmButtonLabel="Delete"
  confirmButtonAppearance="negative"
  message="Are you sure you want to delete this?"
>
  Delete snap
</ConfirmationButton>
```

---

## Card

```tsx
import { Card } from "@canonical/react-components";

<Card title="Card title">
  <p>Card body content.</p>
</Card>

<Card highlighted title="Highlighted card">
  <p>Stands out visually.</p>
</Card>
```

---

## Notification

```tsx
import { Notification } from "@canonical/react-components";

<Notification severity="information" title="Info">
  Message text.
</Notification>

<Notification severity="positive" title="Success">
  Changes saved.
</Notification>

<Notification severity="negative" title="Error">
  Something went wrong.
</Notification>

<Notification severity="caution" title="Warning">
  Proceed with care.
</Notification>

<!-- Dismissible -->
<Notification
  severity="information"
  title="Info"
  onDismiss={() => setVisible(false)}
>
  Message.
</Notification>

<!-- Inline (no border/background) -->
<Notification severity="caution" title="Warning" inline>
  Brief warning.
</Notification>
```

`severity` values: `"information"` | `"positive"` | `"negative"` | `"caution"`

---

## NotificationProvider / Notifications

For toast-style notifications managed via context:

```tsx
import { NotificationProvider, useNotify } from "@canonical/react-components";

// Wrap your app/section
<NotificationProvider>
  <MyComponent />
</NotificationProvider>

// Inside a component
const notify = useNotify();
notify.success("Saved successfully.");
notify.failure("Save failed.", error);
notify.info("Processing...");
```

---

## Form, Input, Field, Label

```tsx
import { Form, Input, Select, Textarea, CheckboxInput, RadioInput, Field } from "@canonical/react-components";

<Form onSubmit={handleSubmit}>
  <Input
    id="name"
    label="Name"
    type="text"
    help="Enter your display name."
    required
  />

  <Input
    id="email"
    label="Email"
    type="email"
    error={errors.email}
  />

  <Select
    id="status"
    label="Status"
    options={[
      { value: "", label: "Select...", disabled: true },
      { value: "active", label: "Active" },
      { value: "inactive", label: "Inactive" },
    ]}
  />

  <Textarea
    id="description"
    label="Description"
    rows={4}
  />

  <CheckboxInput
    id="agree"
    label="I agree to the terms"
    checked={agreed}
    onChange={(e) => setAgreed(e.target.checked)}
  />

  <RadioInput
    id="option-a"
    label="Option A"
    name="choice"
    value="a"
  />
</Form>
```

---

## SearchBox

```tsx
import { SearchBox } from "@canonical/react-components";

<SearchBox
  value={query}
  onChange={setQuery}
  onSearch={handleSearch}
  onClear={() => setQuery("")}
  placeholder="Search snaps..."
  externallyControlled
/>
```

---

## SearchAndFilter

Advanced filter UI with chips:

```tsx
import { SearchAndFilter } from "@canonical/react-components";

<SearchAndFilter
  filterPanelData={[
    {
      id: "status",
      heading: "Status",
      chips: [
        { lead: "Status", value: "Published" },
        { lead: "Status", value: "Draft" },
      ],
    },
  ]}
  returnSearchData={(data) => setFilters(data)}
/>
```

---

## MainTable

Full-featured sortable table with pagination:

```tsx
import { MainTable } from "@canonical/react-components";

<MainTable
  headers={[
    { content: "Name", sortKey: "name" },
    { content: "Status", sortKey: "status" },
    { content: "Actions", className: "u-align--right" },
  ]}
  rows={snaps.map((snap) => ({
    key: snap.name,
    columns: [
      { content: snap.name },
      {
        content: (
          <StatusLabel appearance="positive">Published</StatusLabel>
        ),
      },
      {
        content: <Button dense>Edit</Button>,
        className: "u-align--right",
      },
    ],
  }))}
  sortable
  emptyStateMsg="No snaps found."
/>
```

---

## ModularTable

Simpler table driven by column definitions:

```tsx
import { ModularTable } from "@canonical/react-components";

<ModularTable
  columns={[
    { Header: "Name", accessor: "name" },
    { Header: "Version", accessor: "version" },
  ]}
  data={rows}
  emptyMsg="No results."
/>
```

---

## Tabs

```tsx
import { Tabs } from "@canonical/react-components";

<Tabs
  links={[
    { id: "overview", label: "Overview", active: activeTab === "overview" },
    { id: "releases", label: "Releases", active: activeTab === "releases" },
  ]}
  onClick={(id) => setActiveTab(id)}
/>

{activeTab === "overview" && <OverviewPanel />}
{activeTab === "releases" && <ReleasesPanel />}
```

---

## Modal

```tsx
import { Modal } from "@canonical/react-components";

{isOpen && (
  <Modal
    title="Confirm delete"
    close={() => setIsOpen(false)}
    buttonRow={
      <>
        <Button onClick={() => setIsOpen(false)}>Cancel</Button>
        <Button appearance="negative" onClick={handleDelete}>Delete</Button>
      </>
    }
  >
    <p>This action cannot be undone.</p>
  </Modal>
)}
```

---

## ContextualMenu

```tsx
import { ContextualMenu } from "@canonical/react-components";

<ContextualMenu
  toggleLabel={<Icon name="menu" />}
  toggleAppearance="base"
  links={[
    { children: "Edit", onClick: handleEdit },
    { children: "Duplicate", onClick: handleDuplicate },
    { children: "Delete", onClick: handleDelete, className: "u-text--negative" },
  ]}
/>
```

---

## SideNavigation

```tsx
import { SideNavigation } from "@canonical/react-components";

<SideNavigation
  items={[
    {
      items: [
        { label: "Overview", href: "#overview", active: true },
        { label: "Releases", href: "#releases" },
        { label: "Settings", href: "#settings" },
      ],
    },
  ]}
/>
```

---

## Navigation

```tsx
import { Navigation } from "@canonical/react-components";

<Navigation
  logo={{ src: "/logo.svg", title: "Snapcraft", url: "/" }}
  items={[
    { label: "Store", url: "/store" },
    { label: "Publish", url: "/publish" },
  ]}
  theme="dark"
/>
```

---

## Pagination

```tsx
import { Pagination } from "@canonical/react-components";

<Pagination
  currentPage={page}
  itemsPerPage={20}
  totalItems={totalCount}
  paginate={(p) => setPage(p)}
/>
```

---

## Chip

```tsx
import { Chip } from "@canonical/react-components";

<Chip value="ubuntu" lead="OS" />
<Chip value="active" onDismiss={() => removeFilter("active")} />
```

---

## Badge

```tsx
import { Badge } from "@canonical/react-components";

<Badge value={9} />
<Badge value={1000} />  {/* renders "999+" */}
```

---

## StatusLabel

```tsx
import { StatusLabel } from "@canonical/react-components";

<StatusLabel appearance="positive">Published</StatusLabel>
<StatusLabel appearance="negative">Rejected</StatusLabel>
<StatusLabel appearance="caution">Pending</StatusLabel>
<StatusLabel appearance="information">In review</StatusLabel>
```

---

## Accordion

```tsx
import { Accordion } from "@canonical/react-components";

<Accordion
  sections={[
    {
      title: "What is a snap?",
      content: <p>A snap is a containerised application.</p>,
      key: "snaps",
    },
    {
      title: "How do I publish?",
      content: <p>Use snapcraft to upload your snap.</p>,
      key: "publish",
    },
  ]}
/>
```

---

## Tooltip

```tsx
import { Tooltip } from "@canonical/react-components";

<Tooltip message="This is a tooltip" position="top">
  <Button>Hover me</Button>
</Tooltip>
```

---

## Icon

```tsx
import { Icon } from "@canonical/react-components";

<Icon name="plus" />
<Icon name="close" />
<Icon name="search" />
<Icon name="settings" />
<Icon name="information" />
<Icon name="warning" />
<Icon name="error" />
<Icon name="success" />
<Icon name="external-link" />
<Icon name="spinner" className="u-animation--spin" />
```

---

## Spinner / Loader

```tsx
import { Spinner, Loader } from "@canonical/react-components";

<Spinner />
<Spinner text="Loading..." />
<Loader />  {/* full-page overlay loader */}
```

---

## EmptyState

```tsx
import { EmptyState } from "@canonical/react-components";

<EmptyState
  image={<img src="..." alt="" />}
  title="No snaps yet"
  message="Publish your first snap to get started."
  action={<Button appearance="positive">Publish a snap</Button>}
/>
```

---

## Strip

```tsx
import { Strip } from "@canonical/react-components";

<Strip type="light">
  <Row>
    <Col size={12}>Content</Col>
  </Row>
</Strip>
```

---

## Row / Col

```tsx
import { Row, Col } from "@canonical/react-components";

<Row>
  <Col size={6}>Left half</Col>
  <Col size={6}>Right half</Col>
</Row>

<Row>
  <Col size={4} sizeMedium={2}>Sidebar</Col>
  <Col size={8} sizeMedium={4}>Main</Col>
</Row>
```

---

## Panel / SidePanel

```tsx
import { Panel, SidePanel } from "@canonical/react-components";

<Panel title="Details">
  <p>Panel content.</p>
</Panel>

<SidePanel loading={false}>
  <p>Slide-in panel content.</p>
</SidePanel>
```

---

## ApplicationLayout

Full-page layout wrapper used across the publisher dashboard:

```tsx
import { ApplicationLayout } from "@canonical/react-components";

<ApplicationLayout
  logo={<img src="..." alt="Snapcraft" />}
  sideNavigation={<SideNavigation items={navItems} />}
>
  <main>{children}</main>
</ApplicationLayout>
```

---

## Stepper

Multi-step form progress indicator:

```tsx
import { Stepper } from "@canonical/react-components";

<Stepper
  steps={[
    { title: "Details", status: "complete" },
    { title: "Upload", status: "current" },
    { title: "Review", status: "incomplete" },
  ]}
/>
```

---

## Switch

```tsx
import { Switch } from "@canonical/react-components";

<Switch
  id="feature-toggle"
  label="Enable feature"
  checked={enabled}
  onChange={(e) => setEnabled(e.target.checked)}
/>
```

---

## Slider

```tsx
import { Slider } from "@canonical/react-components";

<Slider
  id="scale"
  label="Scale"
  min={0}
  max={100}
  value={value}
  onChange={(e) => setValue(Number(e.target.value))}
/>
```

---

## ColumnSelector

Column visibility toggle for tables:

```tsx
import { ColumnSelector } from "@canonical/react-components";

<ColumnSelector
  columns={[
    { label: "Name", hidden: false },
    { label: "Version", hidden: true },
  ]}
  onChange={setColumns}
/>
```

---

## MultiSelect / CustomSelect

```tsx
import { MultiSelect, CustomSelect } from "@canonical/react-components";

<MultiSelect
  items={["ubuntu", "debian", "centos"]}
  selectedItems={selected}
  onItemsUpdate={setSelected}
  placeholder="Select OS..."
/>

<CustomSelect
  options={[
    { value: "amd64", label: "amd64" },
    { value: "arm64", label: "arm64" },
  ]}
  value={arch}
  onChange={setArch}
/>
```

---

## ThemeSwitcher

```tsx
import { ThemeSwitcher } from "@canonical/react-components";

<ThemeSwitcher />
```

---

## Component → Vanilla class mapping

| React component | Vanilla CSS equivalent |
|---|---|
| `<Button appearance="positive">` | `<button class="p-button--positive">` |
| `<Notification severity="negative">` | `<div class="p-notification--negative">` |
| `<StatusLabel appearance="caution">` | `<div class="p-status-label--caution">` |
| `<Chip>` | `<button class="p-chip">` |
| `<Badge>` | `<span class="p-badge">` |
| `<Spinner>` | `<i class="p-icon--spinner u-animation--spin">` |
| `<Strip type="light">` | `<section class="p-strip--light">` |
| `<Row>` | `<div class="row">` |
| `<Col size={6}>` | `<div class="col-6">` |
