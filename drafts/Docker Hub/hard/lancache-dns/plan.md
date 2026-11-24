# lancache-dns — implementation plan
> Source: ./draft.md · Target: apps/lancache-dns/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | No releases or tags on lancachenet/lancache-dns (master only, 172 commits). Draft tag is `latest`. Plan: track master by commit. UNVERIFIED: the current commit SHA, read it at implementation. |
| Renovate | `datasource=git-refs depName=https://github.com/lancachenet/lancache-dns versioning=loose` (branch master). `VERSION` is a date-style or short SHA value chosen at implementation (open question below). |
| License | MIT (verified, copyright 2015-2017 lancachenet contributors). BIND9 is MPL-2.0 (UNVERIFIED in Ubuntu copyright). `LICENSE` in bake: `MIT`. |
| Source | https://github.com/lancachenet/lancache-dns |
| Downloads | bind9 and dnsutils from apt (amd64 and arm64 both in Ubuntu). dnstool built from https://github.com/lancachenet/dnstool (Go, `CGO_ENABLED=0 go build -trimpath -ldflags "-s -w"`). cache-domains from https://github.com/uklans/cache-domains (git). |
| Checksum | apt signatures; git commits pinned by ARG ref. No published checksums. |
| Upstream Dockerfile | https://github.com/lancachenet/lancache-dns/blob/master/Dockerfile reviewed. Builder `golang:1.27-alpine`; final `lancachenet/ubuntu:latest`; env STEAMCACHE_DNS_VERSION, ENABLE_DNSSEC_VALIDATION=false, LANCACHE_DNSDOMAIN=cache.lancache.net, CACHE_DOMAINS_REPO, CACHE_DOMAINS_BRANCH=master, UPSTREAM_DNS=8.8.8.8; ports 53/udp and 53/tcp; `WORKDIR /scripts`; healthcheck `dig +norecurse @127.0.0.1 . NS`. |
| Overlay (reviewed via tree) | `etc/bind/named.conf`, `named.conf.options`, `cache/zone.tmpl`, `etc/supervisor/conf.d/bind.conf`, `hooks/entrypoint-pre.d/10_generate_config.sh`, `hooks/supervisord-pre.d/10_config_check.sh`. Contents not read: UNVERIFIED, read them when implementing. |
| Docs env | `USE_GENERIC_CACHE`, `LANCACHE_IP`, `<SERVICE>CACHE_IP` (BLIZZARD, FRONTIER, ORIGIN, RIOT, STEAM, UPLAY), `DISABLE_<SERVICE>`, `UPSTREAM_DNS`; custom records via `/etc/bind/cache/custom.db`. Defaults of these not documented. |

## 2. Target layout
- `Dockerfile`, `docker-bake.hcl`, `settings.yaml`, `container-test.yaml`, `start.sh`
- `defaults/bind/named.conf.tmpl`, `defaults/bind/named.conf.options.tmpl`, `defaults/bind/zone.tmpl`: adapted copies of the upstream overlay templates, with paths moved to `/tmp` and `/config`.
- `scripts/`: only if the generation logic from `10_generate_config.sh` is split out of start.sh.
- No supervisor config (one process). No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image
Final stage: `ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`.
Build stage for dnstool: follow `apps/pwndrop/Dockerfile` (ubuntu base build stage that installs Go), then `COPY --from=buildstage`. Go rules: compile only in the build stage, `GOCACHE=/tmp/gocache`. Closest siblings: `apps/pwndrop` (Go), `apps/adguardhome-sync` (settings/test).

## 4. Dockerfile
1. Build stage: `ARG DNSTOOL_REF`; apt `git golang-go ca-certificates`; `git clone` dnstool, `git checkout ${DNSTOOL_REF}`; `CGO_ENABLED=0 go build -trimpath -ldflags "-s -w" -o /out/dnstool`; copy its LICENSE.
2. Final stage: `ARG VERSION TARGETARCH`; `USER root`.
3. `apt-get install -y --no-install-recommends bind9 dnsutils git ca-certificates` (ca-certificates and curl are likely in base; check before adding). Pin `bind9=<version>` and verify against Ubuntu 26.04 (UNVERIFIED version).
4. `git clone --depth=1` cache-domains at pinned `CACHE_DOMAINS_REF` into `/app/cache-domains` (read-only runtime; refresh at start is NOT possible in /app, so start.sh may clone to `/tmp` when `CACHE_DOMAINS_REPO` is set).
5. `setcap 'cap_net_bind_service=+ep' /usr/sbin/named` (libcap2-bin) so UID `apps` binds 53. Verify `named` path.
6. Licenses: `/usr/share/licenses/lancache-dns/` with the repo LICENSE, dnstool LICENSE, cache-domains LICENSE.
7. `COPY --from=buildstage /out/dnstool /usr/local/bin/dnstool`.
8. `chown -R apps:apps /app`, `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 53/udp 53/tcp`, `VOLUME /config`, `CMD ["/start.sh"]`.

## 5. docker-bake.hcl
APP `lancache-dns`; VERSION with `// renovate: datasource=git-refs depName=https://github.com/lancachenet/lancache-dns versioning=loose`; LICENSE `MIT`; SOURCE `https://github.com/lancachenet/lancache-dns`. Args pass VERSION (and DNSTOOL_REF, CACHE_DOMAINS_REF if used, with their own renovate comments). Standard targets: `docker-metadata-action`, `image`, `image-local` (tag `${APP}:${VERSION}`), `image-all` (amd64, arm64), `group "default"`. Run `docker buildx bake --print`.

## 6. settings.yaml
- Header + `schema_version: 1`, `upstream_env_url: "https://github.com/lancachenet/lancache-dns"`.
- ports: 53 udp, 53 tcp (`required: true` for udp).
- env (all read by upstream overlay or docs; defaults per upstream Dockerfile where known): `UPSTREAM_DNS` (8.8.8.8), `LANCACHE_DNSDOMAIN` (cache.lancache.net), `ENABLE_DNSSEC_VALIDATION` (false), `CACHE_DOMAINS_REPO`, `CACHE_DOMAINS_BRANCH` (master), `USE_GENERIC_CACHE` (false: UNVERIFIED default), `LANCACHE_IP` (empty), `STEAMCACHE_IP` etc. (empty), `DISABLE_<SERVICE>`. Mark UNVERIFIED defaults.
- volumes: `/config` (custom.db, generated state).
- dependencies: none. Optional consumer: lancache-monolithic (container to be added).

## 7. start.sh
- Write generated config only to `/tmp/bind` (named.conf, zones, rpz); persist `custom.db` in `/config` (seed empty file if missing) and include it from the rpz zone.
- Render templates from env; generate per-service zones by running dnstool/the template logic over `/app/cache-domains` (or a `/tmp` re-clone if `CACHE_DOMAINS_REPO` differs from the build default).
- named options: `directory "/tmp/bind"`, `listen-on { any; }`, `listen-on-v6 { any; }`, pid-file and session-keyfile in `/tmp`, `allow-recursion` for private ranges, `forwarders` from `UPSTREAM_DNS`, `dnssec-validation` from `ENABLE_DNSSEC_VALIDATION`.
- Run `named-checkconf` before start; fail fast with a clear message.
- `exec named -g -u apps -c /tmp/bind/named.conf` (drop `-u` if already `apps`; `-g` keeps it in foreground and logs to stderr).

## 8. container-test.yaml
```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 120
tcp:
- port: '53'
healthCommands:
- command: dig +time=2 +tries=1 +norecurse @127.0.0.1 . NS
  expectedContent: "status: NOERROR"
  matchContent: true
filePaths:
- /usr/local/bin/dnstool
- /app/cache-domains
```
The UDP 53 path is covered by the dig health command (the schema has no udp probe). Timeout 120 is an estimate; compare with sibling apps.

## 9. Rootless and read-only-rootfs adaptations
- Port 53 as non-root: setcap on `named`; requires `NET_BIND_SERVICE` in the container bounding set (Docker default has it; Kubernetes `drop: ALL` needs it added back, or set `net.ipv4.ip_unprivileged_port_start=0`).
- Upstream write paths: `/etc/bind` (generated config), `/var/cache/bind`, `/var/log/named`, run dir `/run/named`. Remap to `/tmp/bind`, `/tmp/bind/cache`, stderr, `/tmp/bind/run`.
- Draft expected root, no read-only rootfs, no extra persistence; reconciled to `USER apps`, read-only rootfs and `/config` only for custom.db.

## 10. Risks, caveats and open questions
- Host port 53 conflicts (systemd-resolved); needs freeing or remapping.
- No tags upstream: choose the VERSION scheme (commit SHA vs date) and confirm Renovate git-refs support in this repo's renovate config.
- cache-domains is cloned at build, so lists go stale; either rebuild regularly or allow `/tmp` re-clone at start (needs network).
- Overlay hook scripts were not read; the domain-to-zone logic must be ported from `10_generate_config.sh` and `zone.tmpl`.
- DNS only helps once clients point at it.
- arm64: bind9 and Go build are multi-arch; no blocker found.

## 11. Build and test steps
```sh
cd apps/lancache-dns
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create lancache-dns-probe-config
docker run --rm -d --name lancache-dns-probe --read-only --tmpfs /tmp \
  -v lancache-dns-probe-config:/config lancache-dns:<VERSION>
docker logs -f lancache-dns-probe
dig @<container-ip> steamcontent.com   # from a second container or host
forgetool containers test --image lancache-dns:<VERSION> --config ./apps/lancache-dns/container-test.yaml
docker rm -f lancache-dns-probe; docker volume rm lancache-dns-probe-config
```
Expected readiness: named log `running` and `all zones loaded`; port 53 open.

## 12. PR checklist
- Branch `feat/add-lancache-dns`; commit `feat(lancache-dns): add new container`; target `main`; PR template filled, Notes include `🤖 This PR is AI generated.`
- CLA notice: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Untested at planning time: build, runtime on 53 as non-root, setcap behavior, arm64, cache-domains zone generation.
- Pre-completion: bake --print, version alignment, USER apps, empty /config, no DOWNSTREAM_CHANGES.md.
