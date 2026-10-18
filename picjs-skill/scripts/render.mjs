#!/usr/bin/env node
// Render a .picjs source file to SVG or PNG.
//
//   node scripts/render.mjs input.picjs [output.svg|output.png]
//
// Environment:
//   PICJS_BG          background color (default #FAF7F2; "none" for transparent)
//   PICJS_WIDTH       PNG width in pixels (default 1600)
//   PICJS_PADDING     canvas padding in picjs units (default 0.2)
//   PICJS_NO_SOURCE   set to 1 to omit the embedded source comment

// PNG output needs rsvg-convert (macOS: brew install librsvg).

import { readFileSync, writeFileSync, mkdirSync, rmSync, existsSync, statSync } from 'node:fs'
import { basename, dirname, extname, join, resolve } from 'node:path'
import { execFileSync } from 'node:child_process'
import { homedir, tmpdir } from 'node:os'
import { fileURLToPath, pathToFileURL } from 'node:url'

const skillDir = resolve(dirname(fileURLToPath(import.meta.url)), '..')
const cacheRoot = process.env.PICJS_HOME
  ?? join(process.env.XDG_CACHE_HOME ?? join(homedir(), '.cache'), 'picjs-skill')

function moduleCandidate(value) {
  if (!value) return null
  const abs = resolve(value)
  try {
    return statSync(abs).isDirectory() ? join(abs, 'dist/picjs.js') : abs
  } catch {
    return null
  }
}

const candidates = [
  process.env.PICJS_MODULE,
  join(cacheRoot, 'node_modules/@pragdave/picjs/dist/picjs.js'),
  join(skillDir, 'node_modules/@pragdave/picjs/dist/picjs.js'),
  join(process.cwd(), 'node_modules/@pragdave/picjs/dist/picjs.js'),
].map(moduleCandidate).filter(Boolean)

let picjs = null
for (const candidate of candidates) {
  if (existsSync(candidate)) {
    picjs = await import(pathToFileURL(candidate).href)
    break
  }
}
if (!picjs) {
  console.error(
    `picjs runtime not found.\n` +
      `Run: bash scripts/ensure-picjs.sh\n` +
      `(or set PICJS_MODULE to @pragdave/picjs/dist/picjs.js)`,
  )
  process.exit(1)
}
const { renderToStringAsync } = picjs

const args = process.argv.slice(2)
if (args.length === 0 || args[0] === '-h' || args[0] === '--help') {
  console.log(`usage: node scripts/render.mjs <input.picjs> [output.svg|output.png]

env:
  PICJS_BG         background color (default #FAF7F2; "none" for transparent)
  PICJS_WIDTH      PNG width in pixels (default 1600)
  PICJS_PADDING    canvas padding in picjs units (default 0.2)
  PICJS_NO_SOURCE  set to 1 to omit the embedded source comment
  PICJS_HOME       runtime cache (default ~/.cache/picjs-skill)
  PICJS_MODULE     explicit path to @pragdave/picjs/dist/picjs.js`)
  process.exit(args.length === 0 ? 1 : 0)
}

const srcPath = resolve(args[0])
const outPath = resolve(args[1] ?? srcPath.replace(/\.picjs$/, '.svg'))
const source = readFileSync(srcPath, 'utf8')

const { svg, width, height, error } = await renderToStringAsync(source, {
  padding: Number(process.env.PICJS_PADDING ?? 0.2),
  includeSource: process.env.PICJS_NO_SOURCE !== '1',
})

if (error) {
  console.error('picjs error:', error)
  process.exit(1)
}

let out = svg

const bg = process.env.PICJS_BG ?? '#FAF7F2'
if (bg && bg !== 'none') {
  const vb = svg.match(/viewBox="([^"]+)"/)?.[1]
  if (vb) {
    const [x, y, w, h] = vb.split(/\s+/).map(Number)
    out = out.replace(/(<svg[^>]*>)/, `$1<rect x="${x}" y="${y}" width="${w}" height="${h}" fill="${bg}"/>`)
  }
}

mkdirSync(dirname(outPath), { recursive: true })

if (extname(outPath).toLowerCase() === '.png') {
  const tmp = resolve(tmpdir(), `picjs-${process.pid}.svg`)
  writeFileSync(tmp, out)
  try {
    execFileSync(
      'rsvg-convert',
      ['-w', process.env.PICJS_WIDTH ?? '1600', tmp, '-o', outPath],
      { stdio: 'inherit' },
    )
  } catch {
    console.error(
      'PNG output needs rsvg-convert. Install it (macOS: brew install librsvg), ' +
        'or write an .svg file instead.',
    )
    process.exit(1)
  } finally {
    rmSync(tmp, { force: true })
  }
} else {
  writeFileSync(outPath, out)
}

console.log(`${basename(outPath)} written (${width.toFixed(2)} x ${height.toFixed(2)})`)
