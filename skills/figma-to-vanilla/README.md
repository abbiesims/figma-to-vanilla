# Figma-to-Vanilla Skill

Implement Figma designs with existing Canonical components and Vanilla Framework. **Use Vanilla components, patterns, the grid, and utilities wherever possible. Do not add custom CSS to recreate an existing component or chase minor pixel differences.**

## Install in OpenCode

These terminal instructions are for Linux, macOS, or Windows with WSL. If OpenCode is already installed, skip step 1. Do not replace an existing team-managed installation.

1. **Install OpenCode.** Install a supported Node.js LTS release from https://nodejs.org/ if needed (npm is included), then run:

   ```bash
   npm install -g opencode-ai
   opencode --version
   ```

   This is the OpenCode 1 installation documented at https://opencode.ai/docs/. OpenCode 1 and 2 share the `opencode` command; do not install one over the other unintentionally. For OpenCode 2, follow https://opencode.ai/v2/docs/ instead.

2. **Install the skill folder.** From the directory containing `figma-to-vanilla/`, run:

   ```bash
   mkdir -p "$HOME/.config/opencode/skills"
   cp -R figma-to-vanilla "$HOME/.config/opencode/skills/"
   ```

   Copy the entire folder, including `references/`. The result must include `~/.config/opencode/skills/figma-to-vanilla/SKILL.md`. For one project only, use `.opencode/skills/figma-to-vanilla/` in that project instead. If the skill already lives at `~/.agents/skills/figma-to-vanilla/`, OpenCode discovers it automatically; do not install a duplicate.

3. **Connect Figma, if it is not already connected.** Skip this step if the agent can already read your target Figma node. Otherwise, the local [Framelink MCP server](https://github.com/GLips/Figma-Context-MCP) exposes `get_figma_data` and `download_figma_images` through Figma's API. It is a third-party server, not Figma's official server; review it and confirm your team allows it before use.

   Create your own [Figma personal access token](https://help.figma.com/hc/en-us/articles/8085703771159-Manage-personal-access-tokens) with `file_content:read` scope. You must also have view access to the design. In a Bash terminal, enter it without displaying it or adding it to shell history:

   ```bash
   read -rsp "Figma personal access token: " FIGMA_API_KEY
   export FIGMA_API_KEY
   ```

   Merge the following into `~/.config/opencode/opencode.json`. Create that file if it does not exist; preserve any existing settings and MCP servers. Do not put the token itself in the file.

   ```json
   {
     "$schema": "https://opencode.ai/config.json",
     "mcp": {
       "figma": {
         "type": "local",
         "command": ["npx", "-y", "figma-developer-mcp", "--stdio"],
         "enabled": true,
         "environment": {
           "FIGMA_API_KEY": "{env:FIGMA_API_KEY}"
         }
       }
     }
   }
   ```

   The environment variable is available only to processes launched from that terminal. Repeat the secure prompt in a new terminal, or use your team's approved secret manager. Never paste tokens into chat or commit them. Figma's official remote MCP is a separate OAuth-based option, but its current documentation restricts clients to its MCP catalog; do not assume OpenCode access without checking https://developers.figma.com/docs/figma-mcp-server/remote-server-installation/.

4. **Restart and check.** Quit any running OpenCode session. In the terminal with `FIGMA_API_KEY` set, run `opencode mcp list` to check the configured server, then run `opencode` from your application repository. Use `/connect` in OpenCode to connect your model provider if needed. Restart after changing skills or configuration; existing sessions retain their loaded configuration.

5. **Use the skill.** Copy a link to the specific frame in Figma, including `node-id`, and ask:

   ```text
   Use the figma-to-vanilla skill to implement this design: <Figma frame URL>.
   Reuse existing Canonical and Vanilla components. Avoid custom CSS wherever
   possible, and flag shared-library gaps rather than rebuilding components.
   ```

## Troubleshooting

- **Skill missing:** check the exact `SKILL.md` filename, folder location, skill permissions, and duplicate installations, then restart OpenCode.
- **Figma tools missing:** check `opencode mcp list`, Node.js/npm availability, and the MCP configuration. Installing the skill alone does not install Figma tools.
- **Access denied:** confirm the token is exported in the terminal launching OpenCode, has not expired, has `file_content:read` scope, and belongs to a user who can view the file.
- **No screenshot tool:** provide a Figma export or use the available image-download tool to export the target frame. Missing pi-specific tools are not a reason to reinstall working Figma tooling.

## Other Agents

Copy the whole folder into the agent's skill directory: pi uses `~/.agents/skills/`; Claude Code uses `~/.claude/skills/` or a project's `.claude/skills/`. In pi, install Figma tooling with `pi install npm:pi-mono-figma` and configure credentials with `/figma-auth --force`. Those commands are pi-only, not OpenCode commands.

For implementation instructions, see [SKILL.md](SKILL.md). Use each agent's available Figma tools rather than assuming identical tool names or authentication methods.
