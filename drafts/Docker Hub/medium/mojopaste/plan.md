# mojopaste — implementation plan
> Source: ./draft.md · Target: apps/mojopaste/ · Difficulty: medium · Role: main · Verified on 2026-11-25

**Status: blocked on license.** The `LICENSE` value cannot be set until the upstream license is confirmed (rule: `LICENSE` MUST be the license of the software in the image). Do not start the Dockerfile until section 10 is resolved.

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | No GitHub releases (`releases/latest` returns 404). Latest git tag `1.05` (commit `679f4d05`, 2021-06-16). Draft commit `246642c` is dated 2022-01-15 (main HEAD then). Plan pins tag `1.05` if it contains the same script path (UNVERIFIED), otherwise a commit. |
| Draft vs. latest | Draft has no version; upstream `main` moved since 2022 only if a later commit exists (not checked beyond the tags API). Docker Hub `jhthorsen/mojopaste:latest` last updated 2022-01-15, amd64 only. Tag `storage` (2017-12-28) also amd64 only. |
| Renovate | `datasource=github-tags depName=jhthorsen/app-mojopaste versioning=loose` (suggested; repo style not checked, UNVERIFIED). Upstream Dockerfile fetches an unpinned `main` tarball, which Renovate cannot track. |
| License | UNVERIFIED. Repo API `license` field is null; `LICENSE` file at `246642c` returned 404. |
| Source URL | https://github.com/jhthorsen/app-mojopaste |
| Download | Upstream: `https://github.com/jhthorsen/app-mojopaste/archive/main.tar.gz`. Plan: `https://github.com/jhthorsen/app-mojopaste/archive/refs/tags/${VERSION}.tar.gz` (UNVERIFIED that the tag archive has the same layout). |
| Per-arch | Pure Perl app, so the same tarball on amd64 and arm64. Text::CSV has an optional XS path; arm64 build UNVERIFIED. |
| Checksum source | None published. Tag archives are content-addressed by commit; no `.sha256` found (UNVERIFIED). |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/jhthorsen/app-mojopaste/246642c/Dockerfile: `FROM alpine:3.5` (EOL, musl), single stage, `mkdir -p /app/data`, apk installs perl and build deps, cpanminus from `cpanmin.us`, `cpanm -M https://cpan.metacpan.org Text::CSV`, `cpanm --installdeps ./app-mojopaste-main`, removes build deps. |
| Entrypoint | `/usr/bin/perl /app-mojopaste-main/script/mojopaste prefork -l http://*:8080` |
| Ports | 8080 (container). The draft's 3000 is wrong for the container; the README maps host 3000 to container 8080. Source: https://raw.githubusercontent.com/jhthorsen/app-mojopaste/246642c/README.md |
| Env vars (upstream Dockerfile) | `MOJO_MODE=production`, `PASTE_DIR=/app/data`, `PASTE_ENABLE_CHARTS=1`. `MOJO_CONFIG` optional (README). Whether the app reads `PASTE_ENABLE_CHARTS` is UNVERIFIED. |
| Data path | `PASTE_DIR` = `/app/data` upstream (written by the app). |
| Dependencies (cpanfile) | Mojolicious >= 9.11, Text::CSV >= 1.30; test: Test::More 0.88. |
| User | None set (runs as root). |
| Volume | No `VOLUME` directive. |

## 2. Target layout

- `apps/mojopaste/Dockerfile`
- `apps/mojopaste/docker-bake.hcl`
- `apps/mojopaste/settings.yaml`
- `apps/mojopaste/container-test.yaml`
- `apps/mojopaste/start.sh` (creates `/config/data`, then `exec`s the app)

No `defaults/`, `etc/`, `health/` (the app creates its data on first start). No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

```dockerfile
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454
```

Upstream's `alpine:3.5` is EOL and musl, so it is not reused. Ubuntu gives glibc, a supported Perl, and apt `cpanminus`. Closest siblings: `apps/adguardhome-sync` (ubuntu layout, `VOLUME /config`, `USER apps`) and `apps/budge` (build step on the base, then `COPY --chmod=0755 . /`). There is no Perl sibling (UNVERIFIED: not searched beyond the apps list).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Install Perl and the toolchain (apt names UNVERIFIED for Ubuntu 26.04; the list is a starting point):
   ```dockerfile
   RUN apt-get update && \
       apt-get install -y --no-install-recommends \
         perl cpanminus build-essential libssl-dev && \
       rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
   ```
   Check first which of these the base already has.
3. Fetch the pinned tag, unpack to `/app/mojopaste`:
   ```sh
   curl -fsSL -o /tmp/mojopaste.tar.gz "https://github.com/jhthorsen/app-mojopaste/archive/refs/tags/${VERSION}.tar.gz"
   mkdir -p /app/mojopaste && tar xzf /tmp/mojopaste.tar.gz -C /app/mojopaste --strip-components=1
   ```
4. Install CPAN deps with apt `cpanminus` (not the unpinned `cpanmin.us` script used upstream):
   ```sh
   cpanm -M https://cpan.metacpan.org --notest --installdeps /app/mojopaste
   ```
   Set `PERL_CPANM_HOME=/tmp/.cpanm` and `HOME` so caches stay in `/tmp`. Install `Text::CSV` explicitly if `--installdeps` misses it. Modules are installed to the system Perl, so `/app` needs no writes at runtime.
5. Licence file: once the license is confirmed, ship it to `/usr/share/licenses/mojopaste/LICENSE`.
6. Clean up: `rm -rf /tmp/* /var/lib/apt/lists/*`, `apt-get purge -y build-essential` (UNVERIFIED: do not purge packages the runtime needs).
7. `chown -R apps:apps /app/mojopaste` and `chmod -R 755 /app/mojopaste`.
8. `ENV MOJO_MODE=production PASTE_DIR=/config/data PASTE_ENABLE_CHARTS=1 HOME=/config`.
9. Tail:
   ```dockerfile
   USER apps
   COPY --chmod=0755 . /

   EXPOSE 8080
   VOLUME /config
   CMD ["/start.sh"]
   ```

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "mojopaste"
}

variable "VERSION" {
  // renovate: datasource=github-tags depName=jhthorsen/app-mojopaste versioning=loose
  default = "1.05"
}

variable "LICENSE" {
  // BLOCKED: set to the confirmed upstream license (UNVERIFIED)
  default = "UNVERIFIED"
}

variable "SOURCE" {
  default = "https://github.com/jhthorsen/app-mojopaste"
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

The `UNVERIFIED` license placeholder must be replaced before merge. Validate with `docker buildx bake --print` from `apps/mojopaste/`. The `VERSION` default must equal the Dockerfile `ARG VERSION`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/jhthorsen/app-mojopaste"
ports:
  - port: 8080
    protocol: tcp
    required: false
env:
  - name: MOJO_MODE
    default: "production"
    required: false
  - name: PASTE_DIR
    default: "/config/data"
    required: false
  - name: PASTE_ENABLE_CHARTS
    default: "1"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

Only variables the app reads are listed (`PASTE_ENABLE_CHARTS` UNVERIFIED, see section 10). Dependencies: none.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

PASTE_DIR="${PASTE_DIR:-/config/data}"
mkdir -p "$PASTE_DIR"

cd /app/mojopaste
export MOJO_MODE="${MOJO_MODE:-production}"
exec /usr/bin/perl ./script/mojopaste prefork -l "http://*:8080"
```

- Idempotent: creates `/config/data` only when missing, seeds nothing.
- Never writes under `/app`.
- Binds `*` (all interfaces) for use from other containers.
- `exec` so the server is PID 1 under the handoff.
- The port is hard-coded to 8080 to match the upstream entrypoint and `EXPOSE`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '8080'
filePaths:
- /app/mojopaste/script/mojopaste
- /app/mojopaste/lib
- /usr/share/licenses/mojopaste/LICENSE
```

- The `settings.yaml` port has a `tcp` probe. An `http` probe on `/` is not added until a run shows the status code (UNVERIFIED).
- `timeoutSeconds: 120` is a guess; compare with a sibling Perl or Mojolicious app if one appears.
- No required-env code path; `filePaths` covers the app files.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/app/data` (`PASTE_DIR`, paste files) | `/config/data` (`PASTE_DIR` env, created by `start.sh`) |
| Root-owned build tree | Owned by `apps`, read-only at runtime |
| cpanm cache and build dirs | `/tmp` (`PERL_CPANM_HOME`) |
| `HOME` | `/config` (not written by the app; set for tools) |

Expectations reconciled with the draft: the chart forces UID 0 and `readOnlyRootFilesystem: false`. This image runs as `apps` and must pass `--read-only --tmpfs /tmp`. Not privileged. The chart's `/app/data` PVC becomes `/config`. Existing data must be copied to `/config/data` on migration.

## 10. Risks, caveats and open questions

- Blocker: license UNVERIFIED. Upstream has no license in its API or at the pinned commit. Ask the upstream author or the user before adding the image.
- Upstream is dated: last commit 2022-01-15, last tag 2021-06-16. Low activity; confirm the app still runs on current Mojolicious.
- The upstream Dockerfile uses unpinned `main`. This plan pins a tag (`1.05`); the tag must contain `script/mojopaste` and a `cpanfile` (UNVERIFIED).
- Mojolicious >= 9.11 and Text::CSV >= 1.30 must be available from the Ubuntu 26.04 cpanm mirror; UNVERIFIED.
- arm64: pure Perl, but Text::CSV_XS compile on arm64 is UNVERIFIED (Text::CSV_PP fallback exists in CPAN).
- Upstream Docker Hub image is amd64 only, so there is no upstream arm64 reference.
- Port: draft's 3000 is wrong; 8080 is the container port.
- Not musl; no GPU; not privileged. No blocker beyond the license.

## 11. Build and test steps

```sh
cd apps/mojopaste
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name mojopaste-probe --read-only --tmpfs /tmp \
  -v mojopaste-probe-config:/config mojopaste:1.05
docker logs -f mojopaste-probe
forgetool containers test --image mojopaste:1.05 --config ./apps/mojopaste/container-test.yaml
docker rm -f mojopaste-probe; docker volume rm mojopaste-probe-config
```

Expected readiness signal: Mojo's `Listening at "http://*:8080"` and a `Server started` / `Worker` line in the log (UNVERIFIED wording for this app version). Confirm `/config/data` exists after start and survives a restart. Test from outside the container (`-p 8080:8080`) to prove it is not bound to localhost.

## 12. PR checklist

- Branch `feat/add-mojopaste`, commit and PR title `feat(mojopaste): add new container`, target `main`.
- Do not open the PR until the license is confirmed (section 10).
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections and checkboxes, check only applicable boxes.
- Notes section contains `🤖 This PR is AI generated.`
- Tell the user about the CLA: signed Contributor License Agreement required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows the status.
- Say in the PR what was not tested: arm64 build, the Text::CSV XS path, the Mojolicious version on Ubuntu, and the http probe.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; no assertion weakened.
