# adguard-home — implementation plan
> Source: ./draft.md · Target: apps/adguard-home/ · Difficulty: medium · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | **1.0.0** (stable, released 2026-11-19). The draft targets v0.107.80; this plan targets v1.0.0 instead. v1.0 keeps the v0.107 config schema (release notes), so no migration. v1.1.0-b.1 and v1.0.0-b.2 are prereleases and must be ignored. |
| Renovate | `datasource=github-releases`, `depName=AdguardTeam/AdGuardHome`, `versioning=semver` (tags have a `v` prefix; the default semver handling strips it) |
| License | GPL-3.0 (GitHub API). Use SPDX `GPL-3.0-only`. |
| Source | https://github.com/AdguardTeam/AdGuardHome |
| amd64 URL | https://github.com/AdguardTeam/AdGuardHome/releases/download/v1.0.0/AdGuardHome_linux_amd64.tar.gz |
| arm64 URL | https://github.com/AdguardTeam/AdGuardHome/releases/download/v1.0.0/AdGuardHome_linux_arm64.tar.gz |
| Checksums | Release asset `checksums.txt` (sha256, lines like `<hash>  ./AdGuardHome_linux_amd64.tar.gz`). amd64 `19e023d9...1e4f`, arm64 `f5c331d2...2604`. The arm64 tarball was downloaded and its sha256 matched. |
| Tarball layout | `AdGuardHome/AdGuardHome`, `LICENSE.txt`, `README.md`, `CHANGELOG.md`, `AdGuardHome.sig` (verified by listing the arm64 tarball) |
| Upstream Dockerfile | `docker/build.Dockerfile` reviewed: alpine, copies a prebuilt binary to `/opt/adguardhome`, runs `setcap cap_net_bind_service=+eip`, `WORKDIR /opt/adguardhome/work`, args `--no-check-update -c /opt/adguardhome/conf/AdGuardHome.yaml -w /opt/adguardhome/work` |
| Ports (upstream EXPOSE) | 53 tcp+udp, 67/68 udp (DHCP), 80, 443 tcp+udp, 853 tcp+udp, 3000 tcp+udp (setup wizard / alt UI), 5443, 6060 |
| CLI flags (options.go) | `-c/--config`, `-w/--work-dir`, `--web-addr host:port`, `--no-check-update`, `--no-permcheck`, `--check-config`, `-l/--logfile`, `-v/--verbose`, `--pidfile` |
| Env vars read | `ADGUARD_HOME_DEFAULT_WEB_PORT` (home.go: web port used while the install wizard is shown; default 3000). No other env config found. |
| glibc vs musl | The release binary is a static Go build (upstream builds it for alpine and for the tarball); no musl dependency expected. UNVERIFIED: not run, only the file list was inspected. |

## 2. Target layout

```
apps/adguard-home/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```
No `defaults/`: the config must be created by the setup wizard (it sets the admin user). No `root/`. No `DOWNSTREAM_CHANGES.md` (nothing uses it as a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`

Why: single static Go binary, no runtime packages needed (ubuntu already has `curl`, `tar`, `ca-certificates`, `tzdata`, `tini`). Closest sibling: `apps/adguardhome-sync` (Go release tarball on ubuntu).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, then `USER root` (only for the download and `chown`).
2. One `RUN`:
   - Map arch: `case "${TARGETARCH}" in amd64|arm64) ;; *) echo unsupported; exit 1;; esac` (asset names use the same `amd64`/`arm64` strings).
   - `curl -fsSL -o /tmp/agh.tar.gz "https://github.com/AdguardTeam/AdGuardHome/releases/download/v${VERSION#v}/AdGuardHome_linux_${TARGETARCH}.tar.gz"`
   - `curl -fsSL -o /tmp/checksums.txt "https://github.com/AdguardTeam/AdGuardHome/releases/download/v${VERSION#v}/checksums.txt"`
   - Verify: `expected="$(awk -v f="./AdGuardHome_linux_${TARGETARCH}.tar.gz" '$2==f {print $1}' /tmp/checksums.txt)"; echo "${expected}  /tmp/agh.tar.gz" | sha256sum -c -`
   - `tar xzf /tmp/agh.tar.gz -C /tmp`; `mkdir -p /app /usr/share/licenses/adguard-home`; `mv /tmp/AdGuardHome/AdGuardHome /app/AdGuardHome`; `mv /tmp/AdGuardHome/LICENSE.txt /usr/share/licenses/adguard-home/`; `chown -R apps:apps /app && chmod -R 755 /app`; `rm -rf /tmp/*`.
3. No `setcap` (see section 9: a file capability makes `exec` fail when the container's bounding set lacks `NET_BIND_SERVICE`).
4. `USER apps`
5. `COPY --chmod=0755 . /`
6. `EXPOSE 3000 53/tcp 53/udp`, `VOLUME /config`. `HOME=/config` comes from the base image.

## 5. docker-bake.hcl

```hcl
variable "APP"     { default = "adguard-home" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=AdguardTeam/AdGuardHome versioning=semver
  default = "1.0.0"
}
variable "LICENSE" { default = "GPL-3.0-only" }
variable "SOURCE"  { default = "https://github.com/AdguardTeam/AdGuardHome" }
```
Plus the 4 standard targets (`docker-metadata-action`, `image`, `image-local`, `image-all` amd64+arm64) and `group "default" { targets = ["image-local"] }`, copied from `apps/adguardhome-sync/docker-bake.hcl`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

- Schema header, `schema_version: 1`, `upstream_env_url: "https://github.com/AdguardTeam/AdGuardHome"`.
- ports: `3000/tcp required: false` (setup wizard, later the admin UI if the user keeps 3000). Only this port is open on an empty `/config`, so it is the only one listed and probed; the DNS ports (53 tcp/udp, 853, 80, 443) only open after the wizard has written the config and are described in section 10.
- env: `ADGUARD_HOME_DEFAULT_WEB_PORT` default `"3000"` required false (read by the binary, passed through by start.sh); `TZ` default `"Etc/UTC"` required false.
- volumes: `/config` required true.
- dependencies: none (section omitted, as in `apps/adguardhome-sync`).

## 7. start.sh

```bash
#!/usr/bin/env bash
mkdir -p /config/work
exec /app/AdGuardHome --no-check-update \
  -c /config/AdGuardHome.yaml \
  -w /config/work
```
- Idempotent; the config is created by the wizard on first run, never overwritten.
- Nothing is written to `/app`; querylog, stats, filters and sessions all land in `/config/work`.
- `ADGUARD_HOME_DEFAULT_WEB_PORT` is read directly by the binary from the environment; no mapping needed.
- Wizard web server binds 0.0.0.0:3000 by default. UNVERIFIED: confirm with `ss -ltn` from outside the container during the run step.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

tcp:
- port: '3000'

filePaths:
- /app/AdGuardHome
```
(Probe for every port in section 6: 3000.) `timeoutSeconds` left at the default (siblings `adguardhome-sync` and `it-tools` set none). The test runs with no env vars, which is the wizard path, so it needs no extra narrowing.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
|---|---|
| `/opt/adguardhome/conf/AdGuardHome.yaml` | `/config/AdGuardHome.yaml` (`-c`) |
| `/opt/adguardhome/work` (data, querylog, stats, filters) | `/config/work` (`-w`) |
| binary updater / `--update` | disabled with `--no-check-update`; `/app` is read-only |

Draft expectations: chart runs UID 0, `readOnlyRootFilesystem: false`, persistence at `/opt/adguardhome/conf` and `/opt/adguardhome/work`. Here the container runs as UID 568 with a read-only rootfs, and both paths collapse into `/config`. Not privileged.

Port 53: a non-root user cannot bind ports below 1024 unless the runtime allows it. Options, none baked into the image: set `net.ipv4.ip_unprivileged_port_start=53` on the pod or container (preferred), choose a DNS port above 1024 in the wizard and map it at the service level, or run with `cap_add: NET_BIND_SERVICE` plus a custom `setcap` layer.

## 10. Risks, caveats and open questions

- DNS on 53 needs the sysctl or a remapped port (see section 9). The wizard default is 53, so on a stock rootless run the wizard's final step fails to bind until the user picks another port or the sysctl is set.
- Setup wizard on :3000 must be completed once before DNS works; there is no default admin user (intentional, not seeded).
- The draft pins v0.107.80, but v1.0.0 is the current stable. v1.0 has a new UI and new default upstream (Cloudflare instead of Quad9) for new installs only; existing configs are untouched.
- DHCP (67/68 udp) needs host networking and privileges; not supported by this image.
- UNVERIFIED: that the release binary starts on the ubuntu base without extra libs (it is static Go); confirm at the run step.
- The wizard may bind 80/443 as the admin UI port; same sub-1024 restriction applies.

## 11. Build and test steps

```sh
cd apps/adguard-home
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name adguard-home-probe --read-only --tmpfs /tmp \
  -v adguard-home-probe-config:/config adguard-home:1.0.0
docker logs -f adguard-home-probe
forgetool containers test --image adguard-home:1.0.0 --config ./apps/adguard-home/container-test.yaml
docker rm -f adguard-home-probe; docker volume rm adguard-home-probe-config
```
Expected readiness: a log line like `AdGuard Home is available at the following addresses` or `serving url=http://0.0.0.0:3000` and port 3000 open. Start with a fresh `/config` volume every round.

## 12. PR checklist

- Branch `feat/add-adguard-home`; commit and PR title `feat(adguard-home): add new container`; target `main`.
- Fill in `.github/PULL_REQUEST_TEMPLATE.md`, keep all sections; Notes contains `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; check `license/cla`).
- Say what was not tested: wizard completion, DNS resolution after setup, arm64 build and run, sysctl/port-53 behaviour.
- Check "Built container locally" only if the image really was built.
