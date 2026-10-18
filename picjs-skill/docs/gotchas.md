# Gotchas

1. **y is inverted relative to maths.** Negative y is up. `at (0, -1)` is above
   `at (0, 0)`. `Face south` increases y.
2. **Attributes must come before `at`.** `Box "X" fill ~b1 at (0, 0)` works;
   `Box "X" at (0, 0) fill ~b1` fails with “Variable 'fill' is not defined”.
3. **Define a shape before using it in a line.** `Line -> from a.e to b.w` before
   `b = Box …` fails with “Variable 'b' is not defined”.
4. **`bold` inside a rich label is broken in 0.4.0.** `("text" bold 12pt)` is a
   parse error. Use `("text" font_weight bold 12pt)`, or markdown `**bold**`
   inside the string (the easiest way to bold one line of a multi-line label).
   `font italic bold 24pt Georgia` (bare tokens, not a quoted CSS string) works
   for `font`.
5. **`--` in a `//` comment breaks the SVG.** picjs embeds the source in an XML
   comment, and XML comments cannot contain `--`. Avoid `--` in comments, or render
   with `PICJS_NO_SOURCE=1`.
6. **CJK width is underestimated.** Text width is estimated as
   `charCount × fontSize × 0.52`, while a Chinese glyph is about 1 em wide. So
   `fit` boxes can clip Chinese, and a single-line centred Chinese label drifts
   right (start with `0.24 × fontSize × cjkCount`, then verify on the render —
   bold/mixed text needs more). Put the text in one triple-quoted multi-line label
   when possible: `text-anchor="middle"` is exact. Stacked rich labels are
   separate single-line labels and drift too.
7. **Palette slots are theme-dependent.** `~b1` / `~f1` resolve to dark-theme
   colours in `renderToStringAsync`. For light documents use explicit hex, or put
   the image on a dark background.
8. **`font` takes bare tokens.** `font italic bold 24pt Georgia` works;
   `font "italic bold 24pt Georgia"` does not.
9. **`fit` uses the measured width**, so it inherits the CJK problem. Give
   `wid`/`ht` explicitly for bilingual boxes.
10. **The SVG keeps a source comment by default.** That is handy for round-tripping;
    set `includeSource: false` / `PICJS_NO_SOURCE=1` for clean production SVG.
11. **`.filter()` and `.sort()` are not implemented in 0.4.0**, even though the
    official compact skill lists them. Lists support `.push`, `.pop`, `.first`,
    `.last`, `.each`, `.map`, `.length`. Filter inside `.each` / `.map` instead:
    `[1..5].each(n => if (n % 2 == 0) Box "#{n}")`. Always smoke-test snippets from
    `../references/upstream-skill.md`; it can be ahead of the published package.
12. **Multiple bare strings on a standalone `Label` overlap.** `Label "A" "B"`
    creates two labels at the same point. Use one triple-quoted string with a
    real newline (see the centering section), or use a `Box`. Box labels stack
    correctly; standalone labels do not.

---
