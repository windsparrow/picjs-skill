# Quick start

Run commands from the skill root (the folder containing `SKILL.md`).

## 1. Ensure the runtime

```bash
bash scripts/ensure-picjs.sh --check
```

- **installed** → go to step 2.
- **missing** → install it online (npm registry) into a cache:

```bash
bash scripts/ensure-picjs.sh
```

The runtime lives in `${PICJS_HOME:-~/.cache/picjs-skill}`, never inside this
skill. See [install.md](install.md) for versions, offline use, and troubleshooting.

## 2. Write a diagram

```picjs
a = Box ("Input" fill #1F2430 11.5pt)   wid 1.4 ht .6 fill #DCE8F7 stroke #7FA3C8 at (0, 0)
b = Box ("Process" fill #1F2430 11.5pt) wid 1.5 ht .6 fill #F6E3C5 stroke #D9A45B at (2.2, 0)
c = Box ("Output" fill #1F2430 11.5pt)  wid 1.4 ht .6 fill #E4EFE3 stroke #8FB894 at (4.35, 0)

Line -> from a.e to b.w ("step 1" fill #B45309 9pt) above stroke #6B7280
Line -> from b.e to c.w ("step 2" fill #B45309 9pt) above stroke #6B7280
```

This uses explicit light-theme colours, matching `render.mjs`'s paper background.
Palette slots (`~b1`, `~f1`) are dark-theme by default; render those with
`PICJS_BG='#141826'`.

## 3. Render it

```bash
node scripts/render.mjs diagram.picjs diagram.svg
node scripts/render.mjs diagram.picjs diagram.png   # needs rsvg-convert
```

| Variable | Default | Meaning |
|---|---|---|
| `PICJS_BG` | `#FAF7F2` | background fill; `none` = transparent |
| `PICJS_WIDTH` | `1600` | PNG width in pixels |
| `PICJS_PADDING` | `0.2` | canvas padding in picjs units |
| `PICJS_NO_SOURCE` | unset | `1` omits the embedded source comment |

PNG output needs `rsvg-convert` (macOS: `brew install librsvg`). Without it, write
SVG and open it in a browser.

## 4. Render Markdown in place

```bash
bash scripts/picjs-cli.sh process README.md
bash scripts/picjs-cli.sh watch README.md
```

````markdown
```picjs
box "Hello" -> box "World"
```
````

Each `picjs` fence is replaced by SVG; the source stays in an HTML comment beside
it. Fences can be `picjs`, `picjs example` (diagram + source), or `picjs 2up`
(side by side).

## 5. Use the API

In a project that has `@pragdave/picjs` installed:

```js
import { renderToStringAsync } from '@pragdave/picjs'

const { svg, width, height, error } = await renderToStringAsync(source, {
  padding: 0.2,
  includeSource: true,
})
```

Browser entry points: `renderAll('.picjs')`, `render(el)`, `autoInit()`,
`createRunner()`. Animation runtime: `@pragdave/picjs/runtime`.

## 6. Iterate

1. Write the `.picjs` source next to the document it belongs to.
2. Render at the final display size and **look at the PNG**.
3. Fix layout first (padding, text centring, arrows through boxes), then styling.
4. Keep the source beside the rendered `.svg`/`.png`, so it stays editable.
