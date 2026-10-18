# Install: skill and runtime

The **skill** (this folder) and the **picjs runtime** (the npm package) are
separate. The runtime is installed online from npm into a cache, so this skill
does not store `node_modules`.

## 1. Install the skill (once per machine)

The skill is a folder with `SKILL.md`. Put it where the agent scans skills:

```bash
# from the skill root; project-local root, no global permissions needed
bash scripts/install-skill.sh
# -> <project>/.dsh/skills/picjs -> <this folder>
```

The project root is the workspace (the nearest `.git` ancestor, or the current
directory). Restart the session or reload skills.

This skill has `disable-model-invocation: true`, so it is **not** in the model's
automatic catalog. Invoke it explicitly:

- type `/picjs` in the composer (optionally followed by the request);
- or pick **picjs** from the `/` menu.

Remove `disable-model-invocation: true` from `SKILL.md` if you want automatic
discovery again.

If you copy the skill to another machine, copy/clone the whole folder and run
`install-skill.sh` there. The docs and examples are included. If the folder is
published to a Git repo, the equivalent is:

```bash
git clone <repo-url> picjs-skill
cd picjs-skill
bash scripts/install-skill.sh
```

DSH's loader is filesystem-based: there is no separate "install a skill from a
URL" command. Cloning/copying the folder is the supported route; the **runtime**
is still installed online from npm on first use.

### If the agent sandbox blocks `~/.cache`

Point `PICJS_HOME` at a writable directory and use the same value for rendering:

```bash
export PICJS_HOME=/tmp/picjs-skill
bash scripts/ensure-picjs.sh
node scripts/render.mjs ...
```

## 2. Install the runtime (online, outside the skill)

```bash
# from the skill root
bash scripts/ensure-picjs.sh --check   # report only
bash scripts/ensure-picjs.sh           # install/update the pinned version
```

What it does:

1. uses `PICJS_HOME` (default `${XDG_CACHE_HOME:-$HOME/.cache}/picjs-skill`);
2. if `PICJS_MODULE` or a local `node_modules` (beside the skill or in the
   current directory) already provides picjs, it stops and reports it;
3. otherwise checks the cache for `@pragdave/picjs`;
4. if missing, runs `npm install @pragdave/picjs@$PICJS_VERSION` into the cache,
   with npm's cache also under `PICJS_HOME` (avoids a read-only `~/.npm`);
5. prints the installed version and path.

No runtime files are written inside the skill. `render.mjs` looks for the package
in this order:

1. `PICJS_MODULE` (explicit path to `dist/picjs.js`);
2. `$PICJS_HOME/node_modules/@pragdave/picjs/dist/picjs.js`;
3. `node_modules` beside the skill (development only);
4. `node_modules` in the current working directory.

### Knobs

| Variable | Default | Meaning |
|---|---|---|
| `PICJS_VERSION` | current pin (0.4.0) | version to install; edit in `ensure-picjs.sh` or override |
| `PICJS_HOME` | `~/.cache/picjs-skill` | cache root for the runtime |
| `PICJS_MODULE` | unset | explicit module entry; skips cache lookup |

### Offline / preinstalled

- Point `PICJS_HOME` at a directory that already contains
  `node_modules/@pragdave/picjs`.
- Or set `PICJS_MODULE=/path/to/@pragdave/picjs/dist/picjs.js`.
- Or install `@pragdave/picjs` in the project and run the render script from
  there (the local `node_modules` fallback).

## 3. Update

```bash
npm view @pragdave/picjs version
# read ../references/history.md, then edit PICJS_VERSION in scripts/ensure-picjs.sh
bash scripts/ensure-picjs.sh
bash scripts/update-from-upstream.sh   # refresh docs/examples snapshot
```

## 4. Troubleshooting

- **`npm` cache permission error** — `ensure-picjs.sh` sets `--cache` under
  `PICJS_HOME`, so it does not touch `~/.npm`. If you run npm manually and hit
  `EPERM`, add `--cache .npm-cache`.
- **No network** — pre-populate `PICJS_HOME` or set `PICJS_MODULE`.
- **`render.mjs` says runtime not found** — run `ensure-picjs.sh --check`, then
  `ensure-picjs.sh`.
- **PNG fails** — install `rsvg-convert` (`brew install librsvg`) or write SVG.
