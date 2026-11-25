# openra — implementation plan
> Source: ./draft.md · Target: apps/openra/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `release-20250330`, published 2025-03-30. It is the newest non-prerelease on OpenRA/OpenRA, and no newer release was found. The upstream rmoriz Dockerfile default `OPENRA_RELEASE_VERSION=20231010` is older and is not used. The chart uses `rmoriz/openra:latest`, which is a rolling tag (see section 10). |
| Renovate | `datasource=github-releases depName=OpenRA/OpenRA versioning=loose`. Proposed. Repo convention is `loose` (76 uses). Loose handling of the `release-` tag prefix is UNVERIFIED. Fallback: regex versioning with a capture group for the date (one regex precedent exists in `apps/`, pattern UNVERIFIED). |
| License | `GPL-3.0` (GitHub API `license.spdx_id`). |
| Source URL | https://github.com/OpenRA/OpenRA |
| Download, amd64 | AppImage: https://github.com/OpenRA/OpenRA/releases/download/release-20250330/OpenRA-Red-Alert-x86_64.AppImage (confirmed). The same release also has `OpenRA-Tiberian-Dawn-x86_64.AppImage` and `OpenRA-Dune-2000-x86_64.AppImage`. Which game the chart needs is UNVERIFIED. |
| Download, arm64 | No arm64 binary in the release. Source tarball: https://github.com/OpenRA/OpenRA/releases/download/release-20250330/OpenRA-release-20250330-source.tar.bz2 (confirmed). Must be compiled. |
| Checksum source | None. The release has no `.sha256` file, only `.zsync` files for AppImages. UNVERIFIED for any other source. See section 10. |
| Upstream Dockerfile reviewed | https://github.com/rmoriz/openra-dockerfile/blob/62aa1508bb9c3df1ab41b9e20252880ac6823fcc/Dockerfile. Base `${BASE_IMAGE_PREFIX}mono`, `make all RUNTIME=mono`, user `openra`, installs to `/home/openra/lib/openra`, `EXPOSE 1234`, `VOLUME ["/home/openra/.openra"]`, `CMD launch-dedicated.sh`. |
| Ports | `1234` (upstream `EXPOSE`). Other server ports are UNVERIFIED. |
| Env | No runtime env var is confirmed. Upstream `OPENRA_RELEASE_VERSION`, `OPENRA_RELEASE_TYPE` and `OPENRA_RELEASE` are build-time args only. |
| Data path | Upstream `/home/openra/.openra` (VOLUME; subfolders `Logs` and `maps` are created by the Dockerfile). Linux support-dir resolution for this tag is UNVERIFIED. |
| Runtime libs (upstream apt list) | `liblua5.1`, `libsdl2-2.0-0`, `libopenal1`. Which are needed for a headless server is UNVERIFIED. Ubuntu 26.04 package names are UNVERIFIED. |
| Database | None. |
| Architectures (upstream image) | `rmoriz/openra:latest` is amd64 only, last pushed 2021-03-22 (Docker Hub API). |

## 2. Target layout

- `apps/openra/Dockerfile`
- `apps/openra/docker-bake.hcl`
- `apps/openra/settings.yaml`
- `apps/openra/start.sh`
- `apps/openra/container-test.yaml`

No `defaults/` folder until the server's config file format is verified (UNVERIFIED). No `root/`. No `DOWNSTREAM_CHANGES.md` (this app is not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`, for both the build stage and the final stage.

Fits: the amd64 path only extracts an AppImage (which bundles its own runtime), and the arm64 path compiles the source tarball. Both run on the ubuntu base. The upstream mono base is not reused.

Closest sibling for the prebuilt path: `apps/adguardhome-sync` (prebuilt binary on ubuntu, `USER apps`, `/config`). The source-build path follows the build-stage rule for compiled code (build stage, then copy into the final ubuntu stage).

## 4. Dockerfile

1. Build stage: `FROM <ubuntu> AS build`, `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Build stage, one `RUN` that branches on `TARGETARCH`:

```dockerfile
RUN set -eux; \
  mkdir -p /app/openra /tmp/openra; \
  if [ "$TARGETARCH" = "amd64" ]; then \
    curl -fsSL -o /tmp/openra/OpenRA.AppImage \
      "https://github.com/OpenRA/OpenRA/releases/download/${VERSION}/OpenRA-Red-Alert-x86_64.AppImage"; \
    chmod +x /tmp/openra/OpenRA.AppImage; \
    cd /app/openra && /tmp/openra/OpenRA.AppImage --appimage-extract; \
  else \
    # arm64: compile from source (package names and make target UNVERIFIED)
    apt-get update && apt-get install -y --no-install-recommends <dotnet-sdk package, name and version UNVERIFIED>; \
    curl -fsSL "https://github.com/OpenRA/OpenRA/releases/download/${VERSION}/OpenRA-${VERSION}-source.tar.bz2" \
      | tar -xj -C /tmp/openra --strip-components=1; \
    make -C /tmp/openra ...; \
  fi
```

3. Final stage: `FROM <ubuntu>`, `USER root`, install runtime libs (candidates from upstream: `liblua5.1`, `libsdl2-2.0-0`, `libopenal1`; keep only those a headless server needs, names checked on 26.04), then `rm -rf /var/lib/apt/lists/*`.
4. Copy the built tree from the build stage: `COPY --from=build /app/openra /app/openra`.
5. License: `COPY --from=build` the `COPYING` (or `LICENSE`) file to `/usr/share/licenses/openra/` (file name UNVERIFIED).
6. Permissions: `chown -R root:root /app/openra && chmod -R 755 /app/openra`.
7. Tail:

```dockerfile
ENV HOME=/config
USER apps
COPY --chmod=0755 . /

EXPOSE 1234
VOLUME /config
WORKDIR /app/openra
```

Notes on step 2:

- amd64: `--appimage-extract` avoids FUSE. The extracted tree should contain `launch-dedicated.sh` (location inside `squashfs-root` UNVERIFIED).
- arm64: the .NET SDK package and the make target for `release-20250330` are UNVERIFIED. The draft's claim that no mono is needed is also UNVERIFIED. Read the Makefile and INSTALL at the tag before writing this branch.
- The compiled arm64 tree must match the amd64 layout under `/app/openra`.

The arm64 build stage is only needed when arm64 is in scope (section 10). If it is dropped, the Dockerfile has one stage and `image-all` must be removed from `docker-bake.hcl` (see section 5).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "openra"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=OpenRA/OpenRA versioning=loose
  default = "release-20250330"
}

variable "LICENSE" {
  default = "GPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/OpenRA/OpenRA"
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

Validate with `docker buildx bake --print` from `apps/openra`. Keep `image-all` only once the arm64 build is verified.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/OpenRA/OpenRA"
ports:
  - port: 1234
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

- No app env var is listed. None is confirmed as read at runtime (section 1). Add one only after the server's config is verified.
- `dependencies: []`: the server needs no database and no other ContainerForge app.

## 7. start.sh

```bash
#!/usr/bin/env bash

# upstream data dir, remapped by HOME=/config
mkdir -p /config/.openra/Logs /config/.openra/maps

cd /app/openra
echo "Starting OpenRA dedicated server on port 1234"
exec ./launch-dedicated.sh
```

- Idempotent. Creates only what is missing under `/config`. Nothing is written to `/app/openra`.
- `exec` hands PID 1 to the server, so signals propagate.
- The server must bind to all interfaces (`0.0.0.0`), not `127.0.0.1`. The bind address is UNVERIFIED for this tag. Check with `ss -ltn` inside the container and from outside with `-p 1234:1234`.
- The launcher path and whether it takes arguments (mod choice, for example) are UNVERIFIED. The upstream CMD runs it with no arguments.
- Readiness signal: a server "listening" line (wording UNVERIFIED), plus the TCP probe.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '1234'
filePaths:
- /app/openra
- /usr/share/licenses/openra
```

- The game server speaks its own protocol, so there is no `http` probe.
- `timeoutSeconds: 180` is the common value across siblings (not a sibling-specific value).
- `tcp` runs against the container itself. It does not prove that another container can connect. Use the external curl check in section 11 for that.
- No env vars are needed to start, so no required-env paths exist.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap in this image |
| --- | --- |
| `/home/openra/.openra` (config, Logs, maps, downloads) | `/config/.openra` through `HOME=/config`. Same as the ubuntu base convention. |
| Anything under `/app/openra` at runtime | Not allowed. If the server writes there, the path must be redirected to `/config` (UNVERIFIED; the `--read-only` run in section 11 is the check). |
| Temp files | `/tmp` (tmpfs). |

Draft security expectations reconciled:
- The chart runs as UID 0 and GID 0. This image runs as `apps` (568). The chart values need a change (outside this app).
- The chart's `readOnlyRootFilesystem: false` can become `true`, because the image is designed for `--read-only --tmpfs /tmp`. Verify with the run in section 11.
- Not privileged.
- Extra persistence: none beyond `/config`, which matches the draft.

## 10. Risks, caveats and open questions

- **arm64 needs a source build.** It is the main blocker for `image-all`. The .NET SDK route is the draft's claim and is UNVERIFIED for this tag. The build is slow. Option: ship amd64 only (`image-local`) and record arm64 as not supported.
- **Game content.** Whether the server needs content installed on first run (downloaded assets or a content-install step) is UNVERIFIED. The draft's "fetched on first run" is an inference. If content is needed, the install step belongs in `start.sh` (writing to `/config`) or in the build, and the first start needs internet.
- **Stale release.** `release-20250330` is about 20 months old at 2026-11-25. Newer master commits may exist. Whether the chart should track a tag or a commit is a policy question.
- **Third-party image replaced.** The chart uses `rmoriz/openra:latest`, which is amd64 only, rolling, and last pushed in 2021. Moving to this image changes the version the chart runs. Note it in the PR.
- **No checksum.** The AppImage and source tarball have no published checksum. Options: pin a SHA256 the implementer computes (needs a renovate regex manager for the hash), or record the risk in the PR.
- **AppImage extraction.** Extraction with `--appimage-extract` and the bundled runtime on ubuntu 26.04 is UNVERIFIED. Test it.
- **Blockers.** arm64 build (see above) only. amd64 is not blocked by any finding.

## 11. Build and test steps

```sh
cd apps/openra
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name openra-probe --read-only --tmpfs /tmp \
  -v openra-probe-config:/config openra:release-20250330
docker logs -f openra-probe
forgetool containers test --image openra:release-20250330 --config ./apps/openra/container-test.yaml
docker rm -f openra-probe; docker volume rm openra-probe-config
```

- Expected readiness: the `start.sh` echo line, then the server's listening line (wording UNVERIFIED), and port 1234 open. The container must still be running after the startup window.
- Confirm that `/config/.openra` exists after start and survives a restart.
- Check from outside the container: `docker run -p 1234:1234 ...` and a TCP connect from the host, to confirm the bind is not localhost-only.
- Build arm64 only when the amd64 build is green and arm64 is in scope.
- Round limit: 10 (protocol).

## 12. PR checklist

- Branch `feat/add-openra`, commit and PR title `feat(openra): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, and check only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it. The `license/cla` check shows the status.
- State as untested: arm64 (if not built), first-run content, the `--read-only` run (until done), the external connect check, and the checksum decision.
- `docker buildx bake --print` passes. `VERSION` in `docker-bake.hcl` equals `ARG VERSION` in the Dockerfile.
- No assertion weakened.
