#!/usr/bin/env bash
# Check for the picjs runtime, or install it online from npm into a cache.
#
#   bash scripts/ensure-picjs.sh          # install/update the pinned version
#   bash scripts/ensure-picjs.sh --check  # report only; exit 1 if missing
#
# The runtime is never written inside this skill. It goes to
# ${PICJS_HOME:-${XDG_CACHE_HOME:-$HOME/.cache}/picjs-skill}.

set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PICJS_VERSION="${PICJS_VERSION:-0.4.0}"
PICJS_HOME="${PICJS_HOME:-${XDG_CACHE_HOME:-$HOME/.cache}/picjs-skill}"
MODULE_JSON="$PICJS_HOME/node_modules/@pragdave/picjs/package.json"
MODE="${1:-}"

installed_version() {
  [[ -f "$MODULE_JSON" ]] || return 1
  node -p "require('$MODULE_JSON').version" 2>/dev/null
}

local_module() {
  local candidate
  for candidate in \
    "${PICJS_MODULE:-}" \
    "$SKILL_DIR/node_modules/@pragdave/picjs/dist/picjs.js" \
    "$PWD/node_modules/@pragdave/picjs/dist/picjs.js"; do
    if [[ -n "$candidate" && -f "$candidate" ]]; then
      echo "$candidate"
      return 0
    fi
  done
  return 1
}

version="$(installed_version || true)"
if [[ -n "$version" && "$version" == "$PICJS_VERSION" ]]; then
  echo "picjs $version installed at $PICJS_HOME"
  exit 0
fi

if [[ -n "$version" && "$MODE" == "--check" ]]; then
  echo "picjs $version installed at $PICJS_HOME (pinned: $PICJS_VERSION; run without --check to switch)"
  exit 0
fi

if [[ -z "$version" ]] && local_path="$(local_module)"; then
  echo "picjs available at $local_path"
  echo "(PICJS_MODULE or local node_modules; no cache install needed)"
  exit 0
fi

if [[ -n "$version" ]]; then
  echo "updating picjs $version -> $PICJS_VERSION at $PICJS_HOME"
fi

if [[ "$MODE" == "--check" ]]; then
  echo "picjs not installed (wanted $PICJS_VERSION) in $PICJS_HOME" >&2
  echo "run: bash scripts/ensure-picjs.sh" >&2
  exit 1
fi

if ! command -v npm >/dev/null 2>&1; then
  echo "npm not found. Install Node.js/npm, or set PICJS_MODULE to a picjs entry." >&2
  exit 1
fi

mkdir -p "$PICJS_HOME"
echo "installing @pragdave/picjs@$PICJS_VERSION into $PICJS_HOME ..."
install_runtime() {
  npm install --prefix "$PICJS_HOME" --no-save --no-package-lock \
    --cache "$PICJS_HOME/.npm-cache" --fetch-retries=2 \
    "@pragdave/picjs@$PICJS_VERSION"
}

if ! install_runtime; then
  echo "first attempt failed; retrying once..." >&2
  if ! install_runtime; then
    echo "" >&2
    echo "install failed. Offline options:" >&2
    echo "  PICJS_HOME=/path/to/prepared/cache bash scripts/ensure-picjs.sh --check" >&2
    echo "  PICJS_MODULE=/path/to/@pragdave/picjs/dist/picjs.js node scripts/render.mjs ..." >&2
    exit 1
  fi
fi

version="$(installed_version || true)"
if [[ -z "$version" ]]; then
  echo "install finished but $MODULE_JSON is missing" >&2
  exit 1
fi

echo "picjs $version installed at $PICJS_HOME"
echo "module: $PICJS_HOME/node_modules/@pragdave/picjs/dist/picjs.js"
