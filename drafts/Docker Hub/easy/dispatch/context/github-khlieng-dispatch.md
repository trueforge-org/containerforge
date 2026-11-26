# khlieng/dispatch (repository, README, latest release)

Source URL(s) + fetch date:
- https://github.com/khlieng/dispatch (README via raw master) · 2026-11-26
- https://github.com/khlieng/dispatch/releases/latest · 2026-11-26

## What it is
Web-based IRC client: Go server, React/Redux client. Shipped as a "single binary with no dependencies". Features: searchable history, persistent connections, multiple servers and users, DCC downloads, SASL, client certificates.

## Install options
- Prebuilt binaries (README: Windows x64, macOS x64, Linux x64). Other versions on GitHub releases.
- Go 1.11+: `go get github.com/khlieng/dispatch`, then `dispatch`. `dispatch help` shows options.
- Docker image: `khlieng/dispatch`.

## Build steps (README)
- Server: `go install`.
- Client: Node.js and yarn; `GO111MODULE=off go get github.com/jteeuwen/go-bindata/...`; `yarn global add gulp-cli`; `cd client && yarn`; `gulp build`. Server must be rebuilt to embed new client builds.
- Dev mode: `gulp` (frontend) and `dispatch --dev` (backend).

## Runtime / ports / paths
- Container ports 80 (HTTP) and 443 (HTTPS) per README Docker example: `-p <http>:80 -p <https>:443 -v <path>:/data`.
- `/data` is the persistent volume.
- HTTPS: automatic Let's Encrypt (CertMagic) is listed as a feature; no details.
- `dispatch help` gives the full flag list (not in README). `--dev` mentioned.

## Env vars
- None documented. `GO111MODULE=off` is build-time only.

## Version/release info
- Latest release `v0.7` (marked Latest), commit `08ffc79`, released by khlieng on 08 May (year not shown; plan.md says 2020-05-08). 100 commits on master since.
- Release highlight: direct message logging. Nine commits in changelog.
- Release page says "Assets 9" but the asset list did not load. No checksums.txt content or digests were visible. Plan.md's checksum values (from checksums.txt) are NOT confirmed by this fetch.
- Asset naming per plan.md: `dispatch_<version-without-v>_linux_<x64|arm64>.tar.gz` (not confirmed by this fetch).

## License
- MIT (see github-khlieng-dispatch-license.md).

## Project status
- Travis CI badge (status not shown). No version or maintenance statement on README. Hosted demo at dispatch.khlieng.com (fetch failed, see README).
- Docker Hub page says last updated over 5 years ago.

## Gotchas
- Plan.md says the v0.7 release has no DCC feature. README (master) lists DCC downloads as a feature. Plan.md's section 12 also lists DCC as untested. Contradictory inside plan.md; not confirmed either way from v0.7 sources. Left as unverified.
