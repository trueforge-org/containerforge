# dell-idrac-fan-controller — implementation plan
> Source: ./draft.md · Target: apps/dell-idrac-fan-controller/ · Difficulty: easy · Role (main) · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | v1.108, the latest release (published 2026-09-08T22:40:57Z). The release has NO assets: no binary, no checksums. The "binary" is the repo's shell scripts at the tag. Source: https://api.github.com/repos/tigerblue77/Dell_iDRAC_fan_controller_Docker/releases/latest (via gh api) |
| Renovate | `datasource=github-releases depName=tigerblue77/Dell_iDRAC_fan_controller_Docker versioning=loose` (tags are not confirmed semver; UNVERIFIED which versioning is best) |
| License | Conflict: GitHub SPDX reports `AGPL-3.0`. The upstream Dockerfile label reports `AGPL-3.0-only` (https://raw.githubusercontent.com/tigerblue77/Dell_iDRAC_fan_controller_Docker/24fa182fa86f5c247466f023316939096b96042d/Dockerfile). The repo also ships `LICENSE-COMMERCIAL.md` and `NOTICE`. UNVERIFIED which SPDX id the packaged LICENSE file carries; resolve from the file at the tag before filling `LICENSE` in bake. |
| Source URL | https://github.com/tigerblue77/Dell_iDRAC_fan_controller_Docker |
| Download | No download. Clone or fetch the tag tarball `https://github.com/tigerblue77/Dell_iDRAC_fan_controller_Docker/archive/refs/tags/v1.108.tar.gz` and extract the scripts. Arch-independent shell scripts. |
| Checksum source | None published. Pin the tag and verify the tarball sha256 in the Dockerfile (computed at build time from the tag; UNVERIFIED that a publisher checksum exists). |
| Upstream Dockerfile reviewed | Commit 24fa182fa86f5c247466f023316939096b96042d (summary via WebFetch; full text not returned). `BASE_IMAGE` build arg (default `ubuntu:latest`, no digest in file). apt, `--no-install-recommends`: `ipmitool`, `lm-sensors`, `perl`, `libio-socket-ssl-perl`, lists removed in the same RUN. `ADD` for LICENSE, LICENSE-COMMERCIAL.md, NOTICE, functions.sh, constants.sh, healthcheck.sh, Dell_iDRAC_fan_controller.sh, supervisor.sh. `RUN chmod 0755` on four scripts (functions.sh, healthcheck.sh, Dell_iDRAC_fan_controller.sh, supervisor.sh). `WORKDIR /app`. `HEALTHCHECK` runs `/app/healthcheck.sh` every 30s. `ENTRYPOINT ["./supervisor.sh"]`. No USER (root). No TARGETARCH logic. |
| Port | None. The service is disabled; the health check is a script. |
| Env vars (real, Dockerfile ENV defaults) | `IDRAC_HOST` (default `local`), `FAN_SPEED` (`5`), `CPU_TEMPERATURE_THRESHOLD` (`auto`), `CPU_TEMPERATURE_THRESHOLD_TO_START_LINE_INTERPOLATION` (`30`), `CPU_TEMPERATURE_SOURCE` (`auto`, also `ipmi` or `lm-sensors`), `CHECK_INTERVAL` (`5`), `MAXIMUM_IPMI_UNREACHABLE_DURATION` (`60s`), `MAXIMUM_CONSECUTIVE_IPMI_FAILURES` (empty), `DISABLE_THIRD_PARTY_PCIE_CARD_DELL_DEFAULT_COOLING_RESPONSE` (`false`), `KEEP_THIRD_PARTY_PCIE_CARD_COOLING_RESPONSE_STATE_ON_EXIT` (`false`), `MONITORING_ONLY_MODE` (`false`). Commented out upstream: `IDRAC_USERNAME`, `IDRAC_PASSWORD` (required for remote mode per README), `HIGH_FAN_SPEED` (no default; enables the ramp when set). Source: README and Dockerfile. |
| Data write paths | None documented. The controller keeps state in memory and talks to the iDRAC over IPMI. |
| Dependencies | None. Hardware: a Dell PowerEdge server with iDRAC. |

Behavior from upstream README (https://github.com/tigerblue77/Dell_iDRAC_fan_controller_Docker, fetched via gh api at ref v1.108): iDRAC firmware decides whether the raw fan commands work. On 11th-generation iDRACs the speed command with `0xff` may be refused, and the container then discovers accepted fan identifiers `0x00` to `0x07` at runtime (no config needed). Remote mode needs "Enable IPMI over LAN" in the iDRAC web UI (iDRAC settings, Network, IPMI Settings).

## 2. Target layout

- `apps/dell-idrac-fan-controller/Dockerfile`
- `apps/dell-idrac-fan-controller/docker-bake.hcl`
- `apps/dell-idrac-fan-controller/settings.yaml`
- `apps/dell-idrac-fan-controller/container-test.yaml`
- `apps/dell-idrac-fan-controller/start.sh` (replaces upstream `supervisor.sh` as the entry point, or calls it)
- No `app/` directory in the app folder: the upstream scripts are fetched from the tag tarball in the Dockerfile into `/app` (section 4, step 3), so they are not committed under `apps/`.

No `root/`. No `DOWNSTREAM_CHANGES.md` (not a FROM base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. The controller is bash plus `ipmitool` from apt. Upstream uses `ubuntu:latest`, which is not pinned, so the ContainerForge ubuntu base is used instead. `ipmitool` and `perl` are available from ubuntu apt (ipmitool on ubuntu is confirmed by upstream Dockerfile; availability on 26.04 is UNVERIFIED; check during build). Closest sibling: `apps/cloudflareddns` (shell script on ubuntu), `apps/adguardhome-sync` for layout.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`, `ENV HOME=/config`.
2. Install packages, pinned or checked against the base (base already has `bash`, `curl`, `tar`, `ca-certificates`, `tini`):
   ```dockerfile
   RUN apt-get update && apt-get install -y --no-install-recommends ipmitool lm-sensors perl libio-socket-ssl-perl && \
       apt-get clean && rm -rf /var/lib/apt/lists/*
   ```
   Do not reinstall packages the base already ships. Pin the versions if the apt candidate differs from the ubuntu 26.04 archive (check `apt-cache policy ipmitool`).
3. Fetch and verify the source tarball for `VERSION` (tag `v${VERSION}`):
   ```dockerfile
   RUN curl -fsSL -o /tmp/src.tar.gz \
         "https://github.com/tigerblue77/Dell_iDRAC_fan_controller_Docker/archive/refs/tags/v${VERSION}.tar.gz" && \
       echo "<sha256 of the tag tarball>  /tmp/src.tar.gz" | sha256sum -c - && \
       mkdir -p /app && tar xzf /tmp/src.tar.gz -C /app --strip-components=1 && rm /tmp/src.tar.gz
   ```
   The sha256 is computed once from the tag and pinned in the Dockerfile. Mark it UNVERIFIED until computed.
4. Keep the license files: copy `LICENSE`, `LICENSE-COMMERCIAL.md`, `NOTICE` to `/usr/share/licenses/dell-idrac-fan-controller/`.
5. `chmod 0755` on the scripts; `chown -R apps:apps /app && chmod -R 755 /app`.
6. `USER apps`, `COPY --chmod=0755 . /`, `WORKDIR /app`, no `EXPOSE` (no ports), `VOLUME /config` is still declared per the repo rule, although nothing is persisted (settings.yaml `volumes` stays empty because the app keeps no state; UNVERIFIED which choice reviewers prefer).
7. Upstream `HEALTHCHECK` is optional. Skip it unless the health script works unchanged (it reads `/app` only).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "dell-idrac-fan-controller"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=tigerblue77/Dell_iDRAC_fan_controller_Docker versioning=loose
  default = "1.108"
}

variable "LICENSE" {
  default = "AGPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/tigerblue77/Dell_iDRAC_fan_controller_Docker"
}
```

`LICENSE` is set after the conflict in section 1 is resolved from the packaged LICENSE file. Then the four standard targets and `group "default"` copied from `apps/adguardhome-sync/docker-bake.hcl`. Tag `v${VERSION}` is used in the Dockerfile URL, so `VERSION` must be `1.108` and the git tag `v1.108`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/tigerblue77/Dell_iDRAC_fan_controller_Docker"
ports:
  []
env:
  - name: IDRAC_HOST
    default: "local"
    required: true
  - name: IDRAC_USERNAME
    default: ""
    required: false
  - name: IDRAC_PASSWORD
    default: ""
    required: false
  - name: FAN_SPEED
    default: "5"
    required: false
  - name: CPU_TEMPERATURE_THRESHOLD
    default: "auto"
    required: false
  - name: CPU_TEMPERATURE_THRESHOLD_TO_START_LINE_INTERPOLATION
    default: "30"
    required: false
  - name: CPU_TEMPERATURE_SOURCE
    default: "auto"
    required: false
  - name: CHECK_INTERVAL
    default: "5"
    required: false
  - name: MAXIMUM_IPMI_UNREACHABLE_DURATION
    default: "60s"
    required: false
  - name: MAXIMUM_CONSECUTIVE_IPMI_FAILURES
    default: ""
    required: false
  - name: MONITORING_ONLY_MODE
    default: "false"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes: []
```

Notes: `IDRAC_HOST` is `required: true` (default `local` is a value, so it is non-empty). `IDRAC_USERNAME` and `IDRAC_PASSWORD` are read in remote mode and must not be defaulted to real values. Do not list `HIGH_FAN_SPEED` unless start.sh handles it. Two DISABLE/KEEP_THIRD_PARTY variables are optional and can be added with their upstream defaults. `volumes` is empty (no persistence). The chart's `extra-persistence` is "none".

## 7. start.sh

```bash
#!/usr/bin/env bash

cd /app || exit 1
exec ./supervisor.sh
```

Notes: start.sh only sets the working directory and hands off to upstream `supervisor.sh`, which runs the fan loop. Upstream reads its env vars directly. No writes to `/app`. No `/config` seeding needed. `exec` for signal handoff. The upstream `supervisor.sh` must be checked for writes to `/app` or `/tmp` at runtime (UNVERIFIED; check during the run). If it writes, point those writes at `/tmp`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 60
filePaths:
- /app/supervisor.sh
- /app/Dell_iDRAC_fan_controller.sh
- /usr/share/licenses/dell-idrac-fan-controller/LICENSE
runners:
- entrypoint: test -x /app/supervisor.sh
```

No tcp or http probes: settings.yaml declares no ports. The test runs with no env vars. With `IDRAC_HOST=local` and no `/dev/ipmi0`, the controller exits or logs an IPMI error. The readiness check is therefore the file and runner checks above, plus a log signal in step 11. Do not add an assertion that the fan loop runs, because the image cannot reach an iDRAC in CI.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| None documented | Upstream keeps no state on disk. `HOME=/config` is set only so tools that expect a home directory find one. If any tool writes to `$HOME`, `/config` is writable as a volume. |
| `/tmp` | Used by ipmitool or the scripts if they need scratch space (UNVERIFIED). |

Security reconciliation (draft expectations vs upstream): the draft says non-root (568), read-only rootfs and not privileged. Upstream runs as root with no USER. ContainerForge `apps` (568) is compatible if ipmitool needs no root for the device path. Local mode needs the IPMI device node (see section 10), which is the main conflict. Remote mode (IDRAC_HOST = iDRAC IP) uses LAN IPMI and needs no device. Run as `apps` with read-only rootfs and no privileged flag.

## 10. Risks, caveats and open questions

- CONTRADICTION with the draft: the draft says "no local device access". Upstream README runs local mode with `--device=/dev/ipmi0:/dev/ipmi0:rw` (for `IDRAC_HOST=local`). Local mode needs the host IPMI device, which needs a device grant and possibly group access (ipmi group). With the default `IDRAC_HOST=local`, the app may not start on an unprivileged container. Decision needed: keep `local` as the default (matches upstream, needs a device mapping in the chart or the user's run command) or default to remote mode with `IDRAC_HOST` required from the user. This plan recommends documenting that the device mapping is needed for local mode, and not adding it to the image.
- Remote mode requires "Enable IPMI over LAN" in iDRAC and valid credentials (`IDRAC_USERNAME`, `IDRAC_PASSWORD`). Credentials must come from env at runtime, never baked into the image.
- The image tag is rolling (`latest`) upstream. ContainerForge pins `v1.108`, so the version does not change between pulls.
- License conflict (AGPL-3.0 vs AGPL-3.0-only). Resolve from the packaged LICENSE file before setting bake `LICENSE`.
- Fan control affects server cooling. Verify temperatures after first start (as the draft says). Monitoring-only mode (`MONITORING_ONLY_MODE=true`) is available for a dry run.
- Upstream iDRAC firmware compatibility (11th generation fan addressing) is handled by upstream code; ContainerForge does not change it.
- arm64: the image is arch-independent shell scripts, but no Dell arm64 hardware is known, so arm64 is UNVERIFIED for real use. ipmitool is in ubuntu arm64 apt (draft claim, not fetched).
- Blockers: hardware-dependent (Dell PowerEdge with iDRAC). Local mode needs a device (section 10).

## 11. Build and test steps

```sh
cd apps/dell-idrac-fan-controller
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name dell-idrac-probe --read-only --tmpfs /tmp \
  -e IDRAC_HOST=127.0.0.1 -e MONITORING_ONLY_MODE=true \
  dell-idrac-fan-controller:1.108
docker logs -f dell-idrac-probe   # expect the controller start line; IPMI errors are expected without a server
docker rm -f dell-idrac-probe
forgetool containers test --image dell-idrac-fan-controller:1.108 --config ./apps/dell-idrac-fan-controller/container-test.yaml
```

Expected readiness signal: the process stays running and the log shows the controller start line (for example the monitoring-only message). Without an iDRAC, IPMI connection errors are expected; the container must not exit silently. No `/config` volume is needed because nothing is persisted, but run the empty-`/config` check anyway per the protocol. Do not claim the fan loop works: no iDRAC is available for testing.

## 12. PR checklist

- Branch: `feat/add-dell-idrac-fan-controller`. Commit: `feat(dell-idrac-fan-controller): add new container`. PR title matches the commit.
- PR template: `.github/PULL_REQUEST_TEMPLATE.md`. Keep its sections and checkboxes; check only what applies.
- Notes section includes `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; the `license/cla` check shows status).
- Say what was not tested: the fan loop on real Dell hardware, local mode with `/dev/ipmi0`, and arm64.
