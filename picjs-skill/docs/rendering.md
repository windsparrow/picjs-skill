# Rendering and theming

## Themes and background

- `renderToStringAsync` resets the palette to **`sunset`** and uses the **dark
  theme** colours. Default label fill is a light cream, which is invisible on a
  white page.
- A program can change the palette with `Palette.current = "ocean"` (other names:
  `default`, `misty`, `forest`, `warm`, `mono`, `starfish`, `shuksan`, `bay`,
  `lake`, `cascades`), which changes the `~b1`/`~f1` slots. The theme is still
  dark, so a light document still needs explicit colours.
- For a light document, set **explicit** colours:
  - background `#FAF7F2` (via `PICJS_BG` or your own rect);
  - body text `#1F2430`, muted text `#5A6478`;
  - box fills such as `#DCE8F7`, `#E4EFE3`, `#EFE6F5`;
  - borders `#7FA3C8`, `#8FB894`, `#B49BC9`.
- `Label "…" fill …` and rich labels (`Box ("text" fill …)`) override text colour.
  A shape's fill does **not** automatically recolour its label in a light palette.
- `renderToStringAsync` accepts `{ padding, includeSource }`; the generated SVG
  also contains `[data-theme="light"]` rules, but a standalone image has no theme
  attribute, so explicit colours are the reliable route.
- Preview the PNG at the size it will be displayed (e.g. 900 px wide). If the text
  is too small, reduce the canvas / increase font sizes rather than adding more
  content.

### Markdown / site integration

- CLI: `picjs process` / `picjs watch` (see [Quick start](quickstart.md)).
- Eleventy/Lume plugins live upstream in `extras/plugins`.
- Animated diagrams need the runtime; static SVG/PNG only shows time 0.

---
