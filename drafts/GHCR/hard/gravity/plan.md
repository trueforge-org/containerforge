# gravity — implementation plan
> Source: ./draft.md · Target: apps/gravity/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `v0.34.0` (latest tag in https://github.com/BeryJu/gravity; highest seen in `git ls-remote --tags`). Release date: UNVERIFIED (GitHub API rate-limited on 2026-11-25). Source pin for the Dockerfile: `VERSION=v0.34.0`. |
| Chart image (draft) | `ghcr.io/beryju/gravity:v0.34.0@sha256:477047a127d07a5c5d96691a668939e74ab7a348aa8e766b5ba9c35b30135acc` (digest matches GHCR manifest for `v0.34.0`, 2026-11-25). |
| Renovate | Source: `datasource=github-tags depName=BeryJu/gravity versioning=semver`. |
| License | GPL-3.0 (LICENSE is GNU GPL v3 text: https://raw.githubusercontent.com/BeryJu/gravity/38c7947343d673dbe379ba3cc412fabf773ff7d9/LICENSE). SPDX `-only` vs `-or-later`: UNVERIFIED. |
| Source URL | https://github.com/BeryJu/gravity (docs https://gravity.beryju.io/docs/). |
| Download | Source tarball `https://github.com/BeryJu/gravity/archive/refs/tags/${VERSION}.tar.gz`. Upstream publishes gravity-cli binaries only (per draft; the server is not published). |
| Checksum source | None published for the source tarball. Pinned by tag. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/BeryJu/gravity/38c7947343d673dbe379ba3cc412fabf773ff7d9/Dockerfile. Four stages: `node:26` (web UI, `make web-build`); `ubuntu:26.04` (`make internal/resources/macoui internal/resources/blocky internal/resources/tftp`, uses `tshark` and `curl` to fetch data); `golang:1.27` (`CGO_ENABLED=0 GOOS=linux GOARCH=$TARGETARCH`, `make ${GRAVITY_BUILD_ARGS} docker-build`); `debian:stable-slim` (installs `nmap`, `bash-completion`, `bash`, `ca-certificates`; `mkdir /data && chown 65532:65532 /data`; `ENTRYPOINT ["/bin/gravity"]`, `CMD ["server"]`). |
| Makefile build | https://raw.githubusercontent.com/BeryJu/gravity/38c7947343d673dbe379ba3cc412fabf773ff7d9/Makefile: `docker-build` target runs `go build -ldflags "$LD_FLAGS -X beryju.io/gravity/pkg/extconfig.BuildHash=$GIT_BUILD_HASH" -v -a -o gravity ./cmd/server/main`. `LD_FLAGS` sets `beryju.io/gravity/pkg/extconfig.Version=$VERSION`. `internal/resources/macoui` runs `tshark -G manuf`; `blocky` curls `https://adaway.org/hosts.txt`; `tftp` fetches a TFTP resource (URL not read). |
| Go module | `module beryju.io/gravity`, `go 1.27.3` (https://raw.githubusercontent.com/BeryJu/gravity/38c7947343d673dbe379ba3cc412fabf773ff7d9/go.mod). |
| Ports | Chart: `main` http 8008/tcp (targetPort 8008); `dns-tcp` 53/tcp; `dns-udp` 53/udp (values.yaml). Upstream Dockerfile has no EXPOSE. Draft's 8080, 67/udp, 69/udp: not in the chart; UNVERIFIED. |
| Env (chart only) | `INSTANCE_IP=127.0.0.1`, `INSTANCE_LISTEN=0.0.0.0`, `INSTANCE_IDENTIFIER=truecharts-dns-gravity`, `BOOTSTRAP_ROLES="dns;api;etcd;discovery;backup;monitoring;tsdb"`, `ADMIN_PASSWORD` (secret), `ADMIN_TOKEN` (secret). Whether the binary reads these names is UNVERIFIED (the upstream Dockerfile does not declare env). Source: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/gravity/values.yaml |
| Data path | Chart persistence `data` -> `/data`. Upstream creates `/data` owned by 65532. |
| Chart security | `runAsUser: 0`, `runAsGroup: 0`. `readOnlyRootFilesystem` not set (common default). `privileged` not set. |
| Dependencies | None external. Embedded roles run inside the same binary. |
| arm64 | Image published for linux/amd64 and linux/arm64 (GHCR `latest` manifest; v0.34.0 index per-arch entries not parsed: UNVERIFIED for v0.34.0 specifically). |

## 2. Target layout

- `apps/gravity/Dockerfile`
- `apps/gravity/docker-bake.hcl`
- `apps/gravity/settings.yaml`
- `apps/gravity/container-test.yaml`
- `apps/gravity/start.sh`

No `defaults/` unless the server needs a seed config (UNVERIFIED: not seen in the upstream image). No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

Build stages: `docker.io/library/node:26` (web UI, as upstream) and `docker.io/library/golang:1.27` (go.mod requires 1.27.3). Digests UNVERIFIED: resolve and pin at implementation time.

Final stage: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. Upstream's final stage is `debian:stable-slim`; ubuntu is the ContainerForge rule.

Closest sibling for the Go-build pattern: `apps/pwndrop` (build stage, `COPY --from=buildstage`). Closest for a DNS/network service: none confirmed; `apps/wg-easy` is the only app whose settings mention network-privilege terms, and its test was checked only for those terms.

## 4. Dockerfile

1. `FROM docker.io/library/node:26@sha256:<UNVERIFIED> AS web` and `FROM docker.io/library/golang:1.27@sha256:<UNVERIFIED> AS build`, `FROM <ubuntu> AS final`.
2. `web` stage: fetch source tarball `${VERSION}`, `make web-install && make web-build` (targets in Makefile lines 56 and 61). Output `web/dist/`. Use `ENV NODE_ENV=production`; npm cache under `/tmp` (`npm_config_cache=/tmp/npm`).
3. `build` stage: `ARG VERSION`, `ARG TARGETARCH`. Source extracted to `/tmp/src`. Copy `web/dist/` from `web`. Run the Go-side resource targets that do not need network beyond the tarball, or fetch them with `curl` as upstream does (`tshark` needed for `macoui`: install `tshark` in a build-only stage, or pin the result file if upstream does not pin it; UNVERIFIED which approach is cleanest).
4. `CGO_ENABLED=0 GOOS=linux GOARCH=$TARGETARCH GOCACHE=/tmp/gocache GOPATH=/tmp/gopath`, then:
   ```dockerfile
   RUN cd /tmp/src && go build -trimpath \
     -ldflags "-s -w -X beryju.io/gravity/pkg/extconfig.Version=${VERSION} -X beryju.io/gravity/pkg/extconfig.BuildHash=${VERSION}" \
     -o /tmp/out/gravity ./cmd/server/main
   ```
   `-a` from upstream is dropped unless needed; `BuildHash` uses the tag (UNVERIFIED: upstream uses `git rev-parse HEAD`, and no `.git` exists in a tarball).
5. `final` stage: `USER root`, `apt-get install -y --no-install-recommends nmap bash-completion ca-certificates` (`bash` is in the base). `rm -rf /var/lib/apt/lists/*`.
6. `COPY --from=build /tmp/out/gravity /app/gravity/gravity`, `ln -s /config/data /data` (dangling until `start.sh` creates `/config/data`, see sections 6 and 9), `COPY --from=build /tmp/src/LICENSE /usr/share/licenses/gravity/LICENSE`. `chown -R apps:apps /app/gravity && chmod -R 755 /app/gravity`.
7. Tail:
   ```dockerfile
   USER apps
   COPY --chmod=0755 . /
   ENV HOME=/config
   EXPOSE 8008
   VOLUME /config
   ```
   Note `CMD ["server"]` in upstream: `start.sh` does the exec, not a CMD.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "gravity" }
variable "VERSION" {
  // renovate: datasource=github-tags depName=BeryJu/gravity versioning=semver
  default = "v0.34.0"
}
variable "LICENSE" { default = "GPL-3.0-only" }   # UNVERIFIED -only vs -or-later
variable "SOURCE" { default = "https://github.com/BeryJu/gravity" }
```

Keep `v` prefix to match the tag. Four standard targets and the default group copied from `apps/adguardhome-sync`. Validate with `docker buildx bake --print` in `apps/gravity/`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/BeryJu/gravity"
ports:
  - port: 8008
    protocol: tcp
    required: false
env:
  - name: INSTANCE_LISTEN
    default: "0.0.0.0"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
  - path: /data
    required: false
dependencies: []
```

- Only `INSTANCE_LISTEN` is listed as an env, because its name and behaviour are the only ones confirmed to matter for binding; the chart's other names are UNVERIFIED for the binary and must not be listed until confirmed in step 2 (`gravity server --help` or source `pkg/` config reading).
- `ADMIN_TOKEN` and `ADMIN_PASSWORD`: the chart requires them (placeholder `PLACEHOLDERADMINTOKEN…`, password `password`). Do not ship defaults. If the binary requires them, `start.sh` must generate them on first run into `/config` and never use the chart's placeholders (see section 7).
- `/data` vs `/config`: the upstream image uses `/data`; ContainerForge state should live in `/config`. Decide in step 2 whether to set `GRAVITY_DATA` (or equivalent, UNVERIFIED) to `/config/data`, or to symlink `/data` to `/config/data` at build time (the symlink is preferred and avoids a runtime env name).
- Ports 53, 67, 69: not in the first milestone (section 10). Do not list them.

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config/data
# Create the admin token/password under /config only if missing (idempotent).
if [ ! -s /config/admin.env ]; then
  umask 077
  { echo "ADMIN_TOKEN=$(head -c 32 /dev/urandom | base64 | tr -d '/+=' | cut -c1-40)"; } > /config/admin.env
fi
set -a; . /config/admin.env; set +a

export INSTANCE_LISTEN="${INSTANCE_LISTEN:-0.0.0.0}"
cd /config
exec /app/gravity/gravity server
```

Notes:
- The admin token is generated once and kept in `/config`, never in `/app`, never in the process list beyond the env (protocol: keep secrets out of files and the process list: revise to a file-based secret if the binary supports `*_FILE`, UNVERIFIED).
- `ADMIN_PASSWORD` default is not set by this script; if the binary requires one, generate it the same way. Do not reuse the chart's `password`.
- `/config/data` is created before `exec`; `/data` symlink from the image points there.
- No writes to `/app`; `/tmp` for any scratch.
- Confirm the exact env names the binary reads before writing this (section 10).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '8008'
http:
- port: '8008'
  path: /
filePaths:
- /app/gravity/gravity
- /usr/share/licenses/gravity/LICENSE
```

Test runs with no env. `start.sh` must generate the token on first run, so the test covers the empty-`/config` path. If `/` requires auth and returns 401, use the path that returns 200 or a status code the schema accepts (UNVERIFIED). Ports 53 and 67 are not probed (not in settings).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path / need | Remap |
| --- | --- |
| `/data` (chart PVC, upstream image dir) | Symlink `/data` -> `/config/data` at build time, owned by `apps`. |
| Scratch, Go caches | `/tmp` in build; `HOME=/config` only for user-level state the binary writes (check; else `/tmp`). |
| Ports 53/67/69 (privileged below 1024; DHCP needs broadcast) | Not in scope for the first milestone. For a later milestone they need either `CAP_NET_BIND_SERVICE` (not available under ContainerForge `USER apps` by default), `hostNetwork`, or running as root. Decision needed from the user (section 10). |
| Runtime user | Chart forces root. ContainerForge rule: `USER apps`. Web UI and API bind on 8008 (unprivileged), so `apps` is sufficient for the first milestone (UNVERIFIED by running it). |
| `readOnlyRootFilesystem` | Compatible if the binary writes only to `/config` and `/tmp` (verify in step 3 with `--read-only --tmpfs /tmp`). |

## 10. Risks, caveats and open questions

- **Scope decision (blocker for DNS/DHCP).** The chart's purpose is DHCP and DNS, which need privileged ports and host networking. ContainerForge runs `USER apps`. Options: (a) ship the web UI/API only, roles set without `dns`/`dhcp` (confirm role names in the binary; the chart's `BOOTSTRAP_ROLES` lists `dns;api;etcd;discovery;backup;monitoring;tsdb` without DHCP); (b) ship with root and the host network, which is a deliberate exception the user must approve; (c) stop as `blocked`. The plan proposes (a) for the first PR and asks the user before (b).
- Chart forces root: the ContainerForge image must run as `apps`. Do not reintroduce root to satisfy the chart.
- The chart's `ADMIN_TOKEN` and `ADMIN_PASSWORD` are placeholders. They must never become image defaults.
- Upstream binary is not published (only gravity-cli). The image is only as good as the local build. arm64 is UNVERIFIED until built.
- `tshark` is needed only to build `macoui`; installing it into the final image is not required. Keep it build-only, or ship the generated resource file if the upstream build allows it.
- Blocky `adaway.org` hosts and TFTP resources are fetched during the build (network at build time). Build reproducibility is UNVERIFIED; pin the fetched content by checksum if possible.
- `INSTANCE_IP=127.0.0.1` in the chart: the instance advertises localhost; a real deployment needs the LAN IP. This is a configuration caveat, not an image default to copy.
- Draft's read-only-rootfs `possible` is correct: the chart default applies, and the plan's `/tmp` plus `/config` layout should satisfy it.

## 11. Build and test steps

From `apps/gravity/`:

```sh
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name gravity-probe --read-only --tmpfs /tmp \
  -v gravity-probe-config:/config gravity:v0.34.0
docker logs -f gravity-probe
forgetool containers test --image gravity:v0.34.0 --config ./container-test.yaml
docker rm -f gravity-probe; docker volume rm gravity-probe-config
```

Expected readiness signal: an HTTP listen log line on 8008 (exact text UNVERIFIED until step 2). Run a second round with a pre-seeded `/config` to confirm the token file is not regenerated. Also test an arm64 build only if the amd64 build is clean (protocol).

## 12. PR checklist

- Branch `feat/add-gravity`; commit `feat(gravity): add new container`; PR title the same.
- PR body from `.github/PULL_REQUEST_TEMPLATE.md`; `🤖 This PR is AI generated.` in Notes.
- CLA: tell the user to sign at https://cla-assistant.io/trueforge-org/containerforge (only they can sign; the `license/cla` check shows status).
- State untested items: DNS, DHCP, privileged ports, host networking, arm64, the build-time network fetches.
- Do not check "Built container locally" unless steps 2 and 3 passed.
- No downstream `FROM` expected; confirm with `grep -rl "apps/gravity" apps/*/Dockerfile`.
