# ferdium/ferdium-recipes

Source URL(s) + fetch date:
- https://github.com/ferdium/ferdium-recipes (fetched 2026-11-26)

## What it is

Public recipe collection for Ferdium. Each recipe links a web service (WhatsApp, Gmail, Slack, ...) into Ferdium for notifications and UI tweaks. Used by ferdium-server's entrypoint, which clones it at startup.

## Install/build steps and build deps

- Root `package.json`, `pnpm-lock.yaml`, `pnpm-workspace.yaml`, ESLint/Prettier configs.
- `pnpm i` then `pnpm package` (entrypoint). README mentions `pnpm validate` before submitting. `engines.pnpm` not visible on the fetched page; the entrypoint reads it at runtime.

## Runtime deps

- Node + pnpm (version from recipes `package.json` `engines.pnpm`, unverified here).

## Layout

- Top level: `recipes/` folder, `docs/`, `scripts/`, `.github/`, `.devcontainer/`, `.husky/`, `featured.json`.
- Per-recipe docs (README links, labels only): configuration via a recipe `package.json`, frontend API via `webview.js`, backend API via `index.js` (optional).

## Env vars / ports / volumes / user / healthcheck

None. Not a runnable service.

## Version/release info

- 1,297 commits on main; no tag names or release entries shown on the page. Whether tags exist is unknown from this fetch (plan says it has none).

## License

- MIT (LICENSE.md in root, per page).

## Gotchas

- ferdium-server's entrypoint pulls `main` at each start (`git pull -r`), so the recipe set changes without a rebuild.
- Not reproducible across builds unless pinned.
