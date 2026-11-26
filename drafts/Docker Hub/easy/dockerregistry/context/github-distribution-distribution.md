# distribution/distribution (repository, README, latest release)

Source URL(s) + fetch date:
- https://github.com/distribution/distribution (README via raw main) · 2026-11-26
- https://github.com/distribution/distribution/releases/latest · 2026-11-26

## What it is
Open-source implementation of the OCI Distribution Specification (the `registry` server, Go). Also Go libraries (unstable interfaces) and docs at distribution.github.io/distribution. Used as core library by Docker Hub, GHCR, GitLab, DigitalOcean, Harbor.

## Install/build
- No commands on README. BUILDING.md covers dev setup. Go codebase (no Go version stated on README).

## Runtime
- Serves HTTP to clients (OCI API). Default port not stated on README (docs/config use 5000).

## Config / env
- Not on README; see github-distribution-distribution-docs-configuration.md (docs site).

## Version/release info
- Latest release `v3.1.2` (marked Latest), 24 Sep (year from footer 2026), tag commit `3220848f15d9279c66a41aa0a257469e6aede1e9`, signed.
- Release page says "Assets 23" but the list did not load. No sha256 values on the page.
- Per-arch sha256 are hard-coded in the upstream library Dockerfile (see github-distribution-distribution-library-dockerfile.md), for amd64 `40df2224...` and arm64 `09d26f88...`.
- Release archive naming (from library Dockerfile): `registry_<version-without-v>_linux_<arch>.tar.gz` with arch `amd64`, `arm64`, `armv6`, `armv7`, `ppc64le`, `s390x`, `riscv64` (from `apk --print-arch` mapping). Download URL: `https://github.com/distribution/distribution/releases/download/v<version>/registry_<version>_linux_<arch>.tar.gz`.

## License
- Code: Apache-2.0. README and docs folder: CC-BY-4.0.
