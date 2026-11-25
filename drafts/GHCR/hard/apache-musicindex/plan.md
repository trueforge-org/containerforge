# apache-musicindex — implementation plan
> Source: ./draft.md · Target: apps/apache-musicindex/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | UNVERIFIED as an upstream release. The chart image is `ghcr.io/k8s-at-home/apache-musicindex:v1.4.1-2@sha256:c9bd82dc5fdaaad16a9a07c61672e29886d9399c7eee6e57f1d758124783c34a` (chart `https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/apache-musicindex/values.yaml`). The Ubuntu package is `libapache2-mod-musicindex` **1.4.1-6** on resolute (https://packages.ubuntu.com/resolute/libapache2-mod-musicindex). The image tag and the package version differ: the module code behind `v1.4.1-2` is UNVERIFIED. |
| Renovate | UNVERIFIED. No upstream GitHub release source is confirmed. For an apt-pinned package, the datasource is UNVERIFIED (proposed: `datasource=deb` on the Ubuntu archive, to be checked against renovate's supported datasources). |
| License | UNVERIFIED. The packages.ubuntu.com page does not show the license and links to a copyright file, which was not fetched. |
| Source URL | UNVERIFIED. Upstream homepage is `http://hacks.slashdirt.org/musicindex/` (from the Ubuntu package page). The fetch failed with a TLS name mismatch (the certificate is for `genealogy.slashdirt.org`), so the homepage and any source tarball are UNVERIFIED. |
| Per-arch download | Via apt, not a direct file. Architectures on resolute: amd64, arm64, armhf, ppc64el, riscv64, s390x (https://packages.ubuntu.com/resolute/libapache2-mod-musicindex). Download pages: `https://packages.ubuntu.com/resolute/amd64/libapache2-mod-musicindex/download` and `https://packages.ubuntu.com/resolute/arm64/libapache2-mod-musicindex/download`. Direct `.deb` URLs were not read. |
| Checksum source | apt signature verification via the Ubuntu archive (the apt keyring). No separate checksum file. |
| Upstream Dockerfile reviewed | None. The Dockerfile that built the k8s-at-home image was not found again in this run (UNVERIFIED; the draft says it is gone). |
| Chart (upstream) | Service port `10006` (`http`) mapped to container `targetPort: 80`. Security: `readOnlyRootFilesystem: false`, `runAsNonRoot: false`, `runAsUser: 0`, `runAsGroup: 0`. Persistence mount paths and env vars: not in the chart values (UNVERIFIED). |
| Ports | `80/http` (chart targetPort). `443/https`: UNVERIFIED (no evidence in the chart). |
| Dependencies | None. |
| Blockers (per draft and chart) | No upstream Dockerfile. The Apache config must be rewritten for a read-only rootfs and a non-root user. The music library mount path and permissions are UNVERIFIED. |

## 2. Target layout

- `apps/apache-musicindex/Dockerfile`
- `apps/apache-musicindex/docker-bake.hcl`
- `apps/apache-musicindex/settings.yaml`
- `apps/apache-musicindex/container-test.yaml`
- `apps/apache-musicindex/start.sh`
- `apps/apache-musicindex/etc/` for the Apache config the image ships (`apache2.conf` and `sites-enabled/` overrides), since `/etc` is read-only at runtime and the config must be readable by `apps`. Reason: the packaged Apache config does not work with a read-only rootfs and a non-root user (see section 9).

`root/` is never used. `DOWNSTREAM_CHANGES.md` is not needed (not a `FROM` base).

## 3. Base image

- `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`.
- Why: Apache with an apt-installed module, so no language runtime is needed (the draft's "Runtime image: none").
- Closest sibling: `apps/it-tools` (web server on the ubuntu-family base with `defaults/` and `docker-entrypoint.d`). Pick the closest Apache sibling in `apps/` at build time (UNVERIFIED: no Apache sibling checked in this run).

## 4. Dockerfile

1. `FROM <ubuntu> AS final`, `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. `apt-get install -y --no-install-recommends apache2=<pinned> libapache2-mod-musicindex=1.4.1-6` (pin both, check against `VERSION`; the apt versions are not the image tag, so `VERSION` must match the package version used, see section 5). Remove the default `sites-enabled` and `conf-enabled` entries that would bind port 80 or write to `/var`.
3. Enable the module: `a2enmod musicindex` (or the module's documented enable step, UNVERIFIED).
4. Copy the ContainerForge Apache config from `etc/apache2/` into `/etc/apache2` at build time, so it is read-only at runtime.
5. Set `ServerRoot` and paths so every runtime write goes to `/tmp`: `Mutex file:/tmp`, `PidFile /tmp/apache2.pid`, `ErrorLog /dev/stderr`, `CustomLog /dev/stdout`. No `User`/`Group` directives (the process must run as `apps`).
6. `ENV HOME=/config`, `APACHE_RUN_DIR=/tmp`, `APACHE_LOCK_DIR=/tmp`, `APACHE_LOG_DIR=/tmp`, `APACHE_PID_FILE=/tmp/apache2.pid`.
7. `COPY --chmod=0755 . /`, `EXPOSE 8080`, `USER apps`. Port `8080`, not `80`: a non-root process cannot bind `80` without `CAP_NET_BIND_SERVICE`.
8. Ubuntu base already provides `ca-certificates`, `curl`, `tini`; do not re-install.

## 5. docker-bake.hcl

- `APP = "apache-musicindex"`.
- `VERSION`: the Ubuntu package version `1.4.1-6`, not the image tag `v1.4.1-2` (the image is built from the package). Renovate comment: UNVERIFIED datasource (see section 1). `default = "1.4.1-6"`.
- `LICENSE`: UNVERIFIED. Set only after the copyright file is read. Do not guess.
- `SOURCE = "http://hacks.slashdirt.org/musicindex/"` (UNVERIFIED; the page could not be fetched, so this is the Ubuntu package homepage only).
- Targets: `docker-metadata-action`, `image`, `image-local` (`output = ["type=docker"]`, tag `${APP}:${VERSION}`), `image-all` (`linux/amd64`, `linux/arm64`), `group "default" { targets = ["image-local"] }`.
- Validate: `cd apps/apache-musicindex && docker buildx bake --print`.

## 6. settings.yaml

- Header: `# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json` and `schema_version: 1`.
- `upstream_env_url`: UNVERIFIED (use the Ubuntu package page `https://packages.ubuntu.com/resolute/libapache2-mod-musicindex` until a homepage is confirmed).
- `ports`: `- port: 8080`, `protocol: tcp` (settings.yaml uses `tcp`/`udp`, not `http`), `required: true`. Note: the chart maps `10006` to `80`; the ContainerForge port is `8080` and the chart port mapping changes accordingly (UNVERIFIED how the chart library maps this).
- `env`: none confirmed. Do not invent names. Add `TZ` (default `Etc/UTC`, sibling convention).
- `volumes`: none confirmed. The music library mount path is UNVERIFIED. Add `- path: /config` only if the module writes state there (UNVERIFIED).
- `dependencies`: none.

## 7. start.sh

- Idempotent. Create `/tmp/apache-run` and set the Apache runtime paths on each start. Nothing is written to `/app`.
- If the module needs a config file in `/config`, seed it only when missing (UNVERIFIED that any `/config` file is needed).
- `exec apache2 -DFOREGROUND -f /etc/apache2/apache2.conf` so signals reach the process (PID 1 / tini handoff). Confirm the exact foreground flag against the Apache version on resolute.
- Bind `0.0.0.0:8080` (the `Listen` directive), not `localhost`.

## 8. container-test.yaml

- Schema header from the sibling apps (`apps/it-tools/container-test.yaml` style).
- `tcp` on `8080`. `http` on `/` (expected status: UNVERIFIED until the module's default route is confirmed).
- `timeoutSeconds`: copy from `apps/it-tools/container-test.yaml`.
- `filePaths`: the Apache config files under `/etc/apache2` and the module's enabled-state file (UNVERIFIED path).
- Music library: the test runs with no mount. The module's startup must not require a library to be present; if it does, add a narrowed check and note it (UNVERIFIED behaviour).

## 9. Rootless and read-only-rootfs adaptations

| Upstream behaviour (chart) | ContainerForge remap |
| --- | --- |
| Runs as root (`runAsUser: 0`) | Runs as `apps` (`USER apps`); Apache must not `setuid` |
| Listens on `80` | Listens on `8080` |
| `readOnlyRootFilesystem: false` | Must pass with `--read-only --tmpfs /tmp` |
| Apache default PID, lock, log paths (under `/var/run`, `/var/log`) | `/tmp` (`PidFile`, `Mutex`, `ErrorLog /dev/stderr`) |
| Config under `/etc/apache2` edited at runtime (assumed) | Config baked at build time into `/etc/apache2` |
| Music library mount (path UNVERIFIED) | Mounted read-only; the module must be able to read it as `apps` (group access to the mount is UNVERIFIED) |

## 10. Risks, caveats and open questions

- No upstream Dockerfile, so the image cannot be rebuilt from upstream source. The build depends on the Ubuntu package alone.
- Version mismatch: image tag `v1.4.1-2` vs package `1.4.1-6`. The module code behind the chart image is UNVERIFIED.
- License unknown (copyright file not read). Blocks `docker-bake.hcl` LICENSE.
- Upstream homepage could not be fetched (TLS name mismatch).
- Music library path, mount, and read permissions UNVERIFIED.
- Apache config rewrite is manual work for a read-only rootfs and a non-root user.
- Port change: `80` in the chart becomes `8080`. Downstream chart mappings must follow.
- arm64: the package lists arm64 on resolute (see section 1), so arm64 is expected to build but is not tested.
- Blockers: license unknown; module config directives (for `musicindex`) not read; library path unknown.

## 11. Build and test steps

1. `cd apps/apache-musicindex && docker buildx bake --print` (must exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. Probe: `docker run --rm -d --name apache-musicindex-probe --read-only --tmpfs /tmp -v apache-musicindex-probe-config:/config <image>:1.4.1-6`. Tail logs. Pass criteria: the process stays up, Apache logs `resuming normal operations` (the standard Apache start line, UNVERIFIED for this build), and there are no `AH` error lines. Cleanup: `docker rm -f apache-musicindex-probe; docker volume rm apache-musicindex-probe-config`.
4. `forgetool containers test --image <image>:1.4.1-6 --config ./apps/apache-musicindex/container-test.yaml`.
5. arm64 only if the amd64 build fails for an arm64-specific reason.

## 12. PR checklist

- Branch `feat/add-apache-musicindex`, commit `feat(apache-musicindex): add new container`, target `main`.
- PR template `.github/PULL_REQUEST_TEMPLATE.md` filled in, keeping its sections and checkboxes; only check the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it.
- Say what was not tested (license, music library, arm64, the module's config directives, the homepage check).
- Say that the port changed from `80` (chart) to `8080`.
- No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).
