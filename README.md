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

Pick the option that matches your agent. Replace `canonical/agent-skills` with
the repo's real location if it differs.

### Option 1 — pi package (recommended for pi users)

pi can install skills straight from git — no clone or symlink needed:

```bash
pi install git:github.com/canonical/agent-skills
```

To share with your whole team on a project, install into **project** settings so
it's committed to `.pi/settings.json` and pi auto-installs it for anyone who
trusts the project:

```bash
pi install -l git:github.com/canonical/agent-skills
```

Update to a newer version with the same command (optionally pin a ref, e.g.
`git:github.com/canonical/agent-skills@v1`). Manage what's enabled with
`pi config`.

### Option 2 — install script (any agent, any location)

Clone this repo **anywhere**, then run the installer. It resolves paths relative
to itself, so your clone location doesn't matter:

```bash
git clone git@github.com:canonical/agent-skills.git
cd agent-skills
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

## Requirements

- **A supported agent** — pi, Claude Code, or any agent that can read a skill folder (or accept `SKILL.md` as pasted context).
- **Figma access** (for `figma-to-vanilla`): in pi, the `pi-mono-figma` package (`pi install npm:pi-mono-figma`, then `/figma-auth --force`); in other agents, the [Figma MCP server](https://modelcontextprotocol.io/). Both expose equivalent `figma_*` capabilities.
- **A headless browser** (optional, for the visual-validation harness): `google-chrome` / `chromium`, plus `npx sass-embedded` to compile the repo's SCSS.

## Contributing

Edit `skills/<name>/SKILL.md`, commit, push. If you installed via symlink your
local agent picks up changes immediately.
