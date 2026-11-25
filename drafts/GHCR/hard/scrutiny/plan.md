# scrutiny — implementation plan
> Source: ./draft.md · Target: apps/scrutiny/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value | Source |
| --- | --- | --- |
| Latest stable | v0.10.0, published 2026-11-01, not prerelease | https://api.github.com/repos/AnalogJ/scrutiny/releases/latest |
| Draft / TrueCharts image tag | `ghcr.io/analogj/scrutiny:v0.10.0-omnibus` (matches v0.10.0) | draft.md |
| Renovate | `datasource=github-releases depName=AnalogJ/scrutiny versioning=semver` (proposed; not checked against repo renovate config) | GitHub release API |
| License | MIT | https://api.github.com/repos/AnalogJ/scrutiny/license |
| Linux amd64 binaries | `https://github.com/AnalogJ/scrutiny/releases/download/v0.10.0/scrutiny-web-linux-amd64`, `.../scrutiny-collector-metrics-linux-amd64` | release asset list |
| Linux arm64 binaries | `.../scrutiny-web-linux-arm64`, `.../scrutiny-collector-metrics-linux-arm64` | release asset list |
| Frontend | `.../scrutiny-web-frontend.tar.gz` | release asset list |
| Checksum source | UNVERIFIED: no checksums file or digest asset in the v0.10.0 release | release asset list |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/AnalogJ/scrutiny/3ae9db201f5c51751d4b6779593f90144a128bf0/docker/Dockerfile | fetched |

Upstream Dockerfile summary (omnibus image):
- Bases: `node` (frontend), `golang:1.27-trixie` (backend), `debian:trixie-slim` (smartmontools and runtime).
- smartmontools 7.5 built from source (static) with `update-smart-drivedb`.
- Runtime apt: `ca-certificates cron curl tzdata procps xz-utils`. Downloads s6-overlay v3.1.6.2 and InfluxDB 2.8.0 `.deb` (installed with `dpkg -i --force-all`).
- `ENV PATH=/opt/scrutiny/bin:${PATH}`, `INFLUXD_CONFIG_PATH=/opt/scrutiny/influxdb`, `S6_SERVICES_READYTIME=1000`.
- `EXPOSE 8080`. No VOLUME, no USER (runs as root), `CMD ["/init"]` (s6).
- Writes: `/opt/scrutiny` (bin, web, config; config is `chmod -R ugo+rwx`), `/opt/scrutiny/influxdb`, `/usr/sbin/smartctl`, `/usr/share/smartmontools/`, `/etc/cron.d/scrutiny`, `/etc/cont-init.d/*`, `/etc/services.d/*`.

Ports: 8080 (web UI, confirmed by EXPOSE). The draft's 8086 (embedded InfluxDB) is UNVERIFIED: the Dockerfile does not EXPOSE it.
Env vars: only the ENV lines above are confirmed. Scrutiny's own config env names are UNVERIFIED.
Arm64: available (release assets above).
Dependencies: none external; InfluxDB is embedded in the omnibus image.

## 2. Target layout

Files in `apps/scrutiny/`:
- `Dockerfile`, `docker-bake.hcl`, `settings.yaml`, `container-test.yaml`, `start.sh` (required).
- `defaults/` only if a default scrutiny config file is shipped (reason: seeding `/config` on empty start). Not needed if the app generates its config at start.
- No `etc/` unless cron or s6 service files are shipped (see section 4 and open question 1).
- Never use `root/`.
- No `DOWNSTREAM_CHANGES.md`: scrutiny is not a `FROM` base.

## 3. Base image

- `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`
- Why: ubuntu is the foundation for ContainerForge runtime images, and the upstream binaries are static Go builds, so no language runtime is needed.
- Closest sibling: `apps/adguardhome-sync` (prebuilt binary tarball on ubuntu, `USER apps`, `/config`).
- Smartmontools is installed from apt on top of the ubuntu base.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`, `ENV HOME=/config`.
2. Map `TARGETARCH` to the release suffix: `amd64` → `linux-amd64`, `arm64` → `linux-arm64`. Other arches fail the build explicitly.
3. Download `scrutiny-web-linux-$ARCH` and `scrutiny-collector-metrics-linux-$ARCH` and `scrutiny-web-frontend.tar.gz` from the v0.10.0 release into `/tmp`. Verify against a checksum: UNVERIFIED, none published, so pin by version and record the sha256 of each asset in the Dockerfile after downloading them once (flag this in the PR).
4. Install to `/app/bin` and `/app/web` (`/app` is read-only at runtime; these are written only at build time).
5. apt: `smartmontools` (package version pinned against what the ubuntu 26.04 base offers; UNVERIFIED exact version). Do not install `curl` or `ca-certificates` if the base already has them.
6. Ship licence in `/usr/share/licenses/scrutiny/` (MIT).
7. `COPY --chmod=0755 . /`, `EXPOSE 8080`, `VOLUME /config`, `USER apps`.
8. Do not ship InfluxDB 2.8 `.deb` or s6 in this app unless open question 1 resolves to "omnibus". If omnibus is chosen, the influx `.deb` has no checksum (flag as blocker).

## 5. docker-bake.hcl

- `variable "APP" { default = "scrutiny" }`
- `variable "VERSION" { // renovate: datasource=github-releases depName=AnalogJ/scrutiny versioning=semver` then `default = "0.10.0"`. Note: the chart tag is `v0.10.0-omnibus`; the ContainerForge tag must not carry `-omnibus` unless the omnibus path is chosen.
- `variable "LICENSE" { default = "MIT" }`
- `variable "SOURCE" { default = "https://github.com/AnalogJ/scrutiny" }`
- Standard targets: `docker-metadata-action`, `image`, `image-local`, `image-all`, `group "default"`.
- Validate with `cd apps/scrutiny && docker buildx bake --print`.

## 6. settings.yaml

- Schema header with `schema_version: 1`; `upstream_env_url: https://github.com/AnalogJ/scrutiny`.
- `ports`: `8080` tcp, `required: true`.
- `env`: only variables the app reads. Confirmed: none beyond what start.sh sets. Keep list minimal, e.g. `SCRUTINY_WEB_PORT`-style names only after verification (UNVERIFIED).
- `volumes`: `/config` (persistent). Map upstream `/opt/scrutiny/config` and `/opt/scrutiny/influxdb` to `/config/...` in start.sh.
- `dependencies`: none.

## 7. start.sh

- Idempotent. Create `/config/config` and `/config/influxdb` only when missing.
- Set `INFLUXD_CONFIG_PATH=/config/influxdb` (overrides the upstream `/opt/scrutiny/influxdb`).
- Never write under `/app`. Caches and temp files go to `/tmp`.
- Bind the web UI to `0.0.0.0:8080`.
- End with `exec` on the web binary, so signals reach it. If omnibus: start InfluxDB and the collector from the same script, then `exec` the web process (process model to be decided in open question 1).

## 8. container-test.yaml

- Keep the forgetool schema header used by sibling apps.
- `tcp` probe on 8080 with a `timeoutSeconds` value taken from a sibling web app.
- `filePaths`: the generated config path in `/config` and the binary `/app/bin/scrutiny-web`.
- No env vars are set by the test; the no-device path must still start (smartctl finds no disks, so the collector logs and waits).

## 9. Rootless and read-only-rootfs adaptations

- Upstream runs as root with `privileged: true`, `allowPrivilegeEscalation: true`, `capabilities: SYS_RAWIO, SYS_ADMIN`, and a read-only hostPath `/run/udev` (draft; chart values). ContainerForge images run as `apps`, so this is a conflict.
- Target: `USER apps`. SMART access needs raw disk device nodes, so the container will not collect SMART data without privileges and device passthrough. This is a documented limit, not something the Dockerfile can fix.
- Write paths: upstream `/opt/scrutiny/config` → `/config/config`; upstream `/opt/scrutiny/influxdb` → `/config/influxdb`; cron and s6 writes are removed when not used.
- `readOnlyRootFilesystem` is expected to be achievable: everything writable is `/config` or `/tmp`.
- Expected security settings to verify, not to assume: privileged yes (device access), non-root yes (target), read-only yes (target).

## 10. Risks, caveats and open questions

- Open question 1: omnibus (web + collector + embedded InfluxDB + cron, s6) or split (web only, external InfluxDB)? The draft is `hard` because of omnibus. Recommendation: plan the split first, since it fits the one-process model and avoids the unverified InfluxDB `.deb`.
- The InfluxDB 2.8.0 `.deb` download has no checksum (blocker for omnibus).
- Release has no checksum asset (UNVERIFIED): pin and record sha256 of each binary.
- SMART data needs device passthrough (`/dev/sd*`, `SYS_RAWIO`); without it the collector reports nothing (draft inference, consistent with upstream).
- The draft's security expectation of `privileged: yes` is consistent with the upstream chart; it cannot be removed, so the app needs an explicit "privileged required" note in the PR.
- Upgrades: the chart tag is `v0.10.0-omnibus`, which is not a ContainerForge tag scheme; keep `VERSION` in bake as the source of truth.
- Blockers: privileged/raw device access; omnibus unverified InfluxDB download; no arm64 test host assumed.

## 11. Build and test steps

1. `cd apps/scrutiny && docker buildx bake --print` (must exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. `docker run --rm -d --name scrutiny-probe --read-only --tmpfs /tmp -v scrutiny-probe-config:/config ghcr.io/trueforge-org/scrutiny:<version>` (use the local tag `scrutiny:<version>` from image-local), then `docker logs -f scrutiny-probe`.
4. Readiness signal: a line containing `listening` or `Starting` on port 8080 and the process still running. No fatal/panic lines. The collector without disks may log a warning; treat it as non-fatal only if the web process keeps running.
5. Test: `forgetool containers test --image scrutiny:<version> --config ./apps/scrutiny/container-test.yaml`.
6. Cleanup: `docker rm -f scrutiny-probe; docker volume rm scrutiny-probe-config`.
- Not run here: no docker build was run for this plan.

## 12. PR checklist

- Branch `feat/add-scrutiny`, commit `feat(scrutiny): add new container`, target `main`.
- Use `.github/PULL_REQUEST_TEMPLATE.md`; check only the applicable boxes.
- Notes section: `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- State what is not tested (anything not built or run locally).
- Mention the privileged requirement and the open questions above.
