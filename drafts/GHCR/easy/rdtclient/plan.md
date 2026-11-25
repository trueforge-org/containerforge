# aria2 (rdtclient sidecar) — implementation plan
> Source: ./draft.md · Target: apps/aria2/ (provisional) · Difficulty: easy · Role: sidecar (chart `aria2Image`, `ghcr.io/p3terx/aria2-pro`) · Verified on 2026-11-25

Scope blocker: the draft is inconsistent. Its "Container" and "Role: sidecar" fields describe aria2-pro, but its "Application binary" link is the aria2 Windows zip, and the chart's main app is `ghcr.io/rogerfar/rdtclient:2.0.143`. This plan follows the draft's stated reason (the aria2c daemon via apt) and covers the sidecar only. Decide the target name and whether `rdtclient` (main) gets its own container before implementation. Do not start a build until that is settled.

## 1. Verified upstream facts

| Item | Value | Source |
| --- | --- | --- |
| aria2 upstream version | 1.37.0 (release-1.37.0, published 2023-11-15) | `gh api repos/aria2/aria2/releases/latest` |
| aria2 upstream Linux binary | none: assets are source tarballs, win-32/64 zips and an android zip. The draft's Windows zip link is not usable. | release asset list |
| Ubuntu package | aria2 `1.37.0+debian-4` in `resolute` (universe) | https://packages.ubuntu.com/resolute/aria2 |
| License (aria2) | GPL-2.0 | `gh api repos/aria2/aria2/license` |
| Sidecar image | `ghcr.io/p3terx/aria2-pro:latest@sha256:086d1a37...` (chart pins `latest`) | https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/rdtclient/values.yaml |
| aria2-pro Dockerfile | `FROM p3terx/s6-alpine`, `curl -fsSL git.io/aria2c.sh | bash`, `COPY rootfs /`, `EXPOSE 6800 6888 6888/udp`, `VOLUME /config /downloads` | https://raw.githubusercontent.com/P3TERX/Aria2-Pro-Docker/4ec58da/Dockerfile |
| aria2-pro env | `RCLONE_CONFIG`, `UPDATE_TRACKERS`, `CUSTOM_TRACKER_URL`, `LISTEN_PORT=6888`, `RPC_PORT=6800`, `RPC_SECRET`, `PUID`, `PGID`, `DISK_CACHE`, `IPV6_MODE`, `UMASK_SET`, `SPECIAL_MODE` | same Dockerfile |
| aria2-pro license | MIT | `gh api repos/P3TERX/Aria2-Pro-Docker/license` |
| Ports | 6800 tcp (RPC), 6888 tcp and udp (BitTorrent) | same Dockerfile and chart |
| Chart paths | `config` mounted at `/config` in the aria2 workload; `db` at `/data/db` for the rdtclient main | chart values |
| Upstream `rootfs/` scripts | not fetched; UNVERIFIED how they start aria2 and whether they need s6 | — |
| Checksum source | none for aria2 apt package (apt signing covers it) | — |

UNVERIFIED: the s6 init in `rootfs/` (not fetched). The plan does not copy it.

## 2. Target layout

- `apps/aria2/Dockerfile`
- `apps/aria2/docker-bake.hcl`
- `apps/aria2/settings.yaml`
- `apps/aria2/container-test.yaml`
- `apps/aria2/start.sh`

No `defaults/` unless an aria2 config file is seeded (decide in step 7). No `root/` and no `s6` tree.

## 3. Base image

- `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`
- Why: aria2 is an apt package in `resolute`, so the Ubuntu base is the natural fit.
- Closest sibling: `apps/valkey` (apt package pinned against `VERSION`, `health/` dir, `start.sh`).

## 4. Dockerfile

1. `ARG VERSION`, `ARG PACKAGE_VERSION`. Check `"${PACKAGE_VERSION%%-*}" = "${VERSION}"` as valkey does, so the pinned apt version matches the declared version.
2. `USER root`. `apt-get update && apt-get install -y --no-install-recommends "aria2=${PACKAGE_VERSION}"`, then `apt-get purge -y --auto-remove`, then `rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*`.
3. Make the config dir a `/config` path (not `/app`). Aria2 needs `/config` for session and config, `/downloads` for output.
4. `COPY --chmod=0755 start.sh /start.sh`.
5. `ENV RPC_PORT=6800 LISTEN_PORT=6888 DISK_CACHE=64M UPDATE_TRACKERS=false`. Do not set a default `RPC_SECRET`; read it at runtime.
6. License: copy the GPL-2.0 notice from the package's `/usr/share/doc/aria2/copyright` into `/usr/share/licenses/aria2/` (UNVERIFIED that the path exists in the package).
7. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 6800 6888 6888/udp`, `VOLUME /config`, `CMD ["/start.sh"]`.

Version alignment: `ARG VERSION` must be `1.37.0` and `PACKAGE_VERSION` must be `1.37.0+debian-4`, as pinned in the bake target.

## 5. docker-bake.hcl

- `APP` = `aria2`
- `VERSION`: `// renovate: datasource=github-releases depName=aria2/aria2 versioning=loose` then `default = "1.37.0"` (the tag `release-1.37.0` is not strict semver, so `loose`).
- `PACKAGE_VERSION`: `default = "1.37.0+debian-4"` (renovate note: apt version; to be checked against the ubuntu archive).
- `LICENSE` = `GPL-2.0-only`, `SOURCE` = `https://github.com/aria2/aria2`
- Four standard targets and the default group, as in `apps/adguardhome-sync/docker-bake.hcl`. Pass `PACKAGE_VERSION` through `args` as valkey does.
- Validate: `cd apps/aria2 && docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/aria2/aria2"
ports:
  - port: 6800
    protocol: tcp
    required: true
  - port: 6888
    protocol: tcp
    required: true
  - port: 6888
    protocol: udp
    required: false
env:
  - name: RPC_PORT
    default: "6800"
    required: false
  - name: LISTEN_PORT
    default: "6888"
    required: false
  - name: RPC_SECRET
    default: ""
    required: false
  - name: DISK_CACHE
    default: "64M"
    required: false
  - name: UPDATE_TRACKERS
    default: "false"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

- Only vars `start.sh` reads. Drop `RCLONE_CONFIG`, `PUID`, `PGID`, `IPV6_MODE`, `UMASK_SET`, `SPECIAL_MODE` unless start.sh implements them; the aria2-pro s6 scripts are not ported (UNVERIFIED which of them matter).
- Keep `RPC_SECRET` optional with empty default and warn in the PR that an empty secret leaves RPC open on the network.

## 7. start.sh

- Idempotent: create `/config/aria2.conf` only if missing (seed a minimal file with `rpc-listen-port`, `listen-port`, `enable-rpc=true`, `rpc-listen-all=true`, `dir=/downloads`, `input-file`/`save-session` under `/config`). Never overwrite an existing file.
- Substitute `RPC_PORT`, `LISTEN_PORT`, `DISK_CACHE` at start from env, so a changed env applies on every start.
- Pass the RPC secret on the command line from the env var, not written to a file, so it does not sit in `/config` in plain text. Note the process-list exposure in the PR (per the start-script rule to keep secrets out of files and the process list, decide whether to use `--rpc-secret` or an env var that aria2 reads; aria2 reads the secret only from the flag, so the flag is the only option).
- Bind RPC to `0.0.0.0` (`rpc-listen-all=true`).
- Final line: `exec aria2c --conf-path=/config/aria2.conf`.
- Writes only to `/config` and `/tmp`. Never `/app`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

tcp:
- port: '6800'
- port: '6888'
```

- Every port in `settings.yaml` has a probe. The UDP 6888 listener is not probed with `tcp`; note it in the PR (forgetool UDP check: UNVERIFIED if the schema supports it).
- Test runs with no env vars: the RPC secret is empty and the default config applies. The secret-set path is not covered; state that.
- `timeoutSeconds` from the nearest sibling (`apps/valkey`).

## 9. Rootless and read-only-rootfs adaptations

- Runs as `apps`. Chart runs aria2 as root (`runAsUser: 0`, `readOnlyRootFilesystem: false`): not carried over. The non-root base is the target.
- Ports 6800 and 6888 are above 1024, so no root bind is needed.
- Writable: `/config` (session file, conf), `/downloads` (download target, a volume to be mounted), `/tmp` (scratch and the disk cache dir if set).
- Upstream `UMASK_SET`, `PUID` and `PGID` are dropped (the apps user owns the paths).
- Config for the chart's `db` mount (`/data/db`) belongs to rdtclient, not aria2. Do not create `/data` in this image.

## 10. Risks, caveats and open questions

- Scope blocker (above): decide between aria2 (sidecar) and rdtclient (main). rdtclient main is a .NET app on linuxserver alpine (`ghcr.io/linuxserver/baseimage-alpine:3.20`) and needs its own draft.
- The draft's binary link is wrong (Windows zip). The apt package is the only Linux path found; there is no upstream Linux binary to verify.
- `gh` rate limit prevented a release-date check for aria2 and rdtclient; UNVERIFIED.
- Real-Debrid (rdtclient) needs a premium account; not relevant to the aria2 image itself but blocks any end-to-end test.
- RPC secret in the command line is visible in `ps`; state in the PR.
- Blockers: none for aria2 alone. arm64: apt aria2 exists for amd64 and arm64 on Ubuntu (UNVERIFIED for arm64 in resolute).

## 11. Build and test steps

1. `cd apps/aria2 && docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. `docker run --rm -d --name aria2-probe --read-only --tmpfs /tmp -v aria2-probe-config:/config aria2:<version>`
4. `docker logs -f aria2-probe`: expect an aria2 RPC listening line on 6800 and no fatal error (exact text to confirm on first run; UNVERIFIED).
5. `forgetool containers test --image aria2:<version> --config ./apps/aria2/container-test.yaml`
6. Cleanup: `docker rm -f aria2-probe; docker volume rm aria2-probe-config`

## 12. PR checklist

- Branch: `feat/add-aria2`
- Commit / PR title: `feat(aria2): add new container` (use the final name decided under the scope blocker)
- Notes section: `🤖 This PR is AI generated.`
- CLA: the user must sign at https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- PR template: fill in `.github/PULL_REQUEST_TEMPLATE.md`; tick only what applies.
- State in the PR: the draft's Windows-binary link is not used; scope decision (aria2 vs rdtclient); UNVERIFIED s6 rootfs behavior; RPC secret exposure; arm64 and UDP probe untested.
