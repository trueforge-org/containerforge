# stun-turn-server — implementation plan
> Source: ./draft.md · Target: apps/stun-turn-server/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Ubuntu archive `coturn` **4.6.1-2build2** in resolute (26.04 LTS), the ContainerForge base. Source: https://packages.ubuntu.com/search?keywords=coturn&searchon=names&suite=all&section=all . Newer archive versions exist only in later suites (stonking 4.18.0-1); not used. |
| Upstream image tag | Draft says the chart uses `ghcr.io/ich777/stun-turn-server:latest`. Upstream coturn releases: latest tag `docker/4.19.2-r0` (2026-11-19), https://github.com/coturn/coturn/releases/tag/docker/4.19.2-r0 . No release assets. |
| Renovate | Upstream source tracking: `datasource=github-releases depName=coturn/coturn` (tags use the `docker/` prefix, versioning UNVERIFIED). Apt pin tracking: `datasource=deb` for the Ubuntu archive is UNVERIFIED; if unavailable, the pin is bumped by hand. |
| License | Coturn LICENSE is BSD-style three-clause (Copyright 2011–2013 Citrix Systems), https://raw.githubusercontent.com/coturn/coturn/master/LICENSE . SPDX `BSD-3-Clause` inferred from the text. GitHub API reports `NOASSERTION`. |
| Source URL | https://github.com/coturn/coturn |
| Download | No download: the binary comes from the Ubuntu archive via `apt-get install coturn=<pin>`. The draft's `copy-from` option is not used (see section 10). |
| Checksum source | Ubuntu archive signatures (apt). No tarball is fetched. |
| Upstream Dockerfile reviewed | https://github.com/ich777/docker-stun-turn-server/blob/master/Dockerfile (WebFetch summary, not a verbatim copy). Base `ich777/debian-baseimage`; apt installs `coturn openssl`; ENV defaults `PORT=5349`, `REALM=example.com`, `STATIC_AUTH=true`, `SECRET` empty, `LISTENING_IP=0.0.0.0`, `EXTERNAL_IP` empty, `CERT_FILE=cert.pem`, `PRIVKEY_FILE=privkey.pem`, `DH_FILE=dhparam.pem`, `DATA_DIR=/stun-turn`, `UID=99`, `GID=100`, `USER=stun-turn`; EXPOSE `5349` tcp and `5349/udp`; no USER instruction (runs as root); `ENTRYPOINT ["/opt/scripts/start.sh"]`. |
| Ports (coturn defaults) | 3478 tcp/udp (STUN/TURN). 5349 tcp/udp (TURN over TLS/DTLS, the port the ich777 image exposes). The relay port range is UNVERIFIED (not on the fetched pages). |
| arm64 | Ubuntu archive ships coturn for arm64. UNVERIFIED for resolute arm64 specifically (archive page not fetched per architecture). |
| Dependencies | None. |

## 2. Target layout

- `apps/stun-turn-server/Dockerfile`
- `apps/stun-turn-server/docker-bake.hcl`
- `apps/stun-turn-server/settings.yaml`
- `apps/stun-turn-server/container-test.yaml`
- `apps/stun-turn-server/start.sh`
- `defaults/turnserver.conf` only if the start script needs a template (reason: seed `/config/turnserver.conf` when missing). Otherwise write the config inline in `start.sh`.

No `etc/`, `health/` or `root/`. No `DOWNSTREAM_CHANGES.md` (not used as a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. The apt package exists for 26.04, so no runtime image is needed. Closest sibling: `apps/valkey` (apt-installed, version pinned against `VERSION`, `USER apps`, `COPY --chmod=0755 . /`). The draft's `apps/adguardhome-sync` is the prebuilt-binary pattern but is not needed here.

## 4. Dockerfile

1. `ARG VERSION`, `ARG PACKAGE_VERSION`, `USER root`.
2. Pin check as in `apps/valkey`: `RUN test "${PACKAGE_VERSION%%-*}" = "${VERSION}"`, so the bake `VERSION` (`4.6.1`) matches the apt pin (`4.6.1-2build2`).
3. `apt-get update && apt-get install -y --no-install-recommends "coturn=${PACKAGE_VERSION}" openssl`, then `apt-get purge -y --auto-remove`, `rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*`. Install `openssl` only when the base does not already provide it (check with `docker run --rm <base> which openssl`); the draft marks it inferred.
4. Licence: `COPY` the coturn LICENSE from the package docs (`/usr/share/doc/coturn/copyright`, which the package ships) into `/usr/share/licenses/stun-turn-server/`. Do this in the RUN step, not by hand.
5. `COPY --chmod=0755 start.sh /start.sh`.
6. `ENV` (no HOME move needed; the app writes only to `/config` and `/tmp`): `TURN_PORT=3478`, `TURN_TLS_PORT=5349`, `TURN_REALM=example.com`, `TURN_LISTEN_IP=0.0.0.0`.
7. `USER apps`, `COPY --chmod=0755 . /`.
8. `EXPOSE 3478/tcp 3478/udp 5349/tcp 5349/udp`, `VOLUME /config`, `CMD ["/start.sh"]`.

Example pin (lines to verify in the build):

```dockerfile
ARG VERSION
ARG PACKAGE_VERSION
USER root
RUN test "${PACKAGE_VERSION%%-*}" = "${VERSION}" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        "coturn=${PACKAGE_VERSION}" openssl && \
    apt-get purge -y --auto-remove && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
```

`PACKAGE_VERSION` needs a matching `args` entry in `docker-bake.hcl` (set to `4.6.1-2build2`).

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "stun-turn-server" }
variable "VERSION" {
  // renovate: datasource=deb depName=coturn versioning=deb
  default = "4.6.1"
}
variable "PACKAGE_VERSION" { default = "4.6.1-2build2" }
variable "LICENSE" { default = "BSD-3-Clause" }
variable "SOURCE" { default = "https://github.com/coturn/coturn" }
```

Renovate `datasource=deb` is UNVERIFIED for the Ubuntu archive; if it does not work, document the manual bump. Four standard targets and the `default` group copied from `apps/adguardhome-sync`; `PACKAGE_VERSION` passed through the `image` target `args`. Validate with `docker buildx bake --print` from `apps/stun-turn-server`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/coturn/coturn"
ports:
  - port: 3478
    protocol: tcp
    required: true
  - port: 3478
    protocol: udp
    required: true
  - port: 5349
    protocol: tcp
    required: false
env:
  - name: TURN_REALM
    default: "example.com"
    required: false
  - name: TURN_STATIC_AUTH_SECRET
    default: ""
    required: false
  - name: TURN_EXTERNAL_IP
    default: ""
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

Env names follow the ich777 image style only where the upstream names exist: the ich777 image reads `REALM`, `SECRET`, `STATIC_AUTH`, `EXTERNAL_IP`, `LISTENING_IP`, `PORT`. The `TURN_*` names above are ContainerForge names chosen for this plan; the mapping to coturn config keys is done in `start.sh`. Keep names aligned with the sibling family after checking the chart values (UNVERIFIED which env names the TrueCharts chart sets). Dependencies: none.

## 7. start.sh

- `#!/bin/sh`-compatible bash, `set -eu`.
- Create `/config` subpaths only when missing. Seed `/config/turnserver.conf` (if missing) with: `listening-port=${TURN_PORT}`, `tls-listening-port=${TURN_TLS_PORT}`, `listening-ip=${TURN_LISTEN_IP}`, `realm=${TURN_REALM}`, `fingerprint`, `lt-cred-mech` or `use-auth-secret` (set from `TURN_STATIC_AUTH_SECRET`), `cert=/config/cert.pem`, `pkey=/config/privkey.pem`, `dh-file=/config/dhparam.pem`, `no-cli`, `log-file=stdout`, `no-stdout-log` as needed (flag names UNVERIFIED against the packaged coturn version).
- Generate a self-signed cert and key into `/config` only when `cert.pem` / `privkey.pem` are missing (`openssl req -x509 ...`, `CERT_VALID_DAYS` 3650, RSA 2048). Generate `dhparam.pem` in `/tmp` and copy, or skip DH when no DH file is required (UNVERIFIED).
- If `TURN_STATIC_AUTH_SECRET` is empty, generate one with `openssl rand -hex 32` once and store it in `/config`, never in logs beyond the first start.
- Set `userdb` (if the config uses one) to `/tmp/turndb`. Static-secret auth does not need a DB.
- Write only under `/config` and `/tmp`. Never write to `/app`.
- Final line: `exec turnserver -c /config/turnserver.conf --no-cli` (flag UNVERIFIED; check `turnserver --help` in the built image) so the process is PID 1 and gets signals.
- Log the bound ports on start (for the readiness signal in section 11).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 60
tcp:
- port: '3478'
- port: '5349'
filePaths:
- /usr/bin/turnserver
- /config/turnserver.conf
- /usr/share/licenses/stun-turn-server/LICENSE
```

- Every port in `settings.yaml` has a `tcp` probe (3478 tcp, 5349 tcp). 3478/udp has no forgetool probe in this schema: state that in the PR and check it with `ss -lun` manually.
- Tests run without env vars, so the self-signed cert path (no `TURN_*` set) is exercised by the test itself. No required-env code path exists after the seeding in section 7.
- `filePaths` lists `/config/turnserver.conf`: this file exists only after start. If the forgetool file check runs before start, move it out (UNVERIFIED when forgetool runs the check).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path / behaviour | ContainerForge remap |
| --- | --- |
| `/stun-turn` data dir (cert, key, DH, config) | `/config` (`cert.pem`, `privkey.pem`, `dhparam.pem`, `turnserver.conf`) |
| Runs as root (no USER in upstream Dockerfile) | `USER apps`; ports 3478 and 5349 are above 1024, so no root bind is needed |
| `ulimit -n 2048` in RUN (does not persist) | Not carried over. Set the open-file limit at runtime only if the test shows it is needed (UNVERIFIED) |
| TLS certs supplied by the user | Accept user-supplied files in `/config` before generating self-signed ones |
| coturn default `userdb`/pidfile paths under `/var/lib/turn` or `/run` | Set to `/tmp` or disabled in the seeded config; no daemon mode |

Draft security expectations reconciled: the chart runs as UID 0 with `readOnlyRootFilesystem: false` and `privileged: false`. This image is rootless and read-only-rootfs compatible (`--read-only --tmpfs /tmp`) as long as the config avoids writes outside `/config` and `/tmp`. No `hostNetwork`, no `privileged`. The chart's `/stun-turn` persistence maps to `/config`; users migrating from upstream must move their certs into `/config`.

## 10. Risks, caveats and open questions

- Version choice: the apt pin (4.6.1) is older than the upstream image's coturn (4.19.2 release tag). Accepted because the ContainerForge rule is to install from the distro package, not to copy from a Debian image.
- `copy-from amd64` is listed in the draft as `ghcr.io/ich777/stun-turn-server:latest`. That image is Debian (glibc, not musl), so it runs, but copying a binary from another app's image breaks the rule that the upstream Dockerfile is not compiled in our build. The plan does not use it. Draft `copy-from` stays informational.
- Relay UDP port range: not confirmed on the fetched pages. A chart or host mapping must expose it. UNVERIFIED.
- TLS: TLS on 5349 requires certs. Self-signed certs from the start script work for testing only; production users must supply certs in `/config`.
- Public IP / realm: relay allocation fails when `realm` or the external IP is wrong (draft caveat, inferred and not verified against coturn docs fetched here).
- Renovate for the apt pin: UNVERIFIED that `datasource=deb` works for Ubuntu.
- Blockers: none found (no musl-only build, no GPU, not privileged, arm64 available via the archive but not checked per architecture).

## 11. Build and test steps

```sh
cd apps/stun-turn-server
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name stun-turn-probe --read-only --tmpfs /tmp \
  -v stun-turn-probe-config:/config stun-turn-server:4.6.1
docker logs -f stun-turn-probe
forgetool containers test --image stun-turn-server:4.6.1 --config ./apps/stun-turn-server/container-test.yaml
docker rm -f stun-turn-probe; docker volume rm stun-turn-probe-config
```

- Expected readiness: coturn logs `listening on` for 3478 (udp and tcp) and 5349. The process stays up.
- Empty `/config` start must seed the config and certs. Restart must keep them.
- Check 3478/udp manually with `ss -lun` inside the container (not covered by forgetool tcp probes).
- arm64 build only if the amd64 build fails for an arm64-specific reason.

## 12. PR checklist

- Branch `feat/add-stun-turn-server`, commit and PR title `feat(stun-turn-server): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections and checkboxes, check only what applies.
- Notes section includes `🤖 This PR is AI generated.`
- Tell the user a signed CLA is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; `license/cla` shows status.
- Untested to state honestly: the image build and forgetool run (not executed here), arm64, the relay UDP range, and TLS with user-supplied certs.
- Confirm `docker buildx bake --print` passes and `VERSION` equals the Dockerfile `ARG VERSION`.
