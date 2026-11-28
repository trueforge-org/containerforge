# lingva — implementation plan
> Source: ./draft.md · Target: apps/lingva/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Pinned commit `0190ea5da9fbccba51e82184ca855c4ef5728fc7` (committed 2023-01-13). Upstream has no tags and no releases. Repo last pushed 2023-08-01, not archived. The current `main` head was not fetched: UNVERIFIED whether a newer commit is worth pinning. |
| Default branch | `main`. The draft's `archive/refs/heads/master.tar.gz` is wrong for this repo. `master.tar.gz` is UNVERIFIED to exist and is not used. |
| Renovate | `// renovate: datasource=git-refs depName=https://github.com/TheDavidDelta/lingva-translate currentValue=main` (precedent `apps/tvheadend`, `apps/fenrus` plan) |
| License | AGPL-3.0 (GitHub, not archived). |
| Source URL | https://github.com/TheDavidDelta/lingva-translate (`SOURCE`; GitHub casing `thedaviddelta` also resolves). |
| amd64 download | Source archive only: `https://github.com/TheDavidDelta/lingva-translate/archive/${VERSION}.tar.gz` (commit SHA). No prebuilt binary. amd64 = yes (archive is the official vendor download; the image is built from it). |
| arm64 download | Same archive. Built in the image with yarn and Next.js. The build is pure JavaScript, arch-neutral except for the native SWC binary that `yarn install` resolves per platform. UNVERIFIED: that `yarn install` succeeds on arm64. |
| Checksum source | None published. The archive is pinned by commit SHA. |
| Upstream Dockerfile reviewed | `Dockerfile` at `0190ea5`: a `node:lts-alpine` deps stage (`libc6-compat`, `yarn install --frozen-lockfile`), a builder stage with `curl`, user `nextjs` (UID 1001), `USER nextjs`, `EXPOSE 3000`, `NODE_ENV=production`, `NEXT_TELEMETRY_DISABLED=1`, `HEALTHCHECK` with `curl http://localhost:3000/`. `CMD` runs `yarn build && yarn start` at container start. |
| Port | 3000 (upstream `EXPOSE 3000`, chart service port 3000). |
| Env vars (real) | The upstream `CMD` maps shell variables `site_domain`, `force_default_theme`, `default_source_lang`, `default_target_lang` to `NEXT_PUBLIC_SITE_DOMAIN`, `NEXT_PUBLIC_FORCE_DEFAULT_THEME`, `NEXT_PUBLIC_DEFAULT_SOURCE_LANG`, `NEXT_PUBLIC_DEFAULT_TARGET_LANG`. Upstream defaults for these are UNVERIFIED in this run. The chart sets only `site_domain: ""`. |
| Data and config paths | None. No volume. `.next/` build output is written at build time (upstream writes it at container start). |
| Docker Hub | `thedaviddelta/lingva-translate`, tag `latest` only, amd64, last updated 2022-10-21. No arm64 image. |
| Chart | `docker.io/thedaviddelta/lingva-translate`, tag `latest@sha256:7c9837562e49923ccadfe0e2a017fa3419a1d2878efdd33b2ef754316b6d0ae7`. Security: `readOnlyRootFilesystem: false`, `runAsUser: 0`, `runAsGroup: 0`, `persistence: {}`. |

## 2. Target layout

- `apps/lingva/Dockerfile`
- `apps/lingva/docker-bake.hcl`
- `apps/lingva/settings.yaml`
- `apps/lingva/container-test.yaml`
- `apps/lingva/start.sh`

No `defaults/`, `etc/`, `health/` or `root/`. No `DOWNSTREAM_CHANGES.md`: nothing uses this image as a `FROM` base. No `VOLUME /config`: the app has no state (see section 6).

## 3. Base image

```dockerfile
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a
```

The draft proposes `python-node`. That is not needed: there is no Python code. The repo table maps Node apps to `ghcr.io/trueforge-org/ubuntu`, and `apps/docusaurus` already runs `npm` on that base, so Node is expected to be present there. UNVERIFIED: the Node and npm versions in the ubuntu base, and whether `yarn` is present. If Node is missing or too old for `package.json`, switch to `ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5` (Node 24 per `apps/budge`), and say so in the PR.

Closest sibling: `apps/docusaurus` (ubuntu, Node tooling, `/tmp` caches, read-only-compatible).

## 4. Dockerfile

1. `ARG VERSION`, `USER root`.
2. Env: `NEXT_TELEMETRY_DISABLED=1`, caches in `/tmp` (`YARN_CACHE_FOLDER`, `npm_config_cache`).
3. Build stage in one `RUN`: download the pinned archive, install with `yarn install --frozen-lockfile`, run `yarn build`, copy to `/app/lingva`, install the license.
4. Make the build output read-only for `apps`, and symlink `.next/cache` to `/tmp` (section 7).
5. `USER apps` and `COPY --chmod=0755 . /`.

```dockerfile
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
USER root

ENV NEXT_TELEMETRY_DISABLED=1 \
    YARN_CACHE_FOLDER=/tmp/yarn-cache \
    npm_config_cache=/tmp/npm-cache \
    npm_config_update_notifier=false

RUN echo "*** Installing lingva-translate ${VERSION} ***" && \
  mkdir -p /tmp/src /app/lingva && \
  curl -fsSL "https://github.com/TheDavidDelta/lingva-translate/archive/${VERSION}.tar.gz" \
    | tar xz -C /tmp/src --strip-components=1 && \
  cd /tmp/src && \
  corepack enable && \
  yarn install --frozen-lockfile && \
  yarn build && \
  cp -a /tmp/src/. /app/lingva/ && \
  rm -rf /app/lingva/.next/cache && \
  ln -s /tmp/next-cache /app/lingva/.next/cache && \
  install -d /usr/share/licenses/lingva && \
  cp /tmp/src/LICENSE /usr/share/licenses/lingva/LICENSE && \
  chown -R root:root /app && chmod -R 755 /app && \
  echo "*** Cleaning Up ***" && \
  rm -rf /tmp/* /var/lib/apt/lists/*

USER apps
COPY --chmod=0755 . /

EXPOSE 3000
WORKDIR /app/lingva
```

- `corepack enable` provides the pinned `yarn` from `package.json` (`packageManager`). UNVERIFIED that the repo pins yarn that way. If not, install the yarn version the lockfile needs, and pin it.
- `cp -a /tmp/src/.` copies `.next` and `node_modules`, so the runtime does not need `/tmp/src`.
- `/tmp/next-cache` must exist at runtime (created by `start.sh`); `/tmp` is tmpfs under `--read-only`.
- `install -d` and `cp` for the license: the tarball has `LICENSE` at the root. UNVERIFIED path: confirm in the build.
- No `VOLUME`: stateless.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "lingva"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/TheDavidDelta/lingva-translate currentValue=main
  default = "0190ea5da9fbccba51e82184ca855c4ef5728fc7"
}

variable "LICENSE" {
  default = "AGPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/TheDavidDelta/lingva-translate"
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

Validate with `docker buildx bake --print` from `apps/lingva`. The `ARG VERSION` in the Dockerfile must be the same full commit SHA. The image tag `lingva:<40-char SHA>` is long; keep it, since no release tag exists. Alternative: a short SHA in the tag only, but do not split the value.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/TheDavidDelta/lingva-translate"
ports:
  - port: 3000
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
```

- The four `NEXT_PUBLIC_*` settings (`site_domain`, `force_default_theme`, `default_source_lang`, `default_target_lang`) are NOT listed yet. They are used at build time by Next.js (see section 10). Add them only after the decision in section 10 is made, with defaults taken from the upstream Dockerfile.
- `volumes`: omitted. No state, so no `/config`. Chart `persistence: {}` matches.
- No `dependencies`: standalone.

## 7. start.sh

```bash
#!/usr/bin/env bash

# next start writes its image cache under .next/cache; /tmp is the writable scratch space
mkdir -p /tmp/next-cache

cd /app/lingva
exec ./node_modules/.bin/next start -H 0.0.0.0 -p 3000
```

- Idempotent: no seeding, no `/config`, nothing written to `/app`.
- No `yarn build` at start. The draft's and upstream's `CMD` runs the build at every start, which fails on a read-only rootfs and is slow. The build now happens in the image.
- `next start` with `-H 0.0.0.0 -p 3000`: the flags are UNVERIFIED for the Next.js version in the lockfile. Also UNVERIFIED whether the upstream `start` script adds anything else (check `package.json` `scripts.start`). If it does, keep the same behavior.
- `exec` hands PID 1 to Next.js.
- `NEXT_TELEMETRY_DISABLED=1` is set in the image.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '3000'
http:
- port: '3000'
  path: /
filePaths:
- /app/lingva/package.json
- /app/lingva/.next/BUILD_ID
- /usr/share/licenses/lingva/LICENSE
```

- `timeoutSeconds: 120`: Next.js starts in seconds, but the image's first request may compile; no sibling precedent was checked. Adjust only if needed.
- `http /` returns 200 is UNVERIFIED. It needs no outbound network if the root page does not call translation APIs at render time. Check in the run. If it does call them, the probe may fail without network: say so in the PR and narrow it to what the run shows, but do not remove the probe.
- `.next/BUILD_ID` proves the build ran at image build time.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `yarn build` at container start, writes `.next/` | Moved to image build time. `/app/lingva` is read-only at runtime. |
| `.next/cache` (Next.js image cache, UNVERIFIED that `next start` writes here) | Symlink to `/tmp/next-cache`, created at build time, directory created by `start.sh`. |
| Yarn and npm caches | `/tmp` (`YARN_CACHE_FOLDER`, `npm_config_cache`), removed in the same layer. |
| User | Upstream `nextjs` (UID 1001) becomes `apps`. |
| Chart | Runs as UID 0, `readOnlyRootFilesystem: false`. This image runs as `apps` and works read-only with `--tmpfs /tmp`, to be proven in section 11. |

Not privileged. No extra capabilities. No persistence. The chart needs no persistent volume.

## 10. Risks, caveats and open questions

- **Decision needed: `NEXT_PUBLIC_*` are build-time values.** Next.js inlines `NEXT_PUBLIC_*` variables into the client bundle during `next build` (expected Next.js behavior; not re-checked against the lingva source in this run). Moving the build to image time therefore means `site_domain`, `force_default_theme`, `default_source_lang` and `default_target_lang` are fixed when the image is built. Options:
  - (a) Accept build-time values: pass them as `ARG`s with defaults in the Dockerfile and `docker-bake.hcl`. Changing them means a rebuild. Simple, read-only compatible. Recommended.
  - (b) Keep them runtime: build at start into `/tmp`. Slow, memory-hungry, and the draft already flagged the start-time build as the problem.
  - Verify first: grep the lingva source for `process.env` and `NEXT_PUBLIC_` to see which values are read at runtime on the server. Choose after that. Do not guess.
- **Node version.** UNVERIFIED that the ubuntu base's Node satisfies lingva's `engines` or `.nvmrc`. Check `package.json`, then `node --version` in the base. Fallback is `python-node` (section 3).
- **yarn.** UNVERIFIED how the repo pins yarn. `corepack enable` only works if `packageManager` is set.
- **Upstream is stale.** Last code change 2023-08. Public lingva instances have gone offline (draft). Treat the image as unmaintained; say so in the PR.
- **External dependency.** Translations call third-party endpoints. Without outbound access the app loads but translates nothing (draft). The test does not prove translation works.
- **arm64.** Built from source on both architectures, so there is no reference arm64 image. Yarn install and Next.js build on arm64 are UNVERIFIED.
- **Long version string.** The 40-character SHA is used as the tag. Renovate `git-refs` tracks `main`, so each push to `main` is a new PR (noisy). Pinning a tag is not possible: there are none.
- **Blockers:** none for the build if the Node and yarn checks pass. The env decision above must be made before the settings file is written.

## 11. Build and test steps

```sh
cd apps/lingva
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name lingva-probe --read-only --tmpfs /tmp \
  -v lingva-probe-config:/config lingva:0190ea5da9fbccba51e82184ca855c4ef5728fc7
docker logs -f lingva-probe
forgetool containers test --image lingva:0190ea5da9fbccba51e82184ca855c4ef5728fc7 --config ./apps/lingva/container-test.yaml
docker rm -f lingva-probe; docker volume rm lingva-probe-config
```

The `-v` volume is harmless but unused (no `/config`). Keep it so the empty-`/config` step is the same for every app, or drop it if the protocol changes.

Expected readiness signal: Next.js start line with `http://0.0.0.0:3000` (text UNVERIFIED), then `ready` (UNVERIFIED wording). No build output and no `EROFS` errors in the logs. Check `ss -ltn` for port 3000 and connect from the host with `-p 3000:3000` to prove it is not bound to localhost.

## 12. PR checklist

- Branch `feat/add-lingva`, commit and PR title `feat(lingva): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, check only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it. The `license/cla` check shows the status.
- Say in the PR what is untested: arm64 (yarn install and Next.js build), the Node and yarn versions in the base, the `--read-only` run and any `.next/cache` writes, the bind address, whether translation works without network, and the build-time `NEXT_PUBLIC_*` decision.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; no assertion weakened.
