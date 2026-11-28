# pihole — implementation plan
> Source: ./draft.md · Target: apps/pihole/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | Draft image tag `ghcr.io/pi-hole/pihole:2026.11.0`. Latest `docker-pi-hole` release tag is `2026.11.0` (https://api.github.com/repos/pi-hole/docker-pi-hole/releases/latest, read via `gh api`). FTL binary version: `v6.9`, published 2026-11-11, not a prerelease (https://api.github.com/repos/pi-hole/FTL/releases/tags/v6.9, read via `gh api`). |
| Renovate | FTL: `datasource=github-releases depName=pi-hole/FTL versioning=semver`. Image tag: `datasource=docker depName=ghcr.io/pi-hole/pihole`? UNVERIFIED: renovate config not read; confirm the datasource in sibling apps before committing. |
| License | Pi-hole core: EUPL-1.2 (https://raw.githubusercontent.com/pi-hole/pi-hole/master/LICENSE). Note the exception in that file: commits to master before v3.0 keep their earlier licenses. GitHub reports `NOASSERTION` for pi-hole/pi-hole and pi-hole/docker-pi-hole. `docker-pi-hole` license: UNVERIFIED (not read). |
| Source URL | https://github.com/pi-hole/pi-hole (core), https://github.com/pi-hole/docker-pi-hole (image build), https://github.com/pi-hole/FTL (FTL) |
| Download (FTL) | `https://github.com/pi-hole/FTL/releases/download/v6.9/pihole-FTL-amd64` and `https://github.com/pi-hole/FTL/releases/download/v6.9/pihole-FTL-arm64` (asset names confirmed via the release API). Also available: 386, armv6, armv7, riscv64. |
| Checksum source | Release sidecars: `pihole-FTL-amd64.sha1` (`a438611acfee876d08cb6241b2288e3bae9026a1  pihole-FTL-amd64`) and `pihole-FTL-arm64.sha1` (`66eba44204c46b3adf03d204edbc663af81266f9  pihole-FTL-arm64`), from https://github.com/pi-hole/FTL/releases/download/v6.9/. SHA-1 only: no SHA-256 published upstream. Verify with `sha1sum -c`, and state the SHA-1 limitation in the PR. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/pi-hole/docker-pi-hole/7a8d396/src/Dockerfile (read via WebFetch summary, not verbatim). Base: `alpine:3.24.3@sha256:be2656…` (apk, musl). Installs pi-hole scripts to `/opt/pihole` and `/usr/local/bin`, web UI to `/var/www/html/admin`, core to `/etc/.pihole`. Creates `pihole` user/group UID/GID 1000 (`PIHOLE_UID`/`PIHOLE_GID`). `ENTRYPOINT ["start.sh"]`, no `CMD`, no `USER` (runs as root), no `VOLUME`. `HEALTHCHECK` runs `dig` against 127.0.0.1 for `pi.hole`. |
| Upstream apt/apk packages | Upstream uses apk: bash, bind-tools, curl, git, grep, jq, procps-ng, shadow, tzdata, wget. The draft's apt list (lighttpd, php-cgi, php-sqlite3, php-xml, sqlite3, cron, curl, dnsutils) is NOT verified against the upstream image: it is the Ubuntu-side equivalent the draft inferred. Treat as inferred and confirm against the pi-hole core install docs (UNVERIFIED). |
| Ports | `EXPOSE 53 53/udp`, `67/udp`, `80`, `123/udp`, `443` (upstream). DNS 53 tcp+udp is the core service. |
| Env (real, README) | `TZ`, `FTLCONF_webserver_api_password` (random if unset), `FTLCONF_dns_listeningMode` (`ALL` on bridge), `FTLCONF_misc_etc_dnsmasq_d` (`true` only with the dnsmasq.d volume). Upstream ENV: `DNSMASQ_USER=pihole`, `FTL_CMD=no-daemon`. DNS port: no env var documented; set via port mapping. Source: https://raw.githubusercontent.com/pi-hole/docker-pi-hole/master/README.md |
| Paths | `/etc/pihole` (databases, `pihole.toml`), `/etc/dnsmasq.d` (optional dnsmasq config). |
| Capabilities (README) | `NET_ADMIN` only for DHCP. `SYS_TIME` only for NTP client. `SYS_NICE` optional. The README advises against `--privileged` and recommends naming specific capabilities. |
| Non-root | README does not address running as non-root. Upstream Dockerfile has no `USER`, so the image runs as root. |
| arm64 | FTL arm64 binary exists (asset confirmed). Upstream image arm64 manifest UNVERIFIED (not queried). |
| Dependencies | None (draft agrees). |
| copy-from | `no` (draft). Upstream image is Alpine/musl: does not run on glibc Ubuntu. |

## 2. Target layout

- `apps/pihole/Dockerfile`
- `apps/pihole/docker-bake.hcl`
- `apps/pihole/settings.yaml`
- `apps/pihole/container-test.yaml`
- `apps/pihole/start.sh`
- `apps/pihole/defaults/` for a default `pihole.toml` or `setupVars` seed (planned: seed only when missing in `/config`).
- `apps/pihole/etc/` only if a dnsmasq or lighttpd config must be shipped (see section 9).

Never `root/`. No `DOWNSTREAM_CHANGES.md`: not a `FROM` base.

## 3. Base image

- `ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a` (ubuntu alone, per the draft). `apps/dokuwiki`, `apps/grav` and `apps/bookstack` exist as PHP siblings. UNVERIFIED: which one uses php-cgi on ubuntu. (Both `ubuntu:26.04` and `ubuntu:26.4` tags with this digest are used in `apps/*/Dockerfile`.)
- No Python or Node runtime needed.
- The upstream Alpine base is NOT reused: the pi-hole scripts assume Alpine paths (`apk`, `busybox`). The plan rebuilds the layout on Ubuntu. Record this as the main risk.

## 4. Dockerfile

1. `ARG VERSION` (pi-hole image tag, `2026.11.0`), `ARG FTL_VERSION=v6.9`, `ARG TARGETARCH`.
2. `USER root` for installs only.
3. `RUN apt-get update && apt-get install -y --no-install-recommends lighttpd php-cgi php-sqlite3 php-xml sqlite3 cron curl dnsutils ca-certificates && rm -rf /var/lib/apt/lists/*`. Package list is inferred from the draft (section 1). Pin is not done here: record resolved versions in the PR and check them against `VERSION` if the image is tagged with the upstream pi-hole version.
4. FTL binary:
   - `ARG` maps `TARGETARCH` to the release name: `amd64` → `pihole-FTL-amd64`, `arm64` → `pihole-FTL-arm64`. Any other value fails the build (do not fall back to amd64).
   - `curl -fsSL -o /usr/local/bin/pihole-FTL "https://github.com/pi-hole/FTL/releases/download/${FTL_VERSION}/pihole-FTL-${arch}"`.
   - Verify: `echo "<sha1>  /usr/local/bin/pihole-FTL" | sha1sum -c -`, with the sha1 pinned per arch in the Dockerfile from section 1.
   - `chmod 0755 /usr/local/bin/pihole-FTL`. Check the binary is glibc-linked on Ubuntu: `readelf -d` for `NEEDED` (UNVERIFIED: link type not checked; if it is static musl, the image does not run on ubuntu, see section 10).
5. Pi-hole scripts (core): fetch the `pi-hole` core at the commit or tag the `2026.11.0` image uses. UNVERIFIED: the core tag/commit for `2026.11.0`. Do not use a branch name. Extract scripts to `/opt/pihole` and `/usr/local/bin`, and the web UI to `/var/www/html/admin` (layout per upstream Dockerfile summary, section 1). Set `chmod -R 755`.
6. License: pi-hole core EUPL-1.2 text to `/usr/share/licenses/pihole/LICENSE`. Pi-hole FTL license (GPL-2.0 per the FTL repo) UNVERIFIED: not read.
7. `ENV DNSMASQ_USER=pihole FTL_CMD=no-daemon PIHOLE_UID=1000 PIHOLE_GID=1000 HOME=/config` (no `PIHOLE_UID` mutation at runtime, see section 9).
8. `COPY --chmod=0755 . /`, `USER apps`.
9. `EXPOSE 53 53/tcp 53/udp 8080 8443`. Do not expose 67/udp and 123/udp unless the user needs DHCP or NTP (section 9).
10. `VOLUME /config`. Do not set `ENTRYPOINT`: the base `ubuntu` image runs `tini` then `/entrypoint.sh`, which execs `/start.sh`.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "pihole"
}

variable "VERSION" {
  // renovate: datasource=docker depName=ghcr.io/pi-hole/pihole versioning=docker
  default = "2026.11.0"
}

variable "FTL_VERSION" {
  // renovate: datasource=github-releases depName=pi-hole/FTL versioning=semver
  default = "v6.9"
}

variable "LICENSE" {
  default = "EUPL-1.2"
}

variable "SOURCE" {
  default = "https://github.com/pi-hole/pi-hole"
}
```

`VERSION` aligns with the Dockerfile `ARG VERSION`. The `FTL_VERSION` variable is consumed by the Dockerfile `ARG FTL_VERSION`; add it to `args` in the `image` target so bake and Dockerfile stay aligned. Use `versioning=docker` only if the datasource in sibling apps is docker-based; confirm. Then the four standard targets and the default group as in `apps/adguardhome-sync`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/pi-hole/pi-hole"
ports:
  - port: 53
    protocol: tcp
    required: false
  - port: 53
    protocol: udp
    required: false
  - port: 8080
    protocol: tcp
    required: false
  - port: 8443
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
  - name: FTLCONF_webserver_api_password
    default: ""
    required: false
  - name: FTLCONF_dns_listeningMode
    default: "ALL"
    required: false
  - name: FTLCONF_misc_etc_dnsmasq_d
    default: "false"
    required: false
volumes:
  - path: /config
    required: true
```

- `FTLCONF_webserver_api_password` empty default: upstream generates a random one when unset. start.sh must generate and persist one under `/config` (section 7) and print nothing secret to the log.
- The DNS ports on 53 require a privileged bind (section 9). Decide before committing: listing `53` here while the container cannot bind it is a schema-level lie.
- Do NOT list `67/udp`, `123/udp` unless the user asks (not part of the core service).
- `/etc/pihole` is the persistent path: map `/config` to it (section 9), so the settings file moves with the volume. Confirm mapping in `start.sh`.

## 7. start.sh

Idempotent, empty-`/config` safe, never writes to `/opt/pihole` or `/usr/local/bin`:

```bash
#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config/pihole /config/dnsmasq.d /tmp/pihole

# Seed only when missing: never overwrite existing user state
[ -s /config/pihole/pihole.toml ] || cp /defaults/pihole.toml /config/pihole/pihole.toml

# API password: generate once, persist, never log it
if [ -z "${FTLCONF_webserver_api_password:-}" ] && [ ! -s /config/pihole/.api_password ]; then
  head -c 24 /dev/urandom | base64 > /config/pihole/.api_password
fi
export FTLCONF_webserver_api_password="${FTLCONF_webserver_api_password:-$(cat /config/pihole/.api_password)}"

export FTLCONF_dns_listeningMode="${FTLCONF_dns_listeningMode:-ALL}"

# Web server on an unprivileged port (see section 9)
# lighttpd config is seeded from /defaults in the image

exec /usr/local/bin/pihole-FTL no-daemon
```

- `/config/pihole` vs `/etc/pihole`: FTL reads `/etc/pihole`. The image must either set the FTL config dir to `/config/pihole` (UNVERIFIED env name) or symlink `/etc/pihole` to `/config/pihole` at build time (the symlink is in the image, the target is in `/config`, so it works read-only). Decide in section 10.
- The `FTL_CMD=no-daemon` ENV in the Dockerfile is for the upstream start.sh; this start.sh does not use it. Do not rely on it; use the explicit command.
- lighttpd and cron are not started above. The web UI needs lighttpd and PHP-FPM or php-cgi (section 9). A process supervisor or a multi-process `start.sh` is required. Open point (section 10).
- DHCP and NTP: not started (section 6).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
healthCommands:
- command: dig +short +time=2 @127.0.0.1 pi.hole
tcp:
- port: '53'
- port: '8080'
- port: '8443'
http:
- port: '8080'
  path: /admin/
```

- Every port in `settings.yaml` needs a probe (repo rule). `53/udp` is covered only by the `healthCommands` `dig` check (as in `apps/valkey/container-test.yaml`, `timeoutSeconds` is top-level); `tcp` checks do not test UDP. UNVERIFIED: forgetool's UDP probe support. Port 8443 (TLS) is only listed if lighttpd is configured for it; otherwise drop it from settings and test.
- The test runs as `apps` with no privilege. A `tcp` probe on 53 only passes if the bind succeeds. If the bind fails (section 9), the test fails honestly: do not drop the probe.
- Timeout 180s: FTL initialises the gravity database on first start. Compare with a sibling.
- The HTTP probe path `/admin/` is UNVERIFIED against this build: confirm with a run.

## 9. Rootless and read-only-rootfs adaptations

| Upstream behaviour | ContainerForge adaptation | Reason |
| --- | --- | --- |
| Runs as root | Runs as `apps` (`USER apps`). | Rule for all apps. Chart expects `runAsUser 0` and `allowPrivilegeEscalation true`; ContainerForge does not carry that over. |
| DNS on port 53 (tcp and udp) | Needs `NET_BIND_SERVICE` on the runtime side, OR host networking/port mapping to a high port (for example 5353) with an explicit decision. Cannot be done with `apps` alone. | Binding ports below 1024 needs a capability. This is a **blocker** for "DNS works as-is" (section 10). |
| `/etc/pihole` (config, databases) | `/config/pihole` via a symlink from `/etc/pihole` (build time) or FTL's config dir env (UNVERIFIED) | Persistent state in `/config`. |
| `/etc/dnsmasq.d` | `/config/dnsmasq.d` (`FTLCONF_misc_etc_dnsmasq_d=true` only if the user mounts custom files) | Optional persistent dnsmasq config. |
| Web UI on port 80 and 443 | Bind to 8080 and 8443 (lighttpd `server.port`); `settings.yaml` and `container-test.yaml` use 8080/8443. 80 and 443 need `NET_BIND_SERVICE` too. | Same bind limit as DNS. |
| `pihole` user (UID/GID 1000) | Use the base `apps` user; do not create `pihole`. Keep `DNSMASQ_USER=pihole` only if dnsmasq is used, and then create that user in the Dockerfile (root step). | `USER apps` is the rule. |
| `/tmp` | All caches and scratch in `/tmp` (`TMPDIR=/tmp`). | Read-only rootfs. |
| `cron` (gravity updates) | Not started by default. Decide: run gravity updates from `start.sh` on a timer, or leave updates manual (section 10). | cron needs root to read `/etc/crontab` and write `/var/spool/cron`. |
| `HEALTHCHECK` with `dig` | Keep as `healthCommands` in `container-test.yaml` (section 8). | Same check, run by forgetool. |

- capabilities: none in `settings.yaml` yet. Adding `NET_BIND_SERVICE` is a platform decision (section 10); the draft's list (`NET_ADMIN`, `SETFCAP`, `SETPCAP`, `KILL`, `SYS_TIME`, `SYS_NICE`) is NOT needed for the core DNS and web service. Only `NET_ADMIN` (DHCP) and `SYS_TIME` (NTP) map to optional features. Do not grant the draft's full set.
- `allowPrivilegeEscalation`: not needed for `apps`. Do not set it.
- `readOnlyRootFilesystem`: ContainerForge target is read-only rootfs. Verify with `--read-only --tmpfs /tmp`.

## 10. Risks, caveats and open questions

- BLOCKER (port 53): the core DNS service binds port 53 (tcp and udp) and runs as `apps`. Without `NET_BIND_SERVICE` or a remap to a high port, DNS does not work. The user must choose: (a) add `NET_BIND_SERVICE` (platform-level; check whether ContainerForge allows it), (b) remap to a high port and document that clients must point at it, or (c) host networking. Do not ship with port 53 listed and not bound.
- BLOCKER (base): the upstream image is Alpine/musl. The FTL binary's link type (dynamic glibc vs static) is UNVERIFIED. If it is musl-only, the Ubuntu base will not run it, and the app is not feasible without a rebuild from source (out of scope). Check with `readelf -d` on the downloaded binary before writing the Dockerfile.
- Core install on Ubuntu: the upstream scripts are written for Alpine (apk, busybox). The plan rebuilds on Ubuntu from the pi-hole core source. This is the largest effort item and is NOT verified. Confirm the pi-hole core install path (`automated install` script or manual install) for Ubuntu.
- Multi-process: FTL, lighttpd and cron. Upstream uses `start.sh` with `s6`-style or direct execution. The plan runs FTL as the main process; lighttpd needs its own start. Decide supervision before building (section 7).
- API password: random if unset (README). Generated and persisted in `/config/pihole/.api_password` (section 7). Document.
- Blocklists are downloaded at runtime: first start needs internet (draft caveat, confirmed as an inferred concern; not verified in the fetched pages).
- Clients only benefit if DNS is reachable from the LAN: needs host networking or a published port (draft caveat, inferred).
- Checksums: SHA-1 only for FTL (section 1). Record it.
- arm64: FTL arm64 binary exists. The image on arm64 is UNVERIFIED.
- Blockers: port 53 (above), base compatibility (above). Nothing else blocks a build.

## 11. Build and test steps

Step 0 (before writing the Dockerfile): download `pihole-FTL-amd64` and `pihole-FTL-arm64` into a scratch directory outside the repo, check each against its `.sha1`, run `readelf -d` on the amd64 binary, and record `NEEDED` entries. If the binary needs musl, stop: this is blocker-level (section 10).

From `apps/pihole/`, one app only, in protocol order:

1. `docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. Probe run with an empty config volume and a non-privileged port:
   ```sh
   docker volume create pihole-probe-config
   docker run --rm -d --name pihole-probe --read-only --tmpfs /tmp \
     -p 127.0.0.1:8080:8080 -v pihole-probe-config:/config pihole:2026.11.0
   docker logs -f pihole-probe
   ```
   Pass signal: FTL reports it is listening and lighttpd is serving (exact text UNVERIFIED until run), process still running, no permission errors on port 53. Cleanup: `docker rm -f pihole-probe; docker volume rm pihole-probe-config`.
4. `forgetool containers test --image pihole:2026.11.0 --config ./container-test.yaml` (if forgetool is unavailable, check port 8080 and the `dig` query by hand). Run it via `haiku-triage`. Round limit: 10.

Expected to FAIL on port 53 without a capability or remap: that is the blocker in section 10, not a test to weaken.

## 12. PR checklist

- Branch: `feat/add-pihole` from `main`.
- Commit: `feat(pihole): add new container`.
- PR title matches the commit.
- Notes section: `🤖 This PR is AI generated.`
- CLA: tell the user to sign at https://cla-assistant.io/trueforge-org/containerforge (the `license/cla` check shows status). Only the user can sign.
- Fill in `.github/PULL_REQUEST_TEMPLATE.md`, keeping its sections and checkboxes. Check only the boxes that apply.
- State the port 53 decision and the base decision in the PR.
- Say what was not tested: DNS resolution from a client, blocklist download, DHCP and NTP, arm64 image, and anything the probe run did not reach.
- Not applicable: DOWNSTREAM_CHANGES.md (not a `FROM` base).
