# pocketmine-mp — implementation plan
> Source: ./draft.md · Target: apps/pocketmine-mp/ · Difficulty: medium · Role (main) · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value | Source |
| --- | --- | --- |
| Latest release | 5.44.3, published 2026-07-06 (matches draft tag) | https://api.github.com/repos/pmmp/PocketMine-MP/releases/latest |
| Renovate | UNVERIFIED: no renovate config checked. Planned: `datasource=github-releases depName=pmmp/PocketMine-MP versioning=semver` | — |
| License | LGPL-3.0 (SPDX `LGPL-3.0`). Note: the draft's license field is not set in the draft, so `LICENSE` in bake must be `LGPL-3.0` | https://api.github.com/repos/pmmp/PocketMine-MP/license |
| Source URL | https://github.com/pmmp/PocketMine-MP | draft.md |
| amd64 app download | https://github.com/pmmp/PocketMine-MP/releases/download/5.44.3/PocketMine-MP.phar. The release also has `build_info.json`, `core-permissions.rst`, `start.sh`, `start.ps1`, `start.cmd` | releases API |
| Checksum source | No checksum in asset names. Each release asset carries a sha256 in the GitHub `digest` field of the API response. Verify the phar against that digest | releases API |
| amd64 PHP binary (pmmp PHP 8.4) | UNVERIFIED: the tarball URL was not on any fetched page. Locate it from the PocketMine docs or the php-build-scripts release before writing the Dockerfile | https://doc.pmmp.io/en/rtfd/installation.html (not fetched) |
| arm64 PHP | No binary. Compile PHP 8.4 from source with the upstream `compile.sh -t linux64` path (see upstream Dockerfile) | upstream Dockerfile |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/pmmp/PocketMine-MP/5.44.3/docker/Dockerfile: three stages on `ubuntu:22.04` (build-php, build-pocketmine, final). build-php runs `./compile.sh -t linux64` with `COMPILE_SH_ARGS` default `-f -g -P5`. build-pocketmine needs `ARG GIT_HASH` (fails without it), runs `composer install --classmap-authoritative --no-dev` and builds the phar with `--git`. Final: user `pocketmine` UID/GID 1000, `/data` and `/plugins` owned 1000:1000, `chmod o+x /usr/bin/php`, `USER pocketmine`, `CMD ["start-pocketmine"]` | same |
| Upstream EXPOSE | `19132/tcp`, `19132/udp`, `19133/udp` | same |
| Upstream VOLUME | `/data`, `/plugins` | same |
| Start script | https://raw.githubusercontent.com/pmmp/PocketMine-MP/5.44.3/docker/start.sh: reads `POCKETMINE_PLUGINS` (space-separated, optional `:version`) and `POCKETMINE_ARGS`; downloads plugins to `/plugins/<name>.phar` from `https://poggit.pmmp.io/get/...`; final `exec php PocketMine-MP.phar --no-wizard --enable-ansi --data=/data --plugins=/plugins "${pm_args[@]}"`, run from `/opt/pocketmine` | same |
| Script bug | The download message uses `$VERSION`, which is never set (should be `$PLUGIN_VERSION`). Do not copy the bug | same |
| Env vars | `TERM=xterm` (Dockerfile). `POCKETMINE_PLUGINS`, `POCKETMINE_ARGS` (start.sh) | same |
| Ports | Game port 19132/udp (Bedrock). Upstream also lists 19133/udp and 19132/tcp, UNVERIFIED for this app | same |
| Dependencies | None (no DB) | draft.md |

## 2. Target layout

- `apps/pocketmine-mp/Dockerfile`
- `apps/pocketmine-mp/docker-bake.hcl`
- `apps/pocketmine-mp/settings.yaml`
- `apps/pocketmine-mp/container-test.yaml`
- `apps/pocketmine-mp/start.sh` (replaces upstream `docker/start.sh`, with the same plugin logic and `exec` on the final process)

Not needed: `defaults/` (no seeded config is required; the server creates its data), `etc/`, `health/`, `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`. PHP is not a ContainerForge runtime base, so PHP comes from a build stage (amd64: downloaded binary; arm64: compiled) and is copied into the ubuntu final stage. Upstream builds on ubuntu:22.04; the compiled PHP must run on 26.04 (glibc forward compatibility: UNVERIFIED, test in the probe).

Closest siblings: `apps/bookstack` (PHP stack on ubuntu:26.04, `WORKDIR /config`, `USER apps`) and `apps/valkey` (compiled binary plus `start.sh`).

## 4. Dockerfile

1. `FROM <ubuntu> AS build-php`, `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
   - amd64: download the pmmp PHP 8.4 binary tarball (URL UNVERIFIED, see section 1), verify its checksum if the release publishes one (UNVERIFIED), extract to `/opt/php`.
   - arm64: install build deps (`autoconf bison re2c pkg-config libxml2-dev libssl-dev libcurl4-openssl-dev`, pinned versions checked against the base), then compile PHP 8.4 with the upstream compile script and `-t linux64` (pin the PHP version in an `ARG`, record it in `docker-bake.hcl` as a second renovate-annotated variable). Compile takes a long time (draft caveat).
2. `FROM <ubuntu> AS build-pocketmine`, `ARG VERSION`, `ARG TARGETARCH`, `USER root`:
   - Download `https://github.com/pmmp/PocketMine-MP/releases/download/${VERSION}/PocketMine-MP.phar` (amd64 and arm64 both use the release phar, which is not arch-specific), verify it against the sha256 digest from the release API.
   - Do not build the phar from source: the release asset is the upstream artifact and avoids the composer step. (Alternative: build from source with composer and a `GIT_HASH`; not needed.)
3. Final `FROM <ubuntu>` (same digest), `ARG VERSION`, `ARG TARGETARCH`, `USER root`:
   - `COPY --from=build-php /opt/php /opt/php` and symlink `/usr/local/bin/php` to it (PHP binary is not in the base).
   - `COPY --from=build-pocketmine` the phar to `/opt/pocketmine/PocketMine-MP.phar`.
   - License: copy upstream `LICENSE` (LGPL-3.0) to `/usr/share/licenses/pocketmine-mp/LICENSE`, and the PHP licence files for the PHP binary.
   - `chown -R apps:apps /opt/pocketmine && chmod -R 755 /opt/pocketmine`.
   - Create `/config/data` and `/config/plugins` paths at start, not build time (see start.sh).
   - `ENV TERM=xterm HOME=/config`.
   - `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 19132/udp`, `VOLUME /config`, `WORKDIR /config`.

`apt` packages in the final stage: none beyond the base's (`ca-certificates` and `wget` in base: assumed, UNVERIFIED).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "pocketmine-mp"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=pmmp/PocketMine-MP versioning=semver
  default = "5.44.3"
}

variable "LICENSE" {
  default = "LGPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/pmmp/PocketMine-MP"
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
  platforms = ["linux/amd64", "linux/arm64"]
}
```

Validate with `docker buildx bake --print`. Add a second renovate-annotated variable for the PHP version once the source is confirmed (UNVERIFIED annotation for PHP; datasource to be chosen then). `VERSION` 5.44.3 must equal the Dockerfile `ARG VERSION`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/pmmp/PocketMine-MP"
ports:
  - port: 19132
    protocol: udp
    required: false
env:
  - name: POCKETMINE_ARGS
    default: ""
    required: false
  - name: POCKETMINE_PLUGINS
    default: ""
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

- Port 19132/udp is the Bedrock game port. 19133/udp is upstream-exposed too; list it only if the server listens on it (UNVERIFIED, check the probe log).
- Env vars are the two the upstream start script reads, plus TZ. Defaults empty to match the upstream behaviour (no plugins, no extra args).
- Volumes: `/config` only, with `data/` and `plugins/` under it. The chart uses `/data` and `/plugins`; the draft says `/config`. This plan uses `/config/data` and `/config/plugins` (see section 9).

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config/data /config/plugins

# download plugins listed in POCKETMINE_PLUGINS, only when missing
for entry in ${POCKETMINE_PLUGINS:-}; do
  PLUGIN_NAME="${entry%%:*}"
  PLUGIN_VERSION="${entry#*:}"
  if [ "${PLUGIN_VERSION}" = "${entry}" ]; then PLUGIN_VERSION="latest"; fi
  if [ ! -f "/config/plugins/${PLUGIN_NAME}.phar" ]; then
    echo "Downloading ${PLUGIN_NAME} ${PLUGIN_VERSION}"
    wget -O "/config/plugins/${PLUGIN_NAME}.phar" \
      "https://poggit.pmmp.io/get/${PLUGIN_NAME}/${PLUGIN_VERSION}" || rm -f "/config/plugins/${PLUGIN_NAME}.phar"
  fi
done

read -ra pm_args <<<"${POCKETMINE_ARGS:-}"

cd /config
exec php /opt/pocketmine/PocketMine-MP.phar --no-wizard --enable-ansi \
  --data=/config/data --plugins=/config/plugins "${pm_args[@]}"
```

- Idempotent: plugins are downloaded only when missing; the data dir is created only when missing.
- Fixes the upstream `$VERSION` bug by using `$PLUGIN_VERSION`.
- `--data` and `--plugins` point at `/config` (upstream used `/data` and `/plugins`). This is the required remap for the non-root, `/config`-only layout.
- Never writes to `/opt/pocketmine`. The cwd is `/config`, so any relative writes by PHP go to `/config` (confirm in the probe; if PHP writes to cwd elsewhere, move it to `/tmp`).
- `exec` replaces the shell with PHP for signal handling.
- Bind address: the Bedrock server binds UDP on all interfaces by default (UNVERIFIED, check `server.properties` default and the probe log).
- Start-up `wget` needs network; in an offline probe, plugin download failures are logged, not fatal (the `|| rm -f` line).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
filePaths:
- /opt/pocketmine/PocketMine-MP.phar
- /usr/local/bin/php
- /usr/share/licenses/pocketmine-mp/LICENSE
```

- Coverage gap: the port is UDP. The `tcp` and `http` probes in the forgetool schema do not test UDP. The container-test schema (checked 2026-11-26) has no `udp` key (only `http`, `tcp`, `healthCommands`, `filePaths`, `mainRunner`, `runners`, `readOnlyRootfs`, `mounts`, `timeoutSeconds`), so no UDP probe is possible. State the gap in the PR and note it as a narrowed assertion (comment, per the build-test protocol). Do not drop the check silently.
- `timeoutSeconds` 180 is an estimate; the server start is slow. Compare with a sibling (UNVERIFIED).
- No env vars are needed; plugin download code runs only when `POCKETMINE_PLUGINS` is set, so add `/config/plugins` checks to a separate test or run it manually (container-test instructions).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/data` (world, players, server data, upstream VOLUME) | `--data=/config/data` in start.sh |
| `/plugins` (plugin phars, upstream VOLUME) | `--plugins=/config/plugins` in start.sh |
| Plugin downloads | written to `/config/plugins` only when missing |
| PHP runtime temp and cache | `/tmp` (set `TMPDIR=/tmp`) |
| Working directory | `/config` (cwd), not `/opt/pocketmine` |

Draft security expectations reconciled: the chart runs as root (runAsUser 0), but the upstream image and this plan run as `apps` (UID 568 in ContainerForge; upstream used 1000, which is not used here). The `/data` and `/plugins` paths in the chart differ from `/config` and are a deliberate remap for ContainerForge's `/config` rule. Read-only rootfs is compatible with `--read-only --tmpfs /tmp` once PHP writes go to `/tmp` or `/config`. Not privileged.

## 10. Risks, caveats and open questions

- arm64 PHP compile takes a long time and needs build dependencies; the build may be too slow for CI (draft caveat, confirmed as a risk).
- amd64 PHP binary URL is UNVERIFIED (section 1). Without it, the amd64 path is blocked.
- Upstream base is ubuntu:22.04; this plan uses 26.04. The PHP binary and phar must run on 26.04 (UNVERIFIED, test).
- Bedrock client protocol must match the server version. Keep the server version in step with the client (draft caveat, upstream status UNVERIFIED).
- `start.sh` upstream bug (`$VERSION`): fixed in this plan, record in PR.
- UDP probe gap (section 8).
- Port 19133/udp and 19132/tcp are exposed upstream; only 19132/udp is planned (UNVERIFIED need).
- Blockers: none confirmed. The amd64 PHP tarball source is the first open item to resolve.

## 11. Build and test steps

```sh
cd apps/pocketmine-mp
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name pocketmine-mp-probe --read-only --tmpfs /tmp \
  -v pocketmine-mp-probe-config:/config pocketmine-mp:5.44.3
docker logs -f pocketmine-mp-probe
forgetool containers test --image pocketmine-mp:5.44.3 --config ./apps/pocketmine-mp/container-test.yaml
docker rm -f pocketmine-mp-probe; docker volume rm pocketmine-mp-probe-config
```

Expected readiness signal: PocketMine logs its startup banner and a Bedrock "Server started" / "listening" line on 19132 (exact text UNVERIFIED; take it from the probe run). The process must stay up. Check `/config/data` is created and that the UDP port is open (`ss -lun`). Build arm64 only after amd64 is green; record the compile time in the PR.

## 12. PR checklist

- Branch `feat/add-pocketmine-mp`, commit and PR title `feat(pocketmine-mp): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections and checkboxes, check only what applies.
- Notes section: `🤖 This PR is AI generated.` No "Generated with" or other tool attribution line (AGENTS.md).
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Tell the user; only the user can sign it; the `license/cla` check shows the status.
- State honestly what was not tested: the arm64 PHP compile, the UDP probe gap, the plugin download path, PHP on 26.04, and the Renovate annotation (UNVERIFIED).
