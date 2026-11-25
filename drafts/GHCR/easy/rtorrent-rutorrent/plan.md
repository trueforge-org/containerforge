# rtorrent-exporter — implementation plan
> Source: ./draft.md · Target: apps/rtorrent-exporter/ · Difficulty: easy · Role: sidecar (exportarr for the chart `rtorrent-rutorrent`) · Verified on 2026-11-25

Scope note: the draft's Overview and Container fields describe the rtorrent_exporter sidecar, but the draft's title and chart cover the main rtorrent + ruTorrent image (`ghcr.io/crazy-max/rtorrent-rutorrent`). This plan covers the exporter only. The main image needs its own draft before it can be ported.

## 1. Verified upstream facts

| Item | Value | Source |
| --- | --- | --- |
| Version | v1.3.2 (latest tag used by chart) | https://github.com/thde/rtorrent_exporter/releases/tag/v1.3.2 (asset list via `gh api`) |
| Release date | not fetched (REST API rate-limited); UNVERIFIED | — |
| Renovate | `datasource=github-releases depName=thde/rtorrent_exporter versioning=semver` (standard for a GitHub tag `vX.Y.Z`) | derived from repo tags |
| License | Apache-2.0 | `gh api repos/thde/rtorrent_exporter/license` |
| amd64 asset | https://github.com/thde/rtorrent_exporter/releases/download/v1.3.2/rtorrent_exporter_1.3.2_linux_amd64.tar.gz | release asset list |
| arm64 asset | https://github.com/thde/rtorrent_exporter/releases/download/v1.3.2/rtorrent_exporter_1.3.2_linux_arm64.tar.gz | release asset list |
| Checksums | https://github.com/thde/rtorrent_exporter/releases/download/v1.3.2/rtorrent_exporter_1.3.2_checksums.txt | release asset list |
| sha256 amd64 | db8a6c2695e72a78931e0dc1a97a15c9acf004779bef9afb17bfcb5f7b42d126 | checksums file (fetched) |
| sha256 arm64 | 068f5af0a6e89170de4098cb971c69654e7f53edf12953e02398b62bb93ef2cd | checksums file (fetched) |
| Upstream Dockerfile reviewed | https://github.com/thde/rtorrent_exporter/blob/e79ce427fd812cb1e9d1b0e3be0a9180f8e69cca/Dockerfile | builder `cgr.dev/chainguard/go`, final `cgr.dev/chainguard/static`, `EXPOSE 9135`, binary `/usr/local/bin/rtorrent_exporter`, `GOARCH=amd64` hard-coded |
| Flags and env | `--web.listen-address` (default `:9135`, env `RTORRENT_EXPORTER_WEB_LISTEN_ADDRESS`), `--rtorrent.scrape-uri` (env `RTORRENT_EXPORTER_RTORRENT_SCRAPE_URI`), `--rtorrent.timeout=5s` (env `RTORRENT_EXPORTER_RTORRENT_TIMEOUT`), `--rtorrent.ssl-verify` (env `RTORRENT_EXPORTER_RTORRENT_SSL_VERIFY`), `--log.level`, `--log.format=logfmt|json`, `--web.telemetry-path`, `--web.config.file` | https://raw.githubusercontent.com/thde/rtorrent_exporter/v1.3.2/README.md |
| Chart values | exportarr image `ghcr.io/thde/rtorrent_exporter:v1.3.2@sha256:dac13545...`; `--rtorrent.scrape-uri` set from the xmlrpc service; metrics port 9135 | https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/rtorrent-rutorrent/values.yaml |
| Checksum source | the upstream `_checksums.txt` file | release asset list |

UNVERIFIED: whether the exporter starts with no scrape URI set (the README default is not stated). Confirm at run time (step 11).

## 2. Target layout

- `apps/rtorrent-exporter/Dockerfile`
- `apps/rtorrent-exporter/docker-bake.hcl`
- `apps/rtorrent-exporter/settings.yaml`
- `apps/rtorrent-exporter/container-test.yaml`
- `apps/rtorrent-exporter/start.sh` (only to map the ContainerForge env names to the upstream `RTORRENT_EXPORTER_*` names, and to `exec` the binary)

No `defaults/`, `etc/`, `health/` or `root/`: no seeded config and no extra files are needed. No `DOWNSTREAM_CHANGES.md`: nothing consumes this image as `FROM`.

## 3. Base image

- `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`
- Why: the binary is static (`CGO_ENABLED=0`), so any base works. Ubuntu is the house default for prebuilt binaries and matches the brief's rule for generic userland.
- Closest sibling: `apps/adguardhome-sync` (prebuilt tarball into `/app`, `USER apps`, `COPY --chmod=0755 . /`).

## 4. Dockerfile

1. `ARG VERSION` and `ARG TARGETARCH`. Map `amd64` to `linux_amd64` and `arm64` to `linux_arm64`. Stop on any other arch.
2. `USER root`. Install `curl` only if the base lacks it (check first; do not reinstall what the base has).
3. Download the tarball for the arch and the checksums file to `/tmp`. Verify with `sha256sum -c` against the upstream checksums file (`--ignore-missing`). Do not trust a checksum value copied from the draft without checking it against the file.
4. Extract `rtorrent_exporter` into `/app/`. Set `chown -R apps:apps /app && chmod -R 755 /app`. Copy the upstream `LICENSE` (Apache-2.0) to `/usr/share/licenses/rtorrent-exporter/` if the tarball ships one; otherwise note `UNVERIFIED` in the PR.
5. Remove the temp files in the same `RUN`.
6. `ENV` only if needed. Do not set `HOME` to a path that is not writable.
7. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 9135`, `CMD ["/start.sh"]`.

Version alignment: `ARG VERSION` must be `1.3.2` (tarball name uses no `v`) with the bake `VERSION` `v1.3.2` normalised to `1.3.2` in the URL. Use `${VERSION}` for the file name and `v${VERSION}` for the release path.

## 5. docker-bake.hcl

- `variable "APP" { default = "rtorrent-exporter" }`
- `variable "VERSION" { // renovate: datasource=github-releases depName=thde/rtorrent_exporter versioning=semver` followed by `default = "1.3.2"` (decide `v` vs no-`v` once and keep it consistent with the Dockerfile).
- `variable "LICENSE" { default = "Apache-2.0" }`
- `variable "SOURCE" { default = "https://github.com/thde/rtorrent_exporter" }`
- Four standard targets and the default group as in `apps/adguardhome-sync/docker-bake.hcl`: `docker-metadata-action`, `image`, `image-local`, `image-all`, `group "default"`.
- Validate: `cd apps/rtorrent-exporter && docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/thde/rtorrent_exporter"
ports:
  - port: 9135
    protocol: tcp
    required: true
env:
  - name: RTORRENT_EXPORTER_WEB_LISTEN_ADDRESS
    default: ":9135"
    required: false
  - name: RTORRENT_EXPORTER_RTORRENT_SCRAPE_URI
    default: ""
    required: true
  - name: RTORRENT_EXPORTER_LOG_LEVEL
    default: "info"
    required: false
volumes: []
dependencies: []
```

- `RTORRENT_EXPORTER_RTORRENT_SCRAPE_URI` is required with no safe default. Its empty-default case is covered in section 9.
- No `/config`: the exporter is stateless, so `volumes` stays empty. Do not invent a volume.
- Do not list `TZ` or other vars the binary does not read.

## 7. start.sh

- Shebang `#!/usr/bin/env bash`, no writes outside `/tmp`.
- If `RTORRENT_EXPORTER_RTORRENT_SCRAPE_URI` is empty, print one clear error line and `exit 1`, so the failure is visible in the logs rather than a crash loop.
- `exec /app/rtorrent_exporter` (the binary reads its own env vars, so no flags are needed).
- Keep the listen address at `:9135` (all interfaces), as the standard requires.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

tcp:
- port: '9135'
```

- One `tcp` probe for port 9135, matching `settings.yaml`.
- The test runs with no env vars, so the scrape URI is missing in the test. Two options, choose one and state it in the PR:
  1. Expect the start.sh error path to exit 1 and assert that (a real check of the guard), or
  2. Set a dummy scrape URI in a test-only env if forgetool supports env in the test file (UNVERIFIED; check the schema).
- Do not drop the probe to make a missing-env run pass.

## 9. Rootless and read-only-rootfs adaptations

- Runs as `apps` (from base). Binary is in `/app`, which is read-only at runtime; the exporter writes nothing.
- No `/config`, no seeded state, so the empty-`/config` rule is trivially met.
- Upstream chart runs the main app as root with `readOnlyRootFilesystem: false`. That is a property of the main image and does not carry over to this exporter, which needs root for nothing.
- Chart's `PUID 33` env is an artifact of the main image and is not used by the exporter. Do not add it.
- Run with `--read-only --tmpfs /tmp` (step 11).

## 10. Risks, caveats and open questions

- Scope: this is only the exporter. The chart's real main image (`ghcr.io/crazy-max/rtorrent-rutorrent`, tag `4.2.9-0.9.8_2-0.13.8_1`) needs its own draft. Its layout (`/data`, `/downloads`, `/passwd`, no `/config`) is a remapping job.
- The upstream Dockerfile hard-codes `GOARCH=amd64`. The arm64 release asset is built separately upstream; its behavior is not re-verified here. Smoke-test arm64 only if the build step for arm64 is run.
- The draft's Reason says "stateless, rootless, no writable paths". This is confirmed by the README (no file paths are listed).
- Blockers: none for the exporter itself. No musl-only build (the tarballs are static Go binaries), no GPU, no privileged needs.

## 11. Build and test steps

1. `cd apps/rtorrent-exporter && docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. `docker run --rm -d --name rtorrent-exporter-probe --read-only --tmpfs /tmp -v rtorrent-exporter-probe-config:/config -e RTORRENT_EXPORTER_RTORRENT_SCRAPE_URI=http://127.0.0.1:8000/RPC2/ rtorrent-exporter:<version>`
4. `docker logs -f rtorrent-exporter-probe` and look for a `listening on` line on :9135 and no fatal error.
5. `forgetool containers test --image rtorrent-exporter:<version> --config ./apps/rtorrent-exporter/container-test.yaml`
6. Cleanup: `docker rm -f rtorrent-exporter-probe; docker volume rm rtorrent-exporter-probe-config`

Readiness signal to expect: a listen log on port 9135 (exact text to confirm from the first run; UNVERIFIED).

## 12. PR checklist

- Branch: `feat/add-rtorrent-exporter`
- Commit / PR title: `feat(rtorrent-exporter): add new container`
- Notes section: `🤖 This PR is AI generated.`
- CLA: the user must sign at https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; the `license/cla` check shows the status).
- PR template: fill in `.github/PULL_REQUEST_TEMPLATE.md`, tick only the boxes that apply.
- Untested items to state honestly in the PR: arm64 run, the forgetool run (if not available locally), and the upstream LICENSE presence in the tarball.
