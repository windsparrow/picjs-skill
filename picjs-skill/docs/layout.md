# Layout patterns

## Patterns

### Explicit grid

For a precise architecture, compute a grid and place everything with `at (x, y)`.
Keep the coordinates in a comment or variables so the diagram is easy to edit.

```picjs
w = 2.0
x1 = 0
x2 = 3.0
y1 = 0
y2 = -1.6

a = Box "A" wid w ht .7 at (x1, y1)
b = Box "B" wid w ht .7 at (x2, y1)
c = Box "C" wid w ht .7 at (x1, y2)
```

### Containers with breathing room

Draw the container first, then its children. Leave ≥ 0.15–0.2 units of padding
between an inner box and the container border; an inner box that touches the
border reads as an overlap. Arrows may cross the container border — that is
normal — but give them a clear entry point.

### Bilingual labels

Use **one** multi-line label with a bold English line and a normal Chinese line:

```picjs
Box ("""**Multi-Head Attention**
多头注意力""" 10pt fill #1F2430) wid 2.6 ht .8 fill #DCE8F7 stroke #7FA3C8
```

picjs renders it as one `<text>` with `text-anchor="middle"`, so both lines are
centred exactly. Two separate rich labels are laid out as independent
single-line labels; the CJK line can drift right by the width-estimate error.

### Titles, legends, callouts

- Titles: `Label "…" .h2 fill #1F2430 with .c at (cx - cjkCorrection, y)` —
  centre over the content, not the canvas edge.
- Legends: left-align deliberately with `with .w`; a legend is a list, so
  centring each row hurts reading.
- Use a muted colour for secondary text; one accent colour for the one connection
  the reader should follow.

### Diagrams with a “bus”

For a signal from one column to another, route orthogonally: out of the source,
up/down into an empty lane, across, then into the target. Label the lane, not the
elbow. Avoid diagonal wires in block diagrams.

---
