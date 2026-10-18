#!/usr/bin/env bash
# Symlink this skill into a skills directory so agents can discover it.
#
#   bash scripts/install-skill.sh                 # -> <project>/.dsh/skills/picjs
#   bash scripts/install-skill.sh /path/to/skills # -> /path/to/skills/picjs
#
# The canonical copy stays in this project; the link is only for discovery.
# .dsh/skills is the project-local root scanned by the DSH skill loader.

set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_ROOT="${1:-$(dirname "$SKILL_DIR")/.dsh/skills}"
TARGET="$SKILLS_ROOT/picjs"

mkdir -p "$SKILLS_ROOT"

if [[ -e "$TARGET" || -L "$TARGET" ]]; then
  echo "already exists: $TARGET"
  echo "remove it first if you want to relink."
  exit 1
fi

if command -v python3 >/dev/null 2>&1; then
  RELATIVE="$(python3 -c 'import os,sys; print(os.path.relpath(sys.argv[1], sys.argv[2]))' "$SKILL_DIR" "$SKILLS_ROOT")"
  ln -s "$RELATIVE" "$TARGET"
  echo "linked: $TARGET -> $RELATIVE"
else
  ln -s "$SKILL_DIR" "$TARGET"
  echo "linked: $TARGET -> $SKILL_DIR"
fi
echo "restart the agent session (or reload skills) to pick it up."
