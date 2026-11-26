# Docs: hexo.io (documentation and website)

Source URL(s) + fetch date: https://hexo.io/docs/ (also https://hexo.io, the same site) · fetched 2026-11-26

## Install/build steps and build deps
1. Install prerequisites: Node.js and Git (Linux: apt-get or yum `git-core`; Node.js via NodeSource or nvs/nvm).
2. Install the CLI globally: `npm install -g hexo-cli`.
3. Alternative: `npm install hexo`, then `npx hexo <command>` (or add `./node_modules/.bin` to PATH on Linux).
4. Create a site: `hexo init blog`, then `cd blog`. Launch: `hexo server`. Build static files: `hexo generate`.

## Runtime deps
- Node.js (required version depends on Hexo release): Hexo 8.0+ requires Node.js 20.19.0 minimum; Hexo 7.0+ 14.0.0; Hexo 6.2+ 12.13.0; Hexo 6.0+ 12.13.0 up to below 18.5.0; Hexo 5.0+ 10.13.0 up to below 12.0.0.
- The page recommends the latest Hexo and recommended Node; older versions get no bugfixes.

## Binaries/entrypoint/CLI flags
- `hexo server`, `hexo new`, `hexo generate`, `hexo deploy` are listed. The `hexo server` options page is separate ("Server") and was NOT covered by this fetch.

## Ports
- Default `hexo server` port is not stated on this page. Plan.md states 4000 is hexo's default; the reference image uses 8080 explicitly. Not verified here.

## Version/release info and asset naming
- npm packages `hexo-cli` and `hexo`. No release binaries.

## Gotchas
- Plan.md says Hexo core needs Node >= 20.19.0, which agrees with this page for Hexo 8.0+.
- Not fetched (one-level-deep sub-pages "Server" and "Commands" were not followed because the top page linked them but the page text gave no content for them): hexo server options.
