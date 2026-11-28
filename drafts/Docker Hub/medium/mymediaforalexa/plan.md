# mymediaforalexa — implementation plan
> Source: ./draft.md · Target: apps/mymediaforalexa/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `1.3.156.0`: latest Docker Hub tag (pushed 2026-04-30). Also on Hub: `1.3.154.2`, `1.3.153.4`, `1.3.152.3`. Chart pins `docker.io/bizmodeller/mymediaforalexa:1.3.156.0@sha256:0638ca16...33ca8`. |
| Difference from draft | Draft's `.deb` URLs point at `1.3.147.994` (amd64) and `1.3.152.0` (arm64). Both lag the 1.3.156.0 tag. UNVERIFIED that either file exists (no fetched page lists them). |
| Renovate | Suggested `datasource=docker depName=docker.io/bizmodeller/mymediaforalexa versioning=loose` (dotted 4-part tags). UNVERIFIED against this repo's renovate config. |
| License | UNVERIFIED. Closed-source vendor product; no license text fetched. |
| Source URL | https://www.mymediaalexa.com/ (vendor site; no public source repo) |
| Download | Vendor `.deb` per arch (draft URLs, pattern UNVERIFIED). Vendor docs: https://www.mymediaalexa.com/home/docker (the download page `/home/download` returned 404). |
| Checksum source | None found. UNVERIFIED that the vendor publishes one. |
| Upstream Dockerfile reviewed | None public. The vendor's Docker page was read; it describes the image but not its build. |
| Ports (vendor page and TrueCharts values) | `52051` (main web UI, per chart) and `52050` (sub, enabled in chart). The vendor page says the image `EXPOSE`s tcp/52050 and tcp/52051, and that each must be mapped to the same host port because Alexa discovery advertises IP and port. |
| Data and config paths | `/datadir` (chart `persistence.data`): config, media-server settings and the index database. The vendor page says these must live in a volume. |
| Media path | `/medialibrary` (chart `persistence.media`, read-only media). User-provided bind mount, not a ContainerForge volume. |
| Env vars | UNVERIFIED: none documented on the fetched pages. Do not invent any. |
| User | Chart forces UID/GID 0 (`runAsNonRoot: false`). Vendor's own user is UNVERIFIED. |
| arm64 | Yes on Hub for 1.3.156.0 (Hub manifest). The vendor `.deb` for arm64 is UNVERIFIED for this version. |
| Dependencies | Alexa (external) and a vendor web account (`https://docs.bizmodeller.com/my-media-for-alexa/`, not fetched). FFmpeg is a separate install step on the vendor site (not verified). |

## 2. Target layout

- `apps/mymediaforalexa/Dockerfile`
- `apps/mymediaforalexa/docker-bake.hcl`
- `apps/mymediaforalexa/settings.yaml`
- `apps/mymediaforalexa/start.sh`
- `apps/mymediaforalexa/container-test.yaml`

No `defaults/`, `etc/` or `health/` (no seed config is known; add only after step 1 shows one is needed). No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

```dockerfile
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a
```

Single stage. The vendor ships `.deb` packages, so `dpkg -x` unpacks them on ubuntu. No runtime base is needed. Closest sibling: `apps/adguardhome-sync` (prebuilt archive from a vendor release, extracted into `/app`).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`, `ENV HOME=/config`.
2. Reject unsupported arches (the draft lists only amd64 and arm64; the Hub also has 386 and arm, which have no `.deb` in the draft):

   ```sh
   case "${TARGETARCH}" in amd64|arm64) ;; *) echo "unsupported arch: ${TARGETARCH}" >&2; exit 1 ;; esac
   ```

3. Download and unpack, with no apt packages:

   ```sh
   curl -fL -o /tmp/mymedia.deb \
     "https://bizmodeller.s3.amazonaws.com/MyMediaForAlexa/${VERSION}/linux/mymedia_${VERSION}-1_${TARGETARCH}.deb" && \
   dpkg -x /tmp/mymedia.deb /tmp/mymedia-root
   ```

   The URL pattern is taken from the draft's two URLs and is UNVERIFIED for `1.3.156.0`. Confirm it in step 1 of section 11 before writing the Dockerfile.
4. Move the unpacked tree to `/app/mymediaforalexa/` (exact source path inside the `.deb` is UNVERIFIED; inspect with `dpkg -c`). Copy the vendor copyright or license file to `/usr/share/licenses/mymediaforalexa/`.
5. `chown -R apps:apps /app/mymediaforalexa && chmod -R 755 /app/mymediaforalexa`, then `rm -rf /tmp/*`.
6. `EXPOSE 52051 52050`, `VOLUME /config`, `USER apps`, `COPY --chmod=0755 . /` as the last steps before `EXPOSE`.

Expected tail (same shape as `apps/adguardhome-sync`):

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 52051
EXPOSE 52050
VOLUME /config
```

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "mymediaforalexa"
}

variable "VERSION" {
  // renovate: datasource=docker depName=docker.io/bizmodeller/mymediaforalexa versioning=loose
  default = "1.3.156.0"
}

variable "LICENSE" {
  default = "LicenseRef-Proprietary"
}

variable "SOURCE" {
  default = "https://www.mymediaalexa.com/"
}
```

- `LICENSE`: placeholder `LicenseRef-Proprietary`. Replace it with the vendor's license name once confirmed (UNVERIFIED).
- Keep the four standard targets and the `default` group from `apps/adguardhome-sync/docker-bake.hcl` unchanged.
- Validate with `docker buildx bake --print` in `apps/mymediaforalexa`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://www.mymediaalexa.com/"
ports:
  - port: 52051
    protocol: tcp
    required: false
  - port: 52050
    protocol: tcp
    required: false
env: []
volumes:
  - path: /config
    required: true
```

- `env: []`: no env var is verified (section 1). Add one only after the binary is shown to read it.
- `/datadir` is mapped to `/config` in section 7. The media library is a user bind mount and is not listed.
- Dependencies: none in ContainerForge. Alexa and the vendor account are external.

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config/datadir
ln -sfn /config/datadir /app/mymediaforalexa/datadir   # hypothetical: only if the binary has a fixed path, see section 10

cd /app/mymediaforalexa
exec ./mymedia --datadir /config/datadir               # hypothetical flag, UNVERIFIED
```

The binary name, its flags and how it selects `/datadir` are UNVERIFIED. Find them in step 1 (`dpkg -c`, then the installed `.deb` files and vendor docs) before writing `start.sh`. Rules that apply regardless:

- Seed nothing. Create `/config/datadir` only when missing. Do not write into `/app`.
- Listen on all interfaces (the vendor requires LAN reachability). Confirm the bind address in the logs.
- `exec` the final process so signals reach it.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '52051'
- port: '52050'
filePaths:
- /app/mymediaforalexa
- /usr/share/licenses/mymediaforalexa
```

- A TCP probe for each port in `settings.yaml`. No HTTP probe: the web UI protocol and paths are UNVERIFIED.
- If the server does not open its ports without a configured vendor account, the TCP probes will fail. In that case narrow the test as in the protocol's DB exception only if its criteria hold, and state that the reason is a vendor account, not a database. Do not drop the probes.
- `timeoutSeconds: 120` is a starting value; no sibling in this batch sets it. Confirm against the first run.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/datadir` (config, settings, index DB) | `/config/datadir`, via `start.sh` (flag or symlink, section 7) |
| `/medialibrary` (media, read only) | User bind mount, read only. The app does not need write access to it (UNVERIFIED). |
| Install tree `/app/mymediaforalexa` | Read only at runtime. Nothing is written there (UNVERIFIED for every code path). |
| Caches and temp files | `/tmp` only. Set `TMPDIR=/tmp` if the binary uses it (UNVERIFIED). |

- Chart expectations reconciled: the chart runs as UID 0 and `readOnlyRootFilesystem: false`. This image targets `apps` (UID 568) and read-only rootfs (`--read-only --tmpfs /tmp`), so the chart's root setting is not carried over.
- Ports 52050 and 52051 are above 1024, so no root is needed to bind them.
- Privileged: not required by the draft or chart. Do not set it.
- Host networking: the draft says the app needs host networking, but the chart does not set it. Alexa discovery advertises the IP and port, so the host port must equal the container port (vendor page). Bridge mode with `-p 52051:52051 -p 52050:52050` should work (UNVERIFIED). Test it before the PR.

## 10. Risks, caveats and open questions

- Blocker: the `.deb` URLs and the version are unverified. Confirm they exist for `1.3.156.0` before building. If no `.deb` exists for that version, the fallback is `COPY --from=bizmodeller/mymediaforalexa:1.3.156.0` (the vendor's image, built on an unknown base, UNVERIFIED). Ask the user before using that fallback.
- No upstream checksum found. Record the SHA-256 of each `.deb` in the PR body and pin the URL by version. Do not invent a checksum file.
- Closed-source vendor binary. License, redistribution and the update path are controlled by the vendor. Get the user's approval before shipping it in a public image.
- FFmpeg: the vendor site lists it as a separate install step. UNVERIFIED whether the server needs it at runtime. If it does, add an apt package pinned to the Ubuntu 26.04 version, not an unpinned one.
- Alexa and the vendor account are external. The container cannot be fully tested end to end; say so in the PR.
- Upstream user and env vars are UNVERIFIED. If the binary needs to run as a specific user or reads env vars, add them only after they are confirmed.
- Arm64: the Hub image has arm64, but the vendor `.deb` for arm64 is UNVERIFIED for this version.

## 11. Build and test steps

```sh
cd apps/mymediaforalexa

# 0. Confirm the .deb URL and inspect the package (no build yet)
curl -fLI "https://bizmodeller.s3.amazonaws.com/MyMediaForAlexa/1.3.156.0/linux/mymedia_1.3.156.0-1_amd64.deb"
mkdir -p "$SCRATCH/mma" && curl -fL -o "$SCRATCH/mma/mymedia.deb" "<url>" && dpkg -c "$SCRATCH/mma/mymedia.deb"

# 1. Bake
docker buildx bake --print

# 2. Build (amd64 only; arm64 only if the failure is arm64-specific)
docker buildx bake --set image-local.platform=linux/amd64 image-local

# 3. Run on read-only rootfs with an empty /config
docker run --rm -d --name mymediaforalexa-probe --read-only --tmpfs /tmp \
  -v mymediaforalexa-probe-config:/config -p 52051:52051 -p 52050:52050 \
  mymediaforalexa:1.3.156.0
docker logs -f mymediaforalexa-probe

# 4. Test
forgetool containers test --image mymediaforalexa:1.3.156.0 --config ./apps/mymediaforalexa/container-test.yaml

# Cleanup
docker rm -f mymediaforalexa-probe; docker volume rm mymediaforalexa-probe-config
```

- The `$SCRATCH` path and the `<url>` placeholder are placeholders. Use a fresh empty directory for the download.
- Readiness signal: UNVERIFIED. Expect a vendor startup line that names the listening port (52051 or 52050). Confirm it in the first run and record the exact line here.
- Pass criteria are in `.github/instructions/build-test-protocol.instructions.md`.

## 12. PR checklist

- Branch `feat/add-mymediaforalexa`, commit and PR title `feat(mymediaforalexa): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md` and keep its sections. Check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: contributions need a signed CLA (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it. The `license/cla` check shows the status.
- Say what was not tested: the vendor `.deb` for arm64, the Alexa side (no vendor account in CI), host-network discovery, the FFmpeg question, and the read-only run if it was not done.
- `docker buildx bake --print` passes, and the bake `VERSION` equals the Dockerfile `ARG VERSION`.
