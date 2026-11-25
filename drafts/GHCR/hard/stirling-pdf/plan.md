# stirling-pdf — implementation plan
> Source: ./draft.md · Target: apps/stirling-pdf/ · Difficulty: hard · Role (main/sidecar): main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Latest stable v3.5.0, published 2026-11-22 (https://api.github.com/repos/Stirling-Tools/Stirling-PDF/releases/latest). Draft and chart pin 3.4.0 (`ghcr.io/stirling-tools/s-pdf:3.4.0`); plan targets 3.5.0 unless the user wants the chart version. |
| Renovate | `datasource=github-releases depName=Stirling-Tools/Stirling-PDF versioning=semver`. The tag has a `v` prefix; strip it in the Dockerfile (`${VERSION#v}`) if the asset path needs the bare number. The asset path uses the tag as-is. |
| License | GitHub API reports `NOASSERTION` (https://api.github.com/repos/Stirling-Tools/Stirling-PDF). SPDX **UNVERIFIED**: the repo LICENSE file was not fetched. Blocker: confirm before filling `LICENSE` in docker-bake.hcl. |
| Source URL | https://github.com/Stirling-Tools/Stirling-PDF |
| Download (arch-neutral) | https://github.com/Stirling-Tools/Stirling-PDF/releases/download/v3.5.0/Stirling-PDF.jar (328255525 bytes, sha256 `53e2cd9fd3b8b8beaaab7e6c2c929c80f6f355326418e6703790ed412e2afca9`, GitHub asset digest). Same for amd64 and arm64. |
| Other assets | `Stirling-PDF-server.jar` (sha256 `172cd530c5f4ae549a27116e737ae51f18d1c84c1270cb69e5cb86ebc699cf1f`), `Stirling-PDF-with-login.jar`, `Stirling-PDF-linux-x86_64.AppImage` (amd64 only, sha256 `c51ec24e64d0cf0acb3b6eff6bf40a2c4363bfb04151693a211a1e46868e7d45`, not usable in a container per draft). No arm64 AppImage. |
| Checksum source | GitHub release asset `digest` field (API). Verify the JAR with `sha256sum -c` against the digest in the Dockerfile. Upstream `latest.json` asset exists but was not fetched. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/Stirling-Tools/Stirling-PDF/c544e2c3457f52d05675b36dffacc44a4479149e/docker/embedded/Dockerfile. Stages: `gradle:9.7.1-jdk25` (build, Node 24, Task 3.54.0, FFDetr ONNX model download, `gradle build`), `eclipse-temurin:25-jre-noble` (`jar-extract`, Spring Boot layers), final `${BASE_IMAGE}` = `stirlingtools/stirling-pdf-base:1.1.1` (the tool-heavy base, not fetched). ENTRYPOINT `tini -- /scripts/init.sh`, EXPOSE 8080/tcp, no USER (UID 1000 via PUID/PGID), HEALTHCHECK `GET /api/v1/info/status` on 8080. |
| Java | Upstream runtime is Temurin **25** (`eclipse-temurin:25-jre-noble`), so `apps/java25` is the match. The draft's java17 default does not match upstream. UNVERIFIED that 3.5.0 runs on 17. |
| Env vars (in upstream Dockerfile) | `JAVA_CUSTOM_OPTS`, `_JVM_OPTS` (upstream flag names; plan uses `JAVA_TOOL_OPTIONS` instead, see section 7), `STIRLING_TEMPFILES_DIRECTORY`, `TMPDIR`, `TEMP`, `TMP`, `HOME`, `FORMDETECTION_PREINSTALLEDMODELDIR`, `ORT_DISABLE_TELEMETRY`, `STIRLING_AOT_ENABLE`, `VERSION_TAG`, `DBUS_SESSION_BUS_ADDRESS`, `SAL_TMP`. `PUID`, `PGID`, `UMASK` are the upstream user mapping, which ContainerForge replaces (rootless `apps` user). Any further env names (for example login, security or Spring settings) are UNVERIFIED because the Spring config was not fetched. |
| Data and write paths (upstream) | Runtime writes: `/tmp/stirling-pdf`, `/configs` (incl. `heap_dumps`, detection model seeded on start), `/logs`, `/customFiles`, `/pipeline`, `/storage`. Upstream symlinks `/app/configs|logs|customFiles|pipeline|storage` to the root-level paths. |
| Office and OCR tools | Draft expects apt: libreoffice, tesseract-ocr, ocrmypdf, ghostscript, qpdf, unpaper, pngquant, poppler-utils. The upstream base image (not fetched) owns that list. Release notes (v3.5.0 body) say Stirling Office Convert **replaced LibreOffice** in the docker images from 3.5.1, so the apt list must be re-checked for 3.5.0 (UNVERIFIED). |
| Docs | https://docs.stirlingpdf.com/ not fetched. Anything about env vars or paths beyond the Dockerfile is UNVERIFIED. |

## 2. Target layout

- `apps/stirling-pdf/Dockerfile`
- `apps/stirling-pdf/docker-bake.hcl`
- `apps/stirling-pdf/settings.yaml`
- `apps/stirling-pdf/container-test.yaml`
- `apps/stirling-pdf/start.sh` (replaces upstream `scripts/init.sh`; creates the `/config` subpaths and `exec`s java)

No `defaults/` or `etc/` needed unless the start script ships default config (decide in step 7). No `root/`. No `DOWNSTREAM_CHANGES.md` (not used as a FROM base).

## 3. Base image

- Final stage: `FROM ghcr.io/trueforge-org/java25:25.0.1@sha256:22a0f8a73c79e2f733c7513aefceef24ab8a213fd35af0ab1946996efc21636d`. Matches upstream JDK 25. It already sits on ubuntu, so no separate ubuntu stage is needed.
- Build stage (only if the JAR is built from source; the plan uses the release JAR, so none): not needed.
- Closest siblings: `apps/java25` (base), `apps/nzbhydra2` (Java app that downloads a release JAR/ZIP into `/app/bin`, sets `JAVA_TOOL_OPTIONS`, `USER apps`, `VOLUME ["/config"]`).

## 4. Dockerfile

1. `ARG VERSION` (tag with `v`, for example `v3.5.0`) and `ARG TARGETARCH`. Keep the default in sync with `docker-bake.hcl`.
2. `USER root`, then one `apt-get install -y --no-install-recommends` for the tool packages that the base does not already provide. Check each name against the java25 base first (`dpkg -l`). Candidate list (UNVERIFIED for 3.5.0): `tesseract-ocr`, `ocrmypdf`, `ghostscript`, `qpdf`, `unpaper`, `pngquant`, `poppler-utils`. Do not add LibreOffice unless the 3.5.0 JAR needs it; the fat/office variant is a separate decision (see section 10). Clean `/var/lib/apt/lists/*`.
3. Download the JAR with `curl -fsSL -o /app/Stirling-PDF.jar https://github.com/Stirling-Tools/Stirling-PDF/releases/download/${VERSION}/Stirling-PDF.jar`, then `echo "53e2cd9f...afca9  /app/Stirling-PDF.jar" | sha256sum -c -` for v3.5.0. Keep the checksum next to `VERSION` so a bump updates both (the Renovate bump will need a manual checksum update; note in the PR).
4. Ship the license: `install -Dm644 LICENSE /usr/share/licenses/stirling-pdf/LICENSE` (fetch the LICENSE file from the tag, UNVERIFIED until the license is confirmed).
5. Environment, all under `/tmp` or `/config`: `ENV HOME=/config TMPDIR=/tmp TEMP=/tmp TMP=/tmp STIRLING_TEMPFILES_DIRECTORY=/tmp/stirling-pdf DBUS_SESSION_BUS_ADDRESS=/dev/null ORT_DISABLE_TELEMETRY=1`. Do not set `PUID`/`PGID`.
6. `EXPOSE 8080`, `VOLUME ["/config"]`, `WORKDIR /config`.
7. `USER apps`, then `COPY --chmod=0755 . /`. Keep this line last so `start.sh` lands in the image.

Upstream's build-stage details (Node 24, Task, gradle, ONNX model) are not needed when using the release JAR. If the JAR does not start without the preinstalled FFDetr model, fetch the model from the same URL as upstream (UNVERIFIED URL, not fetched) with a checksum, and set `FORMDETECTION_PREINSTALLEDMODELDIR` to a path under `/usr/share`, not `/app`.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "stirling-pdf"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=Stirling-Tools/Stirling-PDF versioning=semver
  default = "v3.5.0"
}

variable "LICENSE" {
  default = "UNVERIFIED"   // set to the SPDX id once the LICENSE file is confirmed
}

variable "SOURCE" {
  default = "https://github.com/Stirling-Tools/Stirling-PDF"
}
```

Then `group "default" { targets = ["image-local"] }`, `image` (args `VERSION`, labels `source` and `licenses`), `image-local` (`output = ["type=docker"]`, tags `${APP}:${VERSION}`), `image-all` (`linux/amd64`, `linux/arm64`). Run `docker buildx bake --print` before any build. The `LICENSE` placeholder must not ship.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/Stirling-Tools/Stirling-PDF"
ports:
  - port: 8080
    protocol: tcp
    required: true
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

Only add env names the app actually reads (verified list in section 1). `JAVA_CUSTOM_OPTS` is dropped from the env list because the start script no longer reads it. `TZ` is a container convention, not verified upstream: keep it only if sibling apps use it. `dependencies: []` because no database is required (the draft's "no dependency containers" is confirmed by the upstream Dockerfile, which has no DB service).

## 7. start.sh

- `#!/bin/sh` with `set -eu`. Run from `/config` (cwd) so the JAR's relative paths land on the writable volume. Upstream reaches `/app/configs` etc. through symlinks; ContainerForge creates the equivalent directories under `/config` instead (`configs`, `customFiles`, `logs`, `pipeline`, `storage`). Whether the JAR resolves these relatively is UNVERIFIED; check during the first run and set explicit paths if it does not.
- Create the subdirectories with `mkdir -p` on every start (idempotent). Seed nothing else; never write to `/app`.
- Build the command: `exec java -jar /app/Stirling-PDF.jar`, with extra JVM flags passed as `JAVA_TOOL_OPTIONS` (set by the environment, which the JVM reads without word splitting). `exec` so tini and signals reach the JVM. Do not `eval` the env value.
- Bind on all interfaces. The Spring default is `0.0.0.0` (UNVERIFIED for 3.5.0, check with a `ss -ltn` probe in step 11). Port 8080 via `--server.port=8080` if needed.
- Temp and heap dumps: point at `/tmp/stirling-pdf` (not `/config`). Heap dump path must not be `/configs/heap_dumps`; use `-XX:HeapDumpPath=/tmp/stirling-pdf`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

http:
- port: '8080'
  path: /api/v1/info/status
```

- One probe for the only port in `settings.yaml` (8080). The path is the upstream HEALTHCHECK endpoint, so it is a real readiness check.
- `timeoutSeconds`: look at `apps/java25` siblings and use the same value; Spring Boot with this JAR is slow on first start (UNVERIFIED, measure during step 11 and set the value from that).
- Test runs with no env vars. Anything that only runs with login or OCR settings goes to `filePaths`, not the http check.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | ContainerForge path | Remap |
| --- | --- | --- |
| `/app/configs`, `/configs` | `/config/configs` | `start.sh` mkdir; JAR cwd = `/config` (verify) |
| `/app/customFiles`, `/customFiles` | `/config/customFiles` | same |
| `/app/logs`, `/logs` | `/config/logs` | same |
| `/app/pipeline`, `/pipeline` | `/config/pipeline` | same |
| `/app/storage`, `/storage` | `/config/storage` | same |
| `/tmp/stirling-pdf` (temp) | `/tmp/stirling-pdf` | `STIRLING_TEMPFILES_DIRECTORY` (kept) |
| `/configs/heap_dumps` | `/tmp/stirling-pdf` | `-XX:HeapDumpPath` override |
| Model seeded to `/configs` at start | `/usr/share/stirling-pdf/models` | `FORMDETECTION_PREINSTALLEDMODELDIR` (only if the model is shipped) |

Security expectations from the draft are **not** adopted: the chart's `runAsUser 0` and `readOnlyRootFilesystem false` are TrueCharts choices. ContainerForge runs as `apps` with a read-only rootfs, so the container runs `--read-only --tmpfs /tmp` with an empty `/config`. No privileged mode is needed. Extra chart persistence paths (`/usr/share/tessdata`, `/customFiles`, `/logs`, `/configs`) map to `/config` subpaths above. `/usr/share/tessdata` is written by the chart, so check whether OCR needs it writable (UNVERIFIED).

## 10. Risks, caveats and open questions

- **Blocker, license:** GitHub reports `NOASSERTION`. Confirm the SPDX id before shipping `LICENSE`.
- **Blocker, base image:** upstream ships on `stirlingtools/stirling-pdf-base:1.1.1`, which we did not fetch. The apt tool list is therefore inferred (draft and section 4). Verify each package installs on the java25 base before a bake.
- **Version drift:** the draft and chart pin 3.4.0; 3.5.0 is current. Office conversion changed in 3.5.x (LibreOffice replaced), so a 3.4.0 port and a 3.5.0 port need different tool lists.
- **Fat vs ultra-lite:** the draft's caveat stands. A slim image without LibreOffice is the default plan; add office conversion only if required, and document the image size.
- **AppImage:** not usable (draft and AppImage FUSE need); the JAR is the only path.
- **Resources:** OCR and conversion need several GB of RAM (draft, inferred). Put `resources` guidance in the PR, not in `settings.yaml`.
- **arm64:** JAR is arch-neutral, but the apt OCR/office packages must exist for arm64 (UNVERIFIED for each package).
- **Renovate on the checksum:** every bump needs a new sha256 in the Dockerfile. Consider a comment next to `VERSION` telling the bumper where to get it.

## 11. Build and test steps

Run from `apps/stirling-pdf/`, one step at a time, per `.github/instructions/build-test-protocol.instructions.md`.

1. `docker buildx bake --print` (must exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. Run with an empty volume: `docker volume create stirling-pdf-probe-config` then `docker run --rm -d --name stirling-pdf-probe --read-only --tmpfs /tmp -v stirling-pdf-probe-config:/config stirling-pdf:v3.5.0`. Readiness signal: a Spring Boot "Started" line and the HTTP status endpoint answering 200 (UNVERIFIED wording, read the first real log). Check `ss -ltn` for 8080 inside the container.
4. `forgetool containers test --image stirling-pdf:v3.5.0 --config ./container-test.yaml`.
5. Cleanup: `docker rm -f stirling-pdf-probe; docker volume rm stirling-pdf-probe-config`.
6. Build-only check on arm64 is optional: only if the amd64 build fails for an arm64-specific reason.

Expected output: image builds, JAR checksum passes, startup log has no fatal lines, `/api/v1/info/status` returns 200.

## 12. PR checklist

- Branch `feat/add-stirling-pdf`; commit `feat(stirling-pdf): add new container`; target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md` and keep its sections and checkboxes. Check only the boxes that apply.
- Notes section: `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; the `license/cla` check shows status).
- Say what was not tested. If the image was not built or run, do not check "Built container locally".
- Do not commit the `UNVERIFIED` license or the unverified apt list as facts; list them as open items in the PR.
