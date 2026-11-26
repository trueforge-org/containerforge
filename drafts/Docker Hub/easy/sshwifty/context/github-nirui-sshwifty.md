# nirui/sshwifty (upstream repo; release 0.4.13-beta-release-prebuild)

Source URL(s) + fetch date (all 2026-11-26):
- https://raw.githubusercontent.com/nirui/sshwifty/master/Dockerfile (multi-stage: debian:latest build, alpine:latest runtime)
- https://raw.githubusercontent.com/nirui/sshwifty/master/README.md
- https://raw.githubusercontent.com/nirui/sshwifty/master/sshwifty.conf.example.json
- https://raw.githubusercontent.com/nirui/sshwifty/0.4.13-beta-release-prebuild/application/configuration/loader_enviro.go
- https://raw.githubusercontent.com/nirui/sshwifty/0.4.13-beta-release-prebuild/application/configuration/loader_file.go
- https://raw.githubusercontent.com/nirui/sshwifty/0.4.13-beta-release-prebuild/sshwifty.go (license header and entry point only)
- https://raw.githubusercontent.com/nirui/sshwifty/master/sshwifty.sh: 404 (the script is generated inline by the Dockerfile, not a repo file)
- https://github.com/nirui/sshwifty/releases

## What it is
Web SSH and Telnet client (browser UI embedded in a Go binary). Maintenance mode per the Docker Hub page: bug and security fixes only, no new features. Copyright (C) 2019-2026 Ni Rui (sshwifty.go header).

## Install/build steps
Upstream Dockerfile (master):
- Stage `base`: `FROM debian:latest`; installs `build-essential curl git nodejs npm golang-go`; installs `n stable` for newer Node.
- Stage `libbase`: copies source to `/tmp/.build/sshwifty`; `npm install`; `go mod download`.
- Stage `builder`: `npm run build` then moves `./sshwifty` to `/`.
- Final: `FROM alpine:latest`; sets all `SSHWIFTY_*` ENV defaults (below); `COPY --from=builder /sshwifty /`; `adduser -D sshwifty`; writes a generated `/sshwifty.sh` (see below); `USER sshwifty`; `EXPOSE 8182`; `ENTRYPOINT ["/sshwifty.sh"]`; `CMD []`. No VOLUME.
- Generated `/sshwifty.sh`: if `SSHWIFTY_DOCKER_TLSCERT` is set, writes it to `/tmp/cert`; if `SSHWIFTY_DOCKER_TLSCERTKEY` is set, writes it to `/tmp/certkey`; if both files exist, runs `/sshwifty` with `SSHWIFTY_TLSCERTIFICATEFILE=/tmp/cert SSHWIFTY_TLSCERTIFICATEKEYFILE=/tmp/certkey`, else `/sshwifty`.
- Upstream image is built from source (npm + go), not from the release tarball.

Release tarballs (per plan.md; asset names confirmed on releases page): `sshwifty_0.4.13-beta-release_linux_amd64.tar.gz`.

## Runtime deps
Alpine base in upstream image; the binary is static Go (plan.md; not verified here). Needs a browser with WebCrypto (HTTPS context) per README.

## Binaries/entrypoint/CLI flags
- Binary `/sshwifty`. No CLI flags documented. `SSHWIFTY_CONFIG` selects one config file (sshwifty.go, README).
- `SSHWIFTY_DEBUG` non-empty enables debug output (sshwifty.go).

## Env vars (table; ENV defaults in upstream Dockerfile)
| Variable | Dockerfile default | Notes |
| --- | --- | --- |
| `SSHWIFTY_HOSTNAME` | empty | restricts host; empty accepts all |
| `SSHWIFTY_SHAREDKEY` | empty | web password; empty = public access |
| `SSHWIFTY_DIALTIMEOUT` | 10 | |
| `SSHWIFTY_SOCKS5`, `SSHWIFTY_SOCKS5_USER`, `SSHWIFTY_SOCKS5_PASSWORD` | empty | optional proxy |
| `SSHWIFTY_HOOK_BEFORE_CONNECTING` | empty | JSON string array of commands |
| `SSHWIFTY_HOOKTIMEOUT` | 30 | |
| `SSHWIFTY_LISTENINTERFACE` | 0.0.0.0 | |
| `SSHWIFTY_LISTENPORT` | 8182 | |
| `SSHWIFTY_INITIALTIMEOUT`, `SSHWIFTY_READTIMEOUT`, `SSHWIFTY_WRITETIMEOUT`, `SSHWIFTY_HEARTBEATTIMEOUT` | 0 | upstream chart sets 3, 60, 60, 20 |
| `SSHWIFTY_READDELAY`, `SSHWIFTY_WRITEELAY` | 0 | `WRITEELAY` spelling is what the code reads |
| `SSHWIFTY_TLSCERTIFICATEFILE`, `SSHWIFTY_TLSCERTIFICATEKEYFILE` | empty | plain HTTP when empty |
| `SSHWIFTY_DOCKER_TLSCERT`, `SSHWIFTY_DOCKER_TLSCERTKEY` | empty | cert contents, written by sshwifty.sh |
| `SSHWIFTY_PRESETS` | empty | JSON array; env-only |
| `SSHWIFTY_SERVERMESSAGE` | empty | |
| `SSHWIFTY_ONLYALLOWPRESETREMOTES` | empty | non-empty = true (env read) |

Other variables from the README/code (not in the upstream Dockerfile ENV): `SSHWIFTY_ALLOWEDORIGINS` (comma-separated; empty skips origin check per 0.4.13 notes), `SSHWIFTY_PINNEDSSHHOSTFINGERPRINTS` (JSON map), `SSHWIFTY_CONFIG` (config file path), `SSHWIFTY_DEBUG`.

Code details (loader_enviro.go): unset strings become empty; unset or invalid numbers silently become 0 (`parseEnvUintDefault`); JSON variables (hook, presets, pinned fingerprints) error on bad JSON; all variables are optional. Config file search (loader_file.go): `<user home>/.config/sshwifty.conf.json` (home via `user.Current()`, not `HOME`), then `/etc/sshwifty.conf.json`, then `sshwifty.conf.json` next to the executable; first usable file wins; if none, an error lists all paths.

## Ports
8182 (EXPOSE; default `SSHWIFTY_LISTENPORT`).

## Volumes/paths and persistent data
None. Upstream writes only the generated TLS files in `/tmp` (`/tmp/cert`, `/tmp/certkey`). No database or log files.

## User/UID & permissions
Runs as `sshwifty` (created with `adduser -D`, no fixed UID in the Dockerfile).

## Config files and formats
JSON config (`sshwifty.conf.example.json`): top level `HostName`, `SharedKey`, `DialTimeout`, `Socks5`, `Socks5User`, `Socks5Password`, `Hooks` (`before_connecting`), `HookTimeout`, `PinnedSSHFingerprints`, `Servers[]` (`ListenInterface`, `ListenPort`, `InitialTimeout`, `ReadTimeout`, `WriteTimeout`, `HeartbeatTimeout`, `ReadDelay`, `WriteDelay`, `AllowedOrigins`, `TLSCertificateFile`, `TLSCertificateKeyFile`, `ServerMessage`), `Presets[]`, `OnlyAllowPresetRemotes`. The example file sets `ListenInterface` to `127.0.0.1`, so a config file must change it to listen on all interfaces. Example `DialTimeout` 5, `HeartbeatTimeout` 15.

## Healthcheck/readiness endpoints
None in the Dockerfile. Probes in the TrueCharts chart use `/` (see truecharts-sshwifty.md).

## Version/release info and asset naming
- Latest: `0.4.13-beta-release-prebuild`, published 24 Nov, marked Latest. Tag form `<version>-prebuild`; archive `sshwifty_<version>_linux_<arch>.tar.gz`.
- Releases 0.4.4 to 0.4.12 all use the `-prebuild` tag; none flagged prerelease.
- 0.4.13 notes: two critical security fixes (SSH credentials could be stored in browser localStorage through the "Connected before" list; WebSocket messages were unbounded, so memory exhaustion DoS). Also PinnedSSHFingerprints setting, improved CORS/Origin checks, origin verification skipped when AllowedOrigins empty. Notes ask users to update soon.
- 0.4.12: HTTP/2 DoS patches; 0.4.11: CVE fixes; 0.4.9: CVE fixes affecting direct serving without a reverse proxy.
- Each release lists 24 assets. Visible: `GPG.asc`, `Note`, `src`, and `sshwifty_0.4.13-beta-release_<os>_<arch>.tar.gz` for darwin_amd64 and freebsd/linux (386, amd64, arm). linux arm64 is not in the visible list (page truncated).
- Commits signed with GPG key 82AE11AD1E5E8729.

## Arch support
Upstream image built from source. Release archives visible for linux amd64 and 386/arm (arm64 not seen in the fetched list).

## License
AGPL-3.0-or-later (sshwifty.go: "either version 3 of the License, or (at your option) any later version"). README says AGPL; third-party components keep their own licenses (DEPENDENCIES.md).

## Gotchas
- Invalid numeric env values silently become 0 (timeouts and delays).
- `SSHWIFTY_ONLYALLOWPRESETREMOTES` cannot be used from env per the README text (the README lists it under config file options only), though the Dockerfile and code read it.
- Preset data is sent to clients in plain text; avoid secrets there.
- Browser WebCrypto needs HTTPS; clocks must be in sync (README).
- Serving under a subpath is unsupported.
- Without `SSHWIFTY_SHAREDKEY` the web UI is public.

## Contradictions with plan.md
- plan.md says `niruix/sshwifty` "is only the Docker Hub user; the GitHub owner is nirui". The raw Dockerfile under `niruix/sshwifty` master exists and matches the nirui Dockerfile, and Docker Hub links to github.com/niruix/sshwifty. Unverified which repo is canonical.
- plan.md section 10 says linux_arm64 is "confirmed". The releases page lists visible linux (386, amd64, arm) archives only; arm64 is not in the fetched list (the list is partial).
- plan.md section 9 marks the `user.Current()` home lookup "UNVERIFIED"; loader_file.go confirms `user.Current()` (not `HOME`).
