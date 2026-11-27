# golinks — implementation plan
> Source: ./draft.md · Target: apps/golinks/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | v0.0.7, the latest tagged release (https://git.mills.io/api/v1/repos/prologic/golinks/releases?limit=3, published 2021-09-06). Master may be newer; this plan pins the tag. The draft tag `version-154c581` is a TrueCharts chart tag and does not map to an upstream release (UNVERIFIED: which commit it is). |
| Renovate | Proposed `datasource=git-tags depName=https://git.mills.io/prologic/golinks versioning=semver`. UNVERIFIED that renovate resolves this host; the GitHub mirror has no tags. |
| License | MIT, per the `LICENSE` file (https://git.mills.io/prologic/golinks/raw/branch/master/LICENSE). The GitHub mirror reports no SPDX (https://api.github.com/repos/prologic/golinks, `license.spdx_id` null). |
| Source URL | https://git.mills.io/prologic/golinks (the GitHub repo `prologic/golinks` is a README pointing here). |
| Source tarball | https://git.mills.io/prologic/golinks/archive/v0.0.7.tar.gz (HTTP 200 confirmed). |
| Per-arch download | v0.0.7 has release assets: `_0.0.7_linux_amd64.tar.gz`, `_0.0.7_linux_arm64.tar.gz`, `_0.0.7_darwin_amd64.tar.gz` (https://git.mills.io/api/v1/repos/prologic/golinks/releases?limit=3, fetched 2026-11-27). Plan still builds from source for amd64 and arm64. |
| Checksum source | `_0.0.7_checksums.txt` (+ `.sig`) is on the v0.0.7 release (same API response, fetched 2026-11-27). Contents not read. Pin by tag and record the tarball sha256 in the Dockerfile comment block after the first download. |
| Module | `git.mills.io/prologic/golinks`, `go 1.13` (https://git.mills.io/prologic/golinks/raw/branch/master/go.mod). Dependencies: `git.mills.io/prologic/bitcask v1.0.0`, `github.com/GeertJohan/go.rice v1.0.2`. |
| Upstream Dockerfile reviewed | https://git.mills.io/prologic/golinks/raw/branch/master/Dockerfile: `golang:alpine` build (`make TAG=$TAG BUILD=$BUILD build`), `alpine:latest` runtime, `COPY .dockerfiles/start.sh /start.sh`, binary to `/usr/local/bin/golinks`, `EXPOSE 8000/tcp`, `ENTRYPOINT ["/start.sh"]`. No `USER`, no `VOLUME`. |
| Makefile | https://git.mills.io/prologic/golinks/raw/branch/master/Makefile: `CGO_ENABLED=0`, `go build -tags "netgo static_build" -ldflags "-s -w ..."`. The `deps` target runs `rice embed-go` (go.rice tooling needed at build time). |
| Entry script | https://git.mills.io/prologic/golinks/raw/branch/master/.dockerfiles/start.sh: env `BIND` (default `0.0.0.0:8000`), `BASEURL` (default `http://localhost:8000`), `DBPATH` (default `/search.db`), `TITLE` (default `Search`), `SEARCHURL`, `SUGGESTURL`, `CONFIG`. If `CONFIG` is set, runs `golinks -config "$CONFIG"`; otherwise passes the flags. |
| Flags | https://git.mills.io/prologic/golinks/raw/branch/master/main.go: `-config`, `-dbpath` (default `search.db`), `-title`, `-bind` (default `0.0.0.0:8000`), `-baseURL`, `-searchURL`, `-suggestURL`, `-v`. |
| Port | 8000/tcp (not 8080 as the draft guessed). |
| Data path | Bitcask database at `DBPATH`. The upstream default `/search.db` is at filesystem root and must be remapped to `/config`. |
| Architectures | amd64 and arm64 both compile from source with `CGO_ENABLED=0`. |
| copy-from | No. The only published image (`ghcr.io/nicholaswilde/golinks`, https://github.com/nicholaswilde/docker-golinks/blob/bea20bc/Dockerfile) is linuxserver alpine 3.14 and musl-based. |

## 2. Target layout

- `apps/golinks/Dockerfile`
- `apps/golinks/docker-bake.hcl`
- `apps/golinks/settings.yaml`
- `apps/golinks/container-test.yaml`
- `apps/golinks/start.sh` (adapts the upstream `.dockerfiles/start.sh`)

No `defaults/` or `etc/` needed: the script writes all state under `/config`. No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

Final stage: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. Upstream's runtime is `alpine:latest` (musl); this plan does not use it. Our binary is built with `CGO_ENABLED=0`, so a glibc base is fine.

Closest sibling: `apps/pwndrop` (Go built in an ubuntu build stage, copied into the ubuntu runtime stage).

## 4. Dockerfile

1. Build stage: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:... AS buildstage`, `ARG VERSION`, `USER root`.
2. Install the toolchain as pwndrop does: `apt-get install -y --no-install-recommends golang-go git` (version check: `go 1.13` in `go.mod` is old; the apt Go on 26.04 is newer and compatible; confirm with `go version` in the build log, UNVERIFIED for this exact version).
3. Set build caches to `/tmp`: `ENV GOCACHE=/tmp/go-cache GOMODCACHE=/tmp/go-mod GOFLAGS=-mod=mod`.
4. Fetch the tag: `curl -fL "https://git.mills.io/prologic/golinks/archive/${VERSION}.tar.gz" -o /tmp/golinks-src.tar.gz`, extract to `/tmp/golinks` with `--strip-components=1`. `VERSION` is `v0.0.7` (the tag includes the `v`).
5. Build: `cd /tmp/golinks && CGO_ENABLED=0 go build -tags "netgo static_build" -trimpath -ldflags "-s -w" -o /app/golinks/golinks .`. Skip `rice embed-go` only if the embedded assets are already in the tree; otherwise run `go install github.com/GeertJohan/go.rice/rice@v1.0.2` (pinned to the go.mod version, not `@latest`) and `rice embed-go` as the Makefile does (UNVERIFIED that the tarball includes the rice-generated files).
6. License: `COPY --from=buildstage /tmp/golinks/LICENSE /usr/share/licenses/golinks/LICENSE` (copy in the final stage after extracting in the build stage, or copy in the build stage then `COPY --from`).
7. Final stage: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:...`, `ARG VERSION`, `USER root`.
8. `COPY --from=buildstage /app/golinks/ /app/golinks/`, `chown -R apps:apps /app/golinks && chmod -R 755 /app/golinks`.
9. `ENV HOME=/config BIND=0.0.0.0:8000 DBPATH=/config/search.db BASEURL=http://localhost:8000 TITLE=Search`. `SEARCHURL` and `SUGGESTURL` keep the upstream defaults set in `start.sh`.
10. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 8000
VOLUME /config
WORKDIR /config
```

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "golinks"
}

variable "VERSION" {
  // renovate: datasource=git-tags depName=https://git.mills.io/prologic/golinks versioning=semver
  default = "v0.0.7"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://git.mills.io/prologic/golinks"
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

`VERSION` keeps the `v` because the tag does. Validate with `docker buildx bake --print` from `apps/golinks/`. The renovate datasource is a proposal (section 1); confirm renovate can reach git.mills.io before merging.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://git.mills.io/prologic/golinks"
ports:
  - port: 8000
    protocol: tcp
    required: true
env:
  - name: BIND
    default: "0.0.0.0:8000"
    required: false
  - name: BASEURL
    default: "http://localhost:8000"
    required: false
  - name: DBPATH
    default: "/config/search.db"
    required: false
  - name: TITLE
    default: "Search"
    required: false
  - name: SEARCHURL
    default: "https://www.google.com/search?q=%s&btnK"
    required: false
  - name: SUGGESTURL
    default: "https://suggestqueries.google.com/complete/search?client=firefox&q=%s"
    required: false
  - name: CONFIG
    default: ""
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

Defaults match `start.sh`. `CONFIG` (path to a config file) is read by `start.sh`, listed with an empty default. The `DBPATH` default changes from `/search.db` to `/config/search.db`; this is the one deliberate deviation from upstream.

## 7. start.sh

```bash
#!/bin/sh
set -eu

mkdir -p /config

BIND="${BIND:-0.0.0.0:8000}"
BASEURL="${BASEURL:-http://localhost:8000}"
DBPATH="${DBPATH:-/config/search.db}"
TITLE="${TITLE:-Search}"
SEARCHURL="${SEARCHURL:-https://www.google.com/search?q=%s&btnK}"
SUGGESTURL="${SUGGESTURL:-https://suggestqueries.google.com/complete/search?client=firefox&q=%s}"
CONFIG="${CONFIG-}"

if [ -n "$CONFIG" ]; then
  echo "Executing golinks with config file: ${CONFIG}"
  exec /app/golinks/golinks -config "$CONFIG"
fi

echo "Executing golinks on ${BIND}"
exec /app/golinks/golinks -bind="$BIND" -baseURL="$BASEURL" -dbpath="$DBPATH" \
  -title="$TITLE" -searchURL="$SEARCHURL" -suggestURL="$SUGGESTURL"
```

- Idempotent: nothing is seeded; the Bitcask DB is created by the app under `/config` on first start.
- Nothing writes to `/app`. Caches are not used at run time.
- `exec` hands PID 1 to golinks.
- The bind is `0.0.0.0:8000`, so other containers can reach it.
- Quote the values: `SEARCHURL` contains `&` and `%s`; the flags use `=` form so they pass through unsplit.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

tcp:
- port: '8000'
http:
- port: '8000'
  path: /
```

- Every port in `settings.yaml` has a probe (8000).
- `/` is the golinks web UI. Confirm the status code on the first run (UNVERIFIED expected status); if it redirects, use the observed code and keep the assertion real.
- `timeoutSeconds`: copy the sibling value from `apps/pwndrop/container-test.yaml`.
- Test runs without env vars: the defaults in `start.sh` apply. `filePaths`: `/app/golinks/golinks` (existence).

## 9. Rootless and read-only-rootfs adaptations

- Upstream runs as root with no `USER`. Our final stage runs as `apps`. The app binds to 8000 (above 1024), so no capabilities are needed.
- Read-only rootfs: the DB moves from `/search.db` (root path) to `/config/search.db`. `/app` is not written at run time. `HOME=/config`; no caches in `/config`.
- Upstream chart expectations (draft, `charts/stable/golinks`): runAsUser 0 and readOnlyRootFilesystem false. Those are chart-level overrides; this container is designed to run unprivileged and read-only, so they do not apply.
- Extra persistence: `/config` only (the chart's `/data` PVC maps to `/config`).

## 10. Risks, caveats and open questions

- Source of truth: the upstream repo moved to git.mills.io. The last release (v0.0.7) is from 2021. Master may have fixes; decide before the PR whether to pin v0.0.7 or a newer master commit, and record the reason.
- `rice embed-go`: the Makefile needs `go.rice` tooling at build time. If the tarball lacks the generated files, the build fails. UNVERIFIED.
- Renovate datasource for git.mills.io is unverified (section 5).
- Upstream runtime is alpine; the glibc ubuntu base is a deliberate change. `CGO_ENABLED=0` makes this safe, but confirm the binary runs (`ldd` shows no dynamic dependencies).
- Checksum for the source tarball is not published. Record the sha256 after the first download.
- No blockers for amd64 or arm64 once built.

## 11. Build and test steps

From `apps/golinks/`:

```sh
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name golinks-probe --read-only --tmpfs /tmp \
  -v golinks-probe-config:/config golinks:v0.0.7
docker logs -f golinks-probe
docker rm -f golinks-probe; docker volume rm golinks-probe-config
forgetool containers test --image golinks:v0.0.7 --config ./apps/golinks/container-test.yaml
```

Expected readiness signal: `Executing golinks on 0.0.0.0:8000` from `start.sh`, then the app's listen line (record the exact text on the first run). The container must still be running after startup.

Run once with an empty `/config` and once more on restart with the same volume.

## 12. PR checklist

- Branch: `feat/add-golinks`.
- Commit: `feat(golinks): add new container`.
- PR title: `feat(golinks): add new container`.
- PR description: Notes section contains `🤖 This PR is AI generated.`, uses `.github/PULL_REQUEST_TEMPLATE.md`, and only checked boxes that apply.
- CLA: tell the user the PR needs a signed CLA at https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it).
- Untested: arm64 build and the `/` status code until built; say so in the PR if not run.
- Checklist: bake print passes, image-local amd64 builds, container starts read-only with empty `/config`, `container-test.yaml` passes, no assertion weakened.
