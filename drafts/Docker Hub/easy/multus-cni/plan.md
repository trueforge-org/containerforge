# crane (draft: multus-cni) — implementation plan
> Source: ./draft.md · Target: apps/crane/ · Difficulty: easy · Role: sidecar (craneImage of the multus-cni chart) · Verified on 2026-11-23

Naming note: the draft folder is `multus-cni`, but the image is the `crane` CLI (the Multus daemon is not built here). Name the app `crane` (lowercase, describes the content). If the maintainers insist on the chart name, only the folder/APP/tag change.

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | `0.22.1` (tag `v0.22.1`, Latest; chart uses `alpine/crane:0.22.1`, same) |
| Renovate | `datasource=github-releases depName=google/go-containerregistry versioning=semver` |
| License | Apache-2.0 (GitHub license API; the release tarball ships `LICENSE`) |
| Source URL | https://github.com/google/go-containerregistry |
| amd64 asset | https://github.com/google/go-containerregistry/releases/download/v0.22.1/go-containerregistry_Linux_x86_64.tar.gz |
| arm64 asset | https://github.com/google/go-containerregistry/releases/download/v0.22.1/go-containerregistry_Linux_arm64.tar.gz |
| Checksum source | `checksums.txt` in the same release (verified in asset list; also `multiple.intoto.jsonl` provenance). Line format `<sha256>  <file>` (verified). |
| Archive contents | goreleaser builds `crane`, `gcrane`, `krane` (verified from `.goreleaser.yml`, CGO off, static). The amd64 tarball holds `crane`, `gcrane`, `krane`, `LICENSE`, `README.md` at its root (inspected; arm64 UNVERIFIED). `crane version` prints the ldflags value `{{.Version}}`, i.e. `0.22.1` without `v` (from `.goreleaser.yml` and `version.go`). |
| Upstream Dockerfile reviewed | `alpine-docker/crane/Dockerfile` (named in draft): NOT fetched, UNVERIFIED. Not needed; we install the release tarball. |
| Ports / env / data | None. crane is a CLI; reads `~/.docker/config.json` (or `DOCKER_CONFIG`) for registry auth (standard crane behavior, UNVERIFIED in this session). |
| Other assets | `go-containerregistry-0.22.1.tar.gz` (source), many OS/arch tarballs |

## 2. Target layout

```
apps/crane/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh      # tiny: exec the command the chart passes, else print crane help
```

No `defaults/`, `etc/`, `root/`. No `DOWNSTREAM_CHANGES.md` unless another app later uses it as a `FROM` base.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`

Why: static Go CLI, glibc irrelevant, `curl`, `tar`, `ca-certificates`, `bash`, `sha256sum` (coreutils) already in the base so no apt step. The old alpine image had `sh`; ubuntu has `sh` and `bash`, so chart commands using `sh -c` keep working. Closest sibling: `apps/adguardhome-sync` (tarball per arch from GitHub releases).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`, `ENV HOME=/config`.
2. `RUN set -eux`:
   - Map: `case "${TARGETARCH}" in amd64) A=x86_64;; arm64) A=arm64;; *) exit 1;; esac`.
   - `base=https://github.com/google/go-containerregistry/releases/download/v${VERSION}`
   - `curl -fsSL -o /tmp/crane.tar.gz "$base/go-containerregistry_Linux_${A}.tar.gz"`; `curl -fsSL -o /tmp/checksums.txt "$base/checksums.txt"`.
   - Verify: `cd /tmp && grep " go-containerregistry_Linux_${A}.tar.gz\$" checksums.txt | sha256sum -c -`.
   - Extract only the CLI: `mkdir /tmp/crane && tar xzf /tmp/crane.tar.gz -C /tmp/crane`, `install -m 0755 /tmp/crane/crane /usr/local/bin/crane` (binary under `/usr/local/bin` so `/app` stays empty for downstream consumers; allowed by the Dockerfile rules).
   - License: `mkdir -p /usr/share/licenses/crane`; `cp /tmp/crane/LICENSE /usr/share/licenses/crane/`. Only part of the archive is extracted, so shipping the license is required.
   - `rm -rf /tmp/*`.
3. `USER apps`, `COPY --chmod=0755 . /`, `WORKDIR /config`.
4. No `EXPOSE` (no port). `VOLUME /config` (registry credentials under `$HOME/.docker`).

## 5. docker-bake.hcl

`APP=crane`; `VERSION` with `// renovate: datasource=github-releases depName=google/go-containerregistry versioning=semver` default `"0.22.1"`; `LICENSE="Apache-2.0"`; `SOURCE="https://github.com/google/go-containerregistry"`. Targets `docker-metadata-action`, `image`, `image-local`, `image-all` and `group "default"` as in `apps/adguardhome-sync/docker-bake.hcl`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/google/go-containerregistry"
ports:
  []
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: false
```

(`ports: []` follows `apps/ubuntu/settings.yaml`.) `DOCKER_CONFIG` is read by crane but is not set by us, so do not list it. `dependencies`: none.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

# Sidecar use: the chart supplies the command; the ubuntu entrypoint passes it as arguments.
if [[ "$#" -gt 0 ]]; then
  exec "$@"
fi
exec /usr/local/bin/crane --help
```

Idempotent, writes nothing, no config seeding needed. Without arguments it prints help and exits 0 (CLI, not a daemon).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

# crane is a CLI with no port or long-running process; verify the install instead.
# forgetool skips filePaths when mainRunner is disabled, so files are checked by runners.
runners:
- entrypoint: /usr/local/bin/crane
  cmd: --help
  expectedOutput: tool for managing container images
  exitCode: 0
- entrypoint: /usr/bin/ls
  cmd: /usr/share/licenses/crane/LICENSE
  expectedOutput: /usr/share/licenses/crane/LICENSE
  exitCode: 0

mainRunner:
  enabled: false
```

Pattern based on `apps/limnoria/container-test.yaml` (runners + disabled mainRunner; cmd kept space-free). No ports in settings.yaml, so no tcp probe is required. The version string is not asserted here, because a hard-coded version would fail on every Renovate bump; check `crane version` by hand (section 11). The `--help` text comes from `cmd/crane/cmd/root.go` (printed output UNVERIFIED until run).

## 9. Rootless and read-only-rootfs adaptations

- crane writes nothing by default; `HOME=/config` for optional `~/.docker/config.json`; scratch to `/tmp`.
- Draft security expectations (privileged, hostNetwork, hostPID, hostPath mounts, runAsUser 0) belong to the Multus daemon/installer containers of the chart, not to this crane sidecar. The crane image itself runs as `apps` (568), needs no privilege, and works with `readOnlyRootFilesystem: true`. Reconciliation: the sidecar must not be given the privileged settings; if the chart's command copies into hostPath mounts (e.g. `/opt/cni/bin`) the chart must supply write access/user (UNVERIFIED: how the chart uses the sidecar).

## 10. Risks, caveats and open questions

- Draft caveat: Kubernetes node component only; this image is just a CLI helper.
- Open: confirm what command the chart runs in the sidecar and whether it needs `sh`, `cp`, `tar` (present in ubuntu base) or root to write to hostPath.
- Open: app name `crane` vs `multus-cni`.
- arm64 tarball contents UNVERIFIED (amd64 layout and checksum format verified).
- The build-test protocol expects a container that stays running; a CLI image exits, so only the `sleep` run and the runners apply.
- No blockers: static, both arches published.

## 11. Build and test steps

```sh
cd apps/crane
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm --read-only --tmpfs /tmp -v crane-probe-config:/config crane:0.22.1 crane version
docker run --rm -d --name crane-probe --read-only --tmpfs /tmp -v crane-probe-config:/config crane:0.22.1 sleep 60   # empty /config start, check logs
forgetool containers test --image crane:0.22.1 --config ./apps/crane/container-test.yaml
docker rm -f crane-probe; docker volume rm crane-probe-config
```

Readiness signal: `crane version` prints `0.22.1` and exits 0; with no arguments the container prints help (exit 0). A network check (`crane manifest ghcr.io/trueforge-org/ubuntu:26.04`) is a useful manual extra.

## 12. PR checklist

- Branch `feat/add-crane`, commit/PR title `feat(crane): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`; `🤖 This PR is AI generated.` in Notes; check only applicable boxes.
- CLA notice for the user: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Confirm bake VERSION == Dockerfile ARG, `bake --print`, `USER apps`, checksum verified, license shipped.
- Untested at planning time: build, arm64, the test runners, the chart's actual sidecar command.
