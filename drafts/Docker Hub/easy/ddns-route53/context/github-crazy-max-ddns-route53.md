# crazy-max/ddns-route53 (repository, README, releases)

Source URL(s) + fetch date:
- https://github.com/crazy-max/ddns-route53 (README via raw master) · 2026-11-26
- https://github.com/crazy-max/ddns-route53/releases/latest · 2026-11-26

## What it is
Keeps Amazon Route 53 A/AAAA records aligned with the current public IP (IPv4 and/or IPv6). Updates only when the address changes. Built-in scheduler (no external cron needed). Alternative to third-party DDNS providers.

## Install/build steps and build deps
- Binary from GitHub releases, or the Docker image on Docker Hub (`crazymax/ddns-route53`).
- Upstream image build (master Dockerfile): Go build stage on `golang:${GO_VERSION}-alpine${ALPINE_VERSION}` (ARG GO_VERSION=1.26, ALPINE_VERSION=3.23, XX_VERSION=1.9.0). Builds with `xx-go build -trimpath -ldflags "-s -w -X main.version=..." -o /usr/bin/ddns-route53 ./cmd` and `xx-verify --static`. Tests run with `-race`.

## Runtime
- Final upstream stage: `FROM alpine:${ALPINE_VERSION}`, `COPY --from=build /usr/bin/ddns-route53 /usr/local/bin/ddns-route53`, installs ca-certificates, openssl, creates user/group `ddns-route53` uid/gid 1000, `USER ddns-route53`.
- `ENTRYPOINT ["ddns-route53"]`, `CMD ["--config", "/ddns-route53.yml"]`. No EXPOSE, no VOLUME, no HEALTHCHECK.
- Static Go binary (`xx-verify --static` in build).

## Binaries/entrypoint/CLI flags
Binary `ddns-route53`, usage `ddns-route53 [options]`.

| Flag | Env | Default | Notes |
|---|---|---|---|
| `--config` | `CONFIG` | none | config file path |
| `--schedule` | `SCHEDULE` | none | CRON expr. If unset: runs once and exits |
| `--ifname` | `IFNAME` | default interface | interface used for WAN IP lookup |
| `--max-retries` | `MAX_RETRIES` | 3 | WAN IP / AWS request retries |
| `--max-backoff-delay` | `MAX_BACKOFF_DELAY` | 5s | upper bound for AWS retry backoff |
| `--log-level` | `LOG_LEVEL` | info | |
| `--log-json` | `LOG_JSON` | false | |
| `--log-caller` | `LOG_CALLER` | false | |
| `--log-nocolor` | `LOG_NOCOLOR` | false | |
| `--version` | none listed | | |

## Env vars
- `DDNSR53_` prefix plus nested config path uppercased and joined with `_`. Examples: `DDNSR53_CREDENTIALS_ACCESSKEYID`, `DDNSR53_CREDENTIALS_SECRETACCESSKEY`, `DDNSR53_ROUTE53_HOSTEDZONEID`, `DDNSR53_ROUTE53_RECORDSSET_0_NAME` / `_TYPE` / `_TTL` (zero-based array index), `DDNSR53_WANIP_PROVIDERS_IPV4` / `_IPV6` (comma-separated URLs).
- Plus the CLI env vars above.

## Config files and formats
- File `ddns-route53.yml` or `.yaml`. Search order: `/etc/ddns-route53/`, `$XDG_CONFIG_HOME/`, `$HOME/.config/`, `.` (working directory). `--config` / `CONFIG` overrides.
- Keys: `credentials.accessKeyID`, `credentials.secretAccessKey`, `route53.hostedZoneID`, `route53.recordsSet[]` (`name`, `type` e.g. A/AAAA, `ttl` e.g. 300), `wanip.providers.ipv4`, `wanip.providers.ipv6`.
- Config sources "are evaluated in the order listed". Docs do NOT explicitly state that env overrides file (plan.md says confirmed in `internal/config/config.go`, which was not fetched). Treat as unverified here.

## Ports / persistent data
- No ports (outbound only: WAN IP lookup and AWS Route 53 API). No persistent data or volumes.

## User/UID & permissions
- Upstream image runs as `ddns-route53` uid/gid 1000.

## Healthcheck/readiness
- None.

## Version/release info and asset naming
- Latest release: `v2.16.1` (marked Latest), 23 Oct, commit `d8e3a348afe6152e8919e9f2360ad4fec2a2b323` (signed). Notes: built with Go 1.26.10 for CVE-2026-111943; no functional changes vs v2.16.0. Release flagged immutable.
- Asset names (from upstream Dockerfile, the release pipeline): `ddns-route53_<version-without-v>_<os>_<arch><variant>.tar.gz` (windows: `.zip`). Example: `ddns-route53_2.16.1_linux_amd64.tar.gz`.
- Tarball contents: `ddns-route53` (binary), `CHANGELOG.md`, `LICENSE`, `README.md` at archive root.
- `checksums.txt`: generated with `sha256sum -b ddns-route53_*` (binary-mode marker `*` in lines). Strict checked in pipeline.
- Asset list on the releases page did not load in the fetch; the file naming above is from the Dockerfile.

## Arch support
- Linux amd64 and arm64 tarballs per plan.md (the release page did not list them in this fetch; the Dockerfile's TARGETARCH/TARGETVARIANT naming supports this).

## License
- MIT (`MIT License, Copyright (c) 2019-2026 CrazyMax` per plan.md; README/site say MIT).

## Gotchas
- Without `--schedule`, the app runs once and exits (restart loop under an orchestrator).
- Docs do not state the install/run timezone flag. None exists.
