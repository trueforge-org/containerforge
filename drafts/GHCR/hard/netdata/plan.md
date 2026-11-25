# netdata — implementation plan
> Source: ./draft.md · Target: apps/netdata/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | v2.13.0, published 2026-11-19 (`https://api.github.com/repos/netdata/netdata/releases/latest`, read via `gh api`). Draft tag matches. |
| Renovate | `datasource=github-releases depName=netdata/netdata versioning=semver` (proposed, following `apps/adguardhome-sync`; the tag has a `v` prefix, so strip it in the Dockerfile where a bare version is needed). UNVERIFIED against a repo-local renovate config. |
| License | GPL-3.0 (`https://api.github.com/repos/netdata/netdata`, `license.spdx_id`). |
| Source URL | https://github.com/netdata/netdata |
| amd64 download | https://github.com/netdata/netdata/releases/download/v2.13.0/netdata-x86_64-latest.gz.run (372620119 bytes) |
| arm64 download | https://github.com/netdata/netdata/releases/download/v2.13.0/netdata-aarch64-latest.gz.run (329906455 bytes) |
| Checksum source | https://github.com/netdata/netdata/releases/download/v2.13.0/sha256sums.txt. Values: x86_64 `bb0be18228b49c9c816b87193a070ed93defdd8e366368899e39cb7d005ca6f7`, aarch64 `956e7c4d4447b98cb7aee126c36ec64a6e0b131af3651ec44425f009933e0d6d`. |
| Other assets | armv6l and armv7l `.gz.run` also exist (not in scope). |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/netdata/netdata/v2.13.0/packaging/docker/Dockerfile. `FROM netdata/builder:v3` and `FROM netdata/base:v3`. ENTRYPOINT `/usr/sbin/run.sh`, no CMD, no USER (runs as root), EXPOSE 19999, HEALTHCHECK `/usr/sbin/health.sh`, no VOLUME. Creates user `netdata` UID/GID 201 but does not switch to it. Writes `/var/lib/netdata`, `/var/cache/netdata` (owned by UID 201), `/var/lib/netdata/cloud.d` (0700). Sets setuid 4755 on several plugins and 4750 with group 201 on `ipmi.plugin`. |
| Env vars (real) | `NETDATA_LISTENER_PORT=19999`, `NETDATA_OFFICIAL_IMAGE`, `NETDATA_EXTRA_DEB_PACKAGES`. Other runtime variables live in `run.sh`, which was not fetched: UNVERIFIED. |
| Ports | 19999/tcp (dashboard and API), confirmed by upstream EXPOSE. |
| Write paths | `/var/lib/netdata`, `/var/cache/netdata`, `/var/log/netdata` (upstream symlinks to stdout/stderr), `/etc/netdata` (upstream stock copy at `/etc/netdata.stock`). |
| Blockers confirmed upstream | Plugins need setuid and host `/proc`, `/sys`, cgroups for full metrics. Upstream image runs as root. |

Draft claims not confirmed here: the chart's hostPath and capability settings (`SYS_PTRACE`, `fsGroup 201`, ClusterRole) come from `charts/stable/netdata` in TrueCharts, which was not fetched. Treat them as the draft's expectations.

## 2. Target layout

- `apps/netdata/Dockerfile`
- `apps/netdata/docker-bake.hcl`
- `apps/netdata/settings.yaml`
- `apps/netdata/container-test.yaml`
- `apps/netdata/start.sh` (seeds `/config` and `exec`s netdata in the foreground)
- `apps/netdata/etc/netdata/` only if a seeded default `netdata.conf` is needed (reason: the config directory must live in `/config`, see section 7). Not needed if the stock config is used unchanged.

No `root/` (never used by agents). No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`.
Reason: the upstream payload is a static self-extracting installer, so no language runtime is needed. Closest sibling: `apps/adguardhome-sync` (prebuilt binary on ubuntu). Do not use the upstream `netdata/base:v3` image: that is a second base, and the protocol wants the ContainerForge base.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Map the arch: `amd64` to `x86_64`, `arm64` to `aarch64`. Fail the build for anything else.
3. Download to `/tmp`, verify the sha256 from `sha256sums.txt` (pinned in the Dockerfile for the pinned version, or fetched from the release and checked against the `VERSION` line), then install.
4. Install mode for the `.gz.run`: UNVERIFIED which non-interactive flags the installer currently accepts at v2.13.0. Check `./netdata-<arch>-latest.gz.run --help` (or the installer's `--accept` and target options) in a build round before writing the install line. Target the install at `/app/netdata` (or `/opt/netdata` then copy to `/app`). The installer must not run in the final stage.
5. Ship the licence and notices to `/usr/share/licenses/netdata/` (GPL-3.0 licence file from the installed tree).
6. `apt-get install` only if a runtime library is missing. Verify each package is not already in the base first (none is known to be needed: UNVERIFIED).
7. `chown -R apps:apps /app/netdata` and `chmod -R 755 /app/netdata`. Setuid plugins cannot be made to work under `USER apps`: see section 9.
8. `ENV HOME=/config NETDATA_LISTENER_PORT=19999`.
9. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 19999
VOLUME /config
```

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "netdata"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=netdata/netdata versioning=semver
  default = "v2.13.0"
}

variable "LICENSE" {
  default = "GPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/netdata/netdata"
}
```

Use the four standard targets and the default group from `apps/adguardhome-sync`. Note: the GitHub API `spdx_id` is `GPL-3.0`; UNVERIFIED whether `GPL-3.0-only` or `-or-later` applies: check the licence headers before setting `LICENSE`. Run `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/netdata/netdata"
ports:
  - port: 19999
    protocol: tcp
    required: true
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

Add only env vars confirmed in `run.sh` once it is read. `NETDATA_LISTENER_PORT` is set by the image and should not be a user setting unless `start.sh` honours it. Dependencies: none.

## 7. start.sh

Plan (to be verified in round 1):
- Create `/config/netdata/{etc,lib,cache,log}` on first start only. Seed `/config/netdata/etc` from the image's stock config only when empty.
- Export `NETDATA_CONFIG_DIR`, `NETDATA_LIB_DIR`, `NETDATA_CACHE_DIR`, `NETDATA_LOG_DIR` only if the installed build honours them: UNVERIFIED, check the `netdata` binary's `-W` options or the stock `netdata.conf` `[directories]` section.
- Caches and scratch go to `/tmp`, never `/config` (protocol rule).
- Bind the dashboard to `0.0.0.0:19999`, per the Servers-listen-on-all-interfaces rule (check `[web] bind to` in the seeded config).
- `exec /app/netdata/usr/sbin/netdata -D -s /config/...` (path to be confirmed) so netdata is PID 1 and signals propagate.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '19999'
http:
- port: '19999'
  path: /api/v1/info
```

The `http` check on `/api/v1/info` (path UNVERIFIED) is kept only if it returns 200 on the first run; match a sibling's `timeoutSeconds`. netdata's startup is slow, so the timeout should be larger than the sibling default. Every test runs with no env vars, which is fine here because there are no required env vars.

## 9. Rootless and read-only-rootfs adaptations

- Upstream runs as root and sets setuid plugins. The ContainerForge rule is `USER apps`, so the plugins that need root (`apps.plugin`, `ebpf`, `cgroups`, `ipmi`) will fail or lose metrics. This is the main blocker.
- Host access: full metrics need host `/proc`, `/sys`, `/dev` and the host PID namespace. Read-only hostPath mounts are the draft's expectation; they are not confirmed here.
- Writes: redirect `/var/lib/netdata`, `/var/cache/netdata`, `/etc/netdata` to `/config` (persist) and `/tmp` (cache). Confirm the directory variables in section 7.
- `--read-only` is possible only if every write path above is redirected. `cloud.d` (0700) must also live in `/config`.
- Draft's security expectations (non-root no, readOnlyRootFilesystem no, extra persistence `/etc/netdata`, `/var/lib/netdata`, `/var/cache/netdata`) are to be reconciled: the draft expects root. The rule says rootless, so a root-requiring app is out of scope unless maintainers accept an exception.

## 10. Risks, caveats and open questions

- BLOCKER (decision needed): netdata cannot run rootless with full metrics. Either accept a documented exception (root, host mounts, SYS_PTRACE) or do not port. Recommendation: do not merge a container that silently loses plugins.
- The `.gz.run` installer flags and install layout are UNVERIFIED (section 4).
- `run.sh` was not fetched, so the real env var list and its start sequence are UNVERIFIED.
- arm64: the aarch64 installer exists, but it is not run on a real arm64 host in this plan: UNVERIFIED runtime.
- The draft says the chart needs a ClusterRole and a Kubernetes fsGroup: these are not container concerns and are ignored here.
- Outbound internet for the optional Netdata Cloud claim is not required for startup; confirm when running.

## 11. Build and test steps

From `apps/netdata/`:

1. `docker buildx bake --print` (must exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. `docker run --rm -d --name netdata-probe --read-only --tmpfs /tmp -v netdata-probe-config:/config ghcr.io/trueforge-org/netdata:v2.13.0` (use the tag from `image-local`), then `docker logs -f netdata-probe`. Expected readiness: a line that the dashboard is listening on 19999 and no `exiting` line. The exact string is UNVERIFIED until the first run.
4. `forgetool containers test --image <image>:<version> --config ./apps/netdata/container-test.yaml`.
5. Clean up: `docker rm -f netdata-probe; docker volume rm netdata-probe-config`.
6. Expected failure on a non-privileged run: plugins report missing host access. Record it, do not weaken the test.

## 12. PR checklist

- Branch `feat/add-netdata`, commit `feat(netdata): add new container`.
- PR template from `.github/PULL_REQUEST_TEMPLATE.md`, with `🤖 This PR is AI generated.` in the Notes section.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it; the `license/cla` check shows the status).
- State what was not tested: arm64 runtime, full host metrics, and the rootless question. Do not tick "Built container locally" unless the build ran.
- Do not open this PR until the root or rootless decision in section 10 is made.
