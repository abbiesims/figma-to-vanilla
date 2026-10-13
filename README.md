# Figma to Vanilla skill

Turn Figma designs into code for snapcraft.io and charmhub.io.
**Use Vanilla components by default. Avoid custom CSS wherever possible.**
For React pages, reuse `@canonical/react-components` and `@canonical/store-components`.

## Install

Choose your agent below. The terminal commands work on Linux, macOS, or Windows with WSL.

### OpenCode

1. Install [Node.js LTS](https://nodejs.org/) if needed, then install OpenCode:

   ```bash
   npm install -g opencode-ai
   opencode --version
   ```

   Skip this if OpenCode is already installed. This installs OpenCode 1;
   for OpenCode 2, use its [installation guide](https://opencode.ai/v2/docs/).

2. Download this repo and install the skill:

   ```bash
   git clone https://github.com/abbiesims/figma-to-vanilla.git
   cd figma-to-vanilla
   ./install.sh --agent opencode
   ```

3. [Connect Figma](skills/figma-to-vanilla/README.md#install-in-opencode), starting at step 3.
   Skip this if your Figma tools already work.

4. Restart OpenCode. Run `opencode` from the application repo you want to edit.
   Use `/connect` inside OpenCode to connect your model provider if needed.

### pi

Run these commands in your terminal:

```bash
pi install git:github.com/abbiesims/figma-to-vanilla
pi install npm:pi-mono-figma
```

Create a [Figma personal access token](https://help.figma.com/hc/en-us/articles/8085703771159-Manage-personal-access-tokens)
with `file_content:read` access. In pi, run `/figma-auth --force` and enter the token
in the secure prompt. Restart pi after installation.

### Claude Code

```bash
git clone https://github.com/abbiesims/figma-to-vanilla.git
cd figma-to-vanilla
./install.sh --agent claude
```

Connect Figma using its [Claude Code setup guide](https://developers.figma.com/docs/figma-mcp-server/remote-server-installation/#claude-code),
then restart Claude Code.

### Other agents

Copy the whole `skills/figma-to-vanilla/` folder into your agent's skills directory
and connect compatible Figma tools. If your agent has no skill support, give it
[SKILL.md](skills/figma-to-vanilla/SKILL.md) and the linked references as context.

## Use

You need view access to the Figma file. Never paste access tokens into chat or commit them.

1. Start your agent in the application repo you want to edit.
2. In Figma, right-click the frame and choose **Copy link to selection**.
3. Give your agent the link with this prompt:

   ```text
   Use the figma-to-vanilla skill to implement this design: <Figma frame URL>.
   Use Vanilla components and avoid custom CSS wherever possible.
   ```

The skill reuses existing components and checks the result against the design.
Missing shared-library features are reported rather than rebuilt with custom CSS.
Chrome or Chromium is optional for screenshot checks.

## Update

For pi, run the skill installation command again.
For a cloned repo, run `git pull` from that clone. The installer links to the clone,
so updates are picked up after restarting your agent.

The installer replaces the skill at its destination. Preserve local edits before
running it again. Use `--copy` for a fixed copy instead of a link, or `--dir <path>`
for a custom skills directory. Copied installations need the installer rerun to update.

OpenCode also reads `~/.agents/skills/`; if the skill is already there, do not install a duplicate.

For detailed setup and troubleshooting, see the [setup guide](skills/figma-to-vanilla/README.md).
