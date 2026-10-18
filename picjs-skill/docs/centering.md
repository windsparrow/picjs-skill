# Text centering

## Rules

Unless the layout says otherwise, every piece of text is centred on the shape or
point it belongs to — **both horizontally and vertically**.

### The four cases

1. **Text inside a shape** — let the shape own the label:
   ```picjs
   Box "Ready" wid 1.6 ht .6
   ```
   The shape centres the line box on its centre.

2. **Multi-line text** — use **one** label with a newline. A triple-quoted
   string is the reliable way:
   ```picjs
   Box ("""**Multi-Head Attention**
   多头注意力""" 10pt fill #1F2430) wid 2.6 ht .8 fill #DCE8F7 stroke #7FA3C8
   ```
   picjs emits one `<text>` with `text-anchor="middle"`: both lines and the whole
   block are exactly centred. `**…**` makes the first line bold without splitting
   it into another label.

   Avoid stacking rich labels when centring matters:
   ```picjs
   // Avoid: two separate single-line labels; the CJK line can drift right.
   Box ("Multi-Head Attention" 11.5pt) ("多头注意力" 9pt) wid 2.6 ht .8 fill #DCE8F7
   ```

3. **Standalone text** — pin the centre:
   ```picjs
   Label ("Caption" 10pt fill #1F2430) with .c at (3, -1.2)
   ```
   `at` already uses the label's centre; `with .c` makes the intent explicit.
   For several lines, use the triple-quoted form.

4. **Left/right-aligned text (the exception)** — legends, lists, axis labels,
   container labels:
   ```picjs
   Label ("Legend row" 9pt) with .w at (0, 0)          // starts at x = 0
   Label ("Right edge" 9pt) align .e with .e at (6, 0) // ends at x = 6
   ```
   These are intentionally not centred; use them only when reading order or a
   connector makes centring worse.

### Titles

Centre a title over the content it describes, not over the raw canvas edge.

A **Latin-only** single-line title is exact with a centre anchor:

```picjs
Label ("Architecture" 20pt fill #1F2430) with .c at (3.2, -1.6)
```

A **single-line CJK** title drifts right, because picjs estimates text width as
`0.52 × font_size × character_count` while a CJK glyph is about `1.0 em`. For a
pure-CJK title, start with a correction of about
`0.24 × font_size × cjk_count`:

```picjs
// 4 CJK characters at 20pt: start with 0.24 * 0.20 * 4
Label ("系统架构" 20pt fill #1F2430) with .c at (3.2 - 0.24*0.20*4, -1.6)
```

Bold or mixed Latin/CJK text needs a larger correction; **render, measure the ink
bbox, and nudge** — or avoid the problem entirely by making the title part of a
multi-line label:

```picjs
Label ("""**系统架构**
从输入到输出的数据流""" 16pt fill #1F2430) with .c at (3.2, -1.8)
```

The multi-line form is exact because picjs emits `text-anchor="middle"` for the
whole block. This is the preferred route when the title and subtitle can share a
font size.

### Vertical centring

picjs centres the **line box**, not the ink bounding box. All-caps or CJK-only
text without descenders can look a few percent high. If that matters, nudge the
anchor down by `+0.01–0.03` units, or include a mixed-case/descender line. This
is an optical adjustment, not a layout bug.

### Verify

Render at the final display width and look at the PNG. A centred label has equal
visual margins left/right and top/bottom. The usual causes of drift are:

- a single-line CJK label (apply the correction above);
- rich labels stacked as separate single-line labels (use one multi-line label);
- `with .w` / `with .e` used when "centred" was intended (these pin an edge).

---
