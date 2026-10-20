# Staying up to date

picjs is actively developed (0.x), so treat the bundled docs as a **snapshot**.
The runtime version is pinned in `scripts/ensure-picjs.sh` (`PICJS_VERSION`).

## Where to look

| What | URL |
|---|---|
| Original repository (through 0.2.11) | https://github.com/pragdave-devo/picjs |
| Current repository (0.2.12+) | https://github.com/pragdave/picjs |
| Docs home (0.4.0) | https://pragdave.github.io/picjs/ |
| Guide | https://pragdave.github.io/picjs/guide/ |
| Full reference | https://pragdave.github.io/picjs/picjs-reference/ |
| Playground | https://pragdave.github.io/picjs/editor/ |
| npm package (current) | https://www.npmjs.com/package/@pragdave/picjs |
| npm package (original scope) | https://www.npmjs.com/package/@strike48/picjs |
| Registry JSON (latest version) | https://registry.npmjs.org/@pragdave%2Fpicjs |
| Repo file tree (find renamed docs) | https://api.github.com/repos/pragdave/picjs/git/trees/main?recursive=1 |

## Repository provenance

The project began in **`pragdave-devo/picjs`** (created 2026-03-12; 269 commits;
tags through `v0.2.11`; npm scope `@strike48`). That is the **original**
repository and the place to cite as the project's origin.

Releases 0.2.12 → 0.4.0 moved to Dave Thomas's personal account:
**`pragdave/picjs`** (a fork created 2026-09-26; tags `v0.3.0`, `v0.4.0`; npm
scope `@pragdave`). `HISTORY.md` records the move: “The package is now published
as `@pragdave/picjs` (previously `@strike48/picjs`)”. The 0.4.0 docs site
(<https://pragdave.github.io/picjs/>) documents features (such as `last box` /
`2nd last`) that the older <https://pragdave-devo.github.io/picjs/> does not.

This skill pins the **0.4.0** runtime, so `update-from-upstream.sh` syncs from
`pragdave/picjs`; the original repository is the reference for provenance and for
the 0.2.x line. To track 0.2.x deliberately, point `PICJS_REPO_URL` and
`PICJS_VERSION` at `pragdave-devo/picjs` / `@strike48/picjs@0.2.11`, then re-check
the guides: some features this skill documents (referred shapes, palette fixes,
`??` on blocks) do not exist there.

The two official skills are vendored **verbatim** as
`../references/upstream-skill.md` and `../references/upstream-skill-animation.md`;
the update script overwrites them. Put local corrections in `docs/gotchas.md` or
`docs/animation.md` instead of editing the snapshot, or the next sync will lose
them.

## Check and update the runtime

```bash
# from the skill root
npm view @pragdave/picjs version
bash scripts/ensure-picjs.sh --check
```

`ensure-picjs.sh` installs the pinned version into
`${PICJS_HOME:-~/.cache/picjs-skill}`; it does **not** create `node_modules` in
this skill.

To move to a new release:

1. Read `../references/history.md`.
2. Change `PICJS_VERSION` in `scripts/ensure-picjs.sh`.
3. Run `bash scripts/ensure-picjs.sh`.
4. Smoke-test a diagram (below).

Because the project is 0.x, APIs and syntax have changed between releases; bump
deliberately, not automatically.

## Refresh the docs and examples

```bash
# from the skill root
bash scripts/update-from-upstream.sh          # clone main, replace snapshot
bash scripts/update-from-upstream.sh --check  # just print the latest npm version
```

The script:

1. clones `github.com/pragdave/picjs` (shallow);
2. copies `docs/*.md` into `references/` (guide, language, layout, quick
   reference, full reference, animation, grammar, integration, breakdowns);
3. copies `skills/picjs.md` and `skills/picjs-animation.md` into `references/`;
4. replaces `examples/upstream/*.picjs`;
5. copies `LICENSE.md` and `HISTORY.md`;
6. writes `references/upstream-snapshot.md` with the commit hash, UTC date, and
   npm version at sync time.

It never touches `examples/transformer/`, `SKILL.md`, or the `docs/` guides.

If a doc is renamed or added, update the `DOCS` array in
`scripts/update-from-upstream.sh` (use the GitHub tree URL above).

## What to read after an update

1. `../references/history.md` — behaviour changes and fixes.
2. `../references/upstream-snapshot.md` — what commit this snapshot is from.
3. `../references/guide.md` + `../references/quick-reference.md` — syntax refresher.
4. `../references/upstream-skill.md` — the official compact skill (upstream wins
   when this guide and upstream disagree).
5. `../references/upstream-readme.md` — install, CLI, and API entry points.

## Update checklist

```bash
# from the skill root
npm view @pragdave/picjs version
# 1. read ../references/history.md, then bump PICJS_VERSION in scripts/ensure-picjs.sh
bash scripts/ensure-picjs.sh
bash scripts/update-from-upstream.sh
node scripts/render.mjs examples/transformer/transformer.picjs /tmp/picjs-smoke.png
```

If step 4 fails, read the error, compare with
`../references/upstream-skill.md`, and try the same snippet in the online
playground to separate a local setup problem from a language change.
