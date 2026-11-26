# haiwen/seafile-server (repo + releases)

Source URL(s): https://github.com/haiwen/seafile-server (repo page, fetched via WebFetch 2026-11-26); https://api.github.com/repos/haiwen/seafile-server/releases/latest (fetched 2026-11-26). Raw README (`raw.githubusercontent.com/haiwen/seafile-server/master/README.md`) returned 404.

## What it is
- "Seafile Server Core": RPC for Seahub front-end, HTTP APIs for desktop-client sync.
- License: AGPLv3 for server core (other components have other licenses).
- Repo: ~550 stars, 982 commits on master, forum forum.seafile.com.

## Build/install
- README has no build steps; points to https://manual.seafile.com/build_seafile/server/ (not fetched; manual unreachable).
- File tree: `configure.ac`, `autogen.sh`, `Makefile.am` (autotools). Dirs include `python`, `fileserver`, `notification-server`.
- Runtime/build deps: not listed in README.

## Releases (api.github.com releases/latest)
- API "latest" flag returned tag `v7.1.1-server` (html: .../releases/tag/v7.1.1-server), author ly1217.
- Repo page showed Releases section empty; no 14.x tag seen on either page.
- Plan references tag `v14.0.9-server` (2026-09-22): NOT confirmed by these sources (see README conflict).

## Version/asset naming
- Tags pattern `v<major>.<minor>.<patch>-server`.

## Gotchas
- GitHub "latest" flag does not reflect the newest 14.x tag; use tag listing for renovate/version work.
