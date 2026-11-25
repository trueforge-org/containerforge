# smtp-relay — implementation plan
> Source: ./draft.md · Target: apps/smtp-relay/ · Difficulty: medium (effectively hard for read-only, see section 9) · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Chart image | `ghcr.io/ix-ai/smtp:v0.7.7@sha256:4f5f64a386ef8e024b60a45f9cac171f6229dd65eaad1d772337a1db64ba7f3d` (https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/smtp-relay/values.yaml) |
| Upstream status | **Archived and deprecated.** ix-ai/smtp README says the project is archived and moved to `gitlab.com/egos-tech/smtp`, image `1.0.0` (https://raw.githubusercontent.com/ix-ai/smtp/v0.7.7/README.md). Tag `v0.7.7` exists (commit `a58d21a2dc49c5ee7fbd6c32e718aa2a0536a090`). Latest GitHub release is `v0.5.2` (2023-10-16), no assets. |
| Version we package | The wrapper is not versioned upstream, so we version by the packaged software: Exim from Ubuntu 26.04 apt, `exim4-daemon-light 4.99.1-1ubuntu1.5` (https://packages.ubuntu.com/resolute/exim4-daemon-light). Debian stable has 4.98.2-1+deb13u5 (https://packages.debian.org/stable/exim4-daemon-light), not used because the base is Ubuntu. Latest upstream Exim source is 4.100.1 (https://ftp.exim.org/pub/exim/exim4/), not used because we install the distro package. |
| Renovate | Candidate `// renovate: datasource=deb depName=exim4-daemon-light` with a registry URL for Ubuntu resolute. UNVERIFIED: that Renovate's `deb` datasource accepts the Ubuntu archive for this repo. If it does not, use `datasource=repology` or keep the bump manual and say so in the PR. |
| License | Exim is GPL-2.0-or-later (Debian copyright). UNVERIFIED: not read from exim.org or the package copyright file in this run. Upstream ix-ai/smtp is MIT (GitHub API, spdx `MIT`). |
| Source URL | https://github.com/Exim/exim (draft) and https://www.exim.org/ (upstream docs) |
| Download | apt only (`exim4-daemon-light`), no release binary. arm64 apt package exists for the same release (UNVERIFIED for this exact build, standard Ubuntu arch package). |
| Checksum source | apt signature chain (Ubuntu archive `InRelease`), not a per-file checksum. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/ix-ai/smtp/v0.7.7/Dockerfile: `FROM public.ecr.aws/docker/library/debian:stable-slim@sha256:00a24d7c50ebe46934e31f6154c0434e2ab51259a65e028be42413c636385f7f`; ARG PORT=25, BIND_IP=0.0.0.0, BIND_IP6=::0; apt installs ca-certificates, exim4-daemon-light, iproute2 with `--no-install-recommends`; `ENV PORT BIND_IP BIND_IP6`; `EXPOSE ${PORT}`; copies `entrypoint.sh`, `set-exim4-update-conf`, `update-exim4.conf.debug` to `/bin/`; `ENTRYPOINT ["/bin/entrypoint.sh"]`; `CMD ["exim", "-bd", "-q15m", "-v"]`. No `USER` line, so it runs as root. |
| Upstream entrypoint reviewed | https://raw.githubusercontent.com/ix-ai/smtp/v0.7.7/entrypoint.sh: writes `/etc/exim4/exim4.conf.localmacros`, `/etc/mailname`, `/etc/exim4/exim.key`, `exim.crt` (chgrp Debian-exim), `/etc/exim4/dkim.key`, `/etc/exim4/passwd.client`; rewrites `/etc/exim4/exim4.conf.template` when `SMTPPORTOUT` is set; reads `ip addr show dev ${NET_DEV:-eth0}` for relay networks; then `exec /bin/set-exim4-update-conf "${opts[@]}"` and `exec "$@"`. |
| Env vars (real) | From the upstream README and entrypoint: `PORT` (25), `BIND_IP` (0.0.0.0), `BIND_IP6` (::0), `DISABLE_IPV6` (any value), `RELAY_NETWORKS` (must start with `:`), `RELAY_DOMAINS`, `MAILNAME`, `OTHER_HOSTNAMES`, `NET_DEV` (eth0), `SMTPPORTOUT` (25), `KEY_PATH`, `CERTIFICATE_PATH`, `DKIM_KEY_PATH`, `DKIM_SELECTOR` (dkim), `USE_SPLIT_CONFIG` (false), `GMAIL_USER`, `GMAIL_PASSWORD`, `SES_USER`, `SES_PASSWORD`, `SES_REGION` (us-east-1), `SES_PORT` (587), `SMARTHOST_ADDRESS`, `SMARTHOST_PORT` (25), `SMARTHOST_USER`, `SMARTHOST_PASSWORD`, `SMARTHOST_ALIASES`. The `*_FILE` variants exist for GMAIL_*, SES_*, SMARTHOST_* (`file_env`). Source: https://raw.githubusercontent.com/ix-ai/smtp/v0.7.7/README.md and entrypoint.sh. |
| Ports | 25/tcp SMTP (chart service port 25, tcp probes on main). |
| Chart env | `PORT=25`, `RELAY_NETWORKS=172.16.0.0/16`, `DISABLE_IPV6=true`, smarthost values from secret `env-secrets` (values.yaml). |
| Chart security | `runAsNonRoot: false`, `readOnlyRootFilesystem: false`, `runAsUser: 0`, `runAsGroup: 0` (values.yaml). |

## 2. Target layout

- `apps/smtp-relay/Dockerfile`
- `apps/smtp-relay/docker-bake.hcl`
- `apps/smtp-relay/settings.yaml`
- `apps/smtp-relay/container-test.yaml`
- `apps/smtp-relay/start.sh` (replaces the upstream entrypoint, which needs root and writes to `/etc`)
- `apps/smtp-relay/etc/exim4/` with the Exim config template and `set-exim4-update-conf` copied from the upstream repo, only if the template is still needed (see section 4 step 5). Reason: the Debian `update-exim4.conf` flow reads `/etc/exim4`. Upstream copies must keep their license header (GPL/MIT, to be checked).
- No `root/`, no `DOWNSTREAM_CHANGES.md` (not a FROM base).
- `defaults/` only if a default config must be seeded into `/config` (see section 7).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. The draft's Debian base is replaced because the Exim package and the other ContainerForge apps are Ubuntu based. Closest sibling for a single apt daemon with config under `/etc`: `apps/valkey` (pinned apt version and `health/` dir). Most apps in `apps/` use this base (91 Dockerfiles).

## 4. Dockerfile

1. `ARG VERSION` (Exim package version, `4.99.1`), `ARG TARGETARCH`, `USER root`.
2. `apt-get update && apt-get install -y --no-install-recommends exim4-daemon-light=4.99.1-1ubuntu1.5 ca-certificates`. Pin the package and verify the pin matches the `VERSION` default in `docker-bake.hcl` before the build (repository rule). Check first whether `ca-certificates` and `iproute2` (used by the entrypoint `ip addr` call) are already in the base, and install `iproute2` only if missing. Re-verify the pin at build time, because Ubuntu security updates change the `-1ubuntu1.N` suffix.
3. Remove the apt lists and caches (`/var/lib/apt/lists/*`, `/var/cache/*`, `/tmp/*`) in the same `RUN`.
4. Do not install `exim4-config` by hand unless the `exim4-daemon-light` dependency does not bring it in. UNVERIFIED: whether `exim4-daemon-light` pulls the Debian config package. Check with `apt-cache depends` in the build stage.
5. Exim config. The runtime `/etc` is read-only for `apps`, so the config must be generated at build time or read from a path under `/config` or `/tmp` that start.sh writes. Preferred: generate the static base config at build time (`update-exim4.conf` with defaults, run as root), and in `start.sh` apply env-driven macros by passing them to exim with `-D` on the command line or by writing `/tmp/smtp-relay/exim4.conf.localmacros` and passing `-C` to exim. Exact mechanism to prove in a PoC (section 9).
6. `COPY --chmod=0755 . /` is the final copy (not the one in step 7). Put the upstream helper scripts in `etc/` (allowed by `include/.dockerignore`), not in `root/`.
7. `ENV PORT=2525 BIND_IP=0.0.0.0 BIND_IP6=::0 HOME=/config` (non-privileged port, see section 9).
8. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 2525
VOLUME /config
```

The final stage must end with `USER apps`. UID is the image default.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" { default = "smtp-relay" }

variable "VERSION" {
  // renovate: datasource=deb depName=exim4-daemon-light versioning=deb   (UNVERIFIED: datasource and registryUrls, see section 1)
  default = "4.99.1"
}

variable "LICENSE" { default = "GPL-2.0-or-later" }   // UNVERIFIED: confirm against the Exim copyright file before commit
variable "SOURCE" { default = "https://github.com/Exim/exim" }

group "default" { targets = ["image-local"] }
```

Then the four standard targets (`image`, `image-local`, `image-all`) copied from `apps/adguardhome-sync/docker-bake.hcl`. Validate with `docker buildx bake --print` in `apps/smtp-relay`. The image tag then carries Exim `4.99.1`, not the chart's `v0.7.7`. This is a deliberate difference from the chart tag and must be stated in the PR.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/Exim/exim"
ports:
  - port: 2525
    protocol: tcp
    required: false
env:
  - name: PORT
    default: "2525"
    required: false
  - name: BIND_IP
    default: "0.0.0.0"
    required: false
  - name: DISABLE_IPV6
    default: "true"
    required: false
  - name: RELAY_NETWORKS
    default: ""
    required: false
  - name: RELAY_DOMAINS
    default: ""
    required: false
  - name: MAILNAME
    default: ""
    required: false
  - name: OTHER_HOSTNAMES
    default: ""
    required: false
  - name: SMARTHOST_ADDRESS
    default: ""
    required: false
  - name: SMARTHOST_PORT
    default: "587"
    required: false
  - name: SMARTHOST_USER
    default: ""
    required: false
  - name: SMARTHOST_PASSWORD
    default: ""
    required: false
  - name: SMARTHOST_ALIASES
    default: ""
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

Dependencies: none. Only variables that `start.sh` actually reads are listed. The Gmail, SES, DKIM and TLS variables are upstream features that are not yet wired in. Add them only after the PoC in section 9 works for them, and do not list them until then. Port 2525 is a deliberate change from the upstream default of 25 (section 9).

## 7. start.sh

Requirements, in order:

1. `set -eu`. Create persistent directories under `/config` only when missing: `/config/spool` (Exim spool, mail queue must survive restarts), `/config/log` (Exim log). Never create or write anything under `/app` (there is none for this app) or `/etc`.
2. Ephemeral runtime files under `/tmp/smtp-relay/` (pid file, generated `exim4.conf.localmacros`, `passwd.client`, `/tmp/smtp-relay/mailname`), regenerated on every start. Passwords go into `passwd.client` in `/tmp` (mode 0600) and are never printed.
3. Build the macro set from env vars the same way the upstream entrypoint does, using the variable names in section 6 only. Keep the `*_FILE` behaviour only if the `*_FILE` variables are listed in settings.yaml.
4. Compute relay networks from `ip -o -4 addr show dev "${NET_DEV:-eth0}"` plus `${RELAY_NETWORKS}`, as upstream does.
5. Run `exec exim -C <config> -bd -q15m -v` (upstream CMD) so the daemon is PID 1 handoff, and the config path points at the generated file under `/tmp`.
6. Empty `/config`: first start creates `/config/spool` and `/config/log`, and nothing else is seeded. Restart: nothing is overwritten.
7. Listen on `${BIND_IP}:${PORT}` and `[${BIND_IP6}]:${PORT}` (all interfaces), so other containers can reach it (repo rule).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 60
tcp:
- port: '2525'
filePaths:
- /usr/sbin/exim4
- /usr/share/licenses/smtp-relay/LICENSE
```

- The test runs with no env vars, so the default (no relay) path starts. Code paths that need `SMARTHOST_*` or `RELAY_DOMAINS` are not covered by the test. Add their generated config as `filePaths` only if the start script writes files for them (section 4 step 5). Run the smarthost path by hand per the protocol.
- Optional smoke assertion with a real protocol exchange (for example an `smtp` banner check on 2525) is not in the forgetool schema. Do not invent a check the schema does not accept. The tcp probe is the minimum required.
- Exim `/usr/sbin/exim4` is the Debian path. UNVERIFIED: exact binary path (`dpkg -L exim4-daemon-light`) on the built image; fix the path before commit.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write or privilege | Remap or decision |
| --- | --- |
| Runs as root (no `USER`), chart `runAsUser 0` | Run as `apps`. Exim must not need root for the daemon. Port 25 needs root (privileged port), so the default port is 2525 and `25` is mapped by the user (`-p 25:2525`). Blocker check: confirm that Debian `exim4` runs as a non-root `exim_user` with `-C` and that its listen socket on 2525 works. UNVERIFIED, must be proven with a PoC before any other step. |
| `/etc/exim4/*` (localmacros, key, cert, dkim, passwd.client, template) | Generated at build time, or written to `/tmp/smtp-relay/` and selected with `-C`. Not writable at runtime. |
| `/etc/mailname` | `/tmp/smtp-relay/mailname`, or the `primary_hostname` macro (UNVERIFIED which the Debian template honours). |
| Spool `/var/spool/exim4` (default) | `/config/spool` (persistent queue). Set through the spool macro or the `-C` config. UNVERIFIED macro name in the Debian template. |
| Log `/var/log/exim4` (default) | `/config/log`. Same caveat. |
| pid and socket (`/run/exim4`) | `/tmp/smtp-relay/run`. |
| `ip addr` for relay networks | `ip` is needed at runtime (iproute2). Confirm it is in the base. |
| Chart `readOnlyRootFilesystem: false`, `privileged` not set | Image target: `--read-only --tmpfs /tmp`, so the rootfs must be read-only compatible. Not privileged. |
| Chart extra persistence | None. |

If the PoC shows that Exim cannot run as a non-root user with the required paths, stop and report a blocker. Do not run as root to pass the protocol.

## 10. Risks, caveats and open questions

- Upstream is archived. Its successor is `gitlab.com/egos-tech/smtp`. This plan packages Debian Exim directly and does not depend on the archived project. The chart's `v0.7.7` tag is not reused.
- Port 25 cannot be bound by a non-root user. Hosts and ISPs often block outbound port 25, so relaying to the internet may fail. Those are host-side issues, not app bugs (draft caveat, confirmed in the upstream entrypoint's `SMTPPORTOUT` use).
- Relay networks: a wrong `RELAY_NETWORKS` makes the server an open relay. The default must be empty (no relay) and the README warns about it. Do not set a default network range.
- Upstream smarthost credentials go to a file in `/tmp`, which is ephemeral. Users must supply them as env vars on every start (chart secret does the same).
- Exim version pin: the apt suffix changes with Ubuntu security updates, so a pinned package may disappear from the archive. Renovate must bump both the pin and `VERSION`.
- Draft caveat "spool and log dirs moved to /tmp or /config": confirmed as necessary. This plan uses `/config` for spool and log so a mail queue survives restarts.
- Untested: the whole build, the non-root Exim daemon, every env var path (smarthost, relay networks), arm64, the apt pin on the current archive.
- Blockers: root-only daemon (section 9, must be proven), and no verified Renovate datasource for the apt pin.

## 11. Build and test steps

```sh
cd apps/smtp-relay
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name smtp-relay-probe --read-only --tmpfs /tmp \
  -v smtp-relay-probe-config:/config smtp-relay:4.99.1
docker logs -f smtp-relay-probe
forgetool containers test --image smtp-relay:4.99.1 --config ./apps/smtp-relay/container-test.yaml
docker rm -f smtp-relay-probe; docker volume rm smtp-relay-probe-config
```

- Readiness signal: Exim logs `Exim version 4.99.1` and `daemon started` (or the listen line on port 2525), and the process stays up after the startup window.
- Confirm `/config/spool` and `/config/log` exist after the first start, and that a restart keeps them.
- Run `printf 'EHLO test\r\nQUIT\r\n' | nc 127.0.0.1 2525` inside the container, or from another container on the same network, to confirm an SMTP 250/221 response. Test with `-p 2525:2525` from the host to prove it is not bound to localhost only.
- Test the smarthost path by hand with `SMARTHOST_ADDRESS` pointing at a local test SMTP server.

## 12. PR checklist

- Branch `feat/add-smtp-relay`, commit `feat(smtp-relay): add new container`, PR title the same, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only applicable boxes.
- Notes section contains `🤖 This PR is AI generated.`
- CLA: the PR needs a signed Contributor License Agreement (https://cla-assistant.io/trueforge-org/containerforge). Tell the user. Only the user can sign it, and the `license/cla` check shows the status.
- Say in the PR that the chart image (`ghcr.io/ix-ai/smtp`) is archived upstream and that this container uses Debian Exim from apt instead.
- Untested to state honestly if not run: the full build, the non-root daemon PoC, the smarthost path, arm64, and the Renovate datasource.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION` and the apt pin.
