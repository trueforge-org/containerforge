# GitHub: hexojs/hexo (application source)

Source URL(s) + fetch date: https://github.com/hexojs/hexo, README read from https://raw.githubusercontent.com/hexojs/hexo/master/README.md · fetched 2026-11-26

## What it is
Hexo: a fast, simple and powerful blog framework powered by Node.js. Static site generator with GitHub Flavored Markdown, one-command deploy (e.g. GitHub Pages), an extensible plugin API, and many themes and plugins.

## Install/build steps and build deps
- Prerequisites: Node.js and Git.
- Global CLI: `npm install -g hexo-cli` (or `npm install hexo`, then `npx hexo <command>`).
- Create a project: `hexo init blog`; run local server: `hexo server`; `hexo new "Hello Hexo"`; `hexo generate`.

## Runtime deps
- Node.js. Required minimum depends on Hexo version: Hexo 8.0+ needs Node.js 20.19.0 minimum; Hexo 7.0+ needs 14.0.0; Hexo 6.2+ needs 12.13.0 (older lines listed on the docs page).

## Binaries/entrypoint/CLI flags
- CLI command `hexo` (from `hexo-cli`). Subcommands used by the container: `init`, `server`, `clean`.

## Version/release info and asset naming
- Pure npm packages; no per-arch release binaries. Hexo core version comes from the blog's own package.json.

## Ports
- Default server port is not stated on the README.

## License
- README does not name the license directly (it shows a FOSSA badge). Plan.md records MIT from the npm registry license field.

## Gotchas
- `hexo server` is a development server (see docs summary).
- Contradiction with plan.md: none on Node version (plan says Hexo core needs Node >= 20.19.0, which matches the docs).
