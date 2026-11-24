# docker — implementation plan
> Source: ./draft.md · Target: apps/docker/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | 29.10.0 (draft tag `29.10.0-dind`). `docker-29.10.0.tgz` is the newest file in https://download.docker.com/linux/static/stable/x86_64/ (listing checked; 29.9.2, 29.9.3, 29.10.0 are the last three). |
| Renovate | `datasource=github-releases depName=moby/moby versioning=semver`. UNVERIFIED: whether moby/moby release tags are `v29.10.0` (needs `extractVersion=^v(?<version>.+)$` if so) and whether every moby tag has a matching static tarball. |
| License | Apache-2.0 (https://raw.githubusercontent.com/moby/moby/master/LICENSE begins "Apache License Version 2.0"). |
| Source URL | https://github.com/moby/moby |
| Downloads | amd64: https://download.docker.com/linux/static/stable/x86_64/docker-29.10.0.tgz (HTTP 200, ~78.7 MB). arm64: https://download.docker.com/linux/static/stable/aarch64/docker-29.10.0.tgz (HTTP 200). Rootless extras (HTTP 200 on both arches): `.../docker-rootless-extras-29.10.0.tgz`. |
| Checksum | download.docker.com publishes no checksum file that I found. UNVERIFIED. The upstream docker-library Dockerfile pins a sha256 per arch; copy those from https://github.com/docker-library/docker/blob/70cd6b52204a3bf037510cb750e099c34b081bd4/29/dind/Dockerfile into `ARG` values and verify with `sha256sum -c`. |
| Upstream Dockerfile reviewed | docker-library/docker `29/dind/Dockerfile` at 70cd6b5. It is Alpine, installs `ip6tables iptables openssl pigz shadow-uidmap xz` plus `iptables-legacy`, fetches `hack/dind` from moby at `DIND_COMMIT=8d9e3502aba39127e4d12196dae16d306f76993d`, sets `EXPOSE 2375 2376`, `VOLUME /var/lib/docker`, `ENTRYPOINT ["dockerd-entrypoint.sh"]`, creates `dockremap` with subuid/subgid `165536:65536`, and extracts the static bundle without the `docker` CLI and `containerd` (it uses the embedded one). |
| Upstream entrypoint facts | `dockerd-entrypoint.sh`: if `DOCKER_TLS_CERTDIR` is set it generates certs there and listens on `tcp://0.0.0.0:2376` with TLS; otherwise `tcp://0.0.0.0:2375`. `DOCKER_TLS_SAN` adds SANs. `DOCKERD_ROOTLESS_ROOTLESSKIT_FLAGS` is used in rootless mode. |

## 2. Target layout

```
apps/docker/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```
No `defaults/`, `etc/` or `health/` needed. No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. The bundle is static Go binaries, so glibc Ubuntu is fine (the upstream image is Alpine only for size). Closest sibling: `apps/adguardhome-sync` (prebuilt tarball on ubuntu); for the netns/privilege side `apps/wireguard`.

## 4. Dockerfile

Recommended variant: rootless dockerd, so the final user can be `apps`.
1. `ARG VERSION`, `ARG TARGETARCH`; map `amd64 -> x86_64`, `arm64 -> aarch64` (`ARG DOCKER_ARCH`).
2. `USER root`; `apt-get install -y --no-install-recommends iptables pigz xz-utils uidmap fuse-overlayfs slirp4netns kmod e2fsprogs xfsprogs openssl`; the draft's list was inferred, `uidmap` (newuidmap/newgidmap), `slirp4netns` and `fuse-overlayfs` are needed for rootless, UNVERIFIED which of them rootlesskit in the extras tarball already needs externally. Check each package is not already in the base and pin versions per the dockerfile rules if the image must carry a specific version (the Docker version itself comes from the tarball, so apt pins are not tied to `VERSION`).
3. Download `docker-${VERSION}.tgz` and `docker-rootless-extras-${VERSION}.tgz` for `${DOCKER_ARCH}`, verify sha256, extract to `/usr/local/bin` (system binaries may live under `/usr/local`, keeping `/app` empty).
4. Subordinate IDs for `apps` (UID 568): `echo "apps:100000:65536" >> /etc/subuid` and `/etc/subgid`. Mark `newuidmap`/`newgidmap` setuid is part of the `uidmap` package.
5. Licenses: extract `docker/LICENSE`/`NOTICE` if present in the tarball (UNVERIFIED) and fetch https://raw.githubusercontent.com/moby/moby/v${VERSION}/LICENSE and `NOTICE` into `/usr/share/licenses/docker/`.
6. `ENV HOME=/config XDG_RUNTIME_DIR=/tmp/run DOCKER_HOST=unix:///tmp/run/docker.sock DOCKER_TLS_CERTDIR=/config/certs`.
7. `COPY --chmod=0755 . /`, `EXPOSE 2376`, `VOLUME /config`, final `USER apps`.

## 5. docker-bake.hcl

`APP=docker`, `VERSION=29.10.0` with
```hcl
// renovate: datasource=github-releases depName=moby/moby versioning=semver
```
`LICENSE=Apache-2.0`, `SOURCE=https://github.com/moby/moby`. Standard targets `docker-metadata-action`, `image`, `image-local` (`type=docker`, tag `${APP}:${VERSION}`), `image-all` (amd64, arm64), `group "default" { targets = ["image-local"] }`. Validate with `docker buildx bake --print`. Pass the per-arch sha256 as extra `args` only if they are not hardcoded in the Dockerfile (renovate then cannot bump them: open question, see 10).

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/moby/moby"
ports:
  - port: 2376
    protocol: tcp
    required: false
env:
  - name: DOCKER_TLS_CERTDIR
    default: "/config/certs"
    required: false
  - name: DOCKER_TLS_SAN
    default: ""
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```
Port 2375 only opens when `DOCKER_TLS_CERTDIR` is set empty (verified in upstream entrypoint), so it is not listed. `DOCKER_TLS_CERTDIR` and `DOCKER_TLS_SAN` are the only entrypoint vars verified.

## 7. start.sh

- `mkdir -p /config/docker-data /config/certs /tmp/run`.
- If `DOCKER_TLS_CERTDIR` is non-empty, generate CA, server and client certs there only when missing (port the `_tls_generate_certs` logic from upstream `dockerd-entrypoint.sh`, adding `DOCKER_TLS_SAN`); otherwise listen on `tcp://0.0.0.0:2375` and log a warning that the API is unauthenticated.
- Never write to `/app`. Data root `/config/docker-data` (draft expects `/var/lib/docker`; see 9).
- `exec dockerd-rootless.sh --host=unix:///tmp/run/docker.sock --host=tcp://0.0.0.0:2376 --tlsverify --tlscacert ... --tlscert ... --tlskey ... --data-root /config/docker-data`; set `DOCKERD_ROOTLESS_ROOTLESSKIT_FLAGS="-p 0.0.0.0:2376:2376/tcp"` like upstream. UNVERIFIED: exact flag set; `dockerd-rootless.sh` exists in the extras tarball (HTTP 200 for the tarball only).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 240
tcp:
  - port: '2376'
filePaths:
  - /usr/local/bin/dockerd
  - /usr/local/bin/docker
  - /usr/local/bin/runc
  - /usr/local/bin/containerd
healthCommands:
  - command: "dockerd --version"
    expectedExitCode: 0
```
`timeoutSeconds: 240` taken from the schema example (UNVERIFIED sibling value); no sibling runs a daemon. The test runs without env, so default TLS path (2376) is exercised. Whether the CI runner lets rootless dockerd start without `--privileged` is UNVERIFIED; do not weaken the tcp probe if it fails (see 10).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/var/lib/docker` (VOLUME) | `--data-root /config/docker-data` |
| `/certs/client`, `/certs` | `/config/certs` |
| `/var/run/docker.sock`, `/run` | `/tmp/run` (`XDG_RUNTIME_DIR`) |
| containerd state/root, `/var/lib/containerd` | under `--data-root`/`/tmp/run` (embedded containerd; UNVERIFIED exact flags) |
| `/etc/docker/daemon.json` | optional, read from `/config/daemon.json` via `--config-file` when present |

Draft expectations: UID 0, privileged, hostNetwork, writable rootfs, `/var/lib/docker` and `/certs/client` persistence. Reconciliation: ContainerForge requires `USER apps` and read-only rootfs, so use rootless dockerd. That still needs at least relaxed seccomp/AppArmor, `/dev/net/tun` or vfs storage and a `/config` on a filesystem that supports the overlay driver (`fuse-overlayfs` or `vfs`). It will not work with the draft's rootful features (host cgroup management, `--privileged` dind for arbitrary workloads). Persistence: `/config` only (data root plus certs); expose `/config/certs/client` for clients instead of `/certs/client`.

## 10. Risks, caveats and open questions

- BLOCKER (maintainer decision): the chart expects rootful, privileged DinD. Rootless docker in an unprivileged Kubernetes pod generally needs unconfined seccomp/AppArmor and user namespaces; the container test may not be able to start dockerd in CI. UNVERIFIED in this environment.
- The draft's caveats stand: dockerd needs host cgroups/kernel storage drivers; images pulled inside are not shared with the host; data root must be persistent.
- Static bundle contains `dockerd`, `containerd`, `runc`; upstream deliberately drops the `docker` CLI and standalone `containerd`. Decide whether to ship the CLI (small, useful for `docker info` health command).
- sha256 of the tarballs cannot be bumped by Renovate alone; consider fetching the checksums inside the build from a trusted location (none found) or accept a manual update.
- arm64 tarball exists (HTTP 200), runtime on arm64 untested.

## 11. Build and test steps

```sh
cd apps/docker
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name docker-probe --read-only --tmpfs /tmp \
  -v docker-probe-config:/config docker:29.10.0   # add --security-opt seccomp=unconfined --security-opt apparmor=unconfined if rootless needs them
docker logs -f docker-probe
docker rm -f docker-probe; docker volume rm docker-probe-config
forgetool containers test --image docker:29.10.0 --config ./apps/docker/container-test.yaml
```
Expected readiness: dockerd log `API listen on [::]:2376` (UNVERIFIED exact text, upstream dockerd prints "API listen on"), container still running, port 2376 open.

## 12. PR checklist

- Branch `feat/add-docker`, commit `feat(docker): add new container`, PR title the same, target `main`, template `.github/PULL_REQUEST_TEMPLATE.md` filled in with only applicable boxes checked.
- Notes section contains `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Untested to state honestly: image build, rootless dockerd start, tcp probe, arm64, TLS cert generation, checksums.
- Before completion: bake print ran, version aligned between Dockerfile and bake, `USER apps`, empty `/config` start works.
