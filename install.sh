#!/usr/bin/env bash
#
# Install the skills in this repo into an agent's skills directory.
# Works regardless of where you cloned the repo — it resolves paths
# relative to this script, not a hard-coded location.
#
# Usage:
#   ./install.sh                 # symlink all skills into pi (~/.agents/skills)
#   ./install.sh --agent claude  # install into Claude Code (~/.claude/skills)
#   ./install.sh --copy          # copy instead of symlink (a snapshot; no auto-updates)
#   ./install.sh --dir <path>    # install into an explicit skills directory
#
set -euo pipefail

# Absolute path to this repo's skills/ dir, regardless of cwd or clone location.
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$REPO_DIR/skills"

AGENT="pi"
MODE="symlink"
TARGET_DIR=""

while [ $# -gt 0 ]; do
  case "$1" in
    --agent) AGENT="$2"; shift 2 ;;
    --copy) MODE="copy"; shift ;;
    --dir) TARGET_DIR="$2"; shift 2 ;;
    -h|--help) grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

if [ -z "$TARGET_DIR" ]; then
  case "$AGENT" in
    pi)     TARGET_DIR="$HOME/.agents/skills" ;;
    claude) TARGET_DIR="$HOME/.claude/skills" ;;
    *) echo "Unknown agent '$AGENT'. Use --dir <path> for a custom location." >&2; exit 1 ;;
  esac
fi

mkdir -p "$TARGET_DIR"
echo "Installing skills from $SRC_DIR"
echo "                   into $TARGET_DIR  (mode: $MODE)"
echo

for skill in "$SRC_DIR"/*/; do
  name="$(basename "$skill")"
  dest="$TARGET_DIR/$name"
  rm -rf "$dest"
  if [ "$MODE" = "copy" ]; then
    cp -r "$skill" "$dest"
    echo "  copied   $name"
  else
    ln -s "$skill" "$dest"
    echo "  linked   $name -> $skill"
  fi
done

echo
echo "Done. Restart your agent (or reload skills) to pick them up."
