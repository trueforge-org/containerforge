# ddns-go — implementation plan
> Source: ./draft.md · Target: apps/ddns-go/ · Difficulty: easy · Role (main) · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | v6.18.0 (latest stable, published 2026-11-21). Draft/chart uses v6.17.9 (published 2026-11-17), which is older. Source: https://api.github.com/repos/jeessy2/ddns-go/releases/tags/v6.18.0 |
| Renovate | `datasource=github-releases depName=jeessy2/ddns-go versioning=semver` |
| License | MIT (GitHub SPDX). Source: https://github.com/jeessy2/ddns-go |
| Source URL | https://github.com/jeessy2/ddns-go |
| amd64 download | https://github.com/jeessy2/ddns-go/releases/download/v6.18.0/ddns-go_6.18.0_linux_x86_64.tar.gz (sha256 `e675f829a0fb85774ff6040f14b982cb78a8bbd8c3cbe5099cbdaf2615af98a2`) |
| arm64 download | https://github.com/jeessy2/ddns-go/releases/download/v6.18.0/ddns-go_6.18.0_linux_arm64.tar.gz (sha256 `a5ffd3e136aea3b213ef432791fea85e91df6b27af0ff5ce3d0eae3e954d32d4`) |
| Checksum source | `checksums.txt` asset: https://github.com/jeessy2/ddns-go/releases/download/v6.18.0/checksums.txt (confirmed to list both tarballs) |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/jeessy2/ddns-go/9d83c48bfa8a4cac6c6f58a00dedb49e9f848623/Dockerfile: `FROM alpine`, `apk add curl grep`, WORKDIR /app, `COPY ddns-go /app/`, `COPY zoneinfo /usr/share/zoneinfo`, `ENV TZ=Asia/Shanghai`, `EXPOSE 9876`, `ENTRYPOINT ["/app/ddns-go"]`, `CMD ["-l", ":9876", "-f", "300"]`. No USER, no VOLUME, no arch logic. The upstream image is musl (alpine), so `COPY --from` is not usable on glibc ubuntu. |
| Port | 9876 (EXPOSE and CMD `-l :9876`) |
| Flags | `-l` listen address, `-f` update interval in seconds, `-c` config file path, `-resetPassword`. Source: upstream README (https://github.com/jeessy2/ddns-go) |
| Env vars (real) | Only `TZ` is set by upstream. No other app env var is confirmed. Config comes from the web UI or `-c`. Do not invent env vars. |
| Config path | UNVERIFIED default. README examples mount `/opt/ddns-go:/root`, which suggests `$HOME/.ddns_go_config.yaml`. Set `-c /config/.ddns_go_config.yaml` explicitly in start.sh. |
| Dependencies | None. The user supplies a DNS provider API token in the web UI. |

## 2. Target layout

- `apps/ddns-go/Dockerfile`
- `apps/ddns-go/docker-bake.hcl`
- `apps/ddns-go/settings.yaml`
- `apps/ddns-go/container-test.yaml`
- `apps/ddns-go/start.sh`

No `defaults/`, `etc/` or `health/` needed: ddns-go creates its own config on first start. No `root/`. `DOWNSTREAM_CHANGES.md` not needed (not a FROM base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. Fits because the app is a single static Go binary run directly on glibc ubuntu, so no runtime image is needed. Closest sibling: `apps/adguardhome-sync` (prebuilt tarball on ubuntu, same shape).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`, `ENV HOME=/config`.
2. Map arch: `amd64` gets `x86_64`, `arm64` gets `arm64`. Example:
   ```dockerfile
   RUN case "${TARGETARCH}" in amd64) ARCH=x86_64 ;; arm64) ARCH=arm64 ;; *) exit 1 ;; esac && \
       curl -fsSL -o /tmp/ddns-go.tar.gz \
         "https://github.com/jeessy2/ddns-go/releases/download/v${VERSION}/ddns-go_${VERSION}_linux_${ARCH}.tar.gz" && \
       echo "<sha256 for the arch>  /tmp/ddns-go.tar.gz" | sha256sum -c - && \
       tar xzf /tmp/ddns-go.tar.gz -C /app ddns-go && rm /tmp/ddns-go.tar.gz
   ```
   Pin the two sha256 values per arch in the Dockerfile (from checksums.txt), or read them from `checksums.txt` and verify with `sha256sum -c --ignore-missing`. The bake `VERSION` is `6.18.0` (no leading `v`). The tag path uses `v${VERSION}` and the asset name uses `${VERSION}`, as in the URLs above.
3. Also ship the license: the tarball contains a LICENSE file (UNVERIFIED which member names it). Extract it to `/usr/share/licenses/ddns-go/LICENSE`.
4. `chown -R apps:apps /app && chmod -R 755 /app`.
5. `ENV HOME=/config`, `TZ` is read from the environment (default in settings.yaml).
6. Final: `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 9876`, `VOLUME /config`.
7. Do not copy upstream `zoneinfo`: ubuntu already ships tzdata.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "ddns-go"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=jeessy2/ddns-go versioning=semver
  default = "6.18.0"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/jeessy2/ddns-go"
}
```

Then the four standard targets and the default group copied from `apps/adguardhome-sync/docker-bake.hcl` (`image`, `image-local`, `image-all`, `group "default"`). Validate with `cd apps/ddns-go && docker buildx bake --print`. Note: `adguardhome-sync` uses `v${VERSION}` in the URL, so the Dockerfile here should match that pattern.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/jeessy2/ddns-go"
ports:
  - port: 9876
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

Dependencies: none. Only `TZ` is listed, as the only env var with a confirmed source (upstream `ENV TZ`). The update interval (`-f 300`) and listen address are fixed in start.sh, so they are not env vars.

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config
cd /config || exit 1

exec /app/ddns-go -l :9876 -f 300 -c /config/.ddns_go_config.yaml
```

Notes: idempotent, seeds nothing (ddns-go writes its config on first save via the web UI). No writes to `/app`. `-l :9876` and `-f 300` are the upstream CMD defaults (listen on all interfaces). No env var is read, because none is confirmed upstream. `exec` so the binary receives signals as PID 1 handoff.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 60
tcp:
- port: '9876'
http:
- port: '9876'
  path: /
filePaths:
- /app/ddns-go
- /usr/share/licenses/ddns-go/LICENSE
```

Every settings.yaml port has a tcp probe (AGENTS coverage rule). The http probe checks `/` returns 200 or the web UI redirect (confirm the status on first run). `timeoutSeconds` 60 is an estimate; use the sibling value of `adguardhome-sync` if it differs. No env-only code paths.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| Config (`$HOME/.ddns_go_config.yaml`, UNVERIFIED default) | `-c /config/.ddns_go_config.yaml` in start.sh, and `HOME=/config` |
| Caches / temp | Go binary writes no cache path confirmed. If any appears, use `/tmp`. |

Security reconciliation (draft expectations vs upstream): the chart sets runAsUser 0 and readOnlyRootFilesystem false. Upstream image has no USER, so it runs as root. ContainerForge runs as `apps` (UID 568) with read-only rootfs, which the port needs no root for: ddns-go only binds port 9876 (above 1024) and writes to /config. Expected result: non-root, read-only rootfs, not privileged. The draft's `/root` persistence is replaced by `/config`. `-c` is needed because the default path is UNVERIFIED.

## 10. Risks, caveats and open questions

- Version: the draft says v6.17.9. v6.18.0 is newer; use v6.18.0 unless a reason exists. Verify the tarball contains the `ddns-go` binary at its root (UNVERIFIED member list).
- The upstream image is alpine (musl). The release tarball is a static Go build, so it should run on glibc ubuntu, but this must be confirmed by the run step.
- DNS provider credentials are entered by the user in the web UI. Without them the app runs but updates nothing (inferred).
- Config path: the default location is UNVERIFIED; `-c` avoids the guess.
- Upstream README's docker example uses `--net=host`; on ContainerForge the port 9876 is published through the container port instead. The web UI must be reachable from another container (listen on `:9876`, all interfaces).
- Blockers: none known. No musl-only, GPU or privileged needs.

## 11. Build and test steps

```sh
cd apps/ddns-go
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name ddns-go-probe --read-only --tmpfs /tmp \
  -v ddns-go-probe-config:/config ddns-go:6.18.0
docker logs -f ddns-go-probe   # expect a line like "listening on" or the web UI start line
docker rm -f ddns-go-probe; docker volume rm ddns-go-probe-config
forgetool containers test --image ddns-go:6.18.0 --config ./apps/ddns-go/container-test.yaml
```

Expected readiness signal: process stays alive, and the log shows the ddns-go listen line on port 9876 with no fatal errors. Test with an empty `/config` volume. Then repeat with arm64 only if the amd64 run fails for an arch-specific reason.

## 12. PR checklist

- Branch: `feat/add-ddns-go`. Commit: `feat(ddns-go): add new container`. PR title matches the commit.
- PR template: `.github/PULL_REQUEST_TEMPLATE.md`. Keep its sections and checkboxes; check only what applies.
- Notes section includes `🤖 This PR is AI generated.`
- Tell the user about the CLA: contributions need a signed CLA at https://cla-assistant.io/trueforge-org/containerforge (the `license/cla` check shows status). Only the user can sign it.
- Say what was not tested: arm64 build and run (unless done), and the DNS update path (no provider account).
