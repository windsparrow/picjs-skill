# Animation and the timeline

picjs programs can drive a **timeline**: shapes appear as time advances, and
`move` / `rotate` / `set` / `draw` schedule changes. A static render
(`scripts/render.mjs`) shows only **time 0**; playback needs the browser runtime
(`@pragdave/picjs/runtime`, or the Eleventy/Lume plugin).

Read this when the request involves motion, a timeline, or an animated
explainer. The full upstream treatment is `../references/animation.md`; the
official one-page skill is `../references/upstream-skill-animation.md`.

## The timeline: `@`

`@` is the current time in seconds. It starts at 0.

```picjs
Box "First"                 // at time 0
@ += 1                      // advance one second
Box "Second"                // appears at time 1
```

| Write | Meaning |
|---|---|
| `@ += n` | advance by `n` seconds |
| `@ = t` | jump to absolute time `t` (same as `@.now = t`) |
| `@@` | jump to `@.last_animation_end` |
| `@.last_animation_end` | end of the most recent animation |
| `@.last_animation_start` | start of the most recent animation |
| `@.max_time` | total timeline length |
| `@.start_from = @` | loop start: the player auto-plays up to here, then stops |

A shape created after the timeline advances is added at that time; it does not
exist before it.

`@.start_from` does not move `@.now`: it marks where the next animation begins,
and the player also treats it as the point to stop at after auto-playing the
intro (see the spin pattern below).

## Commands

```picjs
a = Box "A"

move a to (2, 0)              // move the centre
move a.s to (2, 0)            // move a cardinal point to a place
move a north 2                // move in a direction by a distance
rotate a by 90                // degrees
rotate a by 90 about (0, 0)   // around a point
set a.fill to ~red            // animate any attribute
pause                         // stop playback here (play button stays)
pause "Click to continue"     // stop with a message

l = Line -> from a.e to (2, 0)
draw l                        // trace a line, polyline, or arc in
```

Every animation command accepts `take` and `ease`:

```picjs
a = Box "A"
move a to (2, 0) take 2 ease "cubicInOut"
```

- `take` — duration in seconds; **default 0.7**. It can be computed:
  `take 0.3 + 0.2 * distance`.
- `ease` — `linear`, `cubicIn`, `cubicOut`, `cubicInOut`, `cubic`, `quadIn`,
  `quadOut`, `quadInOut`, `quad`, `bounce`.
  0.4.0 has **no `sine*` or `elastic`**; those fail with the list above.

## Parallel or chained

Animations scheduled at the same `@` run **in parallel**:

```picjs
a = Box "A"
set a.wid to 2 take 1
set a.ht to 1.5 take 1        // same start, same one-second span
```

`then` starts the next animation when the previous one ends:

```picjs
a = Box "A"
move a to (2, 0) ease "cubicIn"
then move a.s to (2, 2) ease "linear" take .5
then move a to (4, 0) ease "cubicOut"
@@                            // skip past the whole chain
```

## Hiding and revealing

`draw` animates the **stroke** of a line-like shape (`Line`, polyline, `Arc`)
along its path. In 0.4.0 boxes, circles, and labels ignore `draw` entirely, so it
cannot reveal them.

- **Lines** — add `nodraw` when the line is created, so it is invisible until
  `draw`:

  ```picjs
  a = Box "A"
  b = Box "B" at (2, 0)
  l = Line -> from a.e to b.w nodraw
  @ += .5
  draw l take 1
  ```

- **Everything else** — `nodraw` is a line-only attribute in 0.4.0
  (`Box "A" nodraw` fails with “Variable 'nodraw' is not defined”). Create the
  shape at the moment it should appear, or fade it in:

  ```picjs
  b = Box "B" opacity 0
  @ += .5
  set b.opacity to 1 take .5
  ```

## Patterns

### Sequential reveal

Create shapes as the timeline advances — no `nodraw` needed:

```picjs
[1..4].each(n => {
  @ += .3
  Box "Step #{n}"
})
```

### Move along a path

```picjs
a = Box "Start"
@ += .5
move a.s to a.s + (0, -1) ease "cubicIn"
then move a.s to (2, 0) ease "linear"
then move a.s to (4, 0) ease "cubicOut"
@@
```

### Fade in, then out

```picjs
t = Label "Hello" opacity 0
@ += .5
set t.opacity to 1 take .5
@ += 2
set t.opacity to 0 take .5
```

### Continuous spin

`@.start_from = @` splits the timeline into a one-off intro and a loop: the
player auto-plays to that point, stops, and Play resumes from there.

```picjs
g = Group {
  Circle rad .8
  6.times(n => Line from (0, 0) to (0, -.8) rotation 360/6*n)
}
@.start_from = @
set g.rotation to 360 take 4
then set g.rotation to 0 take 4 ease "cubic"
```

### Timing from a distance

Duration can depend on the geometry, which is how the Towers of Hanoi example
keeps travel time proportional to distance:

```picjs
moveDisk = (pFrom, pTo) => {
  distance = (pFrom.number - pTo.number).abs()
  disk = pFrom.pop()
  move disk.s      to pFrom.n - (0, 10) ease "cubicIn"
  then move disk.s to pTo.n - (0, 10)   ease "linear" take 0.3 + 0.3*distance
  then move disk.s to pTo.push(disk)    ease "cubicOut"
  @@
}
```

See `../examples/upstream/hanoi.picjs` for the complete program.

## Debugging the timeline

- `??@` logs the current time; `??a` logs a shape's attributes.
- A PNG/SVG render is a snapshot of time 0. To check motion, open the diagram in
  the playground (<https://pragdave.github.io/picjs/editor/>) or serve it with
  the runtime.
- The player hides its controls when the program has no animations, so an empty
  timeline looks like a static image.
