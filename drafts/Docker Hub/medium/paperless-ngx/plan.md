# tika — implementation plan
> Source: ./draft.md · Target: apps/tika/ · Difficulty: medium · Role: sidecar (paperless-ngx `tikaImage`) · Verified on 2026-11-25

The draft folder is named `paperless-ngx`, but the container described is the Apache Tika server that paperless-ngx calls. This plan targets `apps/tika/` (open question in section 10).

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `3.4.0` is the latest stable Tika. Docker Hub `apache/tika` tag `3.4.0.0` (last_updated 2026-11-24). The draft and the TrueCharts chart pin `apache/tika:3.3.3.1`, which is older. Source: https://hub.docker.com/v2/repositories/apache/tika/tags?page_size=5&ordering=last_updated and https://archive.apache.org/dist/tika/3.4.0/ |
| Release date | Docker Hub tag date 2026-11-24. Apache announcement date: UNVERIFIED (not fetched). |
| Renovate | UNVERIFIED: there is no GitHub release (`GET repos/apache/tika/releases/latest` returns 404), so `github-releases` does not apply. Proposed: `datasource=maven depName=org.apache.tika:tika-server-standard versioning=maven` (Maven Central hosts the artifact). Confirm the renovate manager supports it before merge. |
| License | Apache-2.0 (GitHub API `spdx_id` for apache/tika) |
| Source URL | https://github.com/apache/tika |
| Download | `https://archive.apache.org/dist/tika/${VERSION}/tika-server-standard-${VERSION}.jar`. Upstream minimal Dockerfile tries dlcdn.apache.org, archive.apache.org and downloads.apache.org in turn. Asset confirmed on the 3.4.0 directory listing: `tika-server-standard-3.4.0.jar` (72M). |
| Checksum source | Apache publishes `tika-server-standard-3.4.0.jar.sha512` and `.asc` next to the jar (confirmed in the directory listing). Upstream verifies the `.asc` with `gpg --verify` against the Tika KEYS file. |
| Upstream Dockerfile reviewed | apache/tika-docker `minimal/Dockerfile` (summary from fetch, not verbatim, https://raw.githubusercontent.com/apache/tika-docker/master/minimal/Dockerfile): stage `base` on `ubuntu:jammy`; stage `fetch_tika` with args `TIKA_VERSION` and `CHECK_SIG=true`, imports KEYS, verifies the signature; runtime installs `openjdk-17-jre-headless`, copies the jar, `USER 35002:35002`, `EXPOSE 9998`, no `VOLUME`, no `CMD`, ENTRYPOINT `java -cp <jar>:/tika-extras/* org.apache.tika.server.core.TikaServerCli` bound to 0.0.0.0. |
| Port | 9998 (EXPOSE, upstream) |
| Env vars (real) | None confirmed. The upstream build args (`TIKA_VERSION`, `CHECK_SIG`, `UID_GID`, `JRE`) are build-time only. Do not invent runtime env vars. |
| Config / data paths | None declared upstream. `/tika-extras` is a classpath directory for extra jars (read-only in our image). |
| arm64 | The jar is architecture-independent. The Java runtime comes from `ghcr.io/trueforge-org/java21`, which provides arm64. Upstream `apache/tika` manifest list: UNVERIFIED (not fetched). |

## 2. Target layout

- `apps/tika/Dockerfile`
- `apps/tika/docker-bake.hcl`
- `apps/tika/settings.yaml`
- `apps/tika/container-test.yaml`
- `apps/tika/start.sh`

No `defaults/`, `etc/` or `health/` (Tika needs no seeded state). No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base; `grep` of `apps/*/Dockerfile` shows no consumer).

## 3. Base image

`FROM ghcr.io/trueforge-org/java21:21.0.8@sha256:bba631340c8aefc1a10656a894475312bd89a9dd75d9e5da12c3098242f1e8f2`

Fits because the app is a Java server jar, and the draft picks java21 as the conservative choice (java25 is the alternative: `ghcr.io/trueforge-org/java25:25.0.1@sha256:22a0f8a73c79e2f733c7513aefceef24ab8a213fd35af0ab1946996efc21636d`). Upstream uses Java 17; java21 is the closest supported runtime that the base provides. Closest siblings: `apps/doplarr` (java21 base, same pinned digest) and `apps/hytale` (java25). `apps/nzbhydra2` and `apps/airsonic-advanced` use java17.

Note: the `Dockerfile` must not use the upstream `ubuntu:jammy` base.

## 4. Dockerfile

1. `ARG VERSION` and `ARG TARGETARCH` (no arch mapping is needed, the jar is noarch).
2. `FROM` line from section 3, followed by `USER root` only for the download step.
3. First `mkdir -p /app/bin /tika-extras`, then download, verify and install in one `RUN`:
   - `apt-get install -y --no-install-recommends gnupg` only if GPG verification is kept in the build. Import the Tika KEYS file from `https://downloads.apache.org/tika/KEYS` (or archive mirror) and run `gpg --verify`. If the signature check cannot be pinned, use the `.sha512` file instead (`sha512sum -c`). Prefer the `.sha512` check, which needs no extra package.
   - `curl -fsSL -o /app/bin/tika-server.jar "https://archive.apache.org/dist/tika/${VERSION}/tika-server-standard-${VERSION}.jar"`
   - `curl -fsSL -o /tmp/tika.sha512 "https://archive.apache.org/dist/tika/${VERSION}/tika-server-standard-${VERSION}.jar.sha512"`, then `echo "$(cut -d' ' -f1 /tmp/tika.sha512)  /app/bin/tika-server.jar" | sha512sum -c -`. Check the file format of the `.sha512` file first (UNVERIFIED: its exact layout was not fetched).
4. License: `mkdir -p /usr/share/licenses/tika` and copy the Apache-2.0 `LICENSE` (fetch from `https://raw.githubusercontent.com/apache/tika/${VERSION}/LICENSE.txt`, or add the license text from the jar `META-INF`). UNVERIFIED: the exact license file path at tag 3.4.0.
5. `mkdir -p /app/bin /tika-extras`, `chown -R root:root /app /tika-extras`, `chmod -R 755 /app /tika-extras`, then `rm -rf /tmp/*`.
6. Keep `/tika-extras` as an empty directory in the image so the classpath wildcard matches nothing and is harmless.
7. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 9998
WORKDIR /app
```

No `VOLUME` (sidecar, state-free). `/config` is not used. Java temp dir is set in `start.sh` (section 7), not in `ENV`.

Build-stage pattern: this is a download-and-verify, not a compile, so no separate build stage is needed. If the jar download moves into a build stage later, copy only `/app/bin/tika-server.jar` into the final stage.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "tika"
}

variable "VERSION" {
  // renovate: datasource=maven depName=org.apache.tika:tika-server-standard versioning=maven
  default = "3.4.0"
}

variable "LICENSE" {
  default = "Apache-2.0"
}

variable "SOURCE" {
  default = "https://github.com/apache/tika"
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
    "linux/amd64",
    "linux/arm64"
  ]
}
```

Validate with `docker buildx bake --print` from `apps/tika/`. The renovate annotation is the proposed one from section 1 and must be confirmed.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/apache/tika"
ports:
  - port: 9998
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes: []
dependencies: []
```

Rules applied:
- `ports` only lists 9998, the port upstream exposes.
- `env` lists only `TZ`, the convention used by siblings. No Tika env vars are invented.
- `volumes` is empty: the app keeps no state, and `/config` is not used. Rule "`/config` MUST be listed when the app persists state" does not apply.
- `dependencies` is empty. paperless-ngx calls Tika; Tika does not depend on paperless-ngx.

## 7. start.sh

```bash
#!/usr/bin/env bash

exec java \
  -Djava.io.tmpdir=/tmp \
  -cp "/app/bin/tika-server.jar:/tika-extras/*" \
  org.apache.tika.server.core.TikaServerCli \
  --host 0.0.0.0 \
  --port 9998
```

- No `/config` handling and no seeding: nothing to persist. Empty `/config` start is trivially satisfied, and `/config` is not mounted.
- `--host 0.0.0.0` makes the server reachable from other containers (rule: bind all interfaces). Upstream ENTRYPOINT already binds 0.0.0.0; the explicit flag keeps it clear. UNVERIFIED: exact flag names `--host` and `--port` for `TikaServerCli` in 3.4.0. Check with `--help` on the jar during the build step before committing.
- `java.io.tmpdir` moves Tika temp files to the `/tmp` tmpfs, required by read-only rootfs.
- `exec` gives the JVM PID 1 handoff so signals reach Java.
- Do not write to `/app`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '9998'
http:
- port: '9998'
  path: /tika
filePaths:
- /app/bin/tika-server.jar
- /usr/share/licenses/tika
```

- `tcp` and `http` probes for 9998, the only port in `settings.yaml`.
- `http` path `/tika` is the Tika server's documented status route (`GET /tika` returns the Tika banner). UNVERIFIED: returns 200 in 3.4.0 (not run). Confirm before commit.
- `timeoutSeconds: 120`: a JVM plus a 72 MB jar can take a while to start. Check a sibling Java app for the same family and match it.
- No `DB` dependency, so no narrowing exception applies.
- Tests run without env vars; Tika needs none.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| JVM temp dir (`java.io.tmpdir`, default `/tmp`) | `/tmp` via `-Djava.io.tmpdir=/tmp` (tmpfs under `--read-only --tmpfs /tmp`) |
| Tika parser scratch and OCR output | `/tmp` (no separate config). The minimal jar has no OCR. |
| Runtime user | Upstream uses `35002:35002`; ContainerForge uses `USER apps` (rule). Final stage ends with `USER apps`. |
| `/app` | read-only; jar stays in `/app/bin`, not written at runtime |
| `/tika-extras` | read-only classpath dir, created empty at build time |

Security expectations from the draft (`runAsUser 0`, `readOnlyRootFilesystem false`) are the TrueCharts chart defaults. This image runs as `apps` and works with `--read-only --tmpfs /tmp`, so the chart can be set to match. The draft's expectation that only `/tmp` is writable beyond the chart's persistence is consistent with this plan. No privileged mode, no extra capabilities.

## 10. Risks, caveats and open questions

- Target name: the draft folder is `paperless-ngx`, but the image is Tika. Decide the app name with the user (plan uses `apps/tika`). The chart still points at `apache/tika` tag `3.3.3.1`, so the chart upgrade to 3.4.0 is a separate downstream change.
- Version: 3.4.0 is newer than the chart's 3.3.3.1. Confirm the 3.4.0 image tag and behaviour before pinning.
- Renovate datasource: maven is proposed. UNVERIFIED that renovate picks the Apache jar version correctly. Fallback: a `custom.regex` manager against the Apache dist index.
- Signature check: the `.sha512` check is planned because it needs no extra package. Upstream uses GPG `.asc` verification. Either is acceptable; document the choice in the `Dockerfile`.
- OCR: the minimal jar has no OCR. The full `tika-server-standard` distribution still needs tesseract and fonts. This plan builds the jar only. The OCR variant is a separate app or a separate task (UNVERIFIED: which OCR packages the full image bundles).
- Memory and CPU: large documents use significant RAM. Set `JAVA_TOOL_OPTIONS=-Xmx` only if a sibling app does so. Not set here.
- arm64: the jar is noarch, but the arm64 java21 base and the Tika runtime are untested here. Build amd64 locally, and say so in the PR if arm64 is not built.
- Blockers: none confirmed. No GPU, no privileged mode, no musl issue (Ubuntu-based).

## 11. Build and test steps

Run from `apps/tika/` with the build/test protocol:

```sh
cd apps/tika
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name tika-probe --read-only --tmpfs /tmp \
  -p 9998:9998 tika:3.4.0
docker logs -f tika-probe   # expect: a line that the server started and is listening on 9998
curl -fsS http://127.0.0.1:9998/tika
docker rm -f tika-probe
forgetool containers test --image tika:3.4.0 --config ./container-test.yaml
```

- Expected readiness signal: the Tika server log line showing it listens on port 9998, with the process still running.
- Also run `java -cp /app/bin/tika-server.jar org.apache.tika.server.core.TikaServerCli --help` inside the image to confirm flags (section 7).
- Empty `/config` start: not applicable, `/config` is not mounted. Run with `--read-only --tmpfs /tmp` only.
- Optional smoke test: `curl -T sample.pdf http://127.0.0.1:9998/tika` returns extracted text (not part of the container test).
- Cleanup: `docker rm -f tika-probe`.

## 12. PR checklist

- Branch: `feat/add-tika`
- Commit and PR title: `feat(tika): add new container`
- PR template from `.github/PULL_REQUEST_TEMPLATE.md`, keeping its sections and checkboxes. Check only the boxes that apply.
- Notes section: `🤖 This PR is AI generated.`
- CLA: tell the user that contributions need a signed CLA at https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it. The `license/cla` check shows the status.
- Not tested in this plan: the image is not built. The PR must say whether the image was built and run locally. Do not check "Built container locally" unless it was.
- Downstream: paperless-ngx chart update (`tikaImage` tag) is a separate change, not in this PR.
