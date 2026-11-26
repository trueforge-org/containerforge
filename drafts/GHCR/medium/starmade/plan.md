# starmade — implementation plan
> Source: ./draft.md · Target: apps/starmade/ · Difficulty: medium · Role: main · Verified on 2026-11-25

Status: **blocked on items marked UNVERIFIED in sections 1, 6 and 10.** The plan is ready once a versioned, checksummed server source and the server port are confirmed by running the server.

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Vendor download page https://www.star-made.org/download states "Latest stable version: 0.305.17" (no date found). UNVERIFIED: no machine-readable version feed was found, so no renovate datasource is confirmed. The draft's image tag `ghcr.io/ich777/starmade-server:latest` is not a version. |
| Renovate | UNVERIFIED: no datasource confirmed. Do not guess one; resolve before writing `docker-bake.hcl`. |
| License | UNVERIFIED for the StarMade server. Upstream wrapper `https://github.com/ich777/docker-starmade` reports license null (gh API). |
| Source URL | https://www.star-made.org/ (website), https://starmadepedia.net (docs) |
| Download | Upstream wrapper (https://raw.githubusercontent.com/ich777/docker-starmade/master/Dockerfile) sets `DL_URL=http://files.star-made.org/StarMade-Starter.jar`. Its `start-server.sh` runs `wget -q -nc -O StarMade-Starter.jar ${DL_URL}`, then the Starter downloads the game into `StarMade/`. The download page links only a launcher AppImage and `https://files.star-made.org/build/` (manual build fallback). |
| Checksum source | None published (download page and upstream script both have none). UNVERIFIED: no checksum to verify against. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/ich777/docker-starmade/master/Dockerfile: `FROM ich777/debian-baseimage`; `DATA_DIR=/starmade`; `ENTRYPOINT ["/opt/scripts/start.sh"]`; no USER, VOLUME or EXPOSE. Its `start.sh` runs as root and drops to `USER` via `su`. JRE: `https://github.com/ich777/runtimes/raw/master/jre/basicjre.tar.gz` (unverified, no checksum). |
| Java command | `java ${EXTRA_JVM_PARAMS} -Xmx${XMX_SIZE}M -Xms${XMS_SIZE}M -jar StarMade/StarMade.jar -server ${GAME_PARAMS}`, run from the game directory. Starter: `java -jar StarMade-Starter.jar -nogui`. |
| Port | UNVERIFIED: 4242/tcp is in the draft only (marked inferred). Upstream Dockerfile has no EXPOSE. |
| Env vars (real) | `XMX_SIZE`=1024, `XMS_SIZE`=1024, `EXTRA_JVM_PARAMS`="", `GAME_PARAMS`="", `STARTER_PARAMS`=`-nogui`, `DL_URL`, `DATA_DIR`, `RUNTIME_NAME`, `UMASK`=000, `UID`=99, `GID`=100, `USER`=starmade, `DATA_PERM`=770 (all from upstream Dockerfile). |
| Data path | Upstream writes under `/starmade`: `runtime/`, `StarMade-Starter.jar`, `StarMade/` (game files), `StarMade/server.cfg` (copied from `/tmp/server.cfg` if absent). |
| arm64 | UNVERIFIED: no arm64 evidence. The upstream JRE tarball name does not say which architecture it targets. |
| Dependencies | None. |

## 2. Target layout

- `apps/starmade/Dockerfile`
- `apps/starmade/docker-bake.hcl`
- `apps/starmade/settings.yaml`
- `apps/starmade/container-test.yaml`
- `apps/starmade/start.sh` (replaces upstream `start.sh` / `start-server.sh`)
- `apps/starmade/defaults/` only if a default `server.cfg` is shipped (reason: upstream copies `/tmp/server.cfg` on first start; ship it under `defaults/` and seed `/config` when missing).

No `root/`. No `DOWNSTREAM_CHANGES.md` (not used as a `FROM` base). No `etc/` or `health/` unless a probe is needed.

## 3. Base image

`FROM ghcr.io/trueforge-org/java17:17.0.16@sha256:74b81362a2cf4b7f6efb8eb67baf0d1090ce56b38fc9e7a0dc11333b35179e1a`. It fits because the server is a Java jar (the upstream runtime is a bundled JRE, which we replace with the base's Java 17). Closest sibling: `apps/nzbhydra2` (Java jar on java17, `/config` as data, `USER apps`). Note: the upstream image is `ich777/debian-baseimage`; we do not reuse it.

## 4. Dockerfile

1. `FROM <java17 digest above>`, `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Install only what the base lacks: `curl` and `ca-certificates` are in the base; add `unzip` only if the Starter needs it (UNVERIFIED).
3. Fetch the Starter jar. Use `https://files.star-made.org/...` if reachable (UNVERIFIED: upstream uses http). Store under `/app/starmade/StarMade-Starter.jar`. Verify a checksum only if one is published (none found). Ship the license/notices to `/usr/share/licenses/starmade/` once known.
4. `ENV` moves all writable paths: `HOME=/config`, `JAVA_TOOL_OPTIONS=-Xmx...` only if needed. No cache directories are created in `/app`.
5. `COPY --chmod=0755 . /` after `USER apps`. `start.sh` and `defaults/` come from the allow-listed build context (`include/.dockerignore`).
6. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 4242
WORKDIR /config
VOLUME ["/config"]
```

`EXPOSE` only after the port is confirmed (section 1).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" { default = "starmade" }

variable "VERSION" {
  // renovate: UNVERIFIED datasource and depName; resolve before merge
  default = "0.305.17"
}

variable "LICENSE" { default = "UNVERIFIED" }
variable "SOURCE" { default = "https://www.star-made.org/" }
```

Four standard targets (`image`, `image-local`, `image-all`) and `group "default" { targets = ["image-local"] }` copied from `apps/nzbhydra2/docker-bake.hcl`. Validate with `docker buildx bake --print`. `VERSION` must equal the Dockerfile `ARG VERSION`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://www.star-made.org/"
ports:
  - port: 4242        # UNVERIFIED: draft only, confirm by running the server
    protocol: tcp
    required: false
env:
  - name: XMX_SIZE
    default: "1024"
    required: false
  - name: XMS_SIZE
    default: "1024"
    required: false
  - name: EXTRA_JVM_PARAMS
    default: ""
    required: false
  - name: GAME_PARAMS
    default: ""
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

Do not list env names the app does not read. `DL_URL`, `UID`, `GID`, `DATA_PERM` and `UMASK` belong in the Dockerfile or `start.sh`, not in `settings.yaml`, unless `start.sh` reads them. No dependencies.

## 7. start.sh

- `mkdir -p /config/runtime /config/StarMade`. Seed `/config/StarMade/server.cfg` from `/defaults/server.cfg` only when missing.
- Do not download the Starter at runtime: it is baked at build time at `/app/starmade/StarMade-Starter.jar` (section 4, read-only). Never write into `/app`.
- `cd /config`. If `/config/StarMade` is missing, run the Starter once to fetch the game (`java -jar /app/starmade/StarMade-Starter.jar -nogui`), otherwise run it to update. UNVERIFIED: that the Starter installs into the current directory and not next to the jar; check on a first run.
- `cd /config/StarMade` and `exec java ${EXTRA_JVM_PARAMS} -Xmx${XMX_SIZE}M -Xms${XMS_SIZE}M -jar StarMade.jar -server ${GAME_PARAMS}`.
- Use `/tmp` for temporary files (the upstream `basicjre.tar.gz` step is not needed on this base).
- Do not `sleep infinity` on failure. Exit non-zero with a clear message so the failure is visible.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 600
tcp:
- port: '4242'
filePaths:
- /app/starmade/StarMade-Starter.jar
```

`timeoutSeconds` is long because the first start downloads the game (look at sibling java apps for the family; 600 is an estimate, not sibling-verified). Probe the port only after section 1 confirms it. The test runs with no env vars, so no required-env path is tested.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/starmade` (DATA_DIR, runtime, game, server.cfg) | `/config` (persistent). The Starter and game write under `/config`. |
| `/opt/scripts` (chmod 770, chown to UID) | Not used. Scripts ship in `/` via `COPY --chmod=0755 . /`. |
| Upstream `su` user switch and `usermod`/`groupmod` | Removed. The image runs as `apps` (568). The draft's `runAsUser: 0` expectation is not kept. |
| `/tmp/server.cfg` | `/defaults/server.cfg` (shipped), copied to `/config` only when missing. |
| Java temp files | `/tmp` (tmpfs under `--read-only`). |

Draft expectations reconciled: the chart runs as root (non-root: no), `readOnlyRootFilesystem: false`, `privileged: false`. This image is intended to be non-root and read-only-rootfs compatible, so those chart overrides must change when the chart is ported.

## 10. Risks, caveats and open questions

- UNVERIFIED version source: no renovate datasource; the vendor page gives "0.305.17" without a date.
- UNVERIFIED port: 4242/tcp (draft only). Must be confirmed by running the server before `EXPOSE`, `settings.yaml` and `container-test.yaml` are written.
- No checksum for the Starter jar (upstream fetches it with `wget -nc`, over http). Downloading at build time gives no verification.
- The game is downloaded on first start, so the container needs internet access and a long startup.
- License unknown (`LICENSE` in `docker-bake.hcl` cannot be set).
- arm64 unverified. Java 17 base is multi-arch upstream, but the StarMade payload is not confirmed.
- Upstream `ich777/debian-baseimage` and `ghcr.io/ich777/starmade-server:latest` are not reused. The draft's `copy-from` option is `ghcr.io/ich777/starmade-server:latest`, which is an unpinned, unversioned, third-party image; do not use `COPY --from` for it.
- Game server ports must be forwarded by the host (draft caveat, not verified).

## 11. Build and test steps

```sh
cd apps/starmade
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name starmade-probe --read-only --tmpfs /tmp \
  -v starmade-probe-config:/config starmade:<VERSION>
docker logs -f starmade-probe
forgetool containers test --image starmade:<VERSION> --config ./apps/starmade/container-test.yaml
docker rm -f starmade-probe; docker volume rm starmade-probe-config
```

Readiness signal: to be determined by running the server (UNVERIFIED). Expected: Starter output, then the server's own "server started" line. Confirm `/config/StarMade` exists after start and survives a restart of the container with the same volume.

## 12. PR checklist

- Branch `feat/add-starmade`, commit and PR title `feat(starmade): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`; keep sections; check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA notice: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows the status.
- Untested, to state honestly: the image build, the first-start game download, port 4242, arm64, and the read-only run.
- Before the PR: `docker buildx bake --print` passes; `VERSION` equals Dockerfile `ARG VERSION`; no assertion weakened.
