# Gallery

Small examples used by the project README.

| File | What it is |
|---|---|
| `flow.picjs` | a light-theme request lifecycle, explicit colours and centred bilingual labels |
| `flow.png` | rendered from `flow.picjs` at 1400 px |
| `petal.png` | rendered from `../upstream/petal.picjs` on a dark background |

Render them from the skill root (after `ensure-picjs.sh`):

```bash
node scripts/render.mjs examples/gallery/flow.picjs examples/gallery/flow.png

PICJS_BG='#141826' \
  node scripts/render.mjs examples/upstream/petal.picjs examples/gallery/petal.png
```

The petal source uses palette colours, which are designed for the dark theme;
render it on `#141826` (or set `PICJS_BG=none` and place it on a dark page).
