# Figma to Vanilla skill

The format of this skill is agent-agnostic — it works with pi, Claude Code, OpenCode and any
agent that supports skills (or as pasted context for those that don't).

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

Update to a newer version with the same command. Manage what's enabled with `pi config`.

### Option 2 — install script (any agent, any location)

Clone this repo **anywhere**, then run the installer. It resolves paths relative
to itself, so your clone location doesn't matter:

```bash
git clone git@github.com:abbiesims/figma-to-vanilla.git
cd figma-to-vanilla
./install.sh                 # symlink all skills into pi (~/.agents/skills)
./install.sh --agent claude  # Claude Code (~/.claude/skills)
./install.sh --agent opencode # opencode (~/.config/opencode/skills)
./install.sh --copy          # copy a snapshot instead of symlinking
./install.sh --dir <path>    # any explicit skills directory
```

Symlinking (the default) keeps you on the latest version after a `git pull` and
lets you commit edits back. Use `--copy` for a fixed snapshot.

### Option 3 — manual / agents without skill support

Skills are just files, so you can place them by hand:

```bash
ln -s "$PWD/skills/figma-to-vanilla" ~/.agents/skills/figma-to-vanilla          # pi
ln -s "$PWD/skills/figma-to-vanilla" ~/.claude/skills/figma-to-vanilla          # Claude Code
ln -s "$PWD/skills/figma-to-vanilla" ~/.config/opencode/skills/figma-to-vanilla # opencode
```

Per-harness skills directories:

- **pi**: `~/.agents/skills/` (global) or a project-local skills dir
- **Claude Code**: `~/.claude/skills/` or `.claude/skills/` in a project
- **opencode** (v1.0.190+): `~/.config/opencode/skills/` (global), `.opencode/skills/` (project), or `.claude/skills/`
- **Any agent without skill support**: open the skill's `SKILL.md` and paste it as context, or point the agent at the file

## Set up Figma access (required)

The skill reads designs directly from Figma, so every user needs the Figma tools
connected to their agent and their **own** Figma credentials. Nothing about auth
is stored in this repo — it's per-person. Follow the path for your agent.

### pi

1. **Install the Figma tools** (once):
   ```bash
   pi install npm:pi-mono-figma
   ```
2. **Create a Figma token**: in Figma, go to **Settings → Security → Personal access tokens → Generate new token**, with at least **read** access to file content. Copy it (you only see it once).
3. **Store the token securely** (once):
   ```
   /figma-auth --force
   ```
   Paste the token into the secure prompt. **Don't** paste tokens into the chat. If you skip this, the skill will prompt you to authenticate on its first Figma call.

### opencode (and other MCP-based agents)

There is no `pi-mono-figma` equivalent — opencode is MCP-native, so you connect
Figma's official MCP server instead and its `figma` tools appear automatically.

1. **Add the Figma remote MCP server** to your opencode config — `~/.config/opencode/opencode.json` (global) or `opencode.json` at the project root:
   ```json
   {
     "$schema": "https://opencode.ai/config.json",
     "mcp": {
       "figma": {
         "type": "remote",
         "url": "https://mcp.figma.com/mcp",
         "enabled": true
       }
     }
   }
   ```
   (Or run `opencode mcp add` to set it up interactively.)
2. **Authenticate**: Figma's remote server uses an **OAuth flow** — on first use you'll be prompted to sign in to Figma in your browser. No manual token step needed.

The remote server (`https://mcp.figma.com/mcp`) is Figma's recommended, no-desktop-app option; a desktop-app-based local server also exists for enterprise cases. See the [Figma MCP server docs](https://developers.figma.com/docs/figma-mcp-server/). The remote tool names may differ slightly from pi's `figma_*` names, but the skill's instructions are capability-based, so the agent maps them to whatever the connected server exposes.

### All agents

Make sure you have at least **view access** to the Figma file you want to implement.

## Using the skill

Once installed and authenticated, just give your agent a Figma URL and ask it to
implement the design. Example prompt:

> Use the figma-to-vanilla skill to implement this design in charmhub: `https://www.figma.com/design/<fileKey>/<name>?node-id=<node>`

Tips:
- **Copy the URL of a specific frame/node** (right-click a frame in Figma → *Copy link to selection*) so the skill targets exactly what you want.
- Run the agent from **inside the target repo** so it can read the installed `@canonical/*` components and write files in the right place. For my personal setup, I have added Stores repos and all related Python modules into one directory and I run the skill from that high-level directory.
- The skill will: parse the URL → render the node → pull structured design context → map elements to `@canonical/store-components` / `@canonical/react-components` / Vanilla classes → write the code → validate its output against the design and iterate.
- It deliberately **minimises custom CSS** and reuses existing components; if something has no component equivalent it will flag it as a shared-library gap rather than hand-rolling CSS.

For the optional visual-validation step the agent can screenshot its output with
a headless browser — install `google-chrome`/`chromium` if you want that (it falls
back to structural checks otherwise).

## Requirements

- **A supported agent** — pi, Claude Code, opencode, or any agent that can read a skill folder (or accept `SKILL.md` as pasted context).
- **Figma access** (for `figma-to-vanilla`): in pi, the `pi-mono-figma` package (`pi install npm:pi-mono-figma`, then `/figma-auth --force`); in other agents, the [Figma MCP server](https://developers.figma.com/docs/figma-mcp-server/). Both expose equivalent `figma_*` capabilities.
- **A headless browser** (optional, for the visual-validation harness): `google-chrome` / `chromium`, plus `npx sass-embedded` to compile the repo's SCSS.
