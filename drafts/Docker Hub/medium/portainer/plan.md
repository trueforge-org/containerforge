# portainer — implementation plan
> Source: ./draft.md · Target: apps/portainer/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `2.45.4`, published 2026-11-18 (https://api.github.com/repos/portainer/portainer/releases/latest). Tag has no `v` prefix. Chart image `portainer/portainer-ce:2.45.4` matches (https://hub.docker.com/v2/repositories/portainer/portainer-ce/tags/2.45.4, last updated 2026-11-18). |
| Renovate | `datasource=github-releases depName=portainer/portainer versioning=semver` |
| License | Zlib (GitHub SPDX, https://api.github.com/repos/portainer/portainer). UNVERIFIED: the repo `LICENSE` file was not read in this run. |
| Source URL | https://github.com/portainer/portainer |
| Binary, amd64 | https://github.com/portainer/portainer/releases/download/2.45.4/portainer-2.45.4-linux-amd64.tar.gz |
| Binary, arm64 | https://github.com/portainer/portainer/releases/download/2.45.4/portainer-2.45.4-linux-arm64.tar.gz |
| Checksum source | Per-asset files in the same release: `portainer-2.45.4-linux-amd64-checksum.txt` and `portainer-2.45.4-linux-arm64-checksum.txt`, format `SHA256 (<file>) = <hash>`. |
| amd64 SHA-256 | `785524df829f847f55126baab67bf554dbf3413efd29ea7a643c4f57a655c1dc` (from the checksum file; tarball downloaded and hash re-computed in this run, matched). |
| arm64 SHA-256 | `73e3478f386e06fb6ce85fc4d0c031247752bf82acbdf59564cd57eea2bb7461` (same method, matched). |
| Tarball layout | Top-level `portainer/`, containing `portainer/portainer` (the binary), `portainer/public/` (UI assets), `portainer/mustache-templates/`. Extract with `--strip-components=1`. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/portainer/portainer/505380c8eecff08cf513c457494bde91634db9ff/build/linux/Dockerfile (summary via WebFetch). It does `FROM portainer/base AS production`, `EXPOSE 9000`, `EXPOSE 9443`, `EXPOSE 8000`, `VOLUME /data`, `WORKDIR /`, `ENTRYPOINT ["/portainer"]`, no `USER`, no `ENV`, `ARG GIT_COMMIT`, `ARG BUILD_DATE`. |
| Ports | 9000/tcp (HTTP UI), 9443/tcp (HTTPS UI), 8000/tcp (edge agent tunnel). Source: upstream `EXPOSE`. |
| Data path | `/data` (upstream `VOLUME /data`). Our image uses `/config`, see section 9. |
| Env vars | UNVERIFIED: the upstream Dockerfile sets none. Portainer CLI flags (`--data`, `--bind`, `--bind-https`, `--tunnel-port`, `--admin-password-file`, `--http-disabled`) and any matching env names were not confirmed on a fetched page in this run. Confirm with `/app/portainer --help` in the built image before writing `settings.yaml` `env`. |
| Binary architectures | amd64 and arm64 tarballs exist. Also ppc64le, arm (v7) and Windows tarballs, out of scope. |
| Dependencies | None for Community Edition. The draft's `portainer-ee` (beImage) is the Enterprise image and is not needed. |
| Docker socket | Managing local Docker needs `/var/run/docker.sock` (root-equivalent). This is a runtime user concern and must not be mounted by the tests. |

## 2. Target layout

- `apps/portainer/Dockerfile`
- `apps/portainer/docker-bake.hcl`
- `apps/portainer/settings.yaml`
- `apps/portainer/container-test.yaml`
- `apps/portainer/start.sh`

No `defaults/`, `etc/`, `health/`, `root/` needed (the app creates its own data under `/config`). No `DOWNSTREAM_CHANGES.md` (not a `FROM` base). Keep the schema header in `settings.yaml` and `container-test.yaml`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`, the final stage and the download stage. Portainer is a static Go binary plus a UI bundle, so ubuntu only needs `curl` and `tar` (already in the base). Closest siblings: a prebuilt-binary app on ubuntu such as `apps/adguardhome-sync` (binary, `defaults/`, `start.sh`), and `apps/it-tools` / `apps/theme-park` for static UI assets.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `ARG VENDOR`, `USER root`, `WORKDIR /app`.
2. Map the arch: `amd64 -> amd64`, `arm64 -> arm64`. Use `${TARGETARCH}` directly (the release names match).
3. Download and verify, in one `RUN`:
   ```sh
   curl -fsSL -o /tmp/portainer.tgz "https://github.com/portainer/portainer/releases/download/${VERSION}/portainer-${VERSION}-linux-${TARGETARCH}.tar.gz"
   echo "${PORTAINER_SHA256}  /tmp/portainer.tgz" | sha256sum -c -
   tar xzf /tmp/portainer.tgz -C /app --strip-components=1
   rm -f /tmp/portainer.tgz
   ```
   The checksum for each arch is an `ARG` (or a `case` on `TARGETARCH`) set from the release checksum file listed in section 1. Do not hard-code the amd64 hash for arm64.
4. Licence: the tarball listing shows no LICENSE file (UNVERIFIED for the full listing; only the first 30 entries were read). Check the full listing; if absent, fetch the repo LICENSE at the `2.45.4` tag and ship it to `/usr/share/licenses/portainer/LICENSE`, and say in the PR where it came from.
5. `chown -R root:root /app && chmod -R 755 /app` (read-only at runtime). `rm -rf /var/lib/apt/lists/* /tmp/*`.
6. `USER apps`, `COPY --chmod=0755 . /`, `WORKDIR /config`.
7. `EXPOSE 9000 9443 8000`, `VOLUME /config`, `ENTRYPOINT`/`CMD` via `start.sh` (section 7).

Sample `RUN` ordering: keep `USER root` only for the download and extract, then switch to `USER apps` (Dockerfile rule).

## 5. docker-bake.hcl

- `variable "APP" { default = "portainer" }`
- `variable "VERSION"` with `// renovate: datasource=github-releases depName=portainer/portainer versioning=semver` and `default = "2.45.4"`.
- `variable "LICENSE" { default = "Zlib" }` (UNVERIFIED against the repo LICENSE file, see section 1).
- `variable "SOURCE" { default = "https://github.com/portainer/portainer" }`
- `docker-metadata-action`, `group "default"` (`image-local`), `image` (args `VERSION`, labels for source and licenses), `image-local` (`type=docker`, tag `${APP}:${VERSION}`), `image-all` (`linux/amd64`, `linux/arm64`). Mirror `apps/sonarr/docker-bake.hcl`.
- Validate with `docker buildx bake --print` from `apps/portainer`.

## 6. settings.yaml

- Schema header from siblings, `schema_version: 1`, `upstream_env_url: https://github.com/portainer/portainer`.
- `ports`: `9000` (http, required true), `9443` (https, required false, TLS in use only if certs are given), `8000` (tcp, required false, edge agent tunnel).
- `env`: only what `start.sh` reads. Start with the variables confirmed by `--help` (section 1). Do not invent names. If none are confirmed, `env` may be empty and that is recorded in the PR.
- `volumes`: `/config` (persistent state, mapped from upstream `/data`).
- `dependencies`: none.

## 7. start.sh

- `#!/bin/sh`, `set -eu` (match the sibling Go-binary app style).
- Create `/config/portainer` (or the chosen data directory) only if missing. Never write under `/app`.
- Caches and temp: `TMPDIR=/tmp`. Portainer's own caches (if any) under `/tmp`, not `/config` (UNVERIFIED: which cache paths the binary uses; the draft's `/.cache` is a chart-side emptyDir, not confirmed).
- Start command: `exec /app/portainer --data /config/portainer --bind 0.0.0.0:9000 --bind-https 0.0.0.0:9443 --tunnel-port 8000` (flag names UNVERIFIED, use exactly what `--help` prints for `2.45.4`; no admin password on the command line).
- Bind all interfaces (`0.0.0.0`), as the start-script rule requires.
- Final line `exec` so the binary is PID 1 handoff.

## 8. container-test.yaml

- Schema header from siblings.
- `tcp` probe for `9000` and `8000`. `9443` gets a TCP probe too (the coverage minimum says every port in `settings.yaml` needs a probe), but if TLS is not enabled in the test it may not listen. Check at build time and leave it only if it listens without certs (UNVERIFIED).
- `http` probe on `9000` at `/api/status` (Portainer status endpoint, UNVERIFIED path: confirm from a running container) or `/`. Use the path that returns 200 without setup.
- `filePaths`: `/app/portainer` (binary), `/app/public/index.html` (UI).
- `timeoutSeconds`: from `apps/sonarr` or a Go sibling. Portainer starts in seconds.
- The test runs with no env. Portainer must start with an empty `/config`. The admin first-run window is a runtime concern, not a test one (UNVERIFIED window length from the draft).

## 9. Rootless and read-only-rootfs adaptations

| Upstream / chart | This plan |
| --- | --- |
| `VOLUME /data` (chart `pvc`) | `/config`. The chart's `/data` maps to `/config` via the chart's own values, not here. |
| Chart `readOnlyRootFilesystem: true`, writable `/data` and `/.cache` | Compatible: `/app` read-only, state under `/config`, temp under `/tmp`. `/.cache` becomes `/tmp`. |
| Chart `runAsUser 568` | `USER apps` in the image. |
| `serviceAccount` / RBAC (chart) | Not relevant to the image; Kubernetes-only. |
| Docker socket (not in chart values) | Not mounted. Document as a runtime concern in `settings.yaml` only if the app reads it. |

## 10. Risks, caveats and open questions

- Env var names and CLI flags are the main unknown. Confirm with `/app/portainer --help` in the built image. Do not write `settings.yaml` `env` before that.
- License text location and the licence on `LICENSE` (GitHub reports Zlib) are UNVERIFIED for this run.
- Admin setup timeout: the draft says Portainer locks first-run admin setup after a short window (inference). Confirm from docs or code. This is a runtime user caveat, not a test failure.
- Docker socket access grants root-equivalent access to the host. The image must not require it to start. Document that in the PR and in `settings.yaml` only if the binary reads it.
- arm64: tarball exists (section 1), not yet built or tested here.
- Blockers: none known. No musl, GPU, or privileged need from the upstream Dockerfile.

## 11. Build and test steps

From `apps/portainer`, per `.github/instructions/build-test-protocol.instructions.md`:

1. `docker buildx bake --print` (must exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. Run with an empty config volume:
   `docker run --rm -d --name portainer-probe --read-only --tmpfs /tmp -v portainer-probe-config:/config portainer:2.45.4`, then `docker logs -f portainer-probe`.
   Expected readiness signal: a line like `Starting Portainer` and a listening line for `:9000` (UNVERIFIED exact text; read from the real logs), with the process still running.
4. Cleanup: `docker rm -f portainer-probe; docker volume rm portainer-probe-config`.
5. `forgetool containers test --image portainer:2.45.4 --config ./apps/portainer/container-test.yaml`.
6. Only if amd64 is green: `image-all` arm64 build as a separate check.

Not run in this planning step.

## 12. PR checklist

- Branch: `feat/add-portainer`.
- Commit: `feat(portainer): add new container`.
- PR title: `feat(portainer): add new container`.
- Use `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections and checkboxes, and check only the boxes that apply.
- Notes section: `🤖 This PR is AI generated.`
- CLA notice: the contributor must sign the CLA at https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it. The `license/cla` check shows the status.
- Honest list of untested items: arm64 build, admin first-run, and anything not built or run locally.
- Note in the PR that the EE image (`portainer-ee`) is not part of this container.
