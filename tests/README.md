# Tests

Local, reproducible checks for skills and examples. **One directory per test
case** — add a new subdirectory (and a row below) rather than mixing artifacts
at this level.

| Case | Skill | Artifacts | Status |
| --- | --- | --- | --- |
| [transformer](transformer/) | drawio-skill | editable `.drawio` + PNG + SVG | passing |
| [solar-system](solar-system/) | picjs | editable `.picjs` + PNG + SVG | passing |
| [solar-system-drawio](solar-system-drawio/) | drawio-skill | editable `.drawio` + PNG + SVG | passing |

## Conventions

- Each case directory is self-contained: its own `README.md`, source file, and
  rendered outputs.
- Keep the editable source (`.drawio`, `.picjs`, …) next to its exports so the
  case can be regenerated and diffed.
- Record the exact command(s) and tool versions used in the case `README.md`.
- Don't commit temporary drafts (`*.draft.png`, crop checks); only final
  artifacts belong in a case directory.
