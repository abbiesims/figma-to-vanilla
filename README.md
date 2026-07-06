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

Clone this repo **anywhere** you like, then run the installer. It resolves paths
relative to itself, so your clone location doesn't matter.

```bash
git clone git@github.com:canonical/agent-skills.git
cd agent-skills
./install.sh                 # symlink all skills into pi (~/.agents/skills)
```

Options:

```bash
./install.sh --agent claude  # install into Claude Code (~/.claude/skills)
./install.sh --copy          # copy a snapshot instead of symlinking (no auto-updates)
./install.sh --dir <path>    # install into an explicit skills directory
```

Symlinking (the default) keeps you on the latest version after a `git pull` and
lets you commit edits back. Use `--copy` if you'd rather take a fixed snapshot.

### Manual install / other agents

The installer only creates symlinks or copies — you can do it by hand too. Skills
live in these directories per harness:

- **pi**: `~/.agents/skills/` (global) or a project-local skills dir
- **Claude Code**: `~/.claude/skills/` or `.claude/skills/` in a project
- **Any agent without skill support**: open the skill's `SKILL.md` and paste it as context, or point the agent at the file

```bash
# e.g. pi, manually
ln -s "$PWD/skills/figma-to-vanilla" ~/.agents/skills/figma-to-vanilla
```

## Requirements

`figma-to-vanilla` needs Figma access:
- **pi**: `pi install npm:pi-mono-figma`, then `/figma-auth --force`
- **other agents**: the Figma MCP server (MCP is cross-agent)

## Contributing

Edit `skills/<name>/SKILL.md`, commit, push. If you installed via symlink your
local agent picks up changes immediately.
