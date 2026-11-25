# photo-stream — implementation plan
> Source: ./draft.md · Target: apps/photo-stream/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Latest GitHub release is `1.5.0` (published 2023-03-16, no release assets). Repo pushed 2026-06-23, so the default branch is newer than the release. Pin the `1.5.0` tag unless a newer tag appears. Source: https://api.github.com/repos/waschinski/photo-stream/releases/latest |
| Draft tag | Draft lists `1.5.0`, matching the release. No difference. |
| Renovate | `datasource=github-releases depName=waschinski/photo-stream versioning=semver` (standard form; not fetched from a renovate config, so the choice is an inference) |
| License | MIT (GitHub SPDX `MIT`). Source: https://api.github.com/repos/waschinski/photo-stream |
| Source URL | https://github.com/waschinski/photo-stream |
| Download | Source for the build: GitHub tag archive `https://github.com/waschinski/photo-stream/archive/refs/tags/${VERSION}.tar.gz`. UNVERIFIED: the archive URL pattern is standard GitHub, not fetched. No prebuilt binary exists (release has zero assets), so the app is built from source. |
| Checksum source | None published (no release assets). UNVERIFIED: a checksum must be recorded from the first build of the tag archive, or the build must rely on the tag's content address. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/waschinski/photo-stream/4f4e0dd71bea2a1db063f03f6ba76ca1ffe02d29/Dockerfile (summary only; verbatim fetch was refused). Base `ruby:3.1.3` on alpine 3.17; installs libvips, exiftool, git, rsync, lftp, openssh, perl; copies project to `/photo-stream`; bundler and jekyll gems, `bundle install`; `ENTRYPOINT` runs `jekyll serve` bound to all interfaces; port 4000; no `USER`, no `VOLUME`, no env vars. |
| Upstream runtime | `jekyll serve` (development server), so the site is generated and served by Jekyll at run time, not at build time. |
| Env vars (real) | None declared in the upstream Dockerfile. UNVERIFIED: any env read by the Jekyll site config (`_config.yml`), since the source was not read. |
| Ports (real) | 4000 (Jekyll dev server, from upstream Dockerfile). The draft's 80 is not upstream. |
| Docker Hub | `waschinski/photo-stream:latest` last updated 2023-03-16, arches amd64 and arm64 (plus unknown entries). Source: https://hub.docker.com/v2/repositories/waschinski/photo-stream/tags/latest |
| arm64 | Upstream image lists arm64, but the Dockerfile uses alpine packages; the build for arm64 in ContainerForge would use the same Jekyll/Ruby toolchain on ubuntu. |
| Photo path | Draft says `/photo-stream/photos/original` (TrueCharts pvc default). UNVERIFIED that the upstream site reads photos from this path at all: the upstream Dockerfile sets no path. |
| Dependencies | None (no database). |

## 2. Target layout

- `apps/photo-stream/Dockerfile`
- `apps/photo-stream/docker-bake.hcl`
- `apps/photo-stream/settings.yaml`
- `apps/photo-stream/container-test.yaml`
- `apps/photo-stream/start.sh` (copies the built site into `/config` only when missing, or only seeds `nginx.conf`; see section 7)
- `apps/photo-stream/defaults/nginx.conf` (only if the runtime nginx config is seeded from the image; reason: the nginx sibling reads `/config/nginx.conf`, see section 7)

No `root/`, no `DOWNSTREAM_CHANGES.md` (not a `FROM` base). `etc/` is not needed.

## 3. Base image

- Build stage: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. Reason: Ruby and Jekyll need apt packages, and the ubuntu base is the generic userland.
- Final stage: `FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:1e4f20bfcf614853820179bb28127b1375061c09f565bb7010495845d4742c9f`. Reason: the site is static once built, so nginx serves it. The draft's runtime choice is nginx; ubuntu is the fallback only if Jekyll must run at container start (see section 10).
- Closest siblings: `apps/nginx` (runtime), `apps/it-tools` and `apps/theme-park` (nginx static sites), `apps/adguardhome-sync` (prebuilt binary layout reference only).

## 4. Dockerfile

1. Build stage `FROM <ubuntu digest> AS build`, `ARG VERSION`, `USER root`.
2. `apt-get install -y --no-install-recommends ruby-full build-essential git libvips-dev` (the gems that need native code compile against it). Pin the Ruby package to the ubuntu 26.04 archive version and check it is at least the Ruby the Gemfile needs (UNVERIFIED: Gemfile not read). `rm -rf /var/lib/apt/lists/*`.
3. `ENV GEM_HOME=/tmp/gems BUNDLE_PATH=/tmp/bundle BUNDLE_APP_CONFIG=/tmp/bundle-config GEM_PATH=/tmp/gems` so no cache writes land in the image or in `/config`.
4. `RUN mkdir -p /tmp/src && curl -fL "https://github.com/waschinski/photo-stream/archive/refs/tags/${VERSION}.tar.gz" | tar xz -C /tmp/src --strip-components=1`; fetch `curl` and `tar` from the base (already present, see base image rules).
5. `cd /tmp/src && bundle install && bundle exec jekyll build --destination /tmp/site` (build output only in `/tmp`, never `/app`).
6. Final stage `FROM <nginx digest>`, `USER root`, `COPY --from=build /tmp/site/ /app/site/` (the build stage `/tmp` is not visible in the final stage, so a plain `cp` would fail), `chown -R apps:apps /app && chmod -R 755 /app`. The nginx sibling is not re-installed (base reuse rule).
7. License: `COPY --from=build /tmp/src/LICENSE /usr/share/licenses/photo-stream/LICENSE` (UNVERIFIED: a LICENSE file is present; the GitHub API reports MIT).
8. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 8080
VOLUME /config
```

   Port 8080 follows `apps/nginx` (non-root cannot bind 80). The draft's port 80 is not used.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "photo-stream"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=waschinski/photo-stream versioning=semver
  default = "1.5.0"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/waschinski/photo-stream"
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

Validate with `docker buildx bake --print` from `apps/photo-stream`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/waschinski/photo-stream"
ports:
  - port: 8080
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

No upstream env var is confirmed, so none is listed beyond `TZ` (matches the nginx sibling). Do not add the draft's photo path as an env var until the upstream site config is read (UNVERIFIED).

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config
if [ ! -s /config/nginx.conf ]; then
    cp /defaults/nginx.conf /config/nginx.conf
fi

exec nginx -c /config/nginx.conf -g "daemon off;"
```

`/config/nginx.conf` is seeded only when missing, and it points `root` at `/app/site`. `exec` keeps signals. No write to `/app`. Caches stay in `/tmp`. The nginx sibling's `CMD` is replaced by this script, so the base's `/config/nginx.conf` contract is preserved. Checked against the repo: `apps/nginx/defaults/nginx.conf` does `include /config/sites/*.conf` and its `default.conf` listens on 8080 with `root /usr/share/nginx/html`; `apps/it-tools` seeds `/config/sites/default.conf` from `/defaults/default.conf` via `docker-entrypoint.d/10-copyconfig.sh`. Prefer that pattern (ship `defaults/default.conf` with `root /app/site;` and a `docker-entrypoint.d` seed script, keep the base `CMD`) over a custom `start.sh` and a replacement `nginx.conf`. UNVERIFIED: what seeds `/config/nginx.conf` in the base (not found in `apps/nginx`).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

tcp:
- port: '8080'
http:
- port: '8080'
  path: /
filePaths:
- /app/site/index.html
- /usr/share/licenses/photo-stream/LICENSE
```

Port 8080 has both a `tcp` and an `http` probe (required by the coverage minimum). `timeoutSeconds` is not set, following the nginx sibling. UNVERIFIED: that `/app/site/index.html` exists (Jekyll output name), so check the build output in step 11.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| Jekyll `_site` (generated in the project folder) | Generated at build time into `/tmp/site`, then copied into `/app/site` (read-only at run time). |
| Ruby gems and bundler cache | `/tmp/gems`, `/tmp/bundle` (build stage only; not in the image). |
| nginx temp and logs | `/tmp` (base `apps/nginx` already uses `/tmp/nginx-temp`, `/tmp/nginx-cache`). |
| Photos `/photo-stream/photos/original` (chart PVC) | Not mounted in this design, see section 10. |

Draft security expectations, reconciled: the chart runs as UID 0 with `readOnlyRootFilesystem: false`. This image runs as `apps` and is read-only compatible: all writes go to `/config` or `/tmp`. Not privileged. Extra persistence from the chart is not needed for a static site.

## 10. Risks, caveats and open questions

- **Photos are not dynamic (blocker for parity).** The upstream image runs `jekyll serve` and the chart mounts photos under `/photo-stream/photos/original`. A build-once static site cannot show new photos without an image rebuild. Options: (a) accept a rebuild per photo change, (b) run `jekyll build` at container start into `/tmp` from a mounted source (needs Ruby in the runtime stage, so use the ubuntu base as final stage), (c) drop the feature. Decide before implementation. UNVERIFIED: how the upstream site discovers photos (source not read).
- The draft's expectation that photos are read from `/photo-stream/photos/original` is not confirmed by the upstream Dockerfile.
- Ruby gems need internet at build time; the build must reach rubygems.org.
- `libvips` and native gems compile per architecture; arm64 is untested.
- Upstream port 4000 and the draft's port 80 are both unconfirmed for the ContainerForge runtime. Plan uses 8080.
- Upstream release is 2023 while the source default branch is 2026-06. Pinning the 1.5.0 tag may miss fixes; decide the tag or commit.
- No blockers beyond the photo design (not musl-only, no GPU, not privileged, no database).

## 11. Build and test steps

```sh
cd apps/photo-stream
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name photo-stream-probe --read-only --tmpfs /tmp \
  -v photo-stream-probe-config:/config photo-stream:1.5.0
docker logs -f photo-stream-probe
forgetool containers test --image photo-stream:1.5.0 --config ./apps/photo-stream/container-test.yaml
docker rm -f photo-stream-probe; docker volume rm photo-stream-probe-config
```

Expected readiness: nginx starts with `daemon off` and the container stays up; `curl -fI http://localhost:8080/` returns 200 from the probe. Confirm `/app/site/index.html` exists in the built image before running the test. Also curl from outside the container (`-p 8080:8080`) to prove nginx is not bound to localhost.

## 12. PR checklist

- Branch `feat/add-photo-stream`, commit and PR title `feat(photo-stream): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows the status.
- Untested to state honestly: the Jekyll build on both architectures, the photo workflow (section 10), the nginx site root, and the `1.5.0` tag's buildability.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; no assertion weakened.
