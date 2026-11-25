# boinc — implementation plan
> Source: ./draft.md · Target: apps/boinc/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | UNVERIFIED. The latest GitHub release of `BOINC/boinc` is `server_release/1.6/1.6.3` (2026-11-13). It is the server, and it has no assets, so it does not give the client version. Source: https://api.github.com/repos/BOINC/boinc/releases/latest |
| Client package | Ubuntu archive `boinc-client` (listed for jammy, jammy-updates and jammy-backports at https://packages.ubuntu.com/search?keywords=boinc-client). UNVERIFIED: the version in the 26.04 (resolute) archive, and arm64 availability. |
| Renovate | UNVERIFIED for an apt pin. Use the same apt pin approach as `apps/valkey`, after the 26.04 version is confirmed. |
| License | LGPL-3.0 (GitHub API: https://api.github.com/repos/BOINC/boinc). |
| Source URL | https://github.com/BOINC/boinc |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/linuxserver/docker-boinc/master/Dockerfile. `FROM ghcr.io/linuxserver/baseimage-selkies:ubunturesolute`; PPA `ppa:costamagnagianfranco/boinc`; installs `boinc-client` (optionally pinned to `BOINC_VERSION`), `boinc-client-opencl`, `boinc-manager`, `at-spi2-core`, `bzip2`, `xz-utils`; links `libOpenCL.so`; `COPY root/ /`; no `EXPOSE`, no `VOLUME`, no `USER`, no `ENTRYPOINT`/`CMD`. |
| Env vars (upstream, Selkies) | `NVIDIA_DRIVER_CAPABILITIES=compute,video,utility`, `DEBIAN_FRONTEND=noninteractive`, `CUSTOM_PORT=8080`, `CUSTOM_HTTPS_PORT=8181`, `TITLE=BOINC`, `NO_GAMEPAD=true`, `PIXELFLUX_WAYLAND=true`. These belong to the desktop base. The headless client reads none of them. |
| Ports | 8080 and 8181 are the upstream Selkies web UI, from env. The draft's 3000, 3001 and 31416 are UNVERIFIED. Port 31416 (BOINC GUI RPC) is the expected remote-control port for the headless client, but no fetched page confirms it. |
| Data / config paths | `/config` (linuxserver convention, UNVERIFIED for this image). The BOINC data directory is set by the client at run time. |
| Dependencies | None. |

## 2. Target layout

- `apps/boinc/Dockerfile`
- `apps/boinc/docker-bake.hcl`
- `apps/boinc/settings.yaml`
- `apps/boinc/container-test.yaml`
- `apps/boinc/start.sh`

No `root/`. No `DOWNSTREAM_CHANGES.md`, because nothing uses this image as `FROM`. Add `defaults/` only if a config seed is needed (UNVERIFIED).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. The draft's reason holds: a headless client from the Ubuntu archive needs only the generic userland. Closest sibling: `apps/valkey` (pinned apt version and health directory).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `ARG BOINC_VERSION` (apt pin, value UNVERIFIED until checked against the 26.04 archive).
2. `USER root`. `apt-get install -y --no-install-recommends boinc-client=${BOINC_VERSION}`. Install no GUI packages (`boinc-manager`, `at-spi2-core`, the Selkies stack are not needed for a headless client).
3. Clean apt lists and `/tmp`.
4. `ENV HOME=/config`. Caches go to `/tmp`.
5. Final stage: `USER apps`, `COPY --chmod=0755 . /`, `VOLUME /config`. `EXPOSE` as decided in section 10.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "boinc" }
variable "VERSION" {
  // renovate: datasource=repology depName=ubuntu_26_04/boinc-client versioning=loose   // UNVERIFIED datasource, confirm before use
  default = "UNVERIFIED"
}
variable "LICENSE" { default = "LGPL-3.0" }
variable "SOURCE" { default = "https://github.com/BOINC/boinc" }
```

The renovate `datasource` line is a placeholder; confirm the right datasource for an Ubuntu apt pin against a sibling before committing. Keep the four standard targets and the `default` group from `apps/adguardhome-sync`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/BOINC/boinc"
ports:
  - port: 31416          # UNVERIFIED: confirm the GUI RPC port the headless client opens
    protocol: tcp
    required: false
env: []                  # no confirmed env var is read by a headless boinc-client
volumes:
  - path: /config
    required: true
```

Dependencies: none.

## 7. start.sh

```bash
#!/usr/bin/env bash
mkdir -p /config
exec boinc --dir /config --allow_remote_gui_rpc   # flag names UNVERIFIED; confirm with `boinc --help` on the build
```

Idempotent. It seeds nothing unless a config is shown to be needed. It writes only to `/config` and `/tmp`. The GUI RPC must listen on all interfaces so other containers can reach it (UNVERIFIED flag, see section 10).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 120
tcp:
- port: '31416'         # UNVERIFIED port, see settings.yaml
filePaths:
- /usr/bin/boinc
```

The test runs with no env vars, so no required-env path is covered here.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| Client data directory | `/config` via `boinc --dir /config` (UNVERIFIED flag). |
| Desktop icons and desktop config (`/usr/share/selkies/...`) | Not needed, because the headless client has no desktop. |
| `/build_version` | Not needed unless the image must report its version (decide during build). |

Reconciling the draft's expectations: the chart runs as root with `readOnlyRootFilesystem: false`. The target runs as `USER apps` on a read-only rootfs with `/config` and `/tmp` writable. No GPU is needed for a headless CPU client, so the `NVIDIA_DRIVER_CAPABILITIES` and OpenCL packages are dropped unless GPU work is required (out of scope here). Not privileged.

## 10. Risks, caveats and open questions

- **Client version unknown.** The GitHub release gives the server, not the client, so the client version and its renovate source must come from the Ubuntu archive. UNVERIFIED.
- **Rolling tag.** The draft's `latest` is rolling. This plan pins the apt version instead.
- **Manual setup.** The account and project attachment are set by hand (draft note). The plan does not automate it.
- **Port.** 31416 (GUI RPC) is expected but UNVERIFIED. The draft's 3000, 3001 and 8080/8181 belong to the Selkies UI and are not used here.
- **Remote GUI RPC security.** Exposing the RPC on all interfaces needs an auth password (`gui_rpc_auth.cfg`). Decide how it is seeded without writing secrets to the image.
- **arm64:** the apt package is listed for ubuntu archives generally, but arm64 availability for 26.04 is UNVERIFIED.

## 11. Build and test steps

```sh
cd apps/boinc
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name boinc-probe --read-only --tmpfs /tmp -v boinc-probe-config:/config boinc:<version>
docker logs -f boinc-probe
forgetool containers test --image boinc:<version> --config ./apps/boinc/container-test.yaml
docker rm -f boinc-probe; docker volume rm boinc-probe-config
```

Readiness signal: UNVERIFIED. Expect a line from the client that it is running and listening on the RPC port (confirm on the first build).

## 12. PR checklist

- Branch `feat/add-boinc`, commit `feat(boinc): add new container`.
- Fill in `.github/PULL_REQUEST_TEMPLATE.md`, keeping sections and checkboxes.
- Notes section: `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it.
- State that nothing was built or run, if that remains true.
