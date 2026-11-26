# lrsjng/h5ai (upstream source)

**Source URL(s):** https://github.com/lrsjng/h5ai (README via https://raw.githubusercontent.com/lrsjng/h5ai/master/README.md; releases via https://github.com/lrsjng/h5ai/releases); project site https://larsjung.de/h5ai/ redirects (307) to https://github.com/lrsjng/h5ai/
**Fetched:** 2026-11-26

## What it is
- "A modern HTTP web server index": a directory index/file browser for HTTP servers.
- Intended for Apache httpd, lighttpd and nginx.
- Install from a prebuilt package (release zip) or build from source.

## Install/build steps and build deps
- Prebuilt release packages: from the GitHub releases page, and also at https://release.larsjung.de/h5ai/ (dev builds at /develop/).
- Do not install from the `src` folder; those files need preprocessing.
- Build from source: `npm install` then `npm run build` at the repo root. Output is a zipball in `build/`. Requires Node 10.0 or newer; tested on Linux only.
- The README does not say where to unzip the package or where `_h5ai` belongs in a web root.

## Runtime deps
- A PHP-capable web server (README names Apache, lighttpd, nginx). PHP version and extensions are not stated in the README or the release notes.
- PHP extensions used by the upstream Docker wrapper (see github-awesometic-docker-h5ai.md): session, json, xml, mbstring, exif, intl, gd, imagick, zip. Thumbnails use ffmpeg and imagemagick.

## Binaries/entrypoint/CLI flags
- No CLI. Served as PHP web files.
- Release asset (v0.30.0): `h5ai-0.30.0.zip` (per plan.md; the release page shows "3 assets" but names did not load in this fetch). Asset URL pattern: `https://github.com/lrsjng/h5ai/releases/download/v<VER>/h5ai-<VER>.zip`. Tag has `v` prefix; file name does not.
- Release note: "Update" (commit aa94de4, 09 Nov). No PHP version requirement stated.

## Env vars
None read by h5ai itself (README). The Docker wrapper variables belong to awesometic/docker-h5ai, not h5ai.

## Ports
None set upstream. Web server decides.

## Volumes/paths and persistent data
- The `_h5ai` folder is the code directory (contains `public/`, `private/`). Its placement relative to the web root is not stated in the README.
- Config: `options.json` (location and keys not stated in README; the Docker wrapper writes it to `/config/options.json` and symlinks `_h5ai/private/conf/options.json` to it, per plan.md).
- Caches: `_h5ai/public/cache` and `_h5ai/private/cache` (per plan.md; not verified against upstream docs).

## User/UID and permissions
Not stated.

## Config files and formats
- `options.json`: not described in the README (only referenced).
- Do not install `src/` contents; use the packaged `_h5ai` tree.

## Healthcheck/readiness endpoints
None stated.

## Version/release info
- Latest release: v0.30.0 (marked Latest, 09 Nov, commit aa94de4). Plan.md says published 2024-11-09.
- Renovate: `datasource=github-releases depName=lrsjng/h5ai versioning=loose`.

## Arch support
Arch-neutral PHP/JS files.

## Gotchas
- No built-in login: anyone reaching the web server sees all files under the served path. Add auth in front (basic auth or proxy).
- Browsing content is whatever is mounted at the served path; mount layout matters.
- License: MIT, Copyright (c) 2020 Lars Jung. Some Material Design icons are CC BY 4.0. (README.)
- The `larsjung.de/h5ai/` site is just a redirect to this repo.
