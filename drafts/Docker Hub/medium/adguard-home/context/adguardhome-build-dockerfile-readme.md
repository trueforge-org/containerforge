# AdGuardHome: docker/build.Dockerfile, README, latest release

## Source URL(s) + date
- https://raw.githubusercontent.com/AdguardTeam/AdGuardHome/003d6e1e15e04127f6d6d5e2f5c1aa843130752a/docker/build.Dockerfile (fetched 2026-11-26)
- https://raw.githubusercontent.com/AdguardTeam/AdGuardHome/master/README.md (fetched 2026-11-26)
- https://api.github.com/repos/AdguardTeam/AdGuardHome/releases/latest (fetched 2026-11-26)

## What it is
- AdGuard Home: network-wide ads and trackers blocking DNS server (Go). Web UI with setup wizard.
- Docker image built from a prebuilt binary (`scripts/make/build-docker.sh` context) via `docker/build.Dockerfile`.

## build.Dockerfile
- `FROM alpine:3.23`
- ARGs: `BUILD_DATE`, `VERSION`, `VCS_REF`, `DIST_DIR`, `TARGETARCH`, `TARGETOS`, `TARGETVARIANT`
- OCI labels: description "Network-wide ads & trackers blocking DNS server", `org.opencontainers.image.licenses="GPL-3.0"`, source `https://github.com/AdguardTeam/AdGuardHome`, title "AdGuard Home", url `https://adguard.com/en/adguard-home/overview.html`, vendor AdGuard.
- `RUN apk --no-cache add ca-certificates libcap tzdata && mkdir -p /opt/adguardhome/conf /opt/adguardhome/work && chown -R nobody: /opt/adguardhome`
- `COPY --chmod=0755 --chown=nobody:nogroup ./${DIST_DIR}/docker/AdGuardHome_${TARGETOS}_${TARGETARCH}_${TARGETVARIANT} /opt/adguardhome/AdGuardHome`
- `RUN setcap 'cap_net_bind_service=+eip' /opt/adguardhome/AdGuardHome`
- `EXPOSE 53/tcp 53/udp 67/udp 68/udp 80/tcp 443/tcp 443/udp 853/tcp 853/udp 3000/tcp 3000/udp 5443/tcp 5443/udp 6060/tcp`
- `WORKDIR /opt/adguardhome/work`
- `ENTRYPOINT ["/opt/adguardhome/AdGuardHome"]`
- `CMD ["--no-check-update", "-c", "/opt/adguardhome/conf/AdGuardHome.yaml", "-w", "/opt/adguardhome/work"]`

## Port table (Dockerfile comments)
| Port | Proto | Use |
| --- | --- | --- |
| 53 | TCP, UDP | DNS |
| 67 | UDP | DHCP server |
| 68 | UDP | DHCP client |
| 80 | TCP | HTTP (main) |
| 443 | TCP, UDP | HTTPS, DoH (incl. HTTP/3), DNSCrypt (main) |
| 853 | TCP, UDP | DoT, DoQ |
| 3000 | TCP, UDP | HTTP(S) alt (incl. HTTP/3) |
| 5443 | TCP, UDP | DNSCrypt alt |
| 6060 | TCP | pprof |

## README (master)
- Docker: "official Docker image on Docker Hub" (`https://hub.docker.com/r/adguard/adguardhome`). `make build-docker` builds locally with Buildx.
- Channels: `beta` and `edge` tags on Docker Hub for unstable builds.
- Build from source: `make build-release CHANNEL=... VERSION=...`.
- License: GPL-3.0 (per Dockerfile label and plan; README section not extracted).

## Latest release (releases/latest API)
- tag `v1.0.0`, published `2026-11-19T15:29:56Z`.
- Asset names: `AdGuardHome_linux_amd64.tar.gz`, `checksums.txt` (plus per-arch tarballs; arm64 name follows the same pattern per plan).
- Browser download example: `https://github.com/AdguardTeam/AdGuardHome/releases/download/v1.0.0/AdGuardHome_linux_amd64.tar.gz`

## Gotchas
- Upstream Dockerfile runs `setcap cap_net_bind_service` on the binary and expects `nobody` ownership; plan.md does not use setcap (see plan section 9).
- `--no-check-update` is in the upstream CMD.
