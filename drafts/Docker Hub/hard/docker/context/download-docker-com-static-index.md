# download.docker.com static Docker binaries (index and asset naming)

Source URL(s) + fetch date:
- https://download.docker.com/linux/static/stable/x86_64/ (directory listing)
- Fetched 2026-11-26
- Direct tarball URLs (`.../x86_64/docker-29.10.0.tgz`, `.../aarch64/docker-29.10.0.tgz`) recorded here as asset naming, not downloaded.

## Asset naming pattern
- Engine: `https://download.docker.com/linux/static/stable/<arch>/docker-<ver>.tgz` (arch dirs: x86_64, aarch64, armel, armhf, ppc64le, s390x; `docker-29.10.0.tgz` exists for x86_64 and aarch64).
- Rootless extras: `docker-rootless-extras-<ver>.tgz` (same arch dirs).
- Each has a companion checksum file: `docker-<ver>.tgz.sha256` (85 bytes), `docker-rootless-extras-<ver>.tgz.sha256` (101 bytes). Also `docker-cli_<ver>.tgz` and `docker-engine_<ver>.tgz` with .sha256.

## Newest entries (as of 2026-11-26)
- `docker-29.10.0.tgz`: 2026-11-16, 75 MB. `docker-rootless-extras-29.10.0.tgz`: 2026-11-16, 12 MB.
- `docker-29.10.1.tgz`: 2026-11-24, 75 MB. `docker-rootless-extras-29.10.1.tgz`: 2026-11-24, 12 MB.
- 29.9.0 to 29.9.3 (29.9.3 dated 2026-11-03) and earlier versions listed with sizes; full history in the page.

## Arch support
- Static tarball dirs per the dind Dockerfile arch map: x86_64 (x86_64), aarch64 (aarch64), armhf (dir armel), armv7 (dir armhf), ppc64le, s390x.

## Gotchas
- 29.10.1 is newer than the 29.10.0 pin used by the plan.
