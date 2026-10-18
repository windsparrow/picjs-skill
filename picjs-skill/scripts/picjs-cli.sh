#!/usr/bin/env bash
# Run the picjs CLI from the runtime cache (installs it on first use).
#
#   bash scripts/picjs-cli.sh process README.md
#   bash scripts/picjs-cli.sh watch README.md

set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PICJS_HOME="${PICJS_HOME:-${XDG_CACHE_HOME:-$HOME/.cache}/picjs-skill}"
CLI="$PICJS_HOME/node_modules/@pragdave/picjs/dist/cli.js"

if [[ ! -f "$CLI" ]]; then
  bash "$SKILL_DIR/scripts/ensure-picjs.sh"
fi

exec node "$CLI" "$@"
