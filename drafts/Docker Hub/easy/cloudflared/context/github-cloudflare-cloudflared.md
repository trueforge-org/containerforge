# cloudflare/cloudflared (repository, README, releases)

Source URL(s) + fetch date:
- https://github.com/cloudflare/cloudflared (fetched as https://raw.githubusercontent.com/cloudflare/cloudflared/master/README.md) · 2026-11-26
- https://github.com/cloudflare/cloudflared/releases/latest · 2026-11-26

## What it is
- Command-line tunnel daemon (`cloudflared`) between Cloudflare's network and an origin. It opens outbound-only connections, so the origin needs no inbound firewall holes.
- Also supports Layer 4 TCP access (SSH, RDP) via the `access` subcommand.

## Install/build steps and build deps (from README)
- Build from source: `make cloudflared`.
- Build deps: GNU Make, capnp, Go `>= 1.27.4`. Optional: capnpc-go, goimports, golangci-lint, gomocks (go.uber.org/mock).
- `go.mod` `go` directive must be full major.minor.patch. Makefile exports `GOTOOLCHAIN=go<version>`; `make <target> GOTOOLCHAIN=local` uses the installed Go. Builds with `GOTOOLCHAIN=local` fail if local Go is older than `go.mod`. A `toolchain` directive in `go.mod` is ignored.
- Make targets: `cloudflared`, `test`, `fmt`, `lint`, `mocks`, `install-hooks`.

## Runtime deps
- None listed beyond the binary and a Cloudflare account/tunnel.

## Binaries/entrypoint/CLI flags
- Binary: `cloudflared`. CLI: `cloudflared tunnel help`, `cloudflared access help`. Tunnel auth and creation commands are in linked docs, not on the README.

## Ports / config paths / env vars / license / arch
- Not stated on the README (no env vars, ports, config paths, license, or supported arches listed). See the release and Dockerfile summaries for what is known from other sources.

## Version/release info and asset naming (from releases/latest)
- Latest release: `2026.11.2` (commit `dc57315`), marked Latest, released 23 Nov (page shows 2026 footer only). Tag format `YYYY.M.P` (no `v`).
- Page says 28 assets; the checksum block lists 25. Names seen:
  - Linux raw binaries: `cloudflared-linux-<arch>` for `386`, `amd64`, `arm`, `arm64`, `armhf`. Also `cloudflared-fips-linux-amd64` (FIPS build). Raw binaries have no archive wrapper.
  - Linux packages: `cloudflared-linux-<arch>.deb` and `.rpm` (rpm uses `x86_64` / `aarch64` names too, e.g. `cloudflared-linux-x86_64.rpm`, `cloudflared-linux-aarch64.rpm`).
  - macOS: `cloudflared-darwin-amd64.tgz`, `cloudflared-darwin-arm64.tgz`, `cloudflared-amd64.pkg`, `cloudflared-arm64.pkg` (the `.pkg` files are macOS installers).
  - Windows: `cloudflared-windows-386.exe|.msi`, `cloudflared-windows-amd64.exe|.msi`.
- Checksums: release page has a `Checksums:` block with `<filename>: <sha256>` lines (the scraping source for checksums). Values for 2026.11.2:
  - `cloudflared-linux-amd64`: 56f13335143ec0e22772963290683a84a04114a35ec64cbc794a4d39ff9bb8cf
  - `cloudflared-linux-arm64`: 04a7b7f08bce85d56b26ffe1fdbfbb21a074495a363d16f0783c40e25b5c5281
  - `cloudflared-linux-arm`: d219494581180764c6d2454409691bb06879d01b43cdeae12476070a7e4e4762
  - `cloudflared-linux-386`: 6bfb8ee3731194223d9a07f4a70f52c203525db5cccccbd55647a0d3c01641b1
- Release page text says 3 commits have landed on master since this release.

## Arch support
- Linux assets exist for 386, amd64, arm, arm64, armhf (plus rpm aarch64/x86_64 names). Windows and Darwin also published.

## Gotchas
- Plan's `.pkg` URLs (`cloudflared-amd64.pkg`) are macOS installers. Linux container should use `cloudflared-linux-<arch>`.
- Support policy: versions within one year of latest are supported.
