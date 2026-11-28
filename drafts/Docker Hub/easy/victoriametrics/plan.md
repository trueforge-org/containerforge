# victoriametrics — implementation plan
> Source: ./draft.md · Target: apps/victoriametrics/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Upstream | https://github.com/VictoriaMetrics/VictoriaMetrics (single-node "vmsingle"), docs https://docs.victoriametrics.com/ |
| Latest stable tag | `v1.157.0` (tags seen: v1.155.0, v1.156.0, v1.157.0). The draft pins `v1.156.0` from the chart; use `1.157.0` unless the maintainers want chart parity |
| Renovate | `datasource=github-releases depName=VictoriaMetrics/VictoriaMetrics versioning=semver` |
| License | Apache-2.0 (`LICENSE` at the tag is the Apache License 2.0 text) |
| Download (amd64) | `https://github.com/VictoriaMetrics/VictoriaMetrics/releases/download/v1.157.0/victoria-metrics-linux-amd64-v1.157.0.tar.gz` (HTTP 200) |
| Download (arm64) | `https://github.com/VictoriaMetrics/VictoriaMetrics/releases/download/v1.157.0/victoria-metrics-linux-arm64-v1.157.0.tar.gz` (HTTP 200) |
| Checksum source | `https://github.com/VictoriaMetrics/VictoriaMetrics/releases/download/v1.157.0/victoria-metrics-linux-<arch>-v1.157.0_checksums.txt`. Each file has two lines: the sha256 of the `.tar.gz` and of the inner `victoria-metrics-prod` binary. amd64 tarball sha256 `7b31192da6cf805b8b9244a904b022948e8022a067a822c30cb9f94600d0c387`, arm64 `e5368dec72d212dcb2b994345ab872245299000d37197f723123e63a50e573b5` (for cross-checking only; the Dockerfile fetches the file) |
| Tarball content | One binary, `victoria-metrics-prod`, no license file (the checksum file lists only the binary). Fetch `LICENSE` separately from `https://raw.githubusercontent.com/VictoriaMetrics/VictoriaMetrics/v1.157.0/LICENSE` |
| Upstream Dockerfile | Reviewed (`app/victoria-metrics/deployment/Dockerfile`): base image + `EXPOSE 8428` + `ENTRYPOINT ["/victoria-metrics-prod"]` + copy of the binary. No flags are baked in |
| Port | `8428/tcp` (HTTP API, web UI `/vmui`, `/health`, `/metrics`). Default when `-httpListenAddr` is unset is `:8428` (all interfaces; `app/victoria-metrics/main.go`) |
| Flags that matter | `-storageDataPath` (default `victoria-metrics-data`, relative to cwd), `-retentionPeriod` (default `1M`; a bare number means months), `-httpListenAddr`, `-envflag.enable` (reads flags from env vars; env name is the flag name with `.` replaced by `_`; command-line flags win), `-envflag.prefix` |
| Readiness log | `started VictoriaMetrics in N seconds` and `started server at http://...:8428/` |
| Auth | None by default; any client that can reach 8428 can read and write |
| Draft correction | The draft's links are the `-cluster.tar.gz` assets. Those contain `vminsert`, `vmselect` and `vmstorage` (cluster components), not the single-node binary. Use the non-cluster `victoria-metrics-linux-<arch>-v<version>.tar.gz` |

## 2. Target layout

```
apps/victoriametrics/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```

No `defaults/`, `etc/` or `health/`: the server needs no config file. `root/` is not used. No `DOWNSTREAM_CHANGES.md`: nothing in the repo builds `FROM` this image (re-check with `grep -r "trueforge-org/victoriametrics" apps/*/Dockerfile` before the PR).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`

Why: static Go binary from release tarballs, no runtime packages. Closest sibling: `apps/adguardhome-sync` (prebuilt Go tarball into `/app`). `curl`, `tar`, `ca-certificates` and `tzdata` are already in the base.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH` (values `amd64` / `arm64`, which match the upstream file names directly, so no mapping is needed).
2. `USER root`, `ENV HOME=/config`.
3. One `RUN`:
   - `cd /tmp`
   - `BASE="https://github.com/VictoriaMetrics/VictoriaMetrics/releases/download/v${VERSION#v}"` and `FILE="victoria-metrics-linux-${TARGETARCH}-v${VERSION#v}.tar.gz"`
   - `curl -fsSL -o "/tmp/${FILE}" "${BASE}/${FILE}"` and `curl -fsSL -o /tmp/checksums.txt "${BASE}/victoria-metrics-linux-${TARGETARCH}-v${VERSION#v}_checksums.txt"`
   - Verify: `grep " ${FILE}\$" /tmp/checksums.txt | (cd /tmp && sha256sum -c -)`. The checksum file has two-space separated `hash  name` lines, so the grep must match the tarball line only.
   - `tar xzf "/tmp/${FILE}" -C /app` (yields `/app/victoria-metrics-prod`)
   - `mkdir -p /usr/share/licenses/victoriametrics && curl -fsSL -o /usr/share/licenses/victoriametrics/LICENSE "https://raw.githubusercontent.com/VictoriaMetrics/VictoriaMetrics/v${VERSION#v}/LICENSE"`
   - `chown -R apps:apps /app && chmod -R 755 /app && rm -rf /tmp/*`
4. `USER apps`
5. `COPY --chmod=0755 . /`
6. `EXPOSE 8428`, `VOLUME /config`.

No apt packages.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "victoriametrics" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=VictoriaMetrics/VictoriaMetrics versioning=semver
  default = "1.157.0"
}
variable "LICENSE" { default = "Apache-2.0" }
variable "SOURCE"  { default = "https://github.com/VictoriaMetrics/VictoriaMetrics" }
```

Plus `target "docker-metadata-action" {}`, `image` (args VERSION, labels `org.opencontainers.image.source` and `.licenses`), `image-local` (`type=docker`, tag `${APP}:${VERSION}`), `image-all` (linux/amd64, linux/arm64), `group "default" { targets = ["image-local"] }`, copied from `apps/adguardhome-sync/docker-bake.hcl`. Run `docker buildx bake --print`.

## 6. settings.yaml

- Schema header, `schema_version: 1`, `upstream_env_url: "https://github.com/VictoriaMetrics/VictoriaMetrics"`.
- `ports`: `8428` / `tcp` / `required: false`.
- `env` (all real flags read through `-envflag.enable`):
  - `TZ` / `Etc/UTC` / false
  - `storageDataPath` / `/config/data` / false (start.sh default; upstream default is the relative `victoria-metrics-data`)
  - `retentionPeriod` / `1M` / false (matches upstream default)
  - `httpListenAddr` / `:8428` / false
- `volumes`: `/config` / required true.
- `dependencies`: none. (No ContainerForge `vmagent`/`vmalert` apps are assumed.)

## 7. start.sh

```bash
#!/usr/bin/env bash
mkdir -p "${storageDataPath:-/config/data}"
export storageDataPath="${storageDataPath:-/config/data}"
export retentionPeriod="${retentionPeriod:-1M}"
export httpListenAddr="${httpListenAddr:-:8428}"
cd /config
exec /app/victoria-metrics-prod -envflag.enable "$@"
```

- Seeds only a directory, and only when missing. No writes to `/app`; nothing in `/tmp` is needed.
- `:8428` binds all interfaces, so other containers can connect.
- `-envflag.enable` lets users set any other flag by environment name (for example `search_maxUniqueTimeseries`) without editing the script. Passing `"$@"` allows `args:` from Kubernetes to append flags. The data path flag is set through the exported env var, so a user can still override it on the command line.
- Final `exec` keeps the signal path for graceful shutdown (VictoriaMetrics flushes in-memory parts on SIGTERM).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '8428'
http:
- port: '8428'
  path: /health
filePaths:
- /app/victoria-metrics-prod
- /usr/share/licenses/victoriametrics/LICENSE
```

The http `path: /health` mirrors the `http` shape used by `apps/it-tools/container-test.yaml`; `/health` returns `OK` on the single-node server. No env var is required, so the test covers the normal path.

## 9. Rootless and read-only-rootfs adaptations

| Upstream behaviour | Remap |
| --- | --- |
| Data in `victoria-metrics-data` relative to cwd (the chart mounts `/victoria-metrics-data`) | `storageDataPath=/config/data`; the draft's "check that the data path points at /config" is handled in start.sh |
| Unclean-shutdown marker, snapshots and indexdb under the data dir | All inside `/config/data` |
| Binary at `/victoria-metrics-prod` | `/app/victoria-metrics-prod`, read-only |
| Chart runs as 568 with read-only rootfs | Matches: `USER apps`, nothing writes outside `/config`; `/tmp` is not used |

The draft's extra persistence (`/victoria-metrics-data` PVC) maps onto `/config`. Anyone migrating from the chart must move data into `/config/data` or set `storageDataPath`.

## 10. Risks, caveats and open questions

- Unauthenticated by default (also `/api/v1/write`, snapshots and delete APIs); expose only on trusted networks, or note `-httpAuth.*` flags in docs. Flags `snapshotAuthKey`, `forceMergeAuthKey` etc. exist.
- Draft pinned 1.156.0; 1.157.0 is newer. Decide on chart parity versus latest.
- Renovate `github-releases` for this repo also sees LTS-line and enterprise tags; check the first renovate PR does not propose an LTS patch release or an `-enterprise` asset.
- Disk space: the server stops accepting data below `-storage.minFreeDiskSpaceBytes` (default 100 MB); mention in docs.
- arm64: official tarball exists, so no blocker. The binary is a static Go build (UNVERIFIED: not run locally); confirm it starts on glibc ubuntu in the build step.
- Low risk: `retentionPeriod` bare numbers mean months; document the `1M` default.

## 11. Build and test steps

```sh
cd apps/victoriametrics
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create victoriametrics-probe-config
docker run --rm -d --name victoriametrics-probe --read-only --tmpfs /tmp \
  -v victoriametrics-probe-config:/config victoriametrics:1.157.0
docker logs -f victoriametrics-probe     # expect: started VictoriaMetrics in ... seconds
docker exec victoriametrics-probe curl -fsS http://127.0.0.1:8428/health
forgetool containers test --image victoriametrics:1.157.0 --config ./apps/victoriametrics/container-test.yaml
docker rm -f victoriametrics-probe; docker volume rm victoriametrics-probe-config
```

Optionally push a sample (`curl -d 'foo 1' http://localhost:8428/api/v1/import/prometheus`) and query it, then restart the container to confirm the data survives in `/config/data`. Optionally repeat on arm64 with `--platform linux/arm64`.

## 12. PR checklist

- Branch `feat/add-victoriametrics`; commit and PR title `feat(victoriametrics): add new container`; target `main`.
- Fill in `.github/PULL_REQUEST_TEMPLATE.md` fully, keeping its sections; check only boxes that apply.
- `🤖 This PR is AI generated.` in the Notes section.
- Tell the user about the CLA at https://cla-assistant.io/trueforge-org/containerforge (only they can sign; see the `license/cla` check).
- List what was not tested (arm64 run, long-run ingest, upgrade from the chart's data path) and do not tick "Built container locally" unless it was built.
- Pre-completion: bake print passes, build passes, empty-`/config` read-only run is clean, forgetool test passes, no assertion weakened, scratch containers removed.
