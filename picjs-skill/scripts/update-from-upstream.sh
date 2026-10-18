#!/usr/bin/env bash
# Refresh the bundled picjs docs and examples from the upstream repository.
#
#   bash scripts/update-from-upstream.sh          # fetch and replace snapshot
#   bash scripts/update-from-upstream.sh --check  # only report the latest version
#
# The example diagrams in examples/transformer/ are never touched.

set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_URL="${PICJS_REPO_URL:-https://github.com/pragdave/picjs.git}"
DOCS=(
  guide
  language
  layout
  quick-reference
  picjs-reference
  animation
  grammar
  integrating
  hanoi-breakdown
  bubble-sort-breakdown
  higher-level-hanoi-breakdown
)

latest_version() {
  local version
  # The registry is authoritative and does not need a writable npm cache.
  version="$(curl -fsSL --retry 2 "https://registry.npmjs.org/@pragdave%2Fpicjs" 2>/dev/null \
    | python3 -c 'import json,sys; print(json.load(sys.stdin)["dist-tags"]["latest"])' 2>/dev/null || true)"
  if [[ -z "$version" ]]; then
    version="$(npm view @pragdave/picjs version 2>/dev/null || true)"
  fi
  echo "${version:-unknown}"
}

echo "skill:        $SKILL_DIR"
echo "repository:   $REPO_URL"
echo "npm latest:   $(latest_version)"

if [[ "${1:-}" == "--check" ]]; then
  exit 0
fi

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

echo "cloning (shallow)..."
git clone --depth 1 "$REPO_URL" "$tmp/picjs" >/dev/null 2>&1
commit="$(git -C "$tmp/picjs" rev-parse --short HEAD)"

mkdir -p "$SKILL_DIR/references" "$SKILL_DIR/examples/upstream"

for doc in "${DOCS[@]}"; do
  cp "$tmp/picjs/docs/$doc.md" "$SKILL_DIR/references/$doc.md"
done

cp "$tmp/picjs/HISTORY.md" "$SKILL_DIR/references/history.md"
cp "$tmp/picjs/README.md" "$SKILL_DIR/references/upstream-readme.md"
cp "$tmp/picjs/skills/picjs.md" "$SKILL_DIR/references/upstream-skill.md"
cp "$tmp/picjs/skills/picjs-animation.md" "$SKILL_DIR/references/upstream-skill-animation.md"
cp "$tmp/picjs/LICENSE.md" "$SKILL_DIR/LICENSE-picjs.md"

# Replace the upstream examples wholesale so removed files do not linger.
rm -f "$SKILL_DIR/examples/upstream/"*.picjs
cp "$tmp/picjs"/examples/*.picjs "$SKILL_DIR/examples/upstream/"

cat > "$SKILL_DIR/references/upstream-snapshot.md" <<EOF
# Upstream snapshot

- Repository: <$REPO_URL>
- Commit: \`$commit\`
- Synced: \`$(date -u +%Y-%m-%dT%H:%M:%SZ)\`
- npm latest at sync time: \`$(latest_version)\`

Refresh with \`bash scripts/update-from-upstream.sh\`.

If the npm version moved, change \`PICJS_VERSION\` in
\`scripts/ensure-picjs.sh\`, then run \`bash scripts/ensure-picjs.sh\`.
EOF

echo "updated docs + examples from commit $commit"
echo "see references/upstream-snapshot.md"
