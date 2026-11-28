# xmrig — implementation plan
> Source: ./draft.md · Target: apps/xmrig/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Upstream | https://github.com/xmrig/xmrig, docs https://xmrig.com/docs |
| Latest upstream | `v6.27.0` (release dated 23 Nov, `src/version.h` `6.27.0`; tags v6.25.0, v6.26.0, v6.27.0). The chart pins `6.21` |
| Ubuntu package | `xmrig` `6.25.0+dfsg-1` in Ubuntu 26.04 (`resolute`), available on amd64 and arm64 (packages.ubuntu.com). This is two minors behind upstream |
| Version to ship | `6.25.0` via apt, with `PACKAGE_VERSION=6.25.0+dfsg-1`, so the image contains the version it is tagged with (Dockerfile rule). The draft's apt route is confirmed; there is no official Linux arm64 release binary (release assets: `linux-static-x64`, `jammy-x64`, `noble-x64`, `resolute-x64`, macOS, Windows, FreeBSD; `linux-static-arm64`, `linux-arm64` return 404), so apt is the only arm64 route without a source build |
| Alternative | amd64 only: `xmrig-6.27.0-linux-static-x64.tar.gz` with `SHA256SUMS` (`1357440946eff0ee02042473c2da96b0543f88ba4e45d9abde62ec7eb428ccdb` for that file) and `SHA256SUMS.sig`. Not recommended: no arm64 |
| Renovate | Follow `apps/valkey`: the apt version cannot be tracked by a stable datasource, so use the same disabled-renovate NOTE/TODO comment style with `versioning=loose`. UNVERIFIED: whether a working `repology` depName (`ubuntu_26_04/xmrig`) is acceptable (valkey notes repology network issues) |
| License | GPL-3.0 (`LICENSE` is GPLv3). UNVERIFIED: "or later" wording of source headers; Debian's `/usr/share/doc/xmrig/copyright` is the authority for the packaged build. Use `GPL-3.0-or-later` only after checking it |
| Upstream Dockerfile | None. The chart image `cooleye72/xmrig:6.21` has no public Dockerfile (draft). The plan builds from the Ubuntu package, so provenance is the Ubuntu archive, not that image |
| Port | `8080/tcp` only if the HTTP API is enabled. Upstream default config: `http.enabled false`, `host 127.0.0.1`, `port 0`, `restricted true` |
| CLI options (verified in `Config_platform.h`) | `--url`/`-o`, `--user`/`-u`, `--pass`/`-p`, `--userpass`, `--rig-id`, `--tls`, `--tls-fingerprint`, `--keepalive`, `--donate-level`, `--threads`, `--cpu-max-threads-hint`, `--no-huge-pages`, `--http-host`, `--http-port`, `--http-access-token`, `--http-no-restricted`, `--config`, `--no-color`, `--print-time`, `--user-agent` |
| Config | `config.json` (`autosave true` in the sample, so xmrig may write the config back to the path it loaded). `randomx.rdmsr/wrmsr true` need root and are skipped as non-root |
| Env vars | Upstream reads none. Wrapper variables defined here (below) |

## 2. Target layout

```
apps/xmrig/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```

No `defaults/` (everything is passed as arguments, and an optional user `config.json` is read from `/config`). No `root/`, no `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`

Why: the package comes from the Ubuntu 26.04 archive that this base tracks. Closest sibling: `apps/valkey` (pinned apt package with `PACKAGE_VERSION`).

## 4. Dockerfile

1. `ARG VERSION`, `ARG PACKAGE_VERSION`, `USER root`.
2. One `RUN` (valkey pattern, adapted for the `+dfsg` suffix):
   ```dockerfile
   RUN test "${PACKAGE_VERSION%%+*}" = "${VERSION}" && \
       apt-get update && \
       apt-get install -y --no-install-recommends "xmrig=${PACKAGE_VERSION}" && \
       apt-get purge -y --auto-remove && \
       rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
   ```
   Runtime libraries (libuv, hwloc, OpenSSL) come in as dependencies. `curl`, `ca-certificates` are in the base.
3. License files: `mkdir -p /usr/share/licenses/xmrig && cp /usr/share/doc/xmrig/copyright /usr/share/licenses/xmrig/` (the package already ships it; keep the copy for the standard path). Verify the path with `dpkg -L xmrig` during the build step.
4. `ENV HOME=/config`.
5. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 8080`, `VOLUME /config`, `WORKDIR /config`.
6. Verify `command -v xmrig` and `xmrig --version` at build time (UNVERIFIED binary path; the Debian package installs `/usr/bin/xmrig`).

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "xmrig" }
variable "VERSION" {
  // NOTE: Ubuntu version is tied to the version of the base image in the Dockerfile
  // renovate disabled for the apt version (see apps/valkey); upstream is at 6.27.0
  default = "6.25.0"
}
variable "PACKAGE_VERSION" { default = "6.25.0+dfsg-1" }
variable "LICENSE" { default = "GPL-3.0-or-later" }   # confirm, see section 1
variable "SOURCE"  { default = "https://github.com/xmrig/xmrig" }
```

`target "image"` passes `VERSION` and `PACKAGE_VERSION` as args. Standard targets as in `apps/valkey/docker-bake.hcl`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

- Schema header, `schema_version: 1`, `upstream_env_url: "https://github.com/xmrig/xmrig"`.
- `ports`: `8080` / `tcp` / `required: false` (HTTP API, read-only "restricted" mode).
- `env` (all `required: false`, defaults equal `start.sh`): `XMRIG_URL` `""` (pool `host:port`), `XMRIG_USER` `""` (wallet), `XMRIG_PASS` `x`, `XMRIG_RIG_ID` `""`, `XMRIG_TLS` `""` (set to enable `--tls`), `XMRIG_DONATE_LEVEL` `1` (UNVERIFIED upstream default; confirm with `xmrig --help`), `XMRIG_THREADS` `""`, `XMRIG_HUGE_PAGES` `true`, `XMRIG_HTTP_PORT` `8080`, `XMRIG_HTTP_ACCESS_TOKEN` `""`, `TZ` `Etc/UTC`.
- `volumes`: `/config` / `required: false` (optional `config.json`).
- `dependencies`: none.

## 7. start.sh

```bash
#!/usr/bin/env bash
args=(--no-color --http-host 0.0.0.0 --http-port "${XMRIG_HTTP_PORT:-8080}"
      --donate-level "${XMRIG_DONATE_LEVEL:-1}")
[ -n "${XMRIG_HTTP_ACCESS_TOKEN:-}" ] && args+=(--http-access-token "$XMRIG_HTTP_ACCESS_TOKEN")
[ "${XMRIG_HUGE_PAGES:-true}" = "false" ] && args+=(--no-huge-pages)
[ -n "${XMRIG_THREADS:-}" ] && args+=(--threads "$XMRIG_THREADS")
[ -n "${XMRIG_RIG_ID:-}" ] && args+=(--rig-id "$XMRIG_RIG_ID")
[ -n "${XMRIG_TLS:-}" ] && args+=(--tls)
if [ -s /config/config.json ]; then
  args+=(--config /config/config.json)
else
  # Without a pool xmrig exits. Use a closed local port so the container idles and
  # logs connection errors until XMRIG_URL / XMRIG_USER are set. Never mines.
  args+=(--url "${XMRIG_URL:-127.0.0.1:1}")
  [ -n "${XMRIG_USER:-}" ] && args+=(--user "$XMRIG_USER")
  args+=(--pass "${XMRIG_PASS:-x}")
  [ -n "${XMRIG_URL:-}" ] || echo "WARNING: XMRIG_URL not set; xmrig is idling against a closed port" >&2
fi
exec xmrig "${args[@]}"
```

- Wallet and password appear in the process list; upstream accepts only CLI or config for these. To keep them out of `ps`, write a `/tmp/xmrig.json` (umask 077) from env and pass `--config /tmp/xmrig.json` instead (preferred; UNVERIFIED config key names, take them from the upstream `config.json` sample: `pools[].url/user/pass/rig-id/tls`, `http.*`, `donate-level`). Implement this variant if the run step confirms the keys.
- Nothing is written to `/app`; `/config/config.json` is only read (if `autosave` tries to write it, the dir is writable). No seeding is needed.
- The HTTP API binds `0.0.0.0` in restricted (read-only) mode, so the declared port is testable. Document that the API leaks hash rate and pool; set a token for exposure.
- UNVERIFIED: xmrig's behaviour with an unreachable pool (assumed to retry forever and keep the API up) and that `--donate-level 1` equals the upstream default. Both are checked in step 11.
- Final command `exec xmrig ...`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 60
tcp:
- port: '8080'
filePaths:
- /usr/bin/xmrig
- /usr/share/licenses/xmrig/copyright
```

Runs with no env, so it covers the idle-pool path only; the real pool path (credentials) cannot be tested without a pool and is excluded on purpose (it would mine). An `http` probe on `/2/summary` could be added if confirmed with the restricted API (UNVERIFIED path).

## 9. Rootless and read-only-rootfs adaptations

| Upstream behaviour | Remap |
| --- | --- |
| Chart runs as UID 0, rootfs writable | `USER apps` (568), read-only rootfs, `/tmp` tmpfs |
| MSR tweaks (`rdmsr`/`wrmsr`) and 1GB huge pages need root/privileged | Not available; xmrig logs a warning and continues at lower hash rate. No privileged mode is planned |
| `autosave` writes `config.json` | Only relevant if a user mounts one in `/config` (writable) |
| HTTP API default off, localhost | Enabled on `0.0.0.0:8080`, restricted |
| Extra persistence | None beyond `/config` (matches draft) |

## 10. Risks, caveats and open questions

- Policy: this is a cryptominer. The draft requires a project-policy review before acceptance; the plan must not be implemented without maintainer sign-off. This is a blocker, not a technicality.
- Version lag: the Ubuntu package (6.25.0) is behind upstream (6.27.0, released today) and security fixes may take time to arrive. The chart's 6.21 is older still.
- Provenance of the chart's `cooleye72/xmrig` image remains unknown; this plan replaces it with the distro package.
- Without huge pages, MSR access and a privileged container, hash rate is far below upstream benchmarks.
- Pool address and wallet are mandatory for useful work; the idle fallback is a design choice that needs maintainer agreement (alternative: exit with an error, which makes the container test fail).
- The apt pin breaks when the archive moves to a new `+dfsg-N`; there is no automated bump.
- License variant UNVERIFIED.

## 11. Build and test steps

```sh
cd apps/xmrig
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name xmrig-probe --read-only --tmpfs /tmp -v xmrig-probe-config:/config xmrig:6.25.0
docker logs -f xmrig-probe   # expect the xmrig banner, "ABOUT"/"CPU" lines and pool connect errors against 127.0.0.1:1; the process must stay up
docker exec xmrig-probe sh -c 'xmrig --version'
docker rm -f xmrig-probe; docker volume rm xmrig-probe-config
forgetool containers test --image xmrig:6.25.0 --config ./apps/xmrig/container-test.yaml
```

Do not point the test at a real pool or wallet.

## 12. PR checklist

- Branch `feat/add-xmrig`, commit and title `feat(xmrig): add new container`, target `main`. Do not open until the policy question is answered.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`; put `🤖 This PR is AI generated.` in Notes.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Untested until implemented: apt package name and install path on 26.04 for both arches, idle-pool behaviour, HTTP API probe, donate-level default.
- Do not tick "Built container locally" unless it was built.

## Fix attempt (2026-11-28)

Files written (Dockerfile, docker-bake.hcl, settings.yaml, container-test.yaml, start.sh) on the user's authorisation to skip the policy sign-off for drafts. Verified: Ubuntu resolute package ships `/usr/bin/xmrig` and `/usr/share/doc/xmrig/copyright` (packages.ubuntu.com filelist); source headers say GPLv3 "or any later version" so `GPL-3.0-or-later`; donate-level default is 1. Base image digest taken from the repo (`f01a4295...`) instead of the older digest in this plan. start.sh writes pool credentials to `/tmp/xmrig.json` (umask 077) so they stay out of `ps`. Still UNVERIFIED (needs a build): the `config.json` key names in start.sh against the upstream sample, idle behaviour against `127.0.0.1:1` keeping the API up on 8080, `+dfsg-1` still current, and the maintainer policy decision.
