# lldap — implementation plan
> Source: ./draft.md · Target: apps/lldap/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | v0.6.3 (GitHub release, asset timestamps 2026-04-30; changelog heading "[0.6.3] 2026-05-01"). Source: https://github.com/lldap/lldap/releases/latest and https://github.com/lldap/lldap/releases/expanded_assets/v0.6.3. The draft's container tag `ghcr.io/lldap/lldap:v0.6.3-debian` matches this version. |
| Renovate | `// renovate: datasource=github-releases depName=lldap/lldap versioning=semver` (standard for a GitHub release; the upstream renovate config was not retrieved). |
| License | GPL-3.0-only (LICENSE text at https://raw.githubusercontent.com/lldap/lldap/v0.6.3/LICENSE). Set `LICENSE = "GPL-3.0-only"`. |
| Source URL | https://github.com/lldap/lldap |
| Per-arch download (confirmed asset names) | amd64: https://github.com/lldap/lldap/releases/download/v0.6.3/amd64-lldap.tar.gz · arm64: https://github.com/lldap/lldap/releases/download/v0.6.3/aarch64-lldap.tar.gz · armhf (not used): https://github.com/lldap/lldap/releases/download/v0.6.3/armhf-lldap.tar.gz |
| Checksum source | None: the release lists no checksum file among its five assets (expanded_assets page). Integrity rests on the pinned tag URL and TLS; record this in the PR. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/lldap/lldap/48a0a8d961f32bd8e3263b202053ce49a6c94781/.github/workflows/Dockerfile.ci.debian: FROM `localhost:5000/lldap/lldap:debian-base`; installs gosu 1.17 with signature check; COPY docker-entrypoint.sh; no EXPOSE, VOLUME, USER or ENTRYPOINT in that file. ContainerForge does not use it (gosu and the root wrapper are not needed). |
| Upstream run model | README (https://raw.githubusercontent.com/lldap/lldap/v0.6.3/README.md): the default container starts as root to fix permissions, then drops to the given user; rootless images are recommended. Database is SQLite by default; MySQL/MariaDB and PostgreSQL are supported. |
| Ports | 3890/tcp (LDAP, `ldap_port`) and 17170/tcp (web UI, `http_port`), both bound to `0.0.0.0` by default. Source: `lldap_config.docker_template.toml` at tag v0.6.3 (https://raw.githubusercontent.com/lldap/lldap/v0.6.3/lldap_config.docker_template.toml). |
| Env vars | Per the v0.6.3 config template, every config key can be set as `LLDAP_<KEY>`; the template names `LLDAP_LDAP_PORT`, `LLDAP_JWT_SECRET` (or `LLDAP_JWT_SECRET_FILE`), `LLDAP_DATABASE_URL`, `LLDAP_KEY_FILE`, and `LLDAP_HEALTHCHECK_OPTIONS__*`. Other names (admin password, base DN) UNVERIFIED here; read them from the template before listing. Documented: the LDAP password comes from the configuration and is the same as the web UI login; default LDAP user DN `cn=admin,ou=people,dc=example,dc=com`. |
| Data path | Template default `database_url = "sqlite:///data/users.db?mode=rwc"` (not writable under `/app`; no `/data` in this image). Override with `LLDAP_DATABASE_URL=sqlite:///config/users.db?mode=rwc` (or the config key). |
| Binary contents | Checked by listing the v0.6.3 amd64 tarball: it has a top-level directory `amd64-lldap/` (arm64: `aarch64-lldap/` UNVERIFIED, assumed same pattern) holding `lldap`, `lldap_migration_tool`, `lldap_set_password` and `app/` (web assets, resolved relative to the working directory). No config template and no LICENSE inside. |
| arm64 | Release has `aarch64-lldap.tar.gz`. Runs on Ubuntu arm64 is UNVERIFIED (test with the arm64 build if it is attempted). |

## 2. Target layout

- `apps/lldap/Dockerfile`
- `apps/lldap/docker-bake.hcl`
- `apps/lldap/settings.yaml`
- `apps/lldap/container-test.yaml`
- `apps/lldap/start.sh`
- `apps/lldap/defaults/` only if a default `lldap_config.toml` must be seeded into `/config` (likely yes, see section 7; the reason is the config file is not in the tarball; copy `lldap_config.docker_template.toml` from the v0.6.3 tag and set `database_url` to a `/config` path).

Never `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. No runtime image is needed (the draft's "ubuntu alone" choice): the upstream binary is a self-contained Rust build from the release tarball.

Closest sibling: `apps/adguardhome-sync` (prebuilt tarball for `TARGETARCH`, extracted into `/app`, `USER apps`, `COPY --chmod=0755 . /`, `VOLUME /config`).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`, `ENV HOME=/config`.
2. Map the architecture (do not use `$TARGETARCH` directly, because the asset names differ):
   ```sh
   case "$TARGETARCH" in
     amd64) LLDAP_ARCH=amd64 ;;
     arm64) LLDAP_ARCH=aarch64 ;;
     *) echo "unsupported arch" >&2; exit 1 ;;
   esac
   ```
3. Download and extract into `/app` at build time (root only for this step):
   `curl -fL -o /tmp/lldap.tar.gz "https://github.com/lldap/lldap/releases/download/v${VERSION}/${LLDAP_ARCH}-lldap.tar.gz"`, then `tar xzf /tmp/lldap.tar.gz -C /app/ --strip-components=1` (the archive has a top-level `${LLDAP_ARCH}-lldap/` directory), so `/app/lldap` and `/app/app/` exist, then `rm /tmp/lldap.tar.gz`. Use `curl --fail` and `--proto '=https'`.
4. No checksum to verify (see section 1). Record that in the PR.
5. License: copy the repo's LICENSE to `/usr/share/licenses/lldap/LICENSE` (the tarball may not include it; fetch from the v0.6.3 tag: `https://raw.githubusercontent.com/lldap/lldap/v${VERSION}/LICENSE`, the same file checked in section 1).
6. `chown -R apps:apps /app && chmod -R 755 /app` (as in the sibling).
7. `USER apps`, `COPY --chmod=0755 . /`.
8. `EXPOSE 3890 17170`. `VOLUME /config`.
9. `ENV` only the config path variable once the name is confirmed (section 1).

## 5. docker-bake.hcl

- `APP = "lldap"`.
- `VERSION = "0.6.3"` with the renovate comment from section 1 (no `v` prefix; the Dockerfile adds it).
- `LICENSE = "GPL-3.0-only"`.
- `SOURCE = "https://github.com/lldap/lldap"`.
- Targets: `docker-metadata-action`, `image` (args VERSION; labels `org.opencontainers.image.source` and `.licenses`), `image-local` (output docker, tag `${APP}:${VERSION}`), `image-all` (platforms `linux/amd64`, `linux/arm64`), `group "default" { targets = ["image-local"] }`.
- Validate with `docker buildx bake --print` from `apps/lldap`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/lldap/lldap"
ports:
  - port: 3890        # LDAP
    protocol: tcp
    required: true
  - port: 17170       # web UI
    protocol: tcp
    required: true
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
opt_dependencies:
  - name: postgresql
```
Rules: list only env names the app or start script reads (none beyond TZ until section 1 is confirmed). The `opt_dependencies` key with `- name: postgresql` matches siblings (e.g. `apps/freshrss/settings.yaml`); use the `- name:` form in the snippet too. `postgresql` exists in apps/ (checked). The database secrets (JWT secret, admin password) are required by lldap per the draft; list them as env only once the real names are confirmed, with `required: true` and a start-script generated default (section 7).

## 7. start.sh

1. `#!/usr/bin/env bash`, `set -euo pipefail`, `export HOME=/config`, `export TMPDIR=/tmp`.
2. First start (empty `/config`): if `/config/lldap_config.toml` is missing, seed it from `/defaults/lldap_config.toml` (the file shipped via `defaults/`), with the database path set to `/config/...`. Never overwrite an existing config.
3. Secrets: if the JWT secret and admin password are not set, generate them once and keep them in `/config` (not in the process list, not in logs). Apply the admin password from env on every start only if an env var is set (password from env applied each start, per the start-script rules; confirm the mechanism with lldap's own CLI before writing).
4. Bind address: lldap must listen on all interfaces (`0.0.0.0`), so set the listen host in the seeded config (UNVERIFIED key name) rather than relying on the default.
5. Never write to `/app`. Temp files go to `/tmp`.
6. End with `cd /app && exec /app/lldap run --config-file /config/lldap_config.toml` (binary name confirmed from the tarball; the `run` subcommand and flag are UNVERIFIED; `cd /app` is needed so the relative `app/` web assets resolve, UNVERIFIED `web_root` key).

## 8. container-test.yaml

- Header: the forgetool `$schema` line used by `apps/adguardhome-sync/container-test.yaml`.
- `filePaths`: `/app/lldap` (or the confirmed binary path) and `/start.sh` (or the confirmed start script path).
- `tcp` probes: 3890 and 17170 (every settings.yaml port needs one). Probe timeout: copy `timeoutSeconds` from `apps/adguardhome-sync/container-test.yaml` (UNVERIFIED value; read the sibling at implementation time).
- Test runs with no env vars. The admin/JWT generation path runs on the first start without env, so it is covered; the env-set path is not, and must be run by hand (see section 11).

## 9. Rootless and read-only-rootfs adaptations

- Upstream's root-start and gosu drop are replaced by `USER apps` (the release binary does not need root).
- The database and config live in `/config`; caches and temp in `/tmp` (works with `--read-only --tmpfs /tmp`).
- Upstream's `uid` docker-compose field is not used: ContainerForge sets the user in the image.
- Draft security expectations: non-root yes (chart runAsUser 568 in TrueCharts), read-only rootfs possible (the database is the only write target, under /config), privileged no. Extra persistence: none beyond `/config`; the chart's `/data` mount is not needed because the database lives in `/config`. Verify with the run step.

## 10. Risks, caveats and open questions

- Ports, env names and config keys are unverified (section 1). Do not finalize settings.yaml or container-test.yaml until the tarball's config template is read.
- The default lldap config may refuse to start without a JWT secret or admin password; if so, the empty-`/config` test fails. Fix in `start.sh` (generate once), not by weakening the test.
- No checksum published; record in the PR.
- arm64 runtime on Ubuntu is UNVERIFIED.
- The upstream Debian Dockerfile is not used; the draft's `ghcr.io/lldap/lldap:v0.6.3-debian` is not the source of the binary here.
- Blockers: none confirmed.

## 11. Build and test steps

From `apps/lldap`:
1. `docker buildx bake --print` (exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. Empty-config run: `docker run --rm -d --name lldap-probe --read-only --tmpfs /tmp -v lldap-probe-config:/config lldap:0.6.3`, then `docker logs -f lldap-probe`. Expected readiness: the LDAP and web listeners start (the exact log line is UNVERIFIED; read it from the first run), process still running, no panic.
4. `docker rm -f lldap-probe; docker volume rm lldap-probe-config`.
5. Run again with the JWT/admin env set (names confirmed in section 1) to test the env path by hand.
6. `forgetool containers test --image lldap:0.6.3 --config ./apps/lldap/container-test.yaml`.
7. Optional: `--platform linux/arm64` only if an arm64 failure is suspected.

## 12. PR checklist

- Branch `feat/add-lldap`, commit `feat(lldap): add new container`, PR title the same.
- Fill `.github/PULL_REQUEST_TEMPLATE.md` (keep sections and checkboxes; tick only what applies).
- Notes section: `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; `license/cla` shows the status).
- State what was not tested: no build, run or forgetool test was executed for this plan; the ports, env names and tarball contents are still unverified.
