# Syntax and mental model

## Mental model

- **Shapes flow like a turtle.** Default direction is east. `Face south` changes
  it; `Face 45` rotates it.
- **Every shape has nine cardinal points:** `.n .s .e .w .ne .nw .se .sw .c`.
- **Position** with `at (x, y)`, relative to another shape
  (`at a.e + (0.5, 0)`), or with a constraint (`with .nw at b.se`).
- **Connect** with `a -> b`, `Line -> from a.e to b.w`, `<->`, `o->`, `|->`.
- **Size** with `wid` / `ht`, `200x100`, `rad`, `rx` / `ry`, or `fit`.
- **Colour** with names (`~red`), hex (`#3a7`), `rgb()`, `oklch()`, `hsl()`,
  palette slots (`~b1` … `~b8`, `~f1` … `~f8`), and operations such as
  `.lighten(20%)`, `.darken(10%)`, `.spin(120)`.
- **Group** with `Group { … }` (lays out as one unit) or `Aside { … }` (does not
  move the layout cursor). `self.name = …` names a child for later reference.
- **Program** with `x = …`, `(a, b) => …`, `if`, `[...]`, `.each`, `.map`,
  `n.times`, and interpolation `"value #{n}"`.
- **Animate** on the `@` timeline with `move`, `rotate`, `set`, `draw`, `take`,
  `ease`, `then`, `@@`, and `pause`. See [animation.md](animation.md).

**Coordinate gotcha:** y grows **downward** (screen coordinates). So negative y is
up; `Face south` increases y. A title above the drawing needs a negative y.

---

## Cheat sheet

### Shapes

```picjs
Box "label"                 // rectangle
Circle rad .3 fill ~red     // circle
Ellipse rx .6 ry .3         // ellipse
Oval 200x80                 // pill / rounded box
Line from a.e to b.w        // straight line (becomes polyline with `then`)
Arc from a.e to b.w ccw     // arc
Label "Title" .h2           // standalone text
Gap .4                      // invisible spacer
Goto (100, 200)             // move cursor without drawing
Skip to (x, y)              // invisible line to a point
```

### Lines and arrows

```picjs
Line -> from a.e to b.w
<-> from a to b                 // arrows both ends
o~> from a to b                 // circle start, arrow end, smooth
|-> from a to b                 // bar start, arrow end

line from a.s then to b.w then to c.n
line from a to b then to c close       // closed polygon
line from a to b then to c rx .1       // rounded corners
Line from a to b smooth                // bezier
Line from a to b stepped               // right angles

Line -> from a to b "label" above
Line -> from a to b "label" at 25% below
```

### Sizes, labels, appearance

```picjs
Box wid 2 ht 1.5
Box 200x100
Box fit "Long text here"
Box "Line one" "Line two"
Label """Line one
Line two"""                            // one label: centred block
Label "Centred" with .c at (x, y)
Label "Left"    with .w at (x, y)
Box ("Important" fill ~red 18pt)
Box ("Bold" font_weight bold 12pt)     // 0.4.0: `bold` alone fails to parse
Label "Title" .h1
Label "Body" .p align .w
Box fill ~b1 stroke ~f1 thick .03
Box dashed
Box dotted
Box opacity .5
Box rotation 45 about (0, 0)
```

### Colours and palettes

```picjs
Palette.current = "ocean"      // default, misty, ocean, forest, warm, mono,
                               // starfish, shuksan, bay, lake, cascades, sunset
Box fill ~b1                   // palette background slot
Box fill ~f1                   // palette foreground slot (contrasts with b1)
Box fill #3a7                  // hex
Box fill rgb(100, 200, 150)
Box fill oklch(70%, .15, 200)
Box fill hsl(200, 80%, 50%)
~red.lighten(20%)
~blue.darken(10%)
~red.spin(120)                 // rotate hue
```

`Palette.current` and the slots are **dark-theme** colours (see
[rendering.md](rendering.md)).

### Defaults and classes

```picjs
Box.fill = ~b2
Box.highlight.fill = ~b3
Circle.radius = .3
Line.stroke = ~f4
Line.thickness = .03

box "A" .highlight
Box "A" .v1                    // built-in variants: .normal, .v1 … .v4
Label "Title" .h1              // label classes: .h1 … .h4, .p
```

### Groups

```picjs
g = Group {
  Face s
  self.top = Box "A"
  Box "B"
  Box "C"
} with .nw at (0, 0)

Line -> from g.top.e to other.w

Aside {
  Circle rad .15 at somePoint    // drawn, but does not move the cursor
}
```

### Language

```picjs
n = 3
name = "hello"
pos = (100, 200)

double = (x) => x * 2
[1..10].each(n => box "#{n}")
5.times(n => Box "step #{n}")
squares = [1..5].map(n => n * n)
[1..5].each(n => if (n % 2 == 0) Box "#{n}")
if (n > 0) Box "positive" else Box "non-positive"
```

### Refer to earlier shapes

```picjs
Box "A"
Box "B"
Circle at last box.s + (0, .5)
Line -> from first circle to last circle
last Shape
```

Ordinals: `first` … `tenth`, `1st`, `2nd`, `3rd`, `last`, `2nd last`,
`second last`.

### Debugging

```picjs
??x                    // log a value to the console
??someBox              // log a shape's attributes
??@                    // log the current timeline time
```

---
