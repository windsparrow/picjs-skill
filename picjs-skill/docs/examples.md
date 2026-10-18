# Examples

All examples are plain `.picjs` files at the skill root's `examples/` folder.
Render them with `scripts/render.mjs` (from the skill root).

## Transformer (our worked example)

`../examples/transformer/` — the Transformer architecture in three views.

| File | What it shows |
|---|---|
| `transformer.picjs` | full encoder/decoder architecture, containers, explicit colours, centred bilingual labels |
| `residual.picjs` | one sublayer: residual + LayerNorm |
| `attention.picjs` | scaled dot-product attention, vertical pipeline |
| `notes.md` | a Chinese explainer with the three rendered figures |
| `*.png` / `*.svg` | the rendered output, included for reference |

This is the best reference for a large, precise diagram with explicit
coordinates, centred bilingual labels, and measured CJK title offsets.

## Gallery

`../examples/gallery/` — the small examples used by the project README:

| File | What it is |
|---|---|
| `flow.picjs` | light-theme request lifecycle, explicit colours, centred bilingual labels |
| `flow.png` | rendered from `flow.picjs` |
| `petal.png` | rendered from `../upstream/petal.picjs` on a dark background |

## Upstream examples

`../examples/upstream/` — all official examples. Good starting points:

| File | What it shows |
|---|---|
| `architecture.picjs` | boxes, groups, labels, connections |
| `petal.picjs` | loops, arcs, colour spin, rotational symmetry |
| `hanoi.picjs` | recursion + animation timeline |
| `state-machine.picjs` | states and labelled transitions |
| `line-labels.picjs` | labels along lines |
| `spiro.picjs` | maths functions and repeated drawing |
| `gear.picjs` | shapes and rotation |
| `palette.picjs` | palette slots |
| `bubble-sort.picjs` | animated algorithm |

```bash
# from the skill root
node scripts/render.mjs examples/upstream/petal.picjs /tmp/petal.png
node scripts/render.mjs examples/transformer/transformer.picjs /tmp/transformer.png
```
