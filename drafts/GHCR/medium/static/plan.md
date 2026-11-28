# static — implementation plan
> Source: ./draft.md · Target: apps/static/ · Difficulty: medium · Role: main · Verified on 2026-11-25

Status: **blocked on items marked UNVERIFIED in sections 1, 6 and 10.** The draft's GitHub source is dead (404); the live source is `git.mills.io`. The license conflicts between sources. Confirm both before writing the Dockerfile.

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Latest release tag `0.0.2`, dated 2020-04-30 (https://git.mills.io/prologic/static, sidebar "Latest"). Tags exist (3 tags, 2 releases). The draft's container tag `ghcr.io/nicholaswilde/static:version-ee8a20c` is a 2021 build of an older commit (`ee8a20c-ls3`, published 2021-06-26, gh API). |
| Renovate | UNVERIFIED: no renovate datasource confirmed for `git.mills.io`. Candidate: `datasource=git-tags` with the git.mills.io URL, to be checked. |
| License | Conflicting. The git.mills.io sidebar lists MIT; its README says "licensed under the terms of the MIC License". UNVERIFIED which applies. The nicholaswilde packaging repo is Apache-2.0 (gh API), which does not license the upstream software. |
| Source URL | `https://git.mills.io/prologic/static.git` (live). `https://github.com/prologic/static` returns 404 (gh API): do not use. Module path: `go.mills.io/static`. |
| Download | No binary release assets. Build from source. README: `go install go.mills.io/static/cmd/static@latest`, or `git clone https://git.mills.io/prologic/static.git && cd static && make install`. |
| Checksum source | None (tags are git refs; pin the tag and commit). |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/nicholaswilde/docker-static/f52fab6/Dockerfile: build stage `golang:1.16.5-alpine3.14`, final `ghcr.io/linuxserver/baseimage-alpine:3.14` (musl). `git clone https://github.com/prologic/static.git` (now 404), `go install -v`, `VOLUME /data`, `EXPOSE 8000/tcp`, `WORKDIR /data`, no ENTRYPOINT/CMD, no USER. Not reusable: alpine/musl, and the GitHub clone path is dead. |
| Port | 8000/tcp (README: `static` then visit http://localhost:8000/; upstream EXPOSE). |
| Usage | `static` with no flags (README). UNVERIFIED: how the content directory is chosen (no flag or env documented on the fetched page). |
| Env vars (real) | None confirmed. Upstream Dockerfile sets only `GO111MODULE=on` (build) and `GOPATH=/go` (final). |
| Data path | `/data` (upstream VOLUME and WORKDIR). UNVERIFIED that the binary serves from `/data` without a flag. |
| arm64 | UNVERIFIED: no arm64 build evidence. Pure Go is expected to build for arm64, but this is not tested. |
| Dependencies | None. |

## 2. Target layout

- `apps/static/Dockerfile`
- `apps/static/docker-bake.hcl`
- `apps/static/settings.yaml`
- `apps/static/container-test.yaml`
- `apps/static/start.sh`

No `defaults/` unless a default site page is needed (reason: an empty `/config` must still serve something, so a seed page is a candidate). No `root/` (reserved). No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

Final stage: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`. Build stage: the same ubuntu digest with `golang-go` from apt (the pattern of `apps/pwndrop`, which builds Go in an ubuntu build stage). Runtime image is ubuntu alone; no language runtime is needed for a static binary.

Closest sibling: `apps/pwndrop` (Go build stage, `COPY --from=buildstage`, `EXPOSE`, `WORKDIR /config`, `VOLUME /config`).

## 4. Dockerfile

1. `FROM <ubuntu digest> as buildstage`, `ARG VERSION`, `USER root`.
2. `apt-get install -y --no-install-recommends golang-go git ca-certificates`. UNVERIFIED: Go version available in the 26.04 archive; check it supports the module (`go.mod` go directive) before pinning.
3. Fetch the source pinned to the tag: `git clone --depth 1 --branch ${VERSION} https://git.mills.io/prologic/static.git /tmp/static` (`VERSION` = `0.0.2`). Do not clone the dead GitHub path.
4. Build with `CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /app/static/static ./cmd/static` (path `./cmd/static` from the README module layout; confirm with the source tree).
5. Ship the license and notices to `/usr/share/licenses/static/` once the license is resolved (section 1).
6. Final stage: `FROM <ubuntu digest>`, `ARG VERSION`, `USER root`, `COPY --from=buildstage /app/static/ /app/static/`. Check that `/app/static/static` is executable.
7. `USER apps`, `COPY --chmod=0755 . /`.

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 8000
WORKDIR /config
VOLUME ["/config"]
```

`/config` (not `/data`) is the persistent path under the ContainerForge model, so the upstream `/data` is remapped (section 9).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" { default = "static" }

variable "VERSION" {
  // renovate: UNVERIFIED datasource and depName (git.mills.io); resolve before merge
  default = "0.0.2"
}

variable "LICENSE" { default = "UNVERIFIED" }   // MIT vs "MIC": resolve first
variable "SOURCE" { default = "https://git.mills.io/prologic/static" }
```

Four standard targets and the default group copied from `apps/nzbhydra2/docker-bake.hcl`. Validate with `docker buildx bake --print`. `VERSION` equals `ARG VERSION`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://git.mills.io/prologic/static"
ports:
  - port: 8000
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

No upstream env vars are confirmed, so none are listed (do not invent them). If section 10's content-directory question resolves to an env var or flag, add it here and in `start.sh`.

## 7. start.sh

- `mkdir -p /config/site` (or the path section 10 confirms) and seed only when empty.
- Never write to `/app`.
- `cd /config` and `exec /app/static/static --<flag per section 10> /config/site`, binding to all interfaces (`0.0.0.0:8000`) if the binary's listen address is configurable; UNVERIFIED that it is.
- Use `exec` so signals reach the server.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 60
tcp:
- port: '8000'
http:
- port: '8000'
  path: /
filePaths:
- /app/static/static
```

The HTTP probe expects a 200 on `/` only if an index exists in the seed. If the seed is empty, the probe may need a different path or a seeded `index.html` from `defaults/`; decide after the first run (UNVERIFIED). Do not weaken the probe to pass.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/data` (VOLUME, WORKDIR) | `/config`. The image sets `WORKDIR /config`. |
| `/go` (GOPATH, build tree copied into final image) | Not copied. Only the built binary goes to `/app/static/`. |
| Build cache (`GOCACHE`) | `/tmp` (`ENV GOCACHE=/tmp/go-cache` in the build stage). |
| Upstream `chown abc:abc` | Removed. Files are owned by root and run as `apps` (568). |

Draft expectations reconciled: the chart runs as root and `readOnlyRootFilesystem: false`; this image targets non-root and `--read-only --tmpfs /tmp`. The chart's `/data` must move to `/config` when ported.

## 10. Risks, caveats and open questions

- Source moved: the draft's GitHub URL is a 404. The live source is git.mills.io only; a build depends on that host being reachable.
- License conflict (MIT vs "MIC") and the packaging repo's Apache-2.0 must not be confused with the upstream license.
- Stale: the last release is 2020 and the upstream Dockerfile used Go 1.16 on musl. Confirm the code builds with the Ubuntu 26.04 Go toolchain.
- UNVERIFIED: how the server picks its content directory (flag or env) and its listen address. The `static` README only shows `static` with no flags.
- No confirmed env vars: none are listed in `settings.yaml`.
- Blockers: license unresolved; content directory unknown; the Ubuntu Go version must be checked against `go.mod`.
- arm64 not built or tested.

## 11. Build and test steps

```sh
cd apps/static
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name static-probe --read-only --tmpfs /tmp \
  -v static-probe-config:/config static:<VERSION>
docker logs -f static-probe
forgetool containers test --image static:<VERSION> --config ./apps/static/container-test.yaml
docker rm -f static-probe; docker volume rm static-probe-config
```

Readiness signal: UNVERIFIED (the binary's log line is not known). Expected: the server stays up, and `curl` to port 8000 from outside the container succeeds.

## 12. PR checklist

- Branch `feat/add-static`, commit and PR title `feat(static): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`; keep sections; check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA notice: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows the status.
- Untested, to state honestly: the build from git.mills.io, runtime on `--read-only`, the HTTP probe, arm64, and the license.
- Before the PR: `docker buildx bake --print` passes; `VERSION` equals Dockerfile `ARG VERSION`; no assertion weakened.
