# embystat — implementation plan
> Source: ./draft.md · Target: apps/embystat/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | 0.2.0-beta.30 (GitHub release tag, https://github.com/mregni/EmbyStat/releases/tag/0.2.0-beta.30). Chart image is `ghcr.io/linuxserver/embystat:0.2.0`, which the linuxserver build pulls from the same upstream release. |
| Release date | UNVERIFIED: the release page shows two timestamps (2022-05-16 and 2024-11-12); which one is the tag date is not clear. |
| Renovate | `datasource=github-releases depName=mregni/EmbyStat versioning=semver` (tag `0.2.0-beta.30` is valid semver with a prerelease part). |
| License | UNVERIFIED: no LICENSE file at the top of the release zips (only third-party `*.LICENSE.txt` inside `dist/static/`). Read the LICENSE of https://github.com/mregni/EmbyStat before filling `docker-bake.hcl` `LICENSE`. |
| Source URL | https://github.com/mregni/EmbyStat |
| Download (amd64) | https://github.com/mregni/EmbyStat/releases/download/0.2.0-beta.30/EmbyStat-ubuntu-x64-v0.2.0-beta.30.zip (65472970 bytes; the linuxserver build uses this one). The draft's `EmbyStat-debian-x64-v0.2.0-beta.30.zip` is the same x64 family and also exists. |
| Download (arm64) | https://github.com/mregni/EmbyStat/releases/download/0.2.0-beta.30/EmbyStat-linux-arm-x64-v0.2.0-beta.30.zip (61564402 bytes). Verified locally: `EmbyStat` and `libcoreclr.so` are ELF AArch64. linuxserver `Dockerfile.aarch64` uses this same asset, so the draft's arm64 caveat is resolved. |
| Checksum source | None published on the release page (no sha256 digest shown). Local sha256 of the zips downloaded here: ubuntu-x64 `02b7cb09a608ce89ece0c9236f4215ca24936dfa46def9edcdba3263499d94c2`, linux-arm-x64 `e7b09c9ad610f54325e7efb8ae06a61d368a452b51dd4760a27dfeef810e46f2`. These are our own pins, not upstream checksums. |
| Packaging | Self-contained .NET 6 app: runtimeconfig has `includedFrameworks` Microsoft.NETCore.App and AspNetCore.App, and `libcoreclr.so` is in the zip. No dotnet runtime from the base is needed. |
| Upstream Dockerfile reviewed | linuxserver `Dockerfile` (https://raw.githubusercontent.com/linuxserver/docker-embystat/5fa06c158344aeefbec98e0e211b34198f4f2063/Dockerfile): `FROM baseimage-ubuntu:jammy`, apt `libicu70 libssl3 unzip`, unzip to `/opt/embystat`, `chmod +x EmbyStat`, `ENV HOME=/config`, `EXPOSE 6555`. Also `Dockerfile.aarch64` (same, arm asset). |
| Upstream run command | `s6-setuidgid abc /opt/embystat/EmbyStat --data-dir /config --log-dir /config/logs --config-dir /config --enable-updates false` (root/etc/s6-overlay/s6-rc.d/svc-embystat/run). |
| Port | 6555/tcp (web GUI and API; EXPOSE, readme, and chart all agree). |
| Env vars (real) | None read by the linuxserver run script. Readme lists `TZ` and the optional `BASE_URL` (reverse-proxy subfolder). Whether the app itself reads `BASE_URL` is UNVERIFIED; leave it out until confirmed in the EmbyStat source. |
| Data path | `/config` (data, config and logs under `/config/logs`) via the `--data-dir`, `--config-dir` and `--log-dir` flags. |
| Chart security | TrueCharts values (https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/embystat/values.yaml): `runAsUser: 0`, `readOnlyRootFilesystem: false`, persistence `/config`. |
| Deprecation notice | linuxserver `99-deprecation`: "Embystat (upstream project) is no longer actively developed." Expect no upstream fixes. |
| Zip layout | Entries use Windows backslashes (for example `updater\Updater.runtimeconfig.json`), so `unzip` on Linux creates literal backslash-named files. Harmless, but do not treat unzip warnings as fatal (linuxserver uses `unzip ... || true`). |

## 2. Target layout

Files in `apps/embystat/`:
- `Dockerfile`
- `docker-bake.hcl`
- `settings.yaml`
- `container-test.yaml`
- `start.sh` (replaces the linuxserver `s6` run script)

No `defaults/`, `etc/` or `health/` directories: EmbyStat creates its own data under `/config` on first run and needs no seeded config. No `root/` (not allowed). No `DOWNSTREAM_CHANGES.md`: the app is not a `FROM` base.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` (single stage). Fits because the upstream is a prebuilt zip with its own .NET runtime, so no build stage is needed. The base already has `curl`, `tar`, `ca-certificates` and `libicu-dev` (checked in `apps/ubuntu/Dockerfile`). Closest sibling: `apps/nzbhydra2` (prebuilt artifact downloaded and unpacked on the ubuntu-derived base). For a .NET-on-ubuntu precedent see `apps/sonarr/Dockerfile` (dotnet on ubuntu).

## 4. Dockerfile

1. `FROM` line above. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Set env: `ENV HOME=/config DOTNET_CLI_TELEMETRY_OPTOUT=1 DOTNET_NOLOGO=1`. Nothing writes to `/app`.
3. Install only what is missing. `unzip` is not in the base list checked above, so add it: `apt-get install -y --no-install-recommends unzip` plus `rm -rf /var/lib/apt/lists/*`. Do not install `libicu70` or `libssl3` blindly: first check `ldd` on the extracted `libSystem.Globalization.Native.so` and `libcoreclr.so`. Add ICU only if `ldd` reports a missing library, using the package name in the 26.04 archive (check with `apt-cache policy`). Not pinned, because these are runtime libraries and not the app.
4. Per-arch asset via `TARGETARCH`:
   ```dockerfile
   RUN case "${TARGETARCH}" in \
         amd64) asset="EmbyStat-ubuntu-x64-v${VERSION}.zip"; sha="02b7cb09a608ce89ece0c9236f4215ca24936dfa46def9edcdba3263499d94c2" ;; \
         arm64) asset="EmbyStat-linux-arm-x64-v${VERSION}.zip"; sha="e7b09c9ad610f54325e7efb8ae06a61d368a452b51dd4760a27dfeef810e46f2" ;; \
         *) echo "unsupported arch ${TARGETARCH}" && exit 1 ;; \
       esac && \
       curl -fsSL -o /tmp/embystat.zip "https://github.com/mregni/EmbyStat/releases/download/${VERSION}/${asset}" && \
       echo "${sha}  /tmp/embystat.zip" | sha256sum -c - && \
       mkdir -p /app/embystat && \
       unzip -q /tmp/embystat.zip -d /app/embystat || true && \
       chmod 0755 /app/embystat/EmbyStat && \
       rm -f /tmp/embystat.zip
   ```
   The sha values are our own pins (no upstream checksum), so say so in a comment. Re-pin them whenever `VERSION` changes. The `|| true` on unzip is needed because of the backslash entries; confirm the `EmbyStat` binary, `EmbyStat.runtimeconfig.json` and `libcoreclr.so` exist after unzip.
5. License: `LICENSE` is UNVERIFIED (see section 1). Once confirmed, copy it into `/usr/share/licenses/embystat/` with the matching `unzip -j` or an explicit extraction. Do not ship a license that was not confirmed.
6. Permissions: `chown -R root:root /app/embystat && chmod -R 755 /app/embystat` (no writes to `/app` at runtime).
7. Tail:
   ```dockerfile
   USER apps
   COPY --chmod=0755 . /
   WORKDIR /config
   EXPOSE 6555
   VOLUME /config
   ```
   `EXPOSE` and `VOLUME` as siblings do. `start.sh` comes in with `COPY . /` (it is on the `.dockerignore` allow-list).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "embystat"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=mregni/EmbyStat versioning=semver
  default = "0.2.0-beta.30"
}

variable "LICENSE" {
  default = "UNVERIFIED"   // replace with the SPDX id confirmed from the upstream LICENSE (section 1)
}

variable "SOURCE" {
  default = "https://github.com/mregni/EmbyStat"
}
```
Then the default group, `image`, `image-local`, `image-all` targets copied from `apps/nzbhydra2/docker-bake.hcl` (labels `org.opencontainers.image.source` and `.licenses`). Do not commit the `UNVERIFIED` placeholder. Validate with `cd apps/embystat && docker buildx bake --print`. `VERSION` must equal the Dockerfile `ARG VERSION`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/mregni/EmbyStat"
ports:
  - port: 6555
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
  - name: UMASK
    default: "002"
    required: false
volumes:
  - path: /config
    required: true
```
- `env`: only `TZ` and `UMASK` (sibling convention). `BASE_URL` is left out until the EmbyStat source confirms it is read (see section 1). Do not add env names the app does not read.
- `dependencies`: none. The Emby or Jellyfin server and its API key are entered in the web UI, not as a ContainerForge dependency.

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config/logs

cd /app/embystat
exec \
    /app/embystat/EmbyStat \
        --data-dir /config \
        --log-dir /config/logs \
        --config-dir /config \
        --enable-updates false
```
- Idempotent: only creates `/config/logs`; nothing is seeded and no file is overwritten.
- No writes to `/app`. The `cd` is needed because the app may resolve static assets relative to its directory (the GUI is in `dist\static\...`).
- `exec` so the app is PID 1 handoff target and gets signals.
- Bind address: ASP.NET Core / Kestrel default is localhost-only unless configured. Check with `ss -ltn` during the run step. If it listens only on 127.0.0.1, add `ASPNETCORE_URLS=http://0.0.0.0:6555` to the `ENV` of the Dockerfile (not a ContainerForge env name, so do not list it in `settings.yaml`). UNVERIFIED until run.
- `--enable-updates false` keeps the updater away from `/app`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '6555'
http:
- port: '6555'
  path: /
filePaths:
- /app/embystat/EmbyStat
- /app/embystat/EmbyStat.runtimeconfig.json
- /start.sh
```
- Every port in `settings.yaml` (6555) has a `tcp` and an `http` probe.
- `http` path `/` may return a redirect to the setup wizard. Use whichever path returns the expected status, and confirm it in the run step (UNVERIFIED).
- `timeoutSeconds: 180` matches the most common sibling value in `apps/*/container-test.yaml`.
- No required env var code paths are known. The app starts on first run with empty `/config` (setup wizard).
- Add the license path to `filePaths` once it is confirmed and installed.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `--data-dir`, `--config-dir` (database, settings) | `/config` (flags in start.sh) |
| `--log-dir` | `/config/logs` |
| `updater\` (self-update) | `--enable-updates false`; no write under `/app` |
| `HOME` | `/config` (linuxserver value kept). Confirm the app writes nothing under `$HOME` other than `/config`; if it does, set `HOME=/tmp`. |
| .NET caches | None expected for a self-contained app; if a `DOTNET_` cache appears under `/app` or `/config` in the run step, point it to `/tmp`. |
| Runtime user | `USER apps` (uid 568). linuxserver runs as root and drops to `abc` with s6; ContainerForge runs the app directly as `apps`. |

Security expectations from the draft (`runAsUser: 0`, `readOnlyRootFilesystem: false`) are the TrueCharts chart values and are not required here. Our target is non-root and `--read-only`, so verify it in the run step.

## 10. Risks, caveats and open questions

- **License unknown (blocker for bake).** Read the LICENSE in https://github.com/mregni/EmbyStat before committing `docker-bake.hcl`. Do not guess the SPDX id.
- **Beta and deprecated upstream.** 0.2.0-beta.30 is a beta, and linuxserver says the upstream project is no longer maintained. Expect rough edges; say so in the PR.
- **Release date ambiguous.** Confirm the tag date before filling any metadata that uses it.
- **Checksums are our own.** No upstream checksum is published; the pins are local sha256 values. Re-verify them when `VERSION` changes.
- **Bind address.** Kestrel may listen on localhost only. Check in the run step; fix with `ASPNETCORE_URLS` if needed.
- **ICU and OpenSSL.** Whether the base already has the libraries the .NET runtime needs is UNVERIFIED until `ldd` is run in the build.
- **External service.** An Emby or Jellyfin server and its API key are set by hand in the UI. The test suite cannot check that link; say so in the PR.
- **arm64 not built here.** The arm64 zip was verified by ELF header only. Run an arm64 build before claiming arm64 support.
- **Draft mismatch.** The draft lists `debian-x64` for amd64; the plan uses `ubuntu-x64` (what the linuxserver build uses) because the target base is ubuntu. Both are x64 and self-contained.

## 11. Build and test steps

Run from `apps/embystat` (protocol: `.github/instructions/build-test-protocol.instructions.md`):

1. `docker buildx bake --print` (must exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. Empty-`/config` run, read-only root:
   ```sh
   docker volume create embystat-probe-config
   docker run --rm -d --name embystat-probe --read-only --tmpfs /tmp \
     -v embystat-probe-config:/config embystat:0.2.0-beta.30
   docker logs -f embystat-probe
   docker exec embystat-probe ss -ltn    # confirm 0.0.0.0:6555
   docker rm -f embystat-probe; docker volume rm embystat-probe-config
   ```
   Expected readiness: the process stays up, the log shows the Kestrel "Now listening on" line for port 6555 (UNVERIFIED exact text until run), and no fatal exception.
4. `forgetool containers test --image embystat:0.2.0-beta.30 --config ./apps/embystat/container-test.yaml`. If forgetool is not available, check the TCP and HTTP probes by hand as in step 3.
5. arm64 only if the amd64 build fails for an arm64 reason, per the protocol. Otherwise note in the PR that arm64 was not built.
6. Scratch containers and volumes removed between rounds (round limit 10).

## 12. PR checklist

- Branch `feat/add-embystat`; commit `feat(embystat): add new container`; target `main`.
- PR title in Conventional Commits form: `feat(embystat): add new container`.
- PR description from `.github/PULL_REQUEST_TEMPLATE.md`, keeping its sections and checkboxes. Only check what applies.
- Notes section includes `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it; the `license/cla` check shows the status).
- State what was not tested: arm64 build (if not run), external Emby or Jellyfin integration, any unconfirmed behaviour (bind address, http status code, release date).
- Downstream check: none (the app is not used as a `FROM` base).
- Pre-completion checklist from AGENTS.md / copilot-instructions.md, including `docker buildx bake --print` output.
