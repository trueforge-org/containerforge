# dashdot — implementation plan
> Source: ./draft.md · Target: apps/dashdot/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | **v6.3.4** (published 2026-03-03, not prerelease). Source: `gh api repos/MauriceNino/dashdot/releases/latest`. The draft's chart image `ghcr.io/mauricenino/dashdot:6.3.4` matches. |
| Renovate | `datasource=github-releases depName=MauriceNino/dashdot versioning=semver` (tag `v6.3.4`; renovate strips the `v`) |
| License | **MIT** (`package.json` `"license": "MIT"` at tag v6.3.4). Source: https://raw.githubusercontent.com/MauriceNino/dashdot/v6.3.4/package.json |
| Source URL | https://github.com/MauriceNino/dashdot |
| Download | Source archive https://github.com/MauriceNino/dashdot/archive/refs/tags/v6.3.4.tar.gz. The release has no binary assets. Node app, so the same archive serves amd64 and arm64. |
| Checksum source | **UNVERIFIED**: no checksum asset on the release, and GitHub returns no digest for the archive. We compute the sha256 of the archive ourselves and pin it, or pin the git commit. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/MauriceNino/dashdot/24cc5d61e10f5255a44f85b5b35d333a3b9bc6d8/docker/Dockerfile. Base `node:20-alpine` (musl). Stages: base, dev, build, prod. Build runs `yarn --immutable`, `yarn build:prod`, `node scripts/strip_package_json.js`. Prod copies `apps/server/dist`, `apps/view/dist`, `apps/cli/dist`, `dist/package.json`, `.yarn/releases`, `.yarnrc.yml`, then `RUN yarn`, `EXPOSE 3001`, `CMD ["node", "server/dist/index.cjs"]`. |
| Runtime packages (upstream, apk) | `lsblk`, `mdadm`, `dmidecode`, `coreutils`, `util-linux`, `lm-sensors`, `speedtest-cli`. Ookla speedtest CLI 1.1.1 from https://install.speedtest.net/app/cli/ookla-speedtest-1.1.1-linux-x86_64.tgz (amd64) and `-linux-aarch64.tgz` (arm64). arm64 and arm/v7 also add `raspberrypi`. Ookla binary checksums: **UNVERIFIED**. |
| Env vars (real, read from `apps/server/src/config.ts` at tag v6.3.4) | All use the `DASHDOT_` prefix. `DASHDOT_PORT` (default 3001), `DASHDOT_ROUTING_PATH` (default `/`), `DASHDOT_RUNNING_IN_DOCKER` (`true` to enable), `DASHDOT_ACCEPT_OOKLA_EULA` (`true` required for speed test), `DASHDOT_SPEED_TEST_FROM_PATH`, `DASHDOT_SPEED_TEST_INTERVAL`, `DASHDOT_SPEED_TEST_INTERVAL_CRON`, `DASHDOT_USE_NETWORK_INTERFACE`, `DASHDOT_FS_DEVICE_FILTER`, `DASHDOT_FS_TYPE_FILTER` (default `cifs,9p,fuse.rclone,fuse.mergerfs,nfs4,iso9660,fuse.shfs,autofs`), `DASHDOT_FS_VIRTUAL_MOUNTS`, `DASHDOT_SHOW_HOST`, `DASHDOT_CUSTOM_HOST`, `DASHDOT_DISABLE_INTEGRATIONS`, `DASHDOT_DISABLE_BACKGROUND_STATS_COLLECTION`, `DASHDOT_ALWAYS_SHOW_PERCENTAGES`, `DASHDOT_USE_IMPERIAL`, plus `*_POLL_INTERVAL`, `*_LABEL_LIST`, `*_WIDGET_*`, `OVERRIDE_*`. Docs (server options): https://raw.githubusercontent.com/MauriceNino/dashdot/v6.3.4/apps/docs/content/docs/configuration/server.mdx. |
| Ports | `DASHDOT_PORT` default **3001**, `EXPOSE 3001` upstream. Source: config.ts and the Dockerfile. |
| Data and write paths | No persistent data is documented. Reads host `/proc`, `/sys` and disks. Write paths in the app: **UNVERIFIED**. |
| Dependencies | None. |

## 2. Target layout

- `apps/dashdot/Dockerfile`
- `apps/dashdot/docker-bake.hcl`
- `apps/dashdot/settings.yaml`
- `apps/dashdot/container-test.yaml`
- `apps/dashdot/start.sh`
- `DOWNSTREAM_CHANGES.md`: **not applicable**, not a `FROM` base.
- No `defaults/`, `etc/`, `health/` or `root/` (the app needs no seeded config).

## 3. Base image

Build stage and runtime stage both use `FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5` (brief's current digest).

Reason: the draft's runtime choice. Node.js is needed to build and run dashdot. Closest sibling: `apps/changedetection` (python-node base, Node build, `USER root` for installs, `USER apps` at the end).

Notes:
- The **node version in python-node is UNVERIFIED**. dashdot's upstream build uses `node:20-alpine`, and the Yarn 4 release is vendored in `.yarn/releases`. Check `node --version` and whether `corepack`/`yarn` exists in the base before relying on it. If the base's Node is too old, stop and record it, rather than installing a second Node.
- Do not use `ubuntu` alone: that would need a Node install from apt, which is not pinned. python-node is the draft's choice and already carries Node.

## 4. Dockerfile

1. Build stage on the base, `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Download `https://github.com/MauriceNino/dashdot/archive/refs/tags/v${VERSION}.tar.gz` (the tag is `v6.3.4`; build the URL from `VERSION` without the `v` only once, to match bake), check the pinned sha256 with `sha256sum -c` (computed by us, see section 1), and extract to `/app/dashdot` with `--strip-components=1`.
3. Install Node dependencies and build: `cd /app/dashdot && corepack enable && yarn --immutable && yarn build:prod && node scripts/strip_package_json.js`. Set `COREPACK_HOME=/tmp/corepack`, `YARN_CACHE_FOLDER=/tmp/yarn-cache`, `npm_config_cache=/tmp/npm-cache`. Caches stay in `/tmp`.
4. Write the build version file the same way upstream does, with a `VERSION` value from bake: `echo "{\"version\":\"${VERSION}\",\"buildhash\":\"unknown\"}" > /app/dashdot/version.json` (upstream writes it from build args `BUILDHASH` and `VERSION`; `BUILDHASH` is not known without git, so write `unknown` and state it in the PR).
5. Speed test: download `https://install.speedtest.net/app/cli/ookla-speedtest-1.1.1-linux-${ookla_arch}.tgz` per arch (`x86_64` for amd64, `aarch64` for arm64). Verify its sha256 (computed by us, UNVERIFIED upstream), extract `speedtest` to `/usr/local/bin/speedtest`. Skip this step and set `DASHDOT_ACCEPT_OOKLA_EULA` to `false` if the binary cannot be verified (see section 10).
6. `rm -rf /tmp/* $HOME/.cache $HOME/.npm /var/lib/apt/lists/*`. Keep the built `server/dist`, `view/dist`, `cli/dist`, `package.json`, `.yarn/releases`, `.yarnrc.yml`, `version.json` under `/app/dashdot`. Run the production install `yarn workspaces focus --production` or the upstream `RUN yarn` equivalent in `/app/dashdot` (exact command **UNVERIFIED** for the prod tree).
7. Licence: copy `LICENSE` (MIT) to `/usr/share/licenses/dashdot/LICENSE` (**file content UNVERIFIED** in this batch; `package.json` MIT is confirmed).
8. Tail:

```dockerfile
ENV NODE_ENV=production \
    DASHDOT_RUNNING_IN_DOCKER=true \
    DASHDOT_PORT=3001 \
    HOME=/tmp

USER apps
COPY --chmod=0755 . /

EXPOSE 3001
WORKDIR /app/dashdot
```

`HOME=/tmp` keeps any home-dir writes off `/config`, since the app has no persistent state. No `VOLUME /config` is set (section 6).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "dashdot"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=MauriceNino/dashdot versioning=semver
  default = "6.3.4"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/MauriceNino/dashdot"
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

Validate with `docker buildx bake --print` from `apps/dashdot/`. The `VERSION` default is `6.3.4` (no `v`), matching the image tag in the draft; the Dockerfile adds the `v` for the tarball URL.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/MauriceNino/dashdot"
ports:
  - port: 3001
    protocol: tcp
    required: false
env:
  - name: DASHDOT_PORT
    default: "3001"
    required: false
  - name: DASHDOT_RUNNING_IN_DOCKER
    default: "true"
    required: false
  - name: DASHDOT_ACCEPT_OOKLA_EULA
    default: "false"
    required: false
  - name: DASHDOT_SHOW_HOST
    default: "false"
    required: false
  - name: DASHDOT_ROUTING_PATH
    default: "/"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes: []
```

- Env names are the `DASHDOT_` names the app reads (section 1). A wrong prefix would be silently ignored.
- `volumes: []`: the app has no persistent state, so `/config` is not declared (schema rule applies only when the app persists state). Confirm with the schema validator.
- `dependencies`: none.

## 7. start.sh

```bash
#!/usr/bin/env bash

export DASHDOT_PORT="${DASHDOT_PORT:-3001}"

cd /app/dashdot
exec node server/dist/index.cjs
```

- Idempotent: it writes nothing, so an empty `/config` needs no seeding and there is nothing to create.
- No writes to `/app`. The `version.json` is baked in at build.
- Bind: the server listens on the configured port. Confirm it binds `0.0.0.0` (not localhost) with a probe from another container, since the rules require this (**UNVERIFIED** until tested).
- `exec` hands PID 1 to node so signals reach it.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 120
tcp:
- port: '3001'
http:
- port: '3001'
  path: /
filePaths:
- /app/dashdot/server/dist/index.cjs
- /app/dashdot/view/dist
- /usr/share/licenses/dashdot/LICENSE
```

- Every port in `settings.yaml` (3001) has a `tcp` and an `http` probe.
- Tests run without env vars, so the default-port path is what is tested. The speed test path needs `DASHDOT_ACCEPT_OOKLA_EULA=true` and is not reached by the default test; add it to `filePaths` (the speedtest binary) rather than run it.
- The `http` probe at `/` should return 200 with the dashboard HTML (**UNVERIFIED**; check after first run).

## 9. Rootless and read-only-rootfs adaptations

| Upstream behaviour | ContainerForge adaptation |
| --- | --- |
| Runs as root in the chart (`runAsUser 0`) | Runs as `apps` (`USER apps`). |
| `privileged: true`, `SYS_ADMIN`, `SYS_RAWIO`, hostPath `/` at `/mnt/host`, hostPath `/dev/mem` (draft chart) | **Not carried over.** The server reads `/proc` and `/sys` without privilege. Host disk and hardware detail (`lsblk`, `dmidecode`, `mdadm`) needs host devices and root, so those panels show less or the container's view. This is the main deviation from the chart. |
| Writes under `/app` | None at runtime. |
| `HOME` and caches | `HOME=/tmp`, `YARN_CACHE_FOLDER` and `npm_config_cache` in `/tmp` at build. |
| Read-only root | Compatible: the app writes nothing at runtime. |

Reconcile the draft's security expectations: confidence is high that the chart needs privilege. The ContainerForge plan removes it, so the host-level panels are a stated caveat, not a silent gap. If the user wants full host stats, the image cannot run rootless or read-only, and that is a blocker to report.

## 10. Risks, caveats and open questions

- **Host stats need privilege (decision for the user)**: without `/proc`, `/sys` and host disks, the dashboard reports the container, not the host (draft caveat, confirmed in the server options). Rootless and read-only operation cannot give full host stats, so the user must accept the reduced view or the image is not a good fit.
- **Speed test binary**: the Ookla CLI is a third-party binary with no checksum from upstream. Verify it, or ship with `DASHDOT_ACCEPT_OOKLA_EULA` unset and the speedtest feature off.
- **Node in python-node**: version and yarn availability are UNVERIFIED (section 3).
- **Single-maintainer project**: check upstream pace before release (draft caveat). Last release 2026-03-03.
- **Slow first build**: the Node build runs on the base (draft caveat).

## 11. Build and test steps

From `apps/dashdot/`:

1. `docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. `docker run --rm -d --name dashdot-probe --read-only --tmpfs /tmp -v dashdot-probe-config:/config dashdot:6.3.4`, then `docker logs -f dashdot-probe`. Expected readiness signal: the server's listening line on port 3001 (**UNVERIFIED** text; read it from the first run), process still running, no stack trace.
4. Clean up: `docker rm -f dashdot-probe; docker volume rm dashdot-probe-config`.
5. `forgetool containers test --image dashdot:6.3.4 --config ./apps/dashdot/container-test.yaml`. If forgetool is unavailable, check the same assertions by hand.
6. arm64 only if amd64 fails in an arm64-specific way.

## 12. PR checklist

- Branch: `feat/add-dashdot`
- Commit: `feat(dashdot): add new container`
- PR title: `feat(dashdot): add new container`
- Notes section: `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it.
- Fill in `.github/PULL_REQUEST_TEMPLATE.md`. Do not tick "Built container locally" unless the build and run in section 11 were done.
- Say what is not tested: arm64 (unless run on arm64 hardware), the speed test path, and host-level stats (not possible rootless).
- State the privilege decision (section 9) in the PR, since the chart's privileged setup is not carried over.
