# redm — implementation plan
> Source: ./draft.md · Target: apps/redm/ · Difficulty: medium · Role (main/sidecar): main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | RedM server artifact (FiveM/RedM build from Cfx.re). No pinned version fetched: the upstream Dockerfile does not download it; it sets `SRV_ADR=https://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/`, so the artifact is fetched at runtime by `start.sh` (not fetched, UNVERIFIED). Latest stable artifact build ID: UNVERIFIED. |
| Renovate | UNVERIFIED: no versioned source found. Do not invent a datasource; the build cannot pin a runtime artifact through renovate in this design (section 10). |
| License | Source repository https://github.com/citizenfx/fivem reports license `NOASSERTION` (GitHub "Other") on the API, last push 2026-11-17, default branch `master`, not archived (https://api.github.com/repos/citizenfx/fivem). Upstream license text: UNVERIFIED. Do not set `LICENSE` to a guessed SPDX id; the build step must read the upstream license file and record it. Use `LICENSE = "NOASSERTION"` only if no SPDX id is confirmed. |
| Source URL | https://github.com/citizenfx/fivem (FiveM/RedM source) |
| Per-arch download | amd64 only: the artifact path is `build_proot_linux` (x86_64 proot build) and the upstream gotty download is `gotty_linux_amd64.tar.gz`. arm64: no build exists (draft says no; consistent with the upstream URL, but not confirmed on a fetched arm64 page: UNVERIFIED). |
| Checksum source | None fetched. The runtime artifact checksum is UNVERIFIED. gotty release checksum: UNVERIFIED (gotty v1.0.1 from its GitHub release, not fetched). |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/ich777/docker-redm-server/master/Dockerfile . FROM `ich777/debian-baseimage`, apt `xz-utils unzip screen`, gotty v1.0.1 (amd64 only), ENV `DATA_DIR=/serverdata`, `SERVER_DIR=${DATA_DIR}/serverfiles`, `SRV_ADR` (FiveM proot artifact URL), `ENABLE_WEBCONSOLE=true`, `GOTTY_PARAMS="-w --title-format RedM"`, `UMASK=000`, `UID=99`, `GID=100`, `SERVER_KEY=template`, `DATA_PERM=770`, `USER=redm`. No EXPOSE, no VOLUME, no USER instruction (root). ENTRYPOINT `/opt/scripts/start.sh`. |
| Ports | Draft: 30120/udp (game), 30120/tcp (game), 40120/http (txAdmin). None declared in the upstream Dockerfile. Confirmed on a fetched page: NO. UNVERIFIED. |
| Data path | Upstream `DATA_DIR=/serverdata`, `SERVER_DIR=/serverdata/serverfiles`. Remapped to `/config` (section 9). |
| Upstream start script | `/opt/scripts/start.sh` (copied from `./scripts/`, not fetched, UNVERIFIED contents). |
| Licence key and txAdmin | Draft inference: Cfx.re license key and txAdmin first-run setup. UNVERIFIED. |

## 2. Target layout

- `apps/redm/Dockerfile`
- `apps/redm/docker-bake.hcl`
- `apps/redm/settings.yaml`
- `apps/redm/container-test.yaml`
- `apps/redm/start.sh`

Not needed: `defaults/` unless a seeded server config is confirmed, `etc/`, `health/`, `root/` (never used). `DOWNSTREAM_CHANGES.md` not needed.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`, build and final stage. The runtime artifact is a glibc-compatible proot build, so the ubuntu base is the right choice (draft: "no language base needed"). Closest sibling: `apps/steamcmd` (game server fetched at runtime) and `apps/webgrabplus` for a runtime-download pattern. No FiveM sibling exists in `apps/`. No dependency container.

## 4. Dockerfile

Single ubuntu stage.

1. `ARG VERSION`, `ARG TARGETARCH`. `USER root`.
2. Enforce amd64: fail the build when `TARGETARCH` is not `amd64` so an arm64 image is never published by mistake, e.g. `RUN test "$TARGETARCH" = "amd64" || { echo "redm: amd64 only"; exit 1; }`.
3. `apt-get install -y --no-install-recommends ca-certificates curl xz-utils unzip` (check each against the base first; drop what is present). `screen` is NOT needed: the upstream `screen` use is for the wrapper, not for ContainerForge; use `exec` in `start.sh` instead.
4. gotty: decide whether to keep the web console. Plan: keep it only if `ENABLE_WEBCONSOLE` is a required feature (it is an upstream feature, default `true`). If kept: download `gotty_linux_amd64.tar.gz` (v1.0.1 from its GitHub release; checksum UNVERIFIED, verify against the release checksum file if published). Extract to `/usr/bin/gotty`. Without the web console, skip this step and document it in the PR.
5. License: copy the upstream license file (from the fivem repo) to `/usr/share/licenses/redm/LICENSE`. Not yet fetched: UNVERIFIED path.
6. Fix layout: `mkdir -p /app/redm && chown -R apps:apps /app && chmod -R 755 /app`. The server binary and runtime live in `/app` only if they are shipped in the image; here they are downloaded at runtime to `/config`, so `/app` holds only the start script and gotty.
7. Tail:

```dockerfile
ENV HOME=/config \
    SRV_ADR="https://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/" \
    ENABLE_WEBCONSOLE=true

USER apps
COPY --chmod=0755 . /

EXPOSE 30120
EXPOSE 40120
VOLUME /config
```

`EXPOSE` ports are UNVERIFIED (section 1); add only ports confirmed on a fetched page or observed in the first run.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "redm"
}

variable "VERSION" {
  // renovate: UNVERIFIED datasource and depName (no versioned runtime artifact identified)
  default = "UNVERIFIED"
}

variable "LICENSE" {
  default = "NOASSERTION"
}

variable "SOURCE" {
  default = "https://github.com/citizenfx/fivem"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
  }
  labels = {
    "org.opencontainers.image.source" = "${SOURCE}"
    "org.opencontainers.image.licenses" = "${LICENSE}"
  }
}

target "image-local" {
  inherits = ["image"]
  output = ["type=docker"]
  tags = ["${APP}:${VERSION}"]
}

target "image-all" {
  inherits = ["image"]
  platforms = [
    "linux/amd64"
  ]
}
```

Use `image-all` with `linux/amd64` only (not arm64), a deliberate deviation from the sibling pattern. `VERSION` is a placeholder until a version source is found (section 10). `LICENSE` must be the license of the software, so set it only after the upstream license is read.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/citizenfx/fivem"
ports:
  - port: 30120
    protocol: udp
    required: true
  - port: 30120
    protocol: tcp
    required: true
  - port: 40120
    protocol: tcp
    required: false
env:
  - name: SRV_ADR
    default: "https://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/"
    required: false
  - name: ENABLE_WEBCONSOLE
    default: "true"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

Ports 30120 and 40120 are draft inference (UNVERIFIED on a fetched page): keep only after confirmation in the first run, otherwise remove. `SRV_ADR` is confirmed in the upstream Dockerfile. Cfx license key env var name is UNVERIFIED: do not add it until the start script is read. `GOTTY_PARAMS` is listed only if the web console is kept.

## 7. start.sh

- `#!/usr/bin/env bash`, idempotent, nothing seeded unless a server config is confirmed.
- `SERVER_DIR=/config/serverfiles` (mirrors upstream layout under `/config`, not `/serverdata`), `mkdir -p "$SERVER_DIR"`.
- Download the runtime artifact into `$SERVER_DIR` on first start (or when missing) from `${SRV_ADR}`: confirm the latest build file name from the artifact index (UNVERIFIED). Verify the artifact checksum if the index publishes one (UNVERIFIED). Use `/tmp` for download scratch, then move into `/config`.
- Run the server with `exec` in the foreground (`exec "$SERVER_DIR/run.sh" ...`, exact command UNVERIFIED: upstream `start.sh` not fetched).
- Bind 0.0.0.0 for game and txAdmin ports (`+endpoint` or equivalent, UNVERIFIED).
- If gotty is kept: run it as a separate process only if the panel requires it; a second process must not block the main `exec`.
- Never write under `/app`. Server key handling: take `SERVER_KEY`/licence key from env only if confirmed, never write it to the process list.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 600
tcp:
- port: '30120'
- port: '40120'
filePaths:
- /usr/share/licenses/redm/LICENSE
- /app/start.sh
```

Concern (section 10): the test runs with no env vars and with no licence key. If the server exits without a licence, the step-3 pass criterion ("container still running") fails and the test cannot pass without a narrowing. The protocol narrows only for DB dependencies, so this app would need a fix in the start script (for example keep the container alive and report the missing licence) or the test must be re-planned with the owner. Do not remove the tcp probes to get green.

`timeoutSeconds: 600` is an estimate for the large first-start download; confirm the real duration in step 11.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/serverdata` (DATA_DIR) and `/serverdata/serverfiles` (SERVER_DIR) | `/config` and `/config/serverfiles` |
| Artifact download scratch | `/tmp` |
| `screen` sessions | not used; `exec` the server |
| Upstream `USER redm` created but container runs as root | `USER apps` (UID 568). Upstream `runAsUser 0` override in the chart is not needed. |
| `ulimit -n 2048` (upstream RUN, not persistent) | not persisted; if the server needs it, set in `start.sh` (`ulimit -n 2048`, may need root: UNVERIFIED) |
| gotty `-w` web terminal | optional; ports and access control UNVERIFIED |

Target: non-root yes, read-only-rootfs yes (download goes to `/tmp` and `/config`; server runs from `/config/serverfiles`), privileged no. Reconcile draft: draft expects non-root no and read-only-rootfs no; this plan changes both and must be verified in step 11.

## 10. Risks, caveats and open questions

- x86_64 only: no arm64 build. The image is amd64-only and the bake file lists `linux/amd64` only. Confirm on a fetched page (UNVERIFIED) before shipping.
- Runtime artifact: the server binary is downloaded at runtime, so the image has no pinned version. `VERSION` in bake is a placeholder; renovate cannot track it in this design. Decision needed: pin a specific artifact build ID (preferred) and record it, or accept a rolling image. Until then, the plan does not claim a version.
- Licence key: RedM needs a Cfx.re licence key (draft inference, UNVERIFIED). Without it the server may exit, which conflicts with the protocol pass criterion (container must stay running). Needs a design decision before the container test can pass honestly.
- txAdmin first-run setup happens in the web UI on first start (draft inference, UNVERIFIED). Port 40120 is the draft's txAdmin port (UNVERIFIED).
- First start is large (artifact download) and needs internet (draft inference, consistent with the runtime download).
- Upstream license: `NOASSERTION` on GitHub; the actual license of the artifact is UNVERIFIED. Must be resolved before `LICENSE` is set.
- gotty v1.0.1 is from a third-party release and is amd64-only; keep it only if the web console is a needed feature.
- No blockers beyond the licence-key test problem and the unverified artifact source. Not musl, no GPU; privileged not needed.

## 11. Build and test steps

```sh
cd apps/redm
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local

docker run --rm -d --name redm-probe --read-only --tmpfs /tmp \
  -v redm-probe-config:/config redm:<VERSION>
docker logs -f redm-probe

forgetool containers test --image redm:<VERSION> --config ./apps/redm/container-test.yaml

docker rm -f redm-probe; docker volume rm redm-probe-config
```

Expected readiness: the artifact download completes, the server prints a startup line and keeps running, and the txAdmin/game ports are open. Readiness text is UNVERIFIED until the upstream start script is read. Run once without a licence to see whether the process stays up (section 10). Restart with the same `/config` volume to confirm the artifact is not re-downloaded needlessly.

## 12. PR checklist

- Branch `feat/add-redm`, commit and PR title `feat(redm): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only applicable boxes.
- Notes section contains `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; `license/cla` shows status).
- Downstream: none.
- Not tested to state honestly: arm64 (not built, intentionally not supported), the licence-key behaviour, the artifact checksum, the txAdmin ports, and the first-start download time.
- `docker buildx bake --print` passes and `VERSION` is a real pinned value matching the Dockerfile input (currently a placeholder: blocked until decided).
