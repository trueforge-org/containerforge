# fivem — implementation plan
> Source: ./draft.md · Target: apps/fivem/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | UNVERIFIED: the Cfx.re runtime is a rolling `master` build. No build number or LATEST file was confirmed. The FiveM docs page (https://docs.fivem.net/docs/server-download/?platform=legacy&os=linux) lists only the Windows artifact (build 38435). |
| Renovate | UNVERIFIED: no datasource for a rolling runtime. Open question, see section 10. |
| License | Repo `citizenfx/fivem`: NOASSERTION ("Other") per GitHub API. UNVERIFIED: the runtime's license terms. Bake `LICENSE` cannot be filled honestly until read. |
| Source | https://github.com/citizenfx/fivem (default branch master, pushed 2026-11-17) |
| Binary (amd64) | Runtime fetched at start from `https://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/` (the upstream default `SRV_ADR`). Artifact file name: UNVERIFIED. |
| Binary (arm64) | None. Draft and upstream both ship x86_64 only. |
| Checksum source | UNVERIFIED: none found on the pages fetched. |
| Upstream Dockerfile | https://raw.githubusercontent.com/ich777/docker-fivem-server/master/Dockerfile: `FROM ich777/debian-baseimage`; apt `xz-utils unzip screen`; gotty v1.0.1 (`https://github.com/yudai/gotty/releases/download/v1.0.1/gotty_linux_amd64.tar.gz`); `ENTRYPOINT ["/opt/scripts/start.sh"]`; no USER (runs as root); no VOLUME/EXPOSE. |
| Upstream start.sh | https://raw.githubusercontent.com/ich777/docker-fivem-server/master/scripts/start.sh: `chown -R ${UID}:${GID} ${DATA_DIR}`; launches `su ${USER} -c "/opt/scripts/start-server.sh" &`. start-server.sh (download/extract logic) was NOT fetched: UNVERIFIED. |
| Env (upstream defaults) | DATA_DIR=/serverdata; SERVER_DIR=/serverdata/serverfiles; GAME_CONFIG=""; SRV_ADR=(runtime URL above); MANUAL_UPDATES=""; ENABLE_WEBCONSOLE=true; GOTTY_PARAMS="-w --title-format FiveM"; UMASK=000; UID=99; GID=100; SERVER_KEY=template; START_VARS=""; DATA_PERM=770; USER=fivem. |
| Chart values | https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/fivem/values.yaml: ports main 9016/http to 8080, tcp+udp 30110 and 30120; env GAME_CONFIG=server.cfg, SRV_ADR, SRV_NAME, START_VARS, SERVER_KEY (secret); persistence /serverdata/serverfiles; `runAsUser: 0`, `runAsGroup: 0`, `readOnlyRootFilesystem: false`. |
| Image in chart | `ghcr.io/ich777/fivemserver:latest@sha256:6534fde2a257c976738049fda0d11f2b257c92806c19d1acde6d4fb095c7dd3f` |
| Ports | 30120 tcp+udp (game); 30110 tcp+udp (chart, not in draft); 8080 http (gotty web console, only if enabled). txAdmin 40120 is UNVERIFIED and not in the chart, so do not list it. |
| Dependencies | None. |

## 2. Target layout

- `apps/fivem/Dockerfile`
- `apps/fivem/docker-bake.hcl`
- `apps/fivem/settings.yaml`
- `apps/fivem/container-test.yaml`
- `apps/fivem/start.sh` (replaces the upstream `start.sh`/`start-server.sh` chain)

No `defaults/`, `etc/`, `health/` needed. No `root/`. No `DOWNSTREAM_CHANGES.md` (not a FROM base). gotty and screen are deliberately not copied in v1 (see section 9).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. The runtime is a glibc x86_64 binary fetched at start, so a generic Ubuntu userland is enough and no language base is needed (draft). Closest sibling: a prebuilt-binary-on-ubuntu app such as `apps/adguardhome-sync`. The upstream `ich777/debian-baseimage` is not used.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`. Fail the build when `TARGETARCH` is not `amd64` (arm64 is not supported upstream).
2. `xz-utils` and `unzip` are already installed by `apps/ubuntu/Dockerfile`, so no `apt-get install` is needed for them. Do not add `screen` (the console is not kept in v1).
3. Do NOT download gotty in v1. Reason: the upstream gotty v1.0.1 is an old, unmaintained binary with no checksum, and the web console adds an unauthenticated shell surface. Open question in section 10.
4. Copy the start script and runtime helpers: `COPY --chmod=0755 . /` covers `start.sh` (installed at `/start.sh`) and `scripts/` if used.
5. Set the license file path only once the license is verified: `/usr/share/licenses/fivem/` (blocked, see section 10).
6. `ENV DATA_DIR=/config SERVER_DIR=/config/server TMPDIR=/tmp HOME=/tmp UMASK=002`.
7. `EXPOSE 30120/tcp 30120/udp`, `VOLUME /config`, `WORKDIR /config`.
8. Final: `USER apps`.

## 5. docker-bake.hcl

Standard layout (copy `apps/budge/docker-bake.hcl`):

```hcl
variable "APP" { default = "fivem" }
variable "VERSION" {
  // renovate: datasource=... depName=... versioning=...  (UNVERIFIED, see section 10)
  default = "UNVERIFIED"
}
variable "LICENSE" { default = "UNVERIFIED" }
variable "SOURCE" { default = "https://github.com/citizenfx/fivem" }
```

`image-all` should list only `linux/amd64` because arm64 cannot build a working image. Validate with `docker buildx bake --print`. `VERSION` must match the Dockerfile `ARG VERSION`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/citizenfx/fivem"
ports:
  - port: 30120
    protocol: tcp
    required: true
  - port: 30120
    protocol: udp
    required: true
env:
  - name: GAME_CONFIG
    default: "server.cfg"
    required: false
  - name: SERVER_KEY
    default: ""
    required: false
  - name: SRV_ADR
    default: "https://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/"
    required: false
  - name: START_VARS
    default: ""
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

Notes: `SERVER_KEY` is a secret with no default, so it is `required: false` in the schema (the rule for `required: true` needs a non-empty default), but the server will not start without a keymaster key (section 10); `start.sh` prints an error when it is empty. `SRV_ADR` is kept as an env with the upstream default (HTTPS form UNVERIFIED), and `start.sh` must read it when it fetches the runtime. The chart's second port 30110 (tcp+udp) has no known purpose in the reviewed sources (UNVERIFIED), so it is not listed. The udp 30120 port has no probe: sibling apps only use `tcp`/`http` probes (UNVERIFIED that forgetool supports udp); the tcp probe covers 30120 (section 8). Do not list 40120 or 8080 unless the web console is added. Dependencies: none.

## 7. start.sh

Idempotent, writes only under `/config`:

```bash
#!/usr/bin/env bash
set -euo pipefail
mkdir -p /config/server
cd /config/server
# fetch the runtime artifact (URL pattern UNVERIFIED) only when /config/server/run.sh is missing
# or MANUAL_UPDATES is not set
[[ -n "${SERVER_KEY:-}" ]] || echo "SERVER_KEY is not set; the server will not start" >&2
exec ./run.sh +set serverKey "${SERVER_KEY}" +exec "${GAME_CONFIG:-server.cfg}" ${START_VARS:-}
```

Rules: passing the key as a command-line argument exposes it in the process list; prefer a file under `/config` with mode 0600 if the server can read the key from its config (UNVERIFIED); no write to `/app`; caches to `/tmp`; seed nothing into `/config` other than the server directory; `exec` the final process. Confirm the exact launch command from the runtime artifact (UNVERIFIED). Bind to all interfaces (`+set endpoint_add_tcp "0.0.0.0:30120"` and udp) instead of the default localhost-only binding, if the artifact uses it.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 300
tcp:
- port: '30120'
filePaths:
- /start.sh
```

Open issue: the test runs without `SERVER_KEY`, so the server may not open 30120 and the tcp probe would fail. Do not weaken it. Either confirm that the runtime starts the port without a key (UNVERIFIED), or narrow the test to the file check and document why. The narrowing is not the DB exception, so it needs an explicit justification in the PR.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/serverdata` (DATA_DIR, chart PVC) | `/config` |
| `/serverdata/serverfiles` (SERVER_DIR, chart PVC) | `/config/server` |
| Runtime download and extract | `/config/server` (writable, persistent) |
| Scratch (`TMPDIR`, `HOME`) | `/tmp` |
| `runAsUser: 0` (chart) | `apps` user; upstream `chown` of DATA_DIR is replaced by the image's own ownership |
| `readOnlyRootFilesystem: false` (chart) | Compatible with `--read-only --tmpfs /tmp` if the runtime writes nothing to `/app` (verify) |
| gotty / screen web console | Not shipped in v1 (reason in section 4) |

Draft reconciled: draft says upstream runs as root (confirmed: no USER). The non-root port is the apps user, not root.

## 10. Risks, caveats and open questions

- BLOCKER, license: GitHub reports NOASSERTION for `citizenfx/fivem`. Read the runtime's terms before setting `LICENSE` in bake or copying a license file.
- BLOCKER, version: no pinned Linux artifact, no checksum, and no renovate source. Decide: pin a dated runtime build URL (needs a verified listing), or accept a rolling `master` build with no renovate and a documented manual bump.
- BLOCKER, server key: FiveM needs a keymaster key (draft, inferred). `container-test` runs without env, so the tcp probe can fail. See section 8.
- arm64: none. `image-all` is amd64 only.
- gotty web console: dropped in v1. Re-adding it means pinning gotty v1.0.1 (old, unmaintained), with its checksum verified.
- The draft's txAdmin port 40120 is UNVERIFIED and is excluded.
- start-server.sh (artifact download, extract and checksum) was not read. The download and launch steps in section 7 are provisional.
- Draft says amd64 `yes` for "fetched at runtime". That is a runtime download, not a build-time COPY. `copy-from` (`ghcr.io/ich777/fivemserver:latest`, a Debian-based image of unknown digest pinning) is not used: rejected because it is the upstream wrapper and the tag is `latest`.

## 11. Build and test steps

```sh
cd apps/fivem
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name fivem-probe --read-only --tmpfs /tmp \
  -v fivem-probe-config:/config fivem:<VERSION>
docker logs -f fivem-probe
forgetool containers test --image fivem:<VERSION> --config ./apps/fivem/container-test.yaml
docker rm -f fivem-probe; docker volume rm fivem-probe-config
```

Readiness signal: UNVERIFIED (the FiveM startup banner is not confirmed). With a real key, expect the server to log the endpoints (`listening` on 30120). Without a key, expect a clear error (not a crash loop).

## 12. PR checklist

- Branch `feat/add-fivem`, commit and PR title `feat(fivem): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep the sections, check only what applies.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it. The `license/cla` check shows status.
- Not tested, state in the PR: any build or run (the blockers above prevent it), arm64 (not supported), the server-key path, the runtime download checksum.
