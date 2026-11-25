# jelu — implementation plan
> Source: ./draft.md · Target: apps/jelu/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `0.88.4`. Marked Latest on https://github.com/bayang/jelu/releases/latest (changelog heading 2026-10-30). Docker Hub `wabayang/jelu:0.88.4` last_updated 2026-10-30. Matches the draft. |
| Renovate | Proposed `datasource=github-releases depName=bayang/jelu versioning=semver`. UNVERIFIED: the repo renovate config was not checked against this value. |
| License | MIT (https://raw.githubusercontent.com/bayang/jelu/main/LICENSE) |
| Source URL | https://github.com/bayang/jelu |
| Download | `https://github.com/bayang/jelu/releases/download/v0.88.4/jelu-0.88.4.jar`. UNVERIFIED: the release page reports "Assets 3" but the asset list did not load, so the file name is not confirmed. The jar is Java bytecode, so one file serves amd64 and arm64. |
| Checksum source | UNVERIFIED: none checked. Look for a `.sha256` asset on the release before pinning. Otherwise none is published. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/bayang/jelu/2aba1840c9d823851a5d219dcf9802e1a194a4e2/Dockerfile (draft commit). `FROM eclipse-temurin:17-jre-noble`, single stage, Calibre 8.4.0 under `/opt/calibre` on amd64/arm64 (apt Calibre elsewhere), Goodreads plugin v1.8.2, copies pre-extracted Spring Boot layers, `EXPOSE 11111`, `ENTRYPOINT ["java", "-jar", "jelu.jar", "--spring.config.additional-location=optional:file:/config/"]`, runs as root. |
| Port | 11111/tcp, HTTP web UI and API (README and upstream `EXPOSE`). |
| Env (real) | Upstream `ENV`: `JELU_DATABASE_PATH=/database/`, `JELU_FILES_IMAGES=/files/images/`, `JELU_FILES_IMPORTS=/files/imports/`, `JELU_METADATA_CALIBRE_PATH=/usr/bin/fetch-ebook-metadata`, `LC_ALL`, `QTWEBENGINE_DISABLE_SANDBOX`. README also documents `JELU_DATABASE_JOURNALMODE` (example `wal`, default UNVERIFIED). Spring Boot maps `JELU_*` variables to `jelu.*` properties. |
| Data paths (upstream) | `/database` (SQLite), `/files/images`, `/files/imports`, `/config` (optional `application.yml` via `--spring.config.additional-location`). Upstream declares no `VOLUME`. |
| Runs as | root (no `USER` in upstream). |

## 2. Target layout

- `apps/jelu/Dockerfile`
- `apps/jelu/docker-bake.hcl`
- `apps/jelu/settings.yaml`
- `apps/jelu/container-test.yaml`
- `apps/jelu/start.sh`

No `defaults/`, `etc/`, `scripts/` or `health/` are needed. The jar and license are placed by the Dockerfile. No `root/`. No `DOWNSTREAM_CHANGES.md`, because jelu is not a `FROM` base.

## 3. Base image

`FROM ghcr.io/trueforge-org/java17:17.0.16@sha256:74b81362a2cf4b7f6efb8eb67baf0d1090ce56b38fc9e7a0dc11333b35179e1a`

Fits because it is the Java 17 runtime the upstream image uses, on the ContainerForge Ubuntu base. Closest siblings: `apps/nzbhydra2` (Java jar, `/config` data) and `apps/airsonic-advanced` (Spring-style war, `/config`, `-Djava.io.tmpdir=/tmp`).

## 4. Dockerfile

1. `ARG VERSION`, then `USER root`.
2. Set paths so nothing falls back to `${user.home}`:

```dockerfile
ENV JELU_DATABASE_PATH=/config/database/ \
    JELU_FILES_IMAGES=/config/files/images/ \
    JELU_FILES_IMPORTS=/config/files/imports/ \
    HOME=/config
```

3. Download the jar and the license into the image, then lock the tree down:

```dockerfile
RUN mkdir -p /app /usr/share/licenses/jelu \
 && curl -fsSL -o /app/jelu.jar \
      "https://github.com/bayang/jelu/releases/download/v${VERSION}/jelu-${VERSION}.jar" \
 && curl -fsSL -o /usr/share/licenses/jelu/LICENSE \
      "https://raw.githubusercontent.com/bayang/jelu/v${VERSION}/LICENSE" \
 && chown -R root:root /app && chmod -R 755 /app \
 && rm -rf /tmp/*
```

   The tag path for the LICENSE is UNVERIFIED. The facts confirm only the `main` branch URL, so if the tag is missing, fetch from `main` and note it. If a `.sha256` asset is found on the release (section 1), verify it with `echo "<sha>  /app/jelu.jar" | sha256sum -c -`.
4. Do not install Calibre (see section 10). Do not set `JELU_METADATA_CALIBRE_PATH`.
5. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 11111
VOLUME /config
```

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "jelu"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=bayang/jelu versioning=semver
  default = "0.88.4"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/bayang/jelu"
}
```

The version has no `v` prefix. The Dockerfile adds it in the URL, as in `apps/adguardhome-sync`. Use the four standard targets and the default group copied from `apps/nzbhydra2`. Check with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/bayang/jelu"
ports:
  - port: 11111
    protocol: tcp
    required: false
env:
  - name: JELU_DATABASE_PATH
    default: "/config/database/"
    required: false
  - name: JELU_FILES_IMAGES
    default: "/config/files/images/"
    required: false
  - name: JELU_FILES_IMPORTS
    default: "/config/files/imports/"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

The three `JELU_*` paths are set in the Dockerfile `ENV`, so the defaults here must match it. `dependencies` is empty: jelu uses an embedded SQLite database.

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config/database /config/files/images /config/files/imports

exec java \
    -Djava.io.tmpdir=/tmp \
    -jar /app/jelu.jar \
    --spring.config.additional-location=optional:file:/config/
```

- Idempotent. It creates directories only and does not seed a config file. The `optional:` prefix lets a missing `/config/application.yml` pass.
- Nothing is written to `/app`.
- `exec` hands PID 1 signals to Java.
- Spring binds to all interfaces by default, so `0.0.0.0` is expected. Verify on the run (UNVERIFIED).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '11111'
filePaths:
- /app/jelu.jar
- /usr/share/licenses/jelu/LICENSE
```

- Port 11111 has a `tcp` probe, as the coverage rule requires. An `http` probe is not added yet: no health or root path is confirmed. Add `http` with `path: /` only after a run returns a known status (UNVERIFIED).
- `timeoutSeconds: 180` matches the common Java siblings.
- No env var is needed to start, so no required-env code path exists.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/database` (SQLite) | `JELU_DATABASE_PATH=/config/database/` |
| `/files/images` | `JELU_FILES_IMAGES=/config/files/images/` |
| `/files/imports` | `JELU_FILES_IMPORTS=/config/files/imports/` |
| `/config` (optional `application.yml`) | Same path, read-only use. Nothing is seeded. |
| `${user.home}/.jelu` (default when no path is set) | Avoided: `HOME=/config` and explicit paths. Confirm nothing is written to `${user.home}` on `--read-only` (UNVERIFIED). |
| Java temp files | `-Djava.io.tmpdir=/tmp` |

- Upstream runs as root. This image runs as `apps` (568), which owns `/config`.
- Chart reconciliation: the chart forces `runAsUser 0` and `readOnlyRootFilesystem: false`. This image works with `--read-only --tmpfs /tmp` and needs neither, so the chart values can be changed later (not in this task).
- Existing chart data is at `/database`, `/files/images`, `/files/imports` (PVCs). Users must move it to `/config/database`, `/config/files/images` and `/config/files/imports`.
- Not privileged.

## 10. Risks, caveats and open questions

- The release jar name and URL are UNVERIFIED (section 1). This is the main blocker. Confirm the asset list before writing the Dockerfile.
- Upstream builds the image from pre-extracted Spring Boot layers, not from the release jar. Check that the release jar starts the same way (UNVERIFIED).
- Calibre: upstream bundles `fetch-ebook-metadata` (Calibre 8.4.0, large and arch-specific under `/opt/calibre`). The plan leaves it out: book metadata lookups that need it will not work. Confirm that jelu starts without `JELU_METADATA_CALIBRE_PATH` set (UNVERIFIED). Adding Calibre is a separate decision. The Calibre download URL is not in the facts file.
- Upstream `JELU_METADATA_CALIBRE_PATH=/usr/bin/...` points at an apt install that this image does not have, so it must not be set here.
- Book metadata lookups need outbound internet (draft caveat).
- Dependencies: none (SQLite embedded). No database container.
- arm64: the Docker Hub image has amd64, arm64 and arm/v7 (upstream). This build's arm64 is not tested.
- Blockers: none confirmed beyond the unverified jar asset and checksum.

## 11. Build and test steps

```sh
cd apps/jelu
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name jelu-probe --read-only --tmpfs /tmp \
  -v jelu-probe-config:/config jelu:0.88.4
docker logs -f jelu-probe
forgetool containers test --image jelu:0.88.4 --config ./apps/jelu/container-test.yaml
docker rm -f jelu-probe; docker volume rm jelu-probe-config
```

- Expected readiness signal: the Spring Boot startup banner, then `Tomcat started on port(s): 11111` (exact wording UNVERIFIED on this version).
- Confirm that `/config/database` exists after the start and that a restart keeps it.
- Check that the port answers from outside the container (`-p 11111:11111`), to show it is not bound to localhost only.

## 12. PR checklist

- Branch `feat/add-jelu`. Commit and PR title `feat(jelu): add new container`. Target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, and check only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it. The `license/cla` check shows status.
- Say in the PR what was not tested: the jar asset and its checksum, the start without Calibre, the `--read-only` run, the arm64 build, and the HTTP probe.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; no assertion was weakened.
