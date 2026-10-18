---
name: picjs
description: Draw and edit diagrams with picjs, the constraint-based SVG drawing language. Use when the user mentions picjs or .picjs, wants a precise text-driven SVG diagram, or asks to update the bundled picjs package, docs, and examples.
disable-model-invocation: true
user-invocable: true
---

# picjs

picjs (by Dave Thomas) is a small language for drawing — and animating — SVG
diagrams. You describe shapes and relationships; picjs works out where everything
goes. It has variables, functions, closures, lists/ranges, loops, groups, and an
animation timeline.

This is the **entry guide**. Detailed material lives in `docs/`; the full
upstream documentation snapshot lives in `references/`. Read only the guide that
matches the task — do not load the whole skill at once.

> **Invocation:** this skill is **user-invocable only** (`disable-model-invocation: true`).
> Type `/picjs` (or pick **picjs** from the `/` menu) to load it; it does not
> auto-trigger from keywords. Remove that flag if you want automatic discovery.

---

## 0. Runtime: check before drawing

Run from the skill root (the folder containing this file):

```bash
bash scripts/ensure-picjs.sh --check
```

- If it reports **installed**, continue.
- If it reports **not installed**, install the runtime online:

```bash
bash scripts/ensure-picjs.sh
```

This downloads the pinned `@pragdave/picjs` version (`PICJS_VERSION`) from npm into
`${PICJS_HOME:-${XDG_CACHE_HOME:-$HOME/.cache}/picjs-skill}` and writes nothing
inside this skill. `npm install` in the skill does **not** install the runtime
(the manifest has no dependencies); use `ensure-picjs.sh`.

If the runtime is already available (cache, `PICJS_MODULE`, or a local
`node_modules`), skip both commands and go straight to the diagram. If the agent
sandbox cannot write `~/.cache`, set `PICJS_HOME` to a writable directory first.
Full options and offline setup: [docs/install.md](docs/install.md).

---

## 1. Load only the guide you need

| Task | Read |
|---|---|
| First diagram, render SVG/PNG, CLI/API | [docs/quickstart.md](docs/quickstart.md) |
| Syntax: shapes, lines, labels, colours, groups, functions, animation | [docs/syntax.md](docs/syntax.md) |
| Layout: flow, constraints, grids, containers, bus routing | [docs/layout.md](docs/layout.md) |
| Text centring: default rules, titles, CJK correction | [docs/centering.md](docs/centering.md) |
| Rendering: themes, background, PNG, Markdown, browser API | [docs/rendering.md](docs/rendering.md) |
| Errors, edge cases, version-specific traps | [docs/gotchas.md](docs/gotchas.md) |
| Examples: Transformer + official examples | [docs/examples.md](docs/examples.md) |
| Updating the runtime or the docs snapshot | [docs/updating.md](docs/updating.md) |

For deep syntax, use the upstream snapshot:
`references/quick-reference.md` (attribute/shape matrix),
`references/picjs-reference.md` (full reference),
`references/language.md` (variables/functions/control flow). These are large;
open them only when the curated guides are not enough.

---

## 2. Minimal loop

1. **Write** the `.picjs` source next to the document or image it belongs to.
2. **Render** it:

   ```bash
   node scripts/render.mjs diagram.picjs diagram.png
   # or .svg; PNG needs rsvg-convert
   ```

3. **Look at the PNG** at the final display size. Layout bugs (touching borders,
   tiny text, arrows through boxes, off-centre text) are obvious visually.
4. **Iterate** on coordinates and labels, then keep the `.picjs` beside the
   rendered `.svg`/`.png`.

Start from the closest file in `examples/` instead of a blank page.

---

## 3. Defaults you must not forget

- **Text is centred by default — both axes.** See [docs/centering.md](docs/centering.md).
  Shape labels are automatic; multi-line text should be **one** triple-quoted
  label (`"""..."""`), not stacked rich labels; single-line CJK needs a small
  anchor correction or the multi-line form.
- **y grows downward** (screen coordinates). Negative y is up; `Face south`
  increases y.
- **Runtime lives in the cache**, not in this skill. `render.mjs` resolves it
  from `PICJS_MODULE`, `PICJS_HOME`, or a local `node_modules` (skill or cwd).
- **Palette slots are dark-theme** in `renderToStringAsync` (`~b1` / `~f1`).
  For light documents use explicit hex, or render on a dark background.

---

## 4. Examples

- `examples/transformer/` — a three-figure Transformer explainer with rendered
  PNGs, SVG, `.picjs` sources, and a Chinese `notes.md`. Best reference for a
  large precise diagram with centred bilingual labels.
- `examples/gallery/` — small README showcase: a light-theme flow and a rendered
  petal.
- `examples/upstream/` — the official examples (architecture, petal, hanoi,
  state machine, spiro, …).

Index and render commands: [docs/examples.md](docs/examples.md).

---

## 5. Updating

```bash
npm view @pragdave/picjs version
# read references/history.md, then bump PICJS_VERSION in scripts/ensure-picjs.sh
bash scripts/ensure-picjs.sh
bash scripts/update-from-upstream.sh
```

The runtime and the docs are updated separately: `ensure-picjs.sh` handles the
npm package, `update-from-upstream.sh` refreshes `references/` and
`examples/upstream/`. URLs, the snapshot file, and the checklist:
[docs/updating.md](docs/updating.md).

---

## 6. Files

```
picjs-skill/
├── SKILL.md                 ← this entry guide (small, always loaded)
├── README.md                ← human-facing overview (Chinese)
├── package.json             ← scripts only; no runtime dependency installed here
├── docs/                    ← curated guides, read on demand
│   ├── install.md
│   ├── quickstart.md
│   ├── syntax.md
│   ├── layout.md
│   ├── centering.md
│   ├── rendering.md
│   ├── gotchas.md
│   ├── examples.md
│   └── updating.md
├── scripts/
│   ├── ensure-picjs.sh      ← online install/check into a cache
│   ├── picjs-cli.sh         ← Markdown CLI from the cache
│   ├── render.mjs           ← .picjs → SVG/PNG
│   ├── update-from-upstream.sh
│   └── install-skill.sh
├── references/              ← upstream docs snapshot (large; read selectively)
├── examples/
│   ├── transformer/         ← our worked example
│   ├── gallery/             ← README showcase (flow + petal)
│   └── upstream/            ← official .picjs examples
└── LICENSE-picjs.md
```

---

## 7. Attribution

picjs is by **Dave Thomas** and is distributed under the **MIT License**.
The bundled docs and examples are copied from
<https://github.com/pragdave/picjs> (snapshot noted in
`references/upstream-snapshot.md`). Keep `LICENSE-picjs.md` with any redistribution.
