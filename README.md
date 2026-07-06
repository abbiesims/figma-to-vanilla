# Canonical agent skills

Portable [Agent Skills](https://docs.claude.com/en/docs/agents-and-tools/agent-skills/overview)
for the webteam. A skill is a plain folder with a `SKILL.md` (YAML frontmatter
`name` + `description`, then Markdown instructions) plus optional reference
files. The format is agent-agnostic — it works with pi, Claude Code, and any
agent that supports skills (or as pasted context for those that don't).

## Skills

| Skill | What it does |
|---|---|
| `figma-to-vanilla` | Implement UI from a Figma design using Canonical's Vanilla Framework and `@canonical/react-components` for snapcraft.io / charmhub.io. |

## Install

Pick the option that matches your agent. Replace `abbiesims/figma-to-vanilla` with
the repo's real location if it differs.

### Option 1 — pi package (recommended for pi users)

pi can install skills straight from git — no clone or symlink needed:

```bash
pi install git:github.com/abbiesims/figma-to-vanilla
```

To share with your whole team on a project, install into **project** settings so
it's committed to `.pi/settings.json` and pi auto-installs it for anyone who
trusts the project:

```bash
pi install -l git:github.com/abbiesims/figma-to-vanilla
```

Update to a newer version with the same command (optionally pin a ref, e.g.
`git:github.com/abbiesims/figma-to-vanilla@v1`). Manage what's enabled with
`pi config`.

### Option 2 — install script (any agent, any location)

Clone this repo **anywhere**, then run the installer. It resolves paths relative
to itself, so your clone location doesn't matter:

```bash
git clone git@github.com:abbiesims/figma-to-vanilla.git
cd figma-to-vanilla
./install.sh                 # symlink all skills into pi (~/.agents/skills)
./install.sh --agent claude  # Claude Code (~/.claude/skills)
./install.sh --copy          # copy a snapshot instead of symlinking
./install.sh --dir <path>    # any explicit skills directory
```

Symlinking (the default) keeps you on the latest version after a `git pull` and
lets you commit edits back. Use `--copy` for a fixed snapshot.

### Option 3 — manual / agents without skill support

Skills are just files, so you can place them by hand:

```bash
ln -s "$PWD/skills/figma-to-vanilla" ~/.agents/skills/figma-to-vanilla   # pi
ln -s "$PWD/skills/figma-to-vanilla" ~/.claude/skills/figma-to-vanilla   # Claude Code
```

Per-harness skills directories:

- **pi**: `~/.agents/skills/` (global) or a project-local skills dir
- **Claude Code**: `~/.claude/skills/` or `.claude/skills/` in a project
- **Any agent without skill support**: open the skill's `SKILL.md` and paste it as context, or point the agent at the file

## Set up Figma access (required)

The skill reads designs directly from Figma, so every user needs the Figma tools
and their **own** personal access token. Nothing about auth is stored in this
repo — it's per-person.

1. **Install the Figma tools** (once):
   ```bash
   pi install npm:pi-mono-figma
   ```
   (Other agents: connect the [Figma MCP server](https://modelcontextprotocol.io/) instead — same `figma_*` capabilities.)

2. **Create a Figma token**: in Figma, go to **Settings → Security → Personal access tokens → Generate new token**, with at least **read** access to file content. Copy it (you only see it once).

3. **Store the token securely** (once):
   ```
   /figma-auth --force
   ```
   Paste the token into the secure prompt. **Don't** paste tokens into the chat. If you skip this, the skill will prompt you to authenticate on its first Figma call.

4. Make sure you have at least **view access** to the Figma file you want to implement.

## Using the skill

Once installed and authenticated, just give your agent a Figma URL and ask it to
implement the design. Example prompt:

> Use the figma-to-vanilla skill to implement this design in charmhub: `https://www.figma.com/design/<fileKey>/<name>?node-id=<node>`

Tips:
- **Copy the URL of a specific frame/node** (right-click a frame in Figma → *Copy link to selection*) so the skill targets exactly what you want.
- Run the agent from **inside the target repo** (e.g. the `stores` monorepo) so it can read the installed `@canonical/*` components and write files in the right place.
- The skill will: parse the URL → render the node → pull structured design context → map elements to `@canonical/store-components` / `@canonical/react-components` / Vanilla classes → write the code → validate its output against the design and iterate.
- It deliberately **minimises custom CSS** and reuses existing components; if something has no component equivalent it will flag it as a shared-library gap rather than hand-rolling CSS.

For the optional visual-validation step the agent can screenshot its output with
a headless browser — install `google-chrome`/`chromium` if you want that (it falls
back to structural checks otherwise).

## Requirements

- **A supported agent** — pi, Claude Code, or any agent that can read a skill folder (or accept `SKILL.md` as pasted context).
- **Figma access** (for `figma-to-vanilla`): in pi, the `pi-mono-figma` package (`pi install npm:pi-mono-figma`, then `/figma-auth --force`); in other agents, the [Figma MCP server](https://modelcontextprotocol.io/). Both expose equivalent `figma_*` capabilities.
- **A headless browser** (optional, for the visual-validation harness): `google-chrome` / `chromium`, plus `npx sass-embedded` to compile the repo's SCSS.

## Contributing

Edit `skills/<name>/SKILL.md`, commit, push. If you installed via symlink your
local agent picks up changes immediately.
