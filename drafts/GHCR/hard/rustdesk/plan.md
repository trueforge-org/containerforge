# rustdesk — implementation plan
> Source: ./draft.md · Target: apps/rustdesk/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | 1.1.16 (chart pins `ghcr.io/rustdesk/rustdesk-server-s6:1.1.16`; release tag https://github.com/rustdesk/rustdesk-server/releases/tag/1.1.16). Release date shown as "20 July" with no year on the fetched page: UNVERIFIED year. |
| Renovate | `datasource=github-releases depName=rustdesk/rustdesk-server versioning=semver` (proposed; no renovate file fetched) |
| License | AGPL-3.0 (`LICENSE`, "GNU AFFERO GENERAL PUBLIC LICENSE", https://raw.githubusercontent.com/rustdesk/rustdesk-server/1.1.16/LICENSE) |
| Source URL | https://github.com/rustdesk/rustdesk-server |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/rustdesk-org/rustdesk-server/1.1.16/docker/Dockerfile (`FROM busybox:stable`, s6-overlay v3.2.0.0, `COPY rootfs /`, `WORKDIR /data`, `VOLUME /data`, `EXPOSE 21115 21116 21116/udp 21117 21118 21119`, `ENV RELAY=relay.example.com ENCRYPTED_ONLY=0`, `HEALTHCHECK ... /usr/bin/healthcheck.sh`, `ENTRYPOINT ["/init"]`, no `USER`) |
| Binary download (amd64) | `https://github.com/rustdesk/rustdesk-server/releases/download/1.1.16/rustdesk-server-linux-amd64.zip` (confirmed in the expanded asset list and in draft.md) |
| Binary download (arm64) | `https://github.com/rustdesk/rustdesk-server/releases/download/1.1.16/rustdesk-server-linux-arm64v8.zip` (confirmed in the asset list; arm64 run on hardware: UNVERIFIED) |
| Other assets | `rustdesk-server-linux-armv7.zip`, `rustdesk-server-linux-i386.zip`, per-arch `.deb` packages for hbbs, hbbr, utils (amd64/arm64/armhf/i386), Windows zip, source zip/tar.gz. Not needed for the plan. |
| Checksum source | None: no checksum file appears in the expanded asset list. UNVERIFIED that upstream publishes one. Plan: pin the sha256 of each zip, computed on the first verified download, and flag it as self-computed. |
| Binaries | `hbbs` (ID/heartbeat, NAT test) and `hbbr` (relay), both Rust. They are inside the zip; the exact zip layout is UNVERIFIED (not fetched). |
| Ports | 21115/tcp (NAT test), 21116/tcp and 21116/udp (ID/heartbeat), 21117/tcp (relay), 21118/tcp (hbbs web client), 21119/tcp (hbbr web client). Source: EXPOSE line above. |
| Env vars | `RELAY` (hbbs relay address, default `relay.example.com` in the upstream image), `ENCRYPTED_ONLY` (default `0`). Whether the upstream s6 scripts read them: UNVERIFIED (rootfs overlay not fetched). |
| Data path | `/data` (upstream `WORKDIR` and `VOLUME`). hbbs writes its key pair (`id_ed25519` and `id_ed25519.pub`) to its working directory; the upstream image uses `/data`. UNVERIFIED on a fetched page. |
| Base | `busybox:stable` with s6-overlay (upstream). Plan uses the ContainerForge ubuntu base instead. |

## 2. Target layout

- `apps/rustdesk/Dockerfile`
- `apps/rustdesk/docker-bake.hcl`
- `apps/rustdesk/settings.yaml`
- `apps/rustdesk/container-test.yaml`
- `apps/rustdesk/start.sh`
- No `defaults/`, `etc/` or `health/` (the server has no config file in the plan; reason: hbbs and hbbr take flags/env). Add `health/` only if the HTTP probe proves insufficient.
- No `root/` (never used by agents). No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`. Both binaries are prebuilt (no compile), so ubuntu alone is enough (the draft's "ubuntu alone" choice holds). Closest sibling: `apps/adguardhome-sync` (prebuilt zip/tar in `/app`, `TARGETARCH` mapping).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Map the release asset name from `TARGETARCH`. Only `amd64` and `arm64` are in scope (armv7/i386 out of scope):
   ```dockerfile
   RUN case "$TARGETARCH" in \
         amd64) ARCH=amd64 ;; \
         arm64) ARCH=arm64v8 ;; \
         *) echo "unsupported arch: $TARGETARCH" && exit 1 ;; \
       esac && \
       echo "$ARCH" > /tmp/rustdesk-arch
   ```
3. Download the zip and verify it against the pinned sha256 (self-computed, see section 1):
   ```sh
   ARCH="$(cat /tmp/rustdesk-arch)"   # shell variables do not persist across RUN steps; merge steps 2 and 3 into one RUN instead if preferred
   curl -fL -o /tmp/rustdesk.zip \
     "https://github.com/rustdesk/rustdesk-server/releases/download/${VERSION}/rustdesk-server-linux-${ARCH}.zip"
   echo "<sha256>  /tmp/rustdesk.zip" | sha256sum -c -
   ```
   Note: the zip name uses `arm64v8` on arm64, not `arm64`. Do not use `$TARGETARCH` directly.
4. Install unzip if the base lacks it (UNVERIFIED whether `ghcr.io/trueforge-org/ubuntu` ships `unzip`; check with `docker run --rm <base> which unzip` before adding the package, and pin the apt version if added).
5. Extract to `/app/rustdesk` (read-only at runtime, binaries only), `chmod 0755` on `hbbs` and `hbbr`.
6. Ship the license: `/usr/share/licenses/rustdesk/LICENSE` from the source tarball or the fetched `LICENSE` text (AGPL-3.0).
7. Remove `/tmp/rustdesk.zip` and `/tmp/rustdesk-arch`.
8. Ownership and mode as sibling: `chown -R apps:apps /app && chmod -R 755 /app`.
9. `ENV HOME=/config TMPDIR=/tmp`.
10. Tail:
    ```dockerfile
    USER apps
    COPY --chmod=0755 . /

    EXPOSE 21115 21116 21116/udp 21117 21118 21119

    VOLUME /config
    WORKDIR /config
    ```
    `WORKDIR /config` (not upstream `/data`) so hbbs writes its key pair to `/config`. Verify this against the actual key location on the first run (UNVERIFIED).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "rustdesk"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=rustdesk/rustdesk-server versioning=semver
  default = "1.1.16"
}

variable "LICENSE" {
  default = "AGPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/rustdesk/rustdesk-server"
}
```

Then the four standard targets and the `default` group copied from `apps/adguardhome-sync/docker-bake.hcl`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/rustdesk/rustdesk-server"
ports:
  - port: 21115
    protocol: tcp
    required: false
  - port: 21116
    protocol: tcp
    required: true
  - port: 21116
    protocol: udp
    required: true
  - port: 21117
    protocol: tcp
    required: true
  - port: 21118
    protocol: tcp
    required: false
  - port: 21119
    protocol: tcp
    required: false
env:
  - name: RELAY
    default: ""
    required: false
  - name: ENCRYPTED_ONLY
    default: "0"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

Env names and defaults come from the upstream Dockerfile. `RELAY` default is empty here (not the upstream `relay.example.com`) so the server does not advertise a fake relay; flag this as a decision. Whether hbbs reads `RELAY` at all is UNVERIFIED. Ports 21118/21119 (web client) are included because the image exposes them; they are optional.

## 7. start.sh

Two daemons in one container, so `start.sh` starts `hbbr` in the background and `exec`s `hbbs`:

```bash
#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config
cd /config

relay_opts=()
if [ -n "${RELAY:-}" ]; then
  relay_opts=(-r "${RELAY}")
fi

/app/rustdesk/hbbr &
exec /app/rustdesk/hbbs "${relay_opts[@]}"
```

Notes: the `-r` relay flag and whether `ENCRYPTED_ONLY` maps to a hbbs/hbbr flag are UNVERIFIED (not confirmed on a fetched page). Run `hbbs --help` and `hbbr --help` on the image before the script is final, and add the `ENCRYPTED_ONLY` handling only if a flag is confirmed. The background `hbbr` has no supervisor, so if it dies, the container keeps running on `hbbs` alone. Flag this as a known risk (section 10); a supervisor (s6, as upstream) is the fix if the risk is unacceptable. The key pair is generated on first run into `/config`, and an existing pair is never overwritten.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 60
tcp:
  - port: '21116'
  - port: '21117'
  - port: '21115'
  - port: '21118'
  - port: '21119'
filePaths:
  - /app/rustdesk/hbbs
  - /app/rustdesk/hbbr
  - /usr/share/licenses/rustdesk/LICENSE
```

Every port in `settings.yaml` needs a probe. UDP 21116 is not covered by the `tcp` probe, so add a UDP check only if forgetool supports one (UNVERIFIED); otherwise note the gap. 21118 and 21119 (web client) are probed with `tcp` only, since whether they answer plain HTTP is UNVERIFIED; if either does not listen without a client, drop its probe and state the reason. `tcp` and `http` run inside the container, so they do not prove client reachability.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/data` (WORKDIR, VOLUME, key pair) | `/config` (WORKDIR and VOLUME in this plan) |
| `/var/run` (upstream `ln -s /run /var/run`) | Not needed on ubuntu; do not add the symlink |
| s6 state (`/run/service`) | Not used (no s6 in this plan). Keep `/tmp` for any runtime scratch. |
| hbbs and hbbr logs | stdout only (UNVERIFIED that they do not write files) |

Reconciled expectations from draft.md: chart runs as UID 0 with `readOnlyRootFilesystem: false`. This plan runs as `apps` with `--read-only --tmpfs /tmp`. All listed ports are above 1024, so no `CAP_NET_BIND_SERVICE` is needed. Not privileged.

## 10. Risks, caveats and open questions

- Blocker (network): clients need inbound UDP 21116 and TCP 21117 reachable. NAT or port forwarding is the user's job (draft caveat).
- Key persistence: the key pair must stay in `/config`. Losing it makes every client refuse the server after a restart (draft caveat). Verify with a restart test (section 11).
- Process supervision: `hbbr` runs in the background with no supervisor. A crash of `hbbr` is silent. Options: accept and document, or add a small supervisor. Decision needed before the PR.
- arm64: the `arm64v8` zip is a separate build; not run on hardware (UNVERIFIED, draft caveat).
- `RELAY` and `ENCRYPTED_ONLY` behaviour and flag names: UNVERIFIED (upstream s6 scripts not fetched).
- Release date year on the release page: UNVERIFIED (see section 1).
- Self-computed sha256 for both zips (no upstream checksum listed).
- `unzip` presence in the ubuntu base: UNVERIFIED.

## 11. Build and test steps

```sh
cd apps/rustdesk
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name rustdesk-probe --read-only --tmpfs /tmp \
  -p 21116:21116 -p 21116:21116/udp -p 21117:21117 \
  -v rustdesk-probe-config:/config rustdesk:1.1.16
docker logs -f rustdesk-probe
docker exec rustdesk-probe ls /config   # expect id_ed25519 and id_ed25519.pub
docker rm -f rustdesk-probe
docker run --rm -d --name rustdesk-probe --read-only --tmpfs /tmp \
  -v rustdesk-probe-config:/config rustdesk:1.1.16   # restart with the same volume
docker volume rm rustdesk-probe-config
forgetool containers test --image rustdesk:1.1.16 --config ./apps/rustdesk/container-test.yaml
```

Readiness signals: hbbs and hbbr startup lines (exact text UNVERIFIED), process alive after the startup window, and both TCP ports open. Restart test: the key pair file is unchanged after the restart.

## 12. PR checklist

- Branch `feat/add-rustdesk`, commit `feat(rustdesk): add new container`, target `main`, PR title matches the commit.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it. The `license/cla` check shows status.
- Untested and to state honestly: arm64 runtime, UDP probe coverage, key persistence across restart, relay and encrypted-only behaviour, and the self-computed sha256 values.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`.
