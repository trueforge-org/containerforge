# truenas-exporter — implementation plan
> Source: ./draft.md · Target: apps/truenas-exporter/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | 0.17.0 (tag `v0.17.0`, released 2026-07-10, latest release; matches draft and the TrueCharts values tag) |
| Renovate | `datasource=github-releases depName=prometheus/graphite_exporter` |
| License | Apache-2.0 (GitHub API and repo `LICENSE`, plus `NOTICE`) |
| Source | https://github.com/prometheus/graphite_exporter |
| amd64 | https://github.com/prometheus/graphite_exporter/releases/download/v0.17.0/graphite_exporter-0.17.0.linux-amd64.tar.gz |
| arm64 | https://github.com/prometheus/graphite_exporter/releases/download/v0.17.0/graphite_exporter-0.17.0.linux-arm64.tar.gz |
| Correction to draft | The draft links the `dragonfly-amd64` asset for amd64. That is a BSD build and MUST NOT be used. Use `linux-amd64`. |
| Tarball content | `graphite_exporter-0.17.0.linux-<arch>/` with `graphite_exporter`, `getool`, `LICENSE`, `NOTICE` (verified for amd64) |
| Checksum | `https://github.com/prometheus/graphite_exporter/releases/download/v0.17.0/sha256sums.txt`; amd64 `109c1f94...c60469`, arm64 `95d49e7f...cfc3f435` (full values are in that file; the Dockerfile reads them at build time) |
| Upstream Dockerfile | `Dockerfile` on busybox: `COPY graphite_exporter /bin/`, `USER nobody`, `EXPOSE 9108 9109 9109/udp`, `ENTRYPOINT ["/bin/graphite_exporter"]` (reviewed) |

Flags and ports (README of v0.17.0): web `:9108` (`/metrics`, flag `--web.listen-address`), graphite ingest `:9109` on TCP and UDP (`--graphite.listen-address`), mapping file `--graphite.mapping-config=<file>`, `--graphite.mapping-strict-match`. The exporter reads no env vars (UNVERIFIED for all flags, only the ones above were checked in the README).

TrueNAS wrapper (https://github.com/Supporterino/truenas-graphite-to-prometheus, GPL-3.0): `FROM prom/graphite-exporter:v0.16.0`, copies `graphite_mapping.conf` (19766 bytes) to `/config/graphite_mapping.conf`, entrypoint `--graphite.mapping-config=/config/graphite_mapping.conf`. TrueCharts mounts the same file read-only at `/config/graphite_mapping.conf` and passes that argument.

## 2. Target layout

```
apps/truenas-exporter/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```
Optional `defaults/graphite_mapping.conf` only if the open question in section 10 is answered "bundle". No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image
`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`

Static Go binary, no extra packages. Closest sibling: `apps/redis-exporter` (release tarball + `sha256sums.txt` check + license kept).

## 4. Dockerfile
1. `ARG VERSION`, `ARG TARGETOS`, `ARG TARGETARCH` (values `linux`, `amd64`/`arm64` match the asset suffix).
2. `USER root`.
3. `RUN` like redis-exporter: `ARCHIVE="graphite_exporter-${VERSION}.${TARGETOS}-${TARGETARCH}"`; `curl -fsSLO` the tarball and `sha256sums.txt` from `.../releases/download/v${VERSION}/`; `grep " ${ARCHIVE}.tar.gz\$" sha256sums.txt | sha256sum -c -`; `tar xzf`; `install -m 0755 "${ARCHIVE}/graphite_exporter" /usr/local/bin/graphite_exporter`; copy `LICENSE` and `NOTICE` to `/usr/share/licenses/truenas-exporter/`; remove the archive, the directory and `sha256sums.txt`.
4. `USER apps`, `COPY --chmod=0755 . /`.
5. `EXPOSE 9108 9109 9109/udp`, `VOLUME /config`.
The `getool` helper in the tarball is not installed.

## 5. docker-bake.hcl
- `APP = "truenas-exporter"`
- `VERSION` with `// renovate: datasource=github-releases depName=prometheus/graphite_exporter`, default `"0.17.0"`
- `LICENSE = "Apache-2.0"`, `SOURCE = "https://github.com/prometheus/graphite_exporter"`
- Standard 4 targets and `group "default"`, copied from `apps/redis-exporter/docker-bake.hcl`. Run `docker buildx bake --print`.

## 6. settings.yaml
Schema header, `schema_version: 1`, `upstream_env_url: "https://github.com/prometheus/graphite_exporter"`.
- ports: `9108` tcp (metrics, required false), `9109` tcp (graphite ingest), `9109` udp (graphite ingest). Schema support for `udp` is already used by `apps/emby/settings.yaml`.
- env: `TZ` (default `Etc/UTC`) and `EXPORTER_ARGS` (default `""`, extra flags appended by `start.sh`; this is a start.sh variable, the exporter itself reads no env). `GRAPHITE_MAPPING_CONFIG` (default `/config/graphite_mapping.conf`, also a start.sh variable).
- volumes: `/config` (required true, holds the mapping file).
- dependencies: none (TrueNAS is an external sender).

## 7. start.sh
```bash
#!/usr/bin/env bash
MAPPING="${GRAPHITE_MAPPING_CONFIG:-/config/graphite_mapping.conf}"
args=(--web.listen-address=":9108" --graphite.listen-address=":9109")
if [[ -f /defaults/graphite_mapping.conf && ! -f "${MAPPING}" ]]; then
  cp -n /defaults/graphite_mapping.conf "${MAPPING}"
fi
if [[ -f "${MAPPING}" ]]; then
  args+=("--graphite.mapping-config=${MAPPING}")
else
  echo "No mapping file at ${MAPPING}, running without a mapping (all metrics are auto-converted)."
fi
# shellcheck disable=SC2086
exec /usr/local/bin/graphite_exporter "${args[@]}" ${EXPORTER_ARGS:-}
```
Ports are listened on `:PORT`, so all interfaces. The `/defaults` branch is dead code unless the file is bundled (section 10).

## 8. container-test.yaml
```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 120
http:
- port: '9108'
  path: /metrics
tcp:
- port: '9109'
filePaths:
- /usr/local/bin/graphite_exporter
- /usr/share/licenses/truenas-exporter/LICENSE
```
The UDP port has no probe type in forgetool (UNVERIFIED), so only the TCP side of 9109 is tested; note this in the PR. Without a mapping file the app still starts, so the no-env test passes. The mapping-file path is exercised manually (section 11).

## 9. Rootless and read-only-rootfs adaptations
- The exporter keeps state in memory only and writes no files. The only read path is the mapping file in `/config`.
- Draft expects UID 568, readOnlyRootFilesystem true, not privileged: all fine with `USER apps`. The draft's extra persistence `/config/graphite_mapping.conf` is covered by the `/config` volume (TrueCharts mounts it as a configmap file over `/config/graphite_mapping.conf`, which works because `start.sh` only copies when missing).
- Ports 9108/9109 are above 1024, so no capabilities are needed.

## 10. Risks, caveats and open questions
- Open: bundle the TrueNAS mapping? It is a GPL-3.0 file from a different project, while the exporter is Apache-2.0, and `LICENSE` in bake must match the image. Recommended default: do NOT bundle; users mount `/config/graphite_mapping.conf` (as TrueCharts does). If bundled, pin a commit, ship its license in `/usr/share/licenses/truenas-exporter/`, and set the label to `Apache-2.0 AND GPL-3.0-only` (decision for the maintainer).
- The draft's doubt about the binary is settled: the TrueCharts chart runs `prom/graphite-exporter:v0.17.0`, so the image is the upstream exporter, and `Supporterino/truenas-graphite-to-prometheus` is only a wrapper that adds the mapping.
- TrueNAS must be configured manually to send Graphite data to port 9109, and both TCP and UDP must be reachable.
- No blockers: Go static binary, both architectures published.

## 11. Build and test steps
```sh
cd apps/truenas-exporter
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name truenas-exporter-probe --read-only --tmpfs /tmp -v truenas-exporter-probe-config:/config truenas-exporter:0.17.0
docker logs -f truenas-exporter-probe   # expect "Listening on :9108" / graphite listener lines
echo "test_tcp 1 $(date +%s)" | nc <container-ip> 9109 && curl -s http://<container-ip>:9108/metrics | grep test_tcp
# second run with a mapping file placed in the fresh /config volume, check the logs show it loaded
docker rm -f truenas-exporter-probe; docker volume rm truenas-exporter-probe-config
forgetool containers test --image truenas-exporter:0.17.0 --config ./apps/truenas-exporter/container-test.yaml
```
Readiness signal: a `listening` log line for both listeners (exact text UNVERIFIED) and `/metrics` answering.

## 12. PR checklist
- Branch `feat/add-truenas-exporter`, commit `feat(truenas-exporter): add new container`, target `main`.
- Fill in the PR template, check only the true boxes.
- `🤖 This PR is AI generated.` in the Notes section.
- CLA notice: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- State untested: arm64 build, UDP ingest on 9109 (no forgetool probe), mapping-file load, real TrueNAS data.
