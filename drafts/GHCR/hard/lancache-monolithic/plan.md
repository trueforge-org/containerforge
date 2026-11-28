# lancache-monolithic — implementation plan
> Source: ./draft.md · Target: apps/lancache-monolithic/ · Difficulty: hard · Role: sidecar (prefillImage) · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | SteamPrefill v3.7.2 (latest release, published 2026-08-25). Draft lists v3.0.0, which is outdated. Source: https://api.github.com/repos/tpill90/steam-lancache-prefill/releases/latest and https://github.com/tpill90/steam-lancache-prefill/releases/tag/v3.7.2 |
| What the image is | The draft's container is `ghcr.io/ich777/lancache-prefill:latest`, a prefill helper built on `ich777/debian-baseimage` (https://raw.githubusercontent.com/ich777/docker-lancache-prefill/master/Dockerfile). It has no pinned tag, and its runtime start script was not fetched. This plan targets the SteamPrefill tool, not the ich777 image. |
| Renovate (SteamPrefill) | `datasource=github-releases depName=tpill90/steam-lancache-prefill versioning=semver` (UNVERIFIED against upstream renovate config; tag is `v`-prefixed, so strip it for `VERSION`) |
| License | MIT (GitHub SPDX `MIT`): https://api.github.com/repos/tpill90/steam-lancache-prefill |
| Source URL | https://github.com/tpill90/steam-lancache-prefill |
| Per-arch download URLs (SteamPrefill v3.7.2) | amd64: `https://github.com/tpill90/steam-lancache-prefill/releases/download/v3.7.2/SteamPrefill-3.7.2-linux-x64.zip` (12096230 bytes). arm64: `https://github.com/tpill90/steam-lancache-prefill/releases/download/v3.7.2/SteamPrefill-3.7.2-linux-arm64.zip` (11823192 bytes). Both from the GitHub API assets list. |
| Checksum source | GitHub API asset digest, confirmed: amd64 `sha256:974d7c4e5c7a4664bd23cc8f1bba3db354ecb465a2cfc442ba766b048160394d`; arm64 `sha256:018330d6f2a2135e6b526662ccb39b54e878d2ae7bebcdc185386b220328f7be`. Verify with `sha256sum -c` in the Dockerfile. |
| Upstream Dockerfile reviewed | ich777 Dockerfile (above): `FROM ich777/debian-baseimage`, apt `unzip jq cron tzdata`, ENV block (DATA_DIR=/lancacheprefill, ENABLE_STEAM=true, CRON_SCHED_STEAM="0 2 * * *", PREFILL_PARAMS_STEAM="--recent", UID=99, GID=100, USER=prefill), `ADD /scripts/` and `/cron/`, `ENTRYPOINT ["/opt/scripts/start.sh"]`, no EXPOSE, no VOLUME, no USER (runs as root). Its `start.sh`, cron files and scripts were NOT fetched: UNVERIFIED how the scheduler and prefill tools are wired. |
| Ports | None. Confirmed: no EXPOSE in the ich777 Dockerfile. The chart's service ports (10279, 10280 to container 80/443) belong to the lancache monolithic cache, not this prefill helper. |
| Env vars | Only the ich777 ENV names in the table above (confirmed in the Dockerfile). Their meaning at runtime is UNVERIFIED (start.sh not fetched). |
| Data and config write paths | Draft chart PVCs: `/data/cache`, `/data/logs`, `/data/prefill` (chart pvc defaults; the ich777 image uses `DATA_DIR=/lancacheprefill`). Mapping to ContainerForge paths is UNVERIFIED. |
| Dependencies | None in ContainerForge terms. Needs network access to Steam and a lancache cache host (shared volume with the monolithic cache, which is not in this batch). Steam account that owns the games (draft claim, UNVERIFIED upstream). |
| Credentials | SteamPrefill login variable names are UNVERIFIED. Do not invent them. |
| arm64 | SteamPrefill has a linux-arm64 zip (confirmed above). The ich777 image's arm64 availability is UNVERIFIED. Draft `copy-from arm64: no` is unconfirmed. |

## 2. Target layout

- `apps/lancache-monolithic/Dockerfile`
- `apps/lancache-monolithic/docker-bake.hcl`
- `apps/lancache-monolithic/settings.yaml`
- `apps/lancache-monolithic/container-test.yaml`
- `apps/lancache-monolithic/start.sh` (needed: a scheduler and an env-to-argument mapping, replacing the ich777 `start.sh`)
- `apps/lancache-monolithic/etc/` or `scripts/` only if a crontab or schedule file is needed; prefer a single `start.sh` (decision in section 10).
- Never `root/`.
- No `DOWNSTREAM_CHANGES.md`: not used as a `FROM` base.

## 3. Base image

- `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a` for the final stage. ContainerForge uses ubuntu for generic userland.
- Build stage: same ubuntu image, used only to download and unpack the zip (no compile).
- Closest sibling: `apps/steamcmd` (Steam tooling on ContainerForge). Review its Dockerfile and `start.sh` before writing (not done in this plan, UNVERIFIED pattern).

## 4. Dockerfile

1. Build stage: `FROM <ubuntu> AS build`, `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. `apt-get install -y --no-install-recommends unzip` (`jq`, `cron` and `tzdata` only if the scheduler design in section 7 needs them; tzdata is probably present in base, UNVERIFIED).
3. Map `TARGETARCH` to the release asset: `amd64` -> `linux-x64`, `arm64` -> `linux-arm64`.
4. Download `SteamPrefill-${VERSION}-linux-<arch>.zip` from `https://github.com/tpill90/steam-lancache-prefill/releases/download/v${VERSION}/` into `/tmp`, then verify it against the checksum for that arch from section 1 (`echo "<sha256>  <file>" | sha256sum -c -`). Keep the digests as build ARGs or a per-arch case block.
5. `unzip` into `/app/steamprefill/`, `chmod 0755` the binary (UNVERIFIED binary name inside the zip; confirm after download).
6. Ship the license: `/usr/share/licenses/lancache-monolithic/` (MIT, from upstream repo LICENSE, UNVERIFIED path inside the zip).
7. Final stage: `FROM <ubuntu>`, `USER root`, install `unzip` only if the start script needs it at runtime (it should not), clean apt lists.
8. `COPY --from=build /app/steamprefill/ /app/steamprefill/` and `COPY --from=build /usr/share/licenses/lancache-monolithic/ /usr/share/licenses/lancache-monolithic/`.
9. `chown -R apps:apps /app && chmod -R 755 /app`.
10. `ENV HOME=/tmp TZ=Etc/UTC` and any cache paths pointed at `/tmp` (SteamPrefill cache location UNVERIFIED; set after the first run shows writes).
11. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

VOLUME /config
```

No `EXPOSE`: there are no ports.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "lancache-monolithic"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=tpill90/steam-lancache-prefill versioning=semver
  default = "3.7.2"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/tpill90/steam-lancache-prefill"
}
```

Plus the four standard targets and default group from `apps/adguardhome-sync/docker-bake.hcl`. Validate with `docker buildx bake --print`.

Naming note: the ContainerForge app name `lancache-monolithic` names the prefill helper, which is confusing next to the lancache monolithic cache. The name follows the chart. Confirm with the user before using it, since the chart name may point at a different ContainerForge app.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/tpill90/steam-lancache-prefill"
ports: []
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

- Ports: empty, because the image has no ports. Do not list the chart's 10279/10280 service ports.
- Env: only `TZ` is confirmed as the image's time zone need (cron schedule names are UNVERIFIED as env here). Add the ich777 schedule and prefill names (`ENABLE_STEAM`, `CRON_SCHED_STEAM`, `PREFILL_PARAMS_STEAM`, `PREFILL_ONSTARTUP`, `UPDATES`, `LOGCLEANUP`) only if `start.sh` actually reads them, because rules say do not invent env vars. Keep their defaults matching the ich777 image (`ENABLE_STEAM=true`, `CRON_SCHED_STEAM="0 2 * * *"`, `PREFILL_PARAMS_STEAM="--recent"`).
- Volumes: `/config` (persisted state, such as cache index and logs). Chart PVCs `/data/cache`, `/data/logs`, `/data/prefill` need a decision (section 10).
- Dependencies: none. The shared cache volume with the monolithic cache is not a ContainerForge dependency.

## 7. start.sh

Design (proposed, to be verified by first run):

```bash
#!/usr/bin/env bash
mkdir -p /config/logs /config/prefill /tmp/steamprefill
# Scheduler: run SteamPrefill with ${PREFILL_PARAMS_STEAM} on ${CRON_SCHED_STEAM} only when ENABLE_STEAM=true.
# First start prefill only when PREFILL_ONSTARTUP=true.
cd /app/steamprefill
exec ./SteamPrefill <args>   # or a scheduler loop that execs as PID 1 (see below)
```

- Idempotent: create `/config` subdirs only when missing; never write to `/app`.
- Caches and temp go to `/tmp`.
- Scheduler choice: the ich777 image uses cron. Cron inside a non-root container is awkward. Options: (a) a small shell loop that sleeps until the next schedule (exec at the end, UNVERIFIED design); (b) a cron binary from apt (UNVERIFIED rootless behaviour). Pick one in the first build and record it in section 10.
- Credentials: read from env only, never write them to files or the process list (protocol rule). Variable names UNVERIFIED.
- `exec` the final long-running process so signals reach it.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 60
filePaths:
- /app/steamprefill/SteamPrefill
- /usr/share/licenses/lancache-monolithic/LICENSE
```

- No `tcp` or `http` probes: the image has no ports (coverage rule is met by having none).
- The test runs with no env. Scheduled prefill would not run without `ENABLE_STEAM`, and the process would stay in the idle loop. Check the idle loop process and the log line in section 11 by hand, since it is not in `container-test.yaml`.
- `filePaths` needs the binary path confirmed from the zip (UNVERIFIED name).
- No DB-dependency exception applies.

## 9. Rootless and read-only-rootfs adaptations

| Upstream path | Remap |
| --- | --- |
| `/lancacheprefill` (DATA_DIR, root-owned in ich777) | `/config` (persistent) for state and logs, `/tmp` for scratch. Upstream root-only use removed. |
| Cron and `/var/spool/cron`, `/etc/cron.d` (ich777 cron) | Replace with the loop in section 7, or a rootless cron (UNVERIFIED). Nothing written under `/etc`. |
| `/opt/scripts`, `/opt/cron` (chmod 777 in ich777) | Not reproduced. Scripts go in `/app` or `start.sh`, read-only, owned by `apps`. |
| SteamPrefill cache (default location UNVERIFIED) | `/tmp` via `HOME=/tmp` or an explicit env, after confirming the path. |
| Draft chart PVCs `/data/cache`, `/data/logs`, `/data/prefill` | Map to `/config/...` in ContainerForge (decision in section 10). |

Security expectations from the chart (draft): runs as root (`runAsUser 0`), not read-only, no privileged flag. Target here: `USER apps` and read-only rootfs compatible. Reconcile: the ich777 image assumes root for cron and the `prefill` user (`UID=99`, `GID=100`).

## 10. Risks, caveats and open questions

- Image identity: the draft's container is the ich777 `lancache-prefill:latest` helper. This plan builds SteamPrefill on ContainerForge ubuntu, which replaces that image. Confirm with the user that rebuilding the helper (not using the ich777 image) is the goal.
- Unpinned upstream: the ich777 image has no tag, so the draft's `latest` cannot be reproduced. Plan pins SteamPrefill v3.7.2, which is a newer version than the draft (v3.0.0).
- Scheduling: cron in a rootless, read-only container is the main design risk (section 7).
- Steam account: prefilling Steam content needs an account that owns the games (draft claim, UNVERIFIED upstream). Without credentials the tool cannot prefill anything, so the container is not useful alone (draft caveat, confirmed in intent).
- First start: needs internet access and downloads at runtime (draft). The plan removes the runtime download of SteamPrefill by pinning it at build time. Other prefill tools (Battle.net, Epic) from the ich777 image are not in this plan: ENABLE_BN and ENABLE_EPIC are excluded unless the user asks (decision).
- Shared cache: the prefill helper only does useful work next to a lancache monolithic cache sharing the same cache volume. That volume is not in ContainerForge yet (UNVERIFIED).
- arm64: SteamPrefill linux-arm64 zip exists (confirmed). Behaviour on arm64 is UNVERIFIED.
- Draft difficulty `hard` is kept: scheduling, credentials and rootless rework.

## 11. Build and test steps

From `apps/lancache-monolithic/`:

1. `docker buildx bake --print`.
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. Probe with an empty `/config`, read-only rootfs and tmpfs:
   `docker run --rm -d --name lancache-monolithic-probe --read-only --tmpfs /tmp -v lancache-monolithic-probe-config:/config lancache-monolithic:3.7.2`, then `docker logs -f lancache-monolithic-probe`.
   Expected: process still running, a log line that the scheduler started and is idle (exact wording UNVERIFIED until the first run). With no credentials, prefill must not start a real download; expect a clean skip log.
   Cleanup: `docker rm -f lancache-monolithic-probe; docker volume rm lancache-monolithic-probe-config`.
4. `forgetool containers test --image lancache-monolithic:3.7.2 --config ./container-test.yaml`.
5. Manual check of the binary: `docker run --rm --read-only --tmpfs /tmp lancache-monolithic:3.7.2 /app/steamprefill/SteamPrefill --help` (confirms the binary runs on glibc ubuntu).

## 12. PR checklist

- Branch: `feat/add-lancache-monolithic`. Commit: `feat(lancache-monolithic): add new container`.
- PR template: `.github/PULL_REQUEST_TEMPLATE.md`, keep sections and check only the boxes that apply.
- Notes section: `🤖 This PR is AI generated.`
- CLA: tell the user to sign at https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Downstream: not used as a `FROM` base, so no `DOWNSTREAM_CHANGES.md`.
- Honest untested list: not built or run in this plan; the scheduler design, Steam credentials and arm64 are untested until the steps above run.
