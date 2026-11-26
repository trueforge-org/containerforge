# google/go-containerregistry (crane CLI upstream)

**Source URL(s) + fetch date:** https://github.com/google/go-containerregistry ; https://raw.githubusercontent.com/google/go-containerregistry/main/cmd/crane/README.md ; https://api.github.com/repos/google/go-containerregistry/releases/tags/v0.22.1 (release 0.22.1 asset list; the release/download page URL pattern is https://github.com/google/go-containerregistry/releases/download/v${VERSION}) · fetched 2026-11-26

## What it is
Go library and tools for working with container registries. The `crane` CLI is the subject here (crane tool for remote images: `ls`, `manifest`, `copy`, `tag`, `auth login`, etc.). Licence: Apache-2.0 (per plan.md).

## Install/build steps and build deps
- Prebuilt release tarball (recommended for containers): `go-containerregistry_${OS}_${ARCH}.tar.gz` from GitHub Releases.
- Alternatives upstream: `go install github.com/google/go-containerregistry/cmd/crane@latest`, Homebrew, Arch pacman.
- Binaries inside each tarball (per plan.md, goreleaser): `crane`, `gcrane`, `krane`, plus `LICENSE` and `README.md`. Static, CGO off.

## Runtime deps
None (static Go binary). Needs CA certificates for HTTPS registries.

## Binaries/entrypoint/CLI flags
- Binary: `crane`. Examples: `crane ls <repo>`, `crane auth login -u <user> -p <pass> <registry>`, `crane tag <image> <newtag>`, `crane copy`, `crane manifest`.
- `crane version` prints the version (without leading `v`, e.g. `0.22.1`, per plan.md).

## Env vars
Not documented on the README page. plan.md states crane reads `DOCKER_CONFIG` / `~/.docker/config.json` for registry auth (UNVERIFIED by fetch).

## Ports
None (CLI).

## Volumes/paths and persistent data
Auth config at `$HOME/.docker/config.json` (or `DOCKER_CONFIG`). Written by `crane auth login`.

## Config files and formats
Docker `config.json` (`auths` map). Login writes entry for the registry (e.g. `https://index.docker.io/v1/`).

## Version/release info and asset naming
- Latest release: **v0.22.1**, published 2026-09-04T00:17:00Z.
- Tag format with `v` prefix; asset version strings have no `v`.
- Assets for v0.22.1 (exact names):
  - `checksums.txt`
  - `go-containerregistry-0.22.1.tar.gz` (source)
  - `go-containerregistry_Linux_x86_64.tar.gz` (amd64), `go-containerregistry_Linux_arm64.tar.gz`, `go-containerregistry_Linux_armv6.tar.gz`, `..._Linux_i386.tar.gz`, `..._Linux_loong64.tar.gz`, `..._Linux_ppc64le.tar.gz`, `..._Linux_riscv64.tar.gz`, `..._Linux_s390x.tar.gz`
  - `go-containerregistry_Darwin_arm64.tar.gz`, `go-containerregistry_Darwin_x86_64.tar.gz`, `go-containerregistry_Windows_arm64.tar.gz`, `go-containerregistry_Windows_x86_64.tar.gz`
  - `multiple.intoto.jsonl` (SLSA 3 provenance)
- Note: amd64 is `Linux_x86_64`, not `Linux_amd64`. Arm64 is `Linux_arm64`. plan.md's `A` variable must map amd64 -> x86_64.
- Checksum file is `checksums.txt` in the same release (plan.md verifies it).

## Arch support
Linux x86_64, arm64, armv6, i386, loong64, ppc64le, riscv64, s390x (release assets).

## Gotchas
- Plan.md says the amd64 tarball holds crane/gcrane/krane/LICENSE/README.md at root; arm64 layout unverified.
- Plan.md's claim of SLSA provenance is supported by `multiple.intoto.jsonl` in the release.
