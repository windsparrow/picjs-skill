# picjs-skill

**English** | [中文](README.zh.md)

An Agent Skill package for [picjs](https://github.com/pragdave/picjs): a compact,
on-demand guide to the language, an upstream documentation snapshot, examples, and
render/update scripts.

Invoke it explicitly with `/picjs`. The picjs runtime is downloaded from npm into a
cache on first use; it is **not** vendored in this repository.

> This repository is **not** picjs itself. It is a skill wrapper plus examples.
> The language, runtime, and upstream docs live at
> **<https://github.com/pragdave/picjs>**.

## Upstream project

| Item | Link |
|---|---|
| picjs source | <https://github.com/pragdave/picjs> |
| Documentation | <https://pragdave.github.io/picjs/> |
| Playground | <https://pragdave.github.io/picjs/editor/> |
| npm package | <https://www.npmjs.com/package/@pragdave/picjs> |
| Author | Dave Thomas |
| License | MIT (see [`picjs-skill/LICENSE-picjs.md`](picjs-skill/LICENSE-picjs.md)) |
| This repository | `https://github.com/<your-name>/<repo-name>` (replace after publishing) |

> After publishing, replace `<your-name>/<repo-name>` with the real repository URL.

## Examples

| Example | Source | What it shows |
|---|---|---|
| Transformer architecture | [`transformer.picjs`](picjs-skill/examples/transformer/transformer.picjs) | explicit coordinates, containers, centered bilingual labels, K/V bus |
| Attention detail | [`attention.picjs`](picjs-skill/examples/transformer/attention.picjs) | vertical pipeline, centered multi-line labels |
| Residual sublayer | [`residual.picjs`](picjs-skill/examples/transformer/residual.picjs) | residual connection + LayerNorm |
| Request lifecycle | [`flow.picjs`](picjs-skill/examples/gallery/flow.picjs) | light theme, explicit colors |
| Petal | [`petal.picjs`](picjs-skill/examples/upstream/petal.picjs) | loops, arcs, color spinning |

The minimal form is just:

```picjs
box "Client" -> box "API Gateway" -> box "Service" -> box "Database"
```

### 1. Transformer architecture

[![Transformer architecture](picjs-skill/examples/transformer/transformer.png)](picjs-skill/examples/transformer/transformer.png)

[Source](picjs-skill/examples/transformer/transformer.picjs) · [Chinese walkthrough](picjs-skill/examples/transformer/notes.md)

<details>
<summary>Expand: attention detail and residual sublayer</summary>

[![Scaled dot-product attention](picjs-skill/examples/transformer/attention.png)](picjs-skill/examples/transformer/attention.png)

[![Residual + LayerNorm](picjs-skill/examples/transformer/residual.png)](picjs-skill/examples/transformer/residual.png)

</details>

### 2. Request lifecycle

[![Request lifecycle](picjs-skill/examples/gallery/flow.png)](picjs-skill/examples/gallery/flow.png)

[Source](picjs-skill/examples/gallery/flow.picjs)

### 3. Petal (loops / arcs / colors)

<a href="picjs-skill/examples/gallery/petal.png"><img src="picjs-skill/examples/gallery/petal.png" width="480" alt="Petal"></a>

[Source](picjs-skill/examples/upstream/petal.picjs) · more in [`examples/upstream/`](picjs-skill/examples/upstream/)

## Features

- **On-demand loading** — `SKILL.md` is a small entry guide (~170 lines); syntax,
  animation, layout, centering, rendering, gotchas, and updating live in `docs/`
  and are read only when needed.
- **Online runtime install** — `scripts/ensure-picjs.sh` installs
  `@pragdave/picjs` from npm into `${PICJS_HOME:-~/.cache/picjs-skill}`; there is
  no `node_modules` in this repository.
- **Installed / missing branch** — `ensure-picjs.sh --check` reports an existing
  runtime; only a missing one triggers the online install.
- **Explicit invocation** — the skill sets `disable-model-invocation: true`, so it
  is not triggered by keywords. Start it with `/picjs` (or pick it from `/`).
- **Docs snapshot** — `references/` keeps the upstream guide, language, layout,
  full reference, animation, and grammar docs; refresh them with one script.

## Installation

Requires Node.js 18+ (20+ recommended).

```bash
git clone <your-repo-url> picjs-exp
cd picjs-exp

# 1) Install the skill into the project's skill directory (symlink).
#    If the .dsh/skills/picjs symlink survives the clone, you can skip this.
bash picjs-skill/scripts/install-skill.sh
# -> <project>/.dsh/skills/picjs

# 2) Install the picjs runtime online into the cache.
bash picjs-skill/scripts/ensure-picjs.sh
```

> `ensure-picjs.sh --check` only reports; it does not install.  
> If the agent sandbox cannot write `~/.cache`, export a writable cache first:
> `export PICJS_HOME=/tmp/picjs-skill`.

## Usage

Restart the session (or reload skills), then type:

```text
/picjs Draw a RAG pipeline diagram
```

You can also use the renderer directly, without the skill:

```bash
cd picjs-skill

# SVG
node scripts/render.mjs examples/gallery/flow.picjs /tmp/flow.svg

# PNG (needs rsvg-convert; macOS: brew install librsvg)
node scripts/render.mjs examples/gallery/flow.picjs /tmp/flow.png

# Process picjs fences in Markdown with the cached CLI
bash scripts/picjs-cli.sh process README.md
```

The curated guides in [`picjs-skill/docs/`](picjs-skill/docs/) are in English.
The Transformer walkthrough in `examples/transformer/notes.md` is in Chinese.

## Repository layout

```text
.
├── README.md                     # this file (default, English)
├── README.zh.md                  # Chinese README
├── LICENSE                       # MIT for this skill wrapper
├── .dsh/skills/picjs -> ../../picjs-skill
└── picjs-skill/
    ├── SKILL.md                  # compact entry (install check + routing)
    ├── README.md                 # detailed Chinese overview
    ├── package.json              # scripts only; no runtime dependency
    ├── docs/                     # 10 on-demand guides (English)
    ├── references/               # upstream docs snapshot
    ├── examples/
    │   ├── transformer/          # 3 figures + PNG/SVG + notes.md
    │   ├── gallery/              # README showcase: flow + petal
    │   └── upstream/             # official .picjs examples
    └── scripts/
        ├── ensure-picjs.sh       # online install/check the runtime
        ├── picjs-cli.sh          # Markdown CLI from the cache
        ├── render.mjs            # .picjs -> SVG/PNG
        ├── update-from-upstream.sh
        └── install-skill.sh
```

## Updating

```bash
cd picjs-skill

# Check the latest upstream version
npm view @pragdave/picjs version

# Bump PICJS_VERSION in scripts/ensure-picjs.sh, then switch/install
bash scripts/ensure-picjs.sh

# Refresh the docs snapshot + official examples
bash scripts/update-from-upstream.sh
bash scripts/update-from-upstream.sh --check   # version check only
```

See [`picjs-skill/docs/updating.md`](picjs-skill/docs/updating.md) for URLs,
the snapshot file, and the full checklist.

## License & attribution

- Skill wrapper code and docs in this repository: MIT, see [`LICENSE`](LICENSE).
- Upstream picjs, its docs and examples: MIT, Copyright © Dave Thomas, see
  [`picjs-skill/LICENSE-picjs.md`](picjs-skill/LICENSE-picjs.md).
- Original project: <https://github.com/pragdave/picjs>
