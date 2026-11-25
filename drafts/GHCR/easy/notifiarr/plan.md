# notifiarr — implementation plan
> Source: ./draft.md · Target: apps/notifiarr/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | v0.10.0, published 2026-11-07. Source: https://api.github.com/repos/Notifiarr/notifiarr/releases/latest. Draft tag `v0.10.0` matches. |
| Renovate | `datasource=github-releases depName=Notifiarr/notifiarr versioning=loose` (v-prefixed tags). |
| License | MIT (GitHub API, https://api.github.com/repos/Notifiarr/notifiarr). |
| Source | https://github.com/Notifiarr/notifiarr |
| Per-arch download | amd64: https://github.com/Notifiarr/notifiarr/releases/download/v0.10.0/notifiarr.amd64.linux.gz; arm64: https://github.com/Notifiarr/notifiarr/releases/download/v0.10.0/notifiarr.arm64.linux.gz |
| Checksums | amd64 `705f88ed9c002bc9cc7e429b2377bc563658899a675970902c1511fc035be260`; arm64 `65da3820f42fd57363c4c8d16a4dc65317ebbefbc1deae0322205f096a39430d`. Source: https://github.com/Notifiarr/notifiarr/releases/download/v0.10.0/checksums.sha256.txt (signed via `.sig`). |
| Draft's package | `.pkg.tar.zst` assets exist, but upstream's image copies the plain `.linux.gz` binary, so the plan uses that and avoids zstd. |
| Upstream Dockerfile | https://raw.githubusercontent.com/Notifiarr/notifiarr/85a85e8/init/docker/Dockerfile.alpine: `FROM alpine:3.24@sha256:be2656061b536c1883c4034790e21d0a09c5aaaf51968b89368a3c0371ea2c9a`, one stage, `COPY --chmod=755 ${TARGETPLATFORM}/notifiarr /notifiarr`, `ENTRYPOINT ["/notifiarr"]`, `EXPOSE 5454`, no USER (runs as root), no VOLUME. apk installs ca-certificates, ipmitool, smartmontools, zfs, sysstat, tzdata. |
| Env vars | Upstream sets only `TZ=UTC`, `PATH`, `USER=root`. Vars the program reads: UNVERIFIED (wiki https://notifiarr.wiki/ is an About page with no config details). |
| Config and data paths | UNVERIFIED. |
| Port | 5454 (EXPOSE in upstream Dockerfile). Bind address UNVERIFIED. |
| Dependencies | None found. Needs a Notifiarr account and API key (draft claim, UNVERIFIED on fetched pages). |
| arm64 | Available (`notifiarr.arm64.linux.gz`). |

## 2. Target layout

- `apps/notifiarr/Dockerfile`
- `apps/notifiarr/docker-bake.hcl`
- `apps/notifiarr/settings.yaml`
- `apps/notifiarr/container-test.yaml`
- `apps/notifiarr/start.sh`

No `defaults/`, `etc/` or `root/` needed. No `DOWNSTREAM_CHANGES.md` (not a FROM base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. Single static Go binary, so the glibc Ubuntu base is fine. Closest sibling: `apps/adguardhome-sync` (prebuilt tarball on ubuntu).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Map `TARGETARCH` to `amd64` or `arm64`. Any other arch fails the build.
3. `curl -fL` the `notifiarr.${arch}.linux.gz` asset into `/tmp`, verify sha256 against the pinned value, `gunzip` to `/app/notifiarr`, `chmod 0755`.
4. Ship license: fetch upstream `LICENSE` into `/usr/share/licenses/notifiarr/` (UNVERIFIED path in repo; confirm before build).
5. `apt-get install ca-certificates tzdata` only if not already in base (check first). Skip ipmitool/smartmontools/zfs/sysstat unless the feature is confirmed needed (UNVERIFIED).
6. Remove `/tmp` download.
7. `ENV HOME=/config`.
8. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 5454`, `VOLUME /config`, `ENTRYPOINT`/`CMD` via start.sh.

## 5. docker-bake.hcl

- `APP` = `notifiarr`; `VERSION` = `v0.10.0` with `// renovate: datasource=github-releases depName=Notifiarr/notifiarr versioning=loose` above it.
- `LICENSE` = `MIT`; `SOURCE` = `https://github.com/Notifiarr/notifiarr`.
- Standard targets: `docker-metadata-action`, `image`, `image-local`, `image-all`, default group `image-local`.
- Validate with `docker buildx bake --print` from `apps/notifiarr`.

## 6. settings.yaml

- Schema header and `schema_version: 1`; `upstream_env_url: "https://github.com/Notifiarr/notifiarr"`.
- `ports`: 5454/tcp, `required: false`.
- `env`: only `TZ` (default `Etc/UTC`) until the program's variables are confirmed (UNVERIFIED; do not invent names).
- `volumes`: `/config` required.
- `dependencies`: none.

## 7. start.sh

- Ensure `/config` exists; no writes to `/app`.
- Pass config path through the flag or env the program actually reads (UNVERIFIED; default to the binary's own default under `/config`).
- Finish with `exec /app/notifiarr`.

## 8. container-test.yaml

- Schema header as in siblings.
- `timeoutSeconds` from `apps/adguardhome-sync` family (UNVERIFIED value).
- `tcp: - port: '5454'`.
- `http:` probe on `/` if the web UI answers (UNVERIFIED path).
- `filePaths: [/app/notifiarr]`.

## 9. Rootless and read-only-rootfs adaptations

- Upstream runs as root; this image runs as `apps`.
- Writes must go to `/config` (state) or `/tmp` (scratch). The hardware-sensor tools in upstream apk (ipmitool, smartmontools, zfs, sysstat) need privileges and are not in the plan; document as a limitation if the feature is needed.
- No `privileged`. The draft's `readOnlyRootFilesystem` expectation is consistent with `--read-only --tmpfs /tmp`.
- The draft's `/etc/machine-id` hostPath is a chart detail, not required in ContainerForge unless the program reads it (UNVERIFIED).

## 10. Risks, caveats and open questions

- Runtime env vars and config path are UNVERIFIED; the plan does not invent them.
- Needs a Notifiarr account and API key to do anything useful; the test only proves startup.
- Sensor tools may be needed for some features; not confirmed.
- Blocker: none for amd64 or arm64.

## 11. Build and test steps

```sh
cd apps/notifiarr
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name notifiarr-probe --read-only --tmpfs /tmp -v notifiarr-probe-config:/config notifiarr:v0.10.0
docker logs -f notifiarr-probe
forgetool containers test --image notifiarr:v0.10.0 --config ./apps/notifiarr/container-test.yaml
docker rm -f notifiarr-probe; docker volume rm notifiarr-probe-config
```

Expected readiness: the process stays up and the log shows the web server listening on 5454 (exact line UNVERIFIED).

## 12. PR checklist

- Branch `feat/add-notifiarr`; commit `feat(notifiarr): add new container`.
- PR template from `.github/PULL_REQUEST_TEMPLATE.md`; `🤖 This PR is AI generated.` in Notes.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- State what was not tested: no image build or run has happened in this planning step.
