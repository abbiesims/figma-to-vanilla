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

Clone the repo, then symlink (preferred) or copy a skill into your agent's
skills directory. Symlinking keeps you on the latest version and lets you commit
edits back.

```bash
git clone git@github.com:canonical/agent-skills.git ~/canonical/agent-skills
```

Install paths per harness:

- **pi**: `~/.agents/skills/` (global) or a project-local skills dir
- **Claude Code**: `~/.claude/skills/` or `.claude/skills/` in a project
- **Other / no skill support**: open `SKILL.md` and paste it as context, or point the agent at the file

```bash
# pi example
ln -s ~/canonical/agent-skills/skills/figma-to-vanilla ~/.agents/skills/figma-to-vanilla
```

## Requirements

`figma-to-vanilla` needs Figma access:
- **pi**: `pi install npm:pi-mono-figma`, then `/figma-auth --force`
- **other agents**: the Figma MCP server (MCP is cross-agent)

## Contributing

Edit `skills/<name>/SKILL.md`, commit, push. If you installed via symlink your
local agent picks up changes immediately.
