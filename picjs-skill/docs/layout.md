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

### Reusable component

Wrap a repeated block in a function that returns a `Group`, then place copies
with `with .nw at`. Name the parts you need to connect to with `self.`:

```picjs
drawServer = (name, pos) => {
  Group {
    Face s
    Label "#{name}" .h4
    Gap .1
    self.app = Box "App" -> Box "DB"
  } with .nw at pos
}

a = drawServer("Ingest", (0, 0))
b = drawServer("Query", (3, 0))
Line -> from a.app.e to b.app.w
```

### Connecting groups

A group is positioned by its constraint, but its members keep their own names, so
connect to `group.member.<cardinal>` rather than to the group's edge:

```picjs
a = Group { self.api = Box "API" }
b = Group { self.handler = Box "Handler" } with .nw at (3, 0)
Line -> from a.api.e to b.handler.w
```

### Flow chart one-liner

`->` between boxes creates the next box and the arrow at the same time; a palette
switch is often all the styling a small flow chart needs:

```picjs
Palette.current = "shuksan"
box "Input" -> box "Process" fill ~b2 -> box "Output"
```

### Architecture skeleton

For a larger diagram, start from explicit coordinates and keep the grid in
variables (see “Explicit grid” above), then add groups for the boxes that repeat.

---
