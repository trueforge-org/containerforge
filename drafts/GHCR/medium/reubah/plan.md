# reubah — implementation plan
> Source: ./draft.md · Target: apps/reubah/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | No release, tag or binary exists (README: no prebuilt release binaries). Pin a commit on `main`. Dockerfile reviewed at commit `04469cf95ea7105f9d60e4906eab5533fb70ccd1`. Chart image `ghcr.io/dendianugerah/reubah:main` (tag list UNVERIFIED). |
| Renovate | `datasource=git-refs depName=https://github.com/DenDianUgerah/reubah currentValue=main` (precedent `apps/tvheadend`). |
| License | MIT (https://api.github.com/repos/DenDianUgerah/reubah) |
| Source URL | https://github.com/DenDianUgerah/reubah (draft also lists `dendianugerah/reubah`; GitHub is case-insensitive, use the draft's canonical casing). |
| Download | Source archive `https://github.com/DenDianUgerah/reubah/archive/${VERSION}.tar.gz` (VERSION = commit SHA). Built for amd64 and arm64 from source. |
| Checksum source | None published. Commit SHA pin is the only integrity anchor. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/dendianugerah/reubah/04469cf95ea7105f9d60e4906eab5533fb70ccd1/Dockerfile (summarized, not verbatim). Builder `golang:1.22-alpine`: apk build deps, `go mod download`, `npm install && npm run build` in `templates/`, `CGO_ENABLED=1 go build -o reubah ./cmd/server`. Runtime `alpine:3.19`: apk `bash libreoffice ttf-liberation libwebp openjdk11-jre curl libheif-dev x265-dev libde265-dev`, `/tmp/.cache /tmp/.config /tmp/.local`, user `appuser` UID/GID 1000, `ENV HOME=/tmp`, `EXPOSE 8081`, HEALTHCHECK `curl -f http://localhost:8081/`, `CMD ["/app/reubah"]`, no ENTRYPOINT, no VOLUME. |
| Port | 8081 (Dockerfile EXPOSE and README). The draft's 8080 is wrong. |
| Env vars | `PORT` (README example sets 8081). No others documented. Code-level env reads UNVERIFIED (source not read beyond the Dockerfile and README). |
| Volumes | README runs `-v doc-temp:/tmp`. Upstream has no VOLUME instruction. |
| Dependencies | No database. Runtime needs LibreOffice (document conversion), a Java runtime (upstream `openjdk11-jre`; purpose UNVERIFIED), and image libraries (libwebp, libheif, x265, libde265). |
| Health endpoint | `GET /` on 8081 (upstream HEALTHCHECK). |

## 2. Target layout

- `apps/reubah/Dockerfile`
- `apps/reubah/docker-bake.hcl`
- `apps/reubah/settings.yaml`
- `apps/reubah/container-test.yaml`
- `apps/reubah/start.sh`

No `defaults/`, `etc/` or `health/` needed unless the app reads a config file (UNVERIFIED). Do not use `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

Final stage: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` (porter table: Go final stage maps to ubuntu). Closest siblings: `apps/adguardhome-sync` (ubuntu, `USER apps`, `COPY --chmod=0755 . /`) and `apps/bookstack` (ubuntu with many apt packages).

Build stage: the porter rule says the Go binary must be built in a dedicated stage. Use a Go image on Debian/Ubuntu (not alpine, so the binary is glibc and matches the final stage). Candidate: `golang:1.22` (version from upstream builder). Pin tag and digest, which are UNVERIFIED in this run. Go version must satisfy the module's `go` directive (UNVERIFIED; README says Go 1.22+).

## 4. Dockerfile

Two stages. Both `USER root` for installs, then `USER apps` in the final stage.

1. Build stage `FROM golang:<tag>@<digest> AS build`:
   - `ARG VERSION`, `ARG TARGETARCH`.
   - `apt-get install -y --no-install-recommends gcc g++ pkg-config libwebp-dev libheif-dev libde265-dev libx265-dev nodejs npm` (package names on Debian/Ubuntu: UNVERIFIED for each; `libheif-dev` and `libde265-dev`/`libx265-dev` may need checking). `nodejs` version must build the Vite/npm frontend (UNVERIFIED).
   - Fetch pinned source: `curl -fL "https://github.com/DenDianUgerah/reubah/archive/${VERSION}.tar.gz" | tar xz -C /src --strip-components=1`.
   - `cd /src && go mod download`, then `cd /src/templates && npm install && npm run build`.
   - `cd /src && CGO_ENABLED=1 go build -o /out/reubah ./cmd/server`.
   - Copy `templates/` and `static/` from `/src` into `/out` (the runtime needs them).
   - Use `GOCACHE=/tmp/go-cache` and `npm_config_cache=/tmp/npm-cache` so no cache is written to `/app`.
2. Final stage `FROM <ubuntu>`:
   - `apt-get install -y --no-install-recommends libreoffice-writer libreoffice-calc libreoffice-impress ttf-mscorefonts-installer bash curl libwebp7 libheif1 libx265-199 libde265-0 default-jre-headless` (package names and set of LibreOffice components UNVERIFIED; upstream installs full `libreoffice`, so start from `libreoffice` and trim only after a test). Do not add a Java version the base does not need; `apps/java21` is the repo precedent if a JRE is needed.
   - `apt-get clean && rm -rf /var/lib/apt/lists/*`.
   - `mkdir -p /app /tmp/.cache /tmp/.config /tmp/.local`.
   - `COPY --from=build /out/ /app/`, then `chown -R apps:apps /app && chmod -R 755 /app`.
   - License: `mkdir -p /usr/share/licenses/reubah && cp /src/LICENSE ...` (copy done in the build stage: `COPY --from=build /src/LICENSE /usr/share/licenses/reubah/LICENSE`).
3. Tail:

```dockerfile
ENV HOME=/tmp \
    PORT=8081 \
    LIBREOFFICE_HOME=/usr/lib/libreoffice

USER apps
COPY --chmod=0755 . /

EXPOSE 8081
VOLUME /config
WORKDIR /app
```

Upstream has no VOLUME; `VOLUME /config` is kept for ContainerForge consistency and the app may not write there (see section 9). The draft's `/app/tmp` emptyDir is not a ContainerForge path: scratch belongs in `/tmp`.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "reubah"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/DenDianUgerah/reubah currentValue=main
  default = "<full commit SHA>"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/DenDianUgerah/reubah"
}
```

Then `image`, `image-local`, `image-all` and `group "default"` copied from `apps/adguardhome-sync/docker-bake.hcl`. `VERSION` is a full commit SHA, never `main`, so builds are reproducible. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/DenDianUgerah/reubah"
ports:
  - port: 8081
    protocol: tcp
    required: true
env:
  - name: PORT
    default: "8081"
    required: false
volumes:
  - path: /config
    required: false
dependencies: []
```

- `PORT` is documented; keep only it until the source is read. Do not invent others.
- `/config` matches `VOLUME /config` in the Dockerfile; whether the app persists state there is UNVERIFIED (section 9).

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /tmp/.cache /tmp/.config /tmp/.local
cd /app || exit 1
export PORT="${PORT:-8081}"
exec /app/reubah
```

- Writes only to `/tmp` (LibreOffice profile, caches). Nothing in `/app`.
- Listen address: the Go server must bind `0.0.0.0` (or `:8081`). Verify in the source that it does not bind `localhost` only (UNVERIFIED; check `cmd/server`).
- Does `PORT` map to the server's listen address in code? Confirm; if the server reads another name, fix `env` in `settings.yaml` to the real name.
- `exec` so the server is PID 1 handoff.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '8081'
http:
- port: '8081'
  path: /
filePaths:
- /app/reubah
- /app/templates
- /app/static
- /usr/share/licenses/reubah/LICENSE
```

- `timeoutSeconds: 180` because the image runs LibreOffice init on first start (reasonable, not from a sibling; sibling check pending).
- `tcp` and `http` probes on 8081 cover the only port.
- The health route `/` returns 200 per upstream HEALTHCHECK; confirm during the probe run.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/tmp` (HOME, LibreOffice `.cache`, `.config`, `.local`, Go/npm caches) | Kept at `/tmp`. Ephemeral, matches ContainerForge. |
| `/app/tmp` (draft: emptyDir chart mount) | Not used. Scratch goes to `/tmp`. |
| `/tmp` as `doc-temp` volume (README) | Ignored. Not a `/config` need. |
| Upload/converted documents | UNVERIFIED where they are written. If under `/tmp`, nothing persists across restarts (draft caveat is correct). If the app stores user files, map them to `/config` and set `VOLUME /config`. |

- Run as `apps` (UID 1000 in upstream is `appuser`; ContainerForge uses `apps`). Confirm the `apps` UID with the base image; do not hard-code 1000.
- LibreOffice needs a writable profile dir: `HOME=/tmp` covers it. Confirm `soffice` starts read-only with `--tmpfs /tmp`.
- Draft security expectations (non-root, read-only rootfs, no privilege) match ContainerForge defaults and are compatible. Confirm no write to `/app` in the code (the Go server may write a temp dir next to the binary; UNVERIFIED).

## 10. Risks, caveats and open questions

- No tags and a rolling `main`: builds are only reproducible with the pinned SHA (`VERSION`). The draft's `:main` tag must not drive the image version.
- Build time: the build stage compiles Go with CGO and runs an npm frontend build for both architectures. It is slow; expect long `image-all` runs.
- LibreOffice is large and is the main image-size cost. Trimming components is an open question and must be tested.
- Java: upstream ships `openjdk11-jre` on alpine; purpose UNVERIFIED. Do not include a JRE if the code path does not need it; confirm first.
- Port: the draft's 8080 is wrong; 8081 is confirmed.
- Blockers: none known besides build size. arm64 is built from source, so it is possible but UNVERIFIED. Musl-to-glibc move: check that `libheif`, `libde265` and `x265` ship on Ubuntu 26.04 for both arches.
- Fonts: `ttf-liberation` (alpine) maps to a Debian/Ubuntu font package (UNVERIFIED name). Document-conversion output depends on fonts.

## 11. Build and test steps

From `apps/reubah` (one app at a time):

1. `docker buildx bake --print` must exit 0.
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`. The build is slow; run it in the background if needed.
3. Probe run, empty `/config`, read-only root:

```sh
docker volume create reubah-probe-config
docker run --rm -d --name reubah-probe --read-only --tmpfs /tmp \
  -v reubah-probe-config:/config reubah:<version>
docker logs -f reubah-probe
```

   Pass: container still running, log shows the server listening on 8081 (exact line UNVERIFIED), and no fatal error. Then `curl -f http://localhost:8081/` from the host (port publish needed for this step only).
4. `forgetool containers test --image reubah:<version> --config ./apps/reubah/container-test.yaml`
5. Cleanup: `docker rm -f reubah-probe; docker volume rm reubah-probe-config`.
6. arm64 only after amd64 is green (protocol: arm64 only for arm64-specific failures). Run `image-all` for both platforms once validated.

## 12. PR checklist

- Branch `feat/add-reubah`, commit `feat(reubah): add new container`, target `main`.
- PR title matches the commit.
- Body: upstream source and pinned commit SHA, Go/Node build stages, base image and digest, port 8081, volumes (`/config` only if used), what was built and tested.
- Notes section includes `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it.
- Use `.github/PULL_REQUEST_TEMPLATE.md`, keep sections and checkboxes, check only the applicable boxes.
- Untested items to list: arm64 build, LibreOffice conversion output, the Java question, and any path not confirmed in the source.
