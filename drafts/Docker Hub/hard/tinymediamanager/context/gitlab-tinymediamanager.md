# tinyMediaManager/tinyMediaManager (upstream source)

**Source URL(s):** https://gitlab.com/tinyMediaManager/tinyMediaManager (README raw URL at master returned 404; repo page fetched instead)
**Fetched:** 2026-11-26

## What it is
- "A multi-OS media management tool" (GitLab description). Java desktop app (Swing) for Kodi-style metadata.
- License: Apache License 2.0 (GitLab page; also OCI label in upstream Dockerfile).

## Repo facts
- Default branch: `devel` (pipeline badge and commit links point to it; not stated explicitly).
- 13,468 commits, 24 branches, 119 tags, 103 releases.
- Linked files: README (`/-/blob/devel/README.md`), LICENSE, changelog.txt, CONTRIBUTING.
- Tag naming: plan.md says `tinyMediaManager-5.3.5`; not re-verified here.

## Install/build steps and build deps
- No build for a container: use the prebuilt Universal Package (see gitlab/download summaries).
- Install (docs): extract the archive into any folder and run the `tinyMediaManager` launcher in that folder (see docs-tinymediamanager-installation.md).

## Runtime deps
- Ships its own Java runtime since v4.0 (`jre` in the Universal Package). The ARM build is the exception: no Java is packaged for ARM devices (see installation summary).
- libmediainfo: the app will say when it is not working. The docs advise installing an official MediaInfo from mediaarea.net. The upstream Docker image installs libzen0v5 and libmediainfo0v5 from mediaarea.net .debs.

## Binaries/entrypoint/CLI flags
- Launcher: `tinyMediaManager` in the install folder (executable). Upstream Docker CMD: `["/app/tinyMediaManager", "-Dtmm.contentfolder=/data"]`.
- Release archives: `tinyMediaManager-<VER>-linux-<arch>.tar.xz` (amd64 and arm64), under the release page path `v5/dist/`. Sizes: amd64 131.5 MB, arm64 130.3 MB (release listing, 2026-10-30).
- Checksums: each download has a sha256 link on the release page (file names not confirmed here; plan.md says `<tarball>.sha256` sidecar with 64 hex chars).

## Env vars
Upstream Docker image (see dockerhub summary): USER_ID, GROUP_ID, PASSWORD, LC_TIME, TZ, ALLOW_DIRECT_VNC, LC_ALL, LANG. These are for the jlesage-style GUI base (not in the native app). Native launcher env options are in `launcher-extra.yml` `env:` (see docs-tinymediamanager-start-parameters.md).

## Ports
Upstream Docker: 4000 (noVNC web), 5900 (VNC, when direct VNC is enabled), and an API port (v4.3+, number not given).

## Volumes/paths and persistent data
- Content folder: holds `data`, `logs`, `cache`, `backup`, `addons`. Default location in the portable install: the tinyMediaManager folder itself; Linux: `~/.local/share/tinyMediaManager`.
- Override with `-Dtmm.contentfolder`, or separately `-Dtmm.datafolder`, `-Dtmm.cachefolder`, `-Dtmm.backupfolder`, `-Dtmm.logfolder`, `-Dtmm.addonfolder`.
- Upstream Docker: `/data` (all local data), `/media/xxx` (media sources), `/app/addons` (custom scrapers; the overview also mentions `/data/addons`).

## User/UID and permissions
Upstream Docker: runs as `USER_ID`/`GROUP_ID` (default 1000/1000); host user must own the mapped volumes. Native app: runs as the invoking user.

## Config files and formats
- `launcher-extra.yml` (documented on start-parameters page; format below). Upstream Docker recommends it at `/app/launcher-extra.yml`.
- `extra.txt`: mentioned only in the installation docs as a place for static `-Dtmm.*` flags in the tinyMediaManager folder. Not on the start-parameters page.

## Healthcheck/readiness endpoints
None documented in this source.

## Version/release info
- Latest stable: 5.3.5 (Oct 30 2026 build timestamps on the download page).
- Release channels: Release, Pre-Release, Nightly (download page).
- Renovate (plan.md): gitlab-tags with extractVersion.

## Arch support
- Native: Linux amd64 and arm64 Universal Packages both listed. arm64 ships WITHOUT a bundled Java (see installation summary).
- Upstream Docker image: x86_64 only (Docker Hub, and the Dockerfile base is `base-amd64`).

## Gotchas
- Upstream image is x86_64 only, which conflicts with plan.md's arm64 claim for `copy-from`; verify before using it as a copy source.
- Upstream docker: `launcher-extra.yml` is the documented config file, not `extra.txt` (plan.md assumed `extra.txt`).
- The README at master returned 404; default branch appears to be `devel`.
