# odoo — implementation plan
> Source: ./draft.md · Target: apps/odoo/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Upstream image tag `20.0`, from `odoo/docker` 20.0 tree at commit `0ea197eb3852ca500e38fd72074b314833ee7dc8` (https://github.com/odoo/docker/blob/0ea197eb3852ca500e38fd72074b314833ee7dc8/20.0/Dockerfile). Upstream pins nightly `ODOO_RELEASE=20261112` with `ODOO_SHA=9b69ffe4ebf8a4412b312d1f71494112d8410e12` (sha1). This plan pins the same dated nightly, not the floating `latest_all` the draft uses. Odoo 20.0 is a pre-release line (draft caveat, not re-verified). |
| Renovate | UNVERIFIED: no Renovate datasource confirmed for a nightly `.deb`. Plan proposes a manual pin with a comment (no datasource): `ODOO_RELEASE` is bumped by hand, see section 10. |
| License | UNVERIFIED: the odoo repo licence was not fetched in this step. Odoo is LGPL-3.0 upstream (to confirm on https://github.com/odoo/odoo before merge). |
| Source URL | https://github.com/odoo/odoo |
| Download | Nightly `.deb`: `http://nightly.odoo.com/20.0/nightly/deb/odoo_20.0.20261112_all.deb` (dated, from upstream Dockerfile). The draft URL `https://nightly.odoo.com/20.0/nightly/deb/odoo_20.0.latest_all.deb` returned HTTP 200, 334,421,350 bytes (HEAD, 2026-11-25), but it floats. Use the dated file for reproducibility. The dated URL itself was not HEAD-checked: UNVERIFIED. |
| Checksum source | Upstream Dockerfile checks the `.deb` with `sha1sum -c` against `ODOO_SHA=9b69ffe4ebf8a4412b312d1f71494112d8410e12`. Reuse it. |
| Upstream Dockerfile reviewed | https://github.com/odoo/docker/blob/0ea197eb3852ca500e38fd72074b314833ee7dc8/20.0/Dockerfile (fetched via `gh api`). Base `ubuntu:noble`. Installs apt deps (`node-less`, `python3-*` libs, `python3-pip`, `python3-setuptools`, `fonts-noto-cjk`, `libssl-dev`, `xz-utils`, `curl`, `dirmngr`, `gnupg`), `postgresql-client` from `apt.postgresql.org` (noble-pgdg), `rtlcss` from npm, wkhtmltopdf `0.12.6.1-3` (jammy build, sha1 per arch: amd64 `967390a7...`, arm64 `90f6e698...`, ppc64le). `ENV LANG=en_US.UTF-8`, `ENV ODOO_VERSION=20.0`, `ENV ODOO_RC=/etc/odoo/odoo.conf`. `VOLUME ["/var/lib/odoo", "/mnt/extra-addons"]`, `EXPOSE 8069 8071 8072`, `USER odoo`, `ENTRYPOINT ["/entrypoint.sh"]`, `CMD ["odoo"]`. |
| Ports | 8069 (web), 8071 (XML-RPC/legacy, from upstream `EXPOSE`), 8072 (longpolling/websocket). Draft lists 8069 and 8072 only. |
| Env vars (real) | `LANG`, `ODOO_VERSION`, `ODOO_RC` from upstream. Others UNVERIFIED: `entrypoint.sh`, `wait-for-psql.py` and `odoo.conf` were not fetched. |
| Data paths | Upstream: `/var/lib/odoo` (filestore, owned by `odoo`), `/mnt/extra-addons` (addons), `/etc/odoo/odoo.conf` (config, chowned to `odoo`). Chart: `/var/lib/odoo` and `/mnt/extra-addons` PVCs, `odoo.conf` from a read-only configmap. |
| Dependencies | PostgreSQL (`apps/postgresql` exists, see section 6). |

## 2. Target layout

- `apps/odoo/Dockerfile`
- `apps/odoo/docker-bake.hcl`
- `apps/odoo/settings.yaml`
- `apps/odoo/container-test.yaml`
- `apps/odoo/start.sh` (replaces upstream `entrypoint.sh`)
- `apps/odoo/defaults/odoo.conf` (seed template, copied to `/config` only when missing). Needed because `/etc/odoo` is not writable at runtime.

No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base). Add `etc/` only if the odoo binary needs a system path that the Dockerfile cannot reach any other way (UNVERIFIED, not planned).

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`

Odoo is a Python business suite, and the Python base already provides the interpreter, `/app/venv` and pip rules. The upstream `ubuntu:noble` is not used: the ContainerForge ubuntu base is `26.04` (see `apps/python`). Installing the nightly `.deb` on 26.04 (not noble) is a risk (section 10). Closest sibling: `apps/bazarr` (python app with apt libs and uv pip install).

## 4. Dockerfile

1. `FROM` line above. `ARG VERSION`, `ARG ODOO_RELEASE=20261112`, `ARG ODOO_SHA=9b69ffe4ebf8a4412b312d1f71494112d8410e12`, `ARG TARGETARCH`, `USER root`.
2. Apt packages (not already in the python base; check `apps/python/Dockerfile` for overlap first): `postgresql-client`, `wkhtmltopdf` (see step 3), `fonts-noto-cjk`, `node-less`, `python3-magic`, `python3-num2words`, `python3-odf`, `python3-pdfminer`, `python3-phonenumbers`, `python3-pyldap`, `python3-qrcode`, `python3-renderpm`, `python3-slugify`, `python3-vobject`, `python3-watchdog`, `python3-xlrd`, `python3-xlwt`, `libpq-dev` (UNVERIFIED need, drafted as inferred). Pin the `apt` versions against `VERSION` when they are not provided by the base, per the Dockerfile rule.
3. wkhtmltopdf: download `https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.jammy_${arch}.deb` and check it with the sha1 for the arch (amd64 `967390a759707337b46d1c02452e2bb6b2dc6d59`, arm64 `90f6e69896d51ef77339d3f3a20f8582bdf496cc`). Map `TARGETARCH` as upstream does. Install with `apt-get install ./wkhtmltox.deb`.
4. Odoo nightly: download the dated `.deb`, run `echo "${ODOO_SHA} odoo.deb" | sha1sum -c -`, then `apt-get install -y --no-install-recommends ./odoo.deb`. Remove the `.deb` and apt lists. Note: `apt-get install` of a 26.04-targeted Debian package may pull dependency versions that are not in the Ubuntu 26.04 archive. Verify with a build (section 11).
5. `/usr/bin/odoo` path from the Debian package is UNVERIFIED. Confirm with `command -v odoo` in the build.
6. Create runtime dirs and fix ownership for the `apps` user (not `odoo`; the image uses `apps` 568 per ContainerForge rules): `mkdir -p /app/odoo-addons && chown -R apps:apps /app/odoo-addons`. Filestore and config go under `/config`.
7. Licence: copy the Odoo licence file from the deb's `/usr/share/doc/odoo/` (UNVERIFIED path) to `/usr/share/licenses/odoo/`.
8. Node: `rtlcss` from npm, global install with npm at build time, then purge npm in the same layer, as upstream does (UNVERIFIED that this is still needed on 26.04; `node-less` is in apt).
9. Tail:
   ```dockerfile
   USER apps
   COPY --chmod=0755 . /

   EXPOSE 8069 8071 8072
   VOLUME /config
   ```
   `VOLUME /config` only; upstream's `/var/lib/odoo` and `/mnt/extra-addons` are remapped (section 9).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "odoo"
}

variable "VERSION" {
  // renovate: datasource=docker depName=docker.io/library/odoo
  default = "20.0"
}

variable "ODOO_RELEASE" {
  // Pinned nightly build date, no Renovate datasource: bump by hand together with ODOO_SHA
  default = "20261112"
}

variable "ODOO_SHA" {
  default = "9b69ffe4ebf8a4412b312d1f71494112d8410e12"
}

variable "LICENSE" {
  default = "LGPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/odoo/odoo"
}
```

The `VERSION` renovate line is a placeholder (the upstream tag `20.0` is not a release pin) and must be reviewed; `LICENSE` must be confirmed against the Odoo repo (UNVERIFIED in this step). Then the four standard targets and the default group, copied from `apps/adguardhome-sync/docker-bake.hcl`, with `ODOO_RELEASE` and `ODOO_SHA` added to the `image` target `args`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/odoo/odoo"
ports:
  - port: 8069
    protocol: tcp
    required: false
  - port: 8071
    protocol: tcp
    required: false
  - port: 8072
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
  - name: PG_HOST
    default: "postgresql"
    required: false
  - name: PG_PORT
    default: "5432"
    required: false
  - name: PG_USER
    default: "odoo"
    required: false
  - name: PG_PASSWORD
    default: "odoo"
    required: true
volumes:
  - path: /config
    required: true
dependencies:
  - postgresql
```

The `PG_*` names and defaults are a proposal, not verified: they must match what `start.sh` and `odoo.conf` actually read (`db_host`, `db_port`, `db_user`, `db_password` in `odoo.conf` are the Odoo keys; the env mapping is UNVERIFIED). Do not list them until the seed `odoo.conf` and `start.sh` consume them. `PG_PASSWORD` with a default `odoo` is a weak default: use `required: true` with no default, and generate or require it in `start.sh` (rule: a required var needs a default or start-time handling). Dependencies: `postgresql` ✅ (`apps/postgresql` exists).

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config/odoo-data /config/addons
if [ ! -s /config/odoo.conf ]; then
  cp /defaults/odoo.conf /config/odoo.conf
fi

export ODOO_RC=/config/odoo.conf
export DB_HOST="${PG_HOST:-postgresql}"
export DB_PORT="${PG_PORT:-5432}"
export DB_USER="${PG_USER:-odoo}"
export DB_PASSWORD="${PG_PASSWORD:?PG_PASSWORD is required}"

cd /app
exec odoo --config "${ODOO_RC}" --http-interface=0.0.0.0 --http-port=8069 --data-dir=/config/odoo-data
```

Points to verify (UNVERIFIED, from the upstream `entrypoint.sh` and `odoo.conf`, which were not fetched):
- The env to config mapping: upstream `entrypoint.sh` reads `HOST`, `USER`, `PASSWORD` and writes `db_*` keys into `odoo.conf`. Replicate that pattern, but keep the names ContainerForge uses in `settings.yaml`.
- The `odoo` flags used (`--http-interface`, `--http-port`, `--data-dir`) must exist in 20.0. Confirm with `odoo --help`.
- Apply `DB_PASSWORD` on every start, so a changed password is applied to the existing config (ContainerForge rule for databases). Write it into `/config/odoo.conf` with a fixed line replacement, not a raw append.
- `/config/odoo.conf` is seeded only when missing or empty. Never overwrite user state.
- The database must exist before the first start (draft caveat); `start.sh` does not create it. Document in the PR. Optionally run `wait-for-psql.py` style check (UNVERIFIED that this script is needed on 26.04).
- Never write to `/app`. Addons go in `/config/addons`, and `addons_path` in `odoo.conf` points there and to `/app/odoo-addons`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 300
tcp:
- port: '8069'
- port: '8072'
http:
- port: '8069'
  path: /web/login
filePaths:
- /usr/bin/odoo
- /usr/bin/wkhtmltopdf
- /defaults/odoo.conf
- /usr/share/licenses/odoo
```

The app needs PostgreSQL to fully start. The test runs with no env vars and no database, so the app will not reach a ready state in the single-container suite. Per the database-dependent exception, narrow the test to a process check plus the listed ports, and annotate:
`# narrowed: requires external postgresql; full functional test not feasible in single-container suite`.
Only apply the narrowing if all three exception criteria hold (hard `dependencies:` on a database, will not start without it, not feasible to wire a sidecar with the available primitives). They do (hard `postgresql` dependency in section 6). Port 8071 needs a probe too (`settings.yaml` rule), so add `tcp` for 8071 as well, or remove it from `settings.yaml` if it is not confirmed to listen. The `http` probe on `/web/login` must return 200 only when the app is up; this is UNVERIFIED without a DB, so it may fail in the single-container suite: confirm, and if needed keep only the `tcp` probes and note it.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/var/lib/odoo` (filestore, chart PVC) | `/config/odoo-data` via `--data-dir`. |
| `/mnt/extra-addons` (user addons, chart PVC) | `/config/addons` (writable), added to `addons_path`. |
| `/etc/odoo/odoo.conf` (upstream, chowned to `odoo`; chart: read-only configmap) | `/config/odoo.conf`, seeded from `/defaults/odoo.conf`. `ODOO_RC` points there. |
| `/app` (rootfs, read-only at runtime) | Only the odoo deb's installed files (system paths) and `/app/odoo-addons` created at build. Nothing written at runtime. |
| `/tmp` | Scratch under `--read-only --tmpfs /tmp`. |
| `wkhtmltopdf` and `libreoffice`-style renderers | Write temp files to `/tmp` only (UNVERIFIED that odoo honours `TMPDIR`; set `TMPDIR=/tmp` in the Dockerfile). |

Draft expectations reconciled: chart runs as UID 1000 with `readOnlyRootFilesystem: false`; this image runs as `apps` (568) and is designed for `--read-only --tmpfs /tmp`, so the rootfs stays read-only. Chart `odoo.conf` is a read-only configmap; the image uses a writable `/config/odoo.conf`, seeded once. Users migrating from the chart must copy `/var/lib/odoo` to `/config/odoo-data` and `/mnt/extra-addons` to `/config/addons`.

## 10. Risks, caveats and open questions

- Nightly, not reproducible: the draft's `latest_all` floats. This plan pins `20261112` and its sha1. The pinned file may be removed from nightly.odoo.com later; the build then fails loudly, which is the intended signal. Bumping is manual (no Renovate datasource).
- Pre-release line: Odoo 20.0 is pre-release per the draft; stability is not verified here.
- Distro mismatch: the `.deb` targets `ubuntu:noble`; this image is 26.04. Dependency resolution may differ. UNVERIFIED until the build runs.
- arm64: the Odoo `.deb` is `Architecture: all`. wkhtmltopdf has an arm64 sha in upstream. Runtime on arm64 is UNVERIFIED.
- Database: a PostgreSQL server must exist and the database must be created before first start (draft). The `PG_*` names are proposals.
- Initial master password: first start needs the master password set in `odoo.conf` (`admin_passwd`). Make it come from the environment in `start.sh`, not a file in the image. Name UNVERIFIED.
- The `odoo.conf` and `entrypoint.sh` in upstream were not fetched. Their behaviour is UNVERIFIED and must be read before `start.sh` is final.
- Debian package licence and documentation path were not fetched (UNVERIFIED).
- Size: the nightly `.deb` is about 334 MB; the image will be large.
- Blockers: none confirmed beyond the above. Not musl-only, no GPU, no privileged need listed upstream. The chart's `runAsUser 1000` does not match `apps` 568; that is intentional for this image.

## 11. Build and test steps

```sh
cd apps/odoo
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name odoo-probe --read-only --tmpfs /tmp \
  -v odoo-probe-config:/config -e PG_PASSWORD=probe-only odoo:20.0
docker logs -f odoo-probe
forgetool containers test --image odoo:20.0 --config ./apps/odoo/container-test.yaml
docker rm -f odoo-probe; docker volume rm odoo-probe-config
```

Readiness signal without a database: the process stays alive and logs a PostgreSQL connection attempt or a startup line (exact text UNVERIFIED). Full readiness needs a PostgreSQL instance: run `apps/postgresql` on the same network and confirm `Modules loaded` or `HTTP service running on 0.0.0.0:8069` in the log, then curl `/web/login`. Wire the DB test by hand per protocol.

## 12. PR checklist

- Branch `feat/add-odoo`, commit and PR title `feat(odoo): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only applicable boxes.
- Notes section contains `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is needed (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows the status.
- Say what was not tested: full functional run against PostgreSQL, arm64 build and run, the nightly reproducibility, the Ubuntu 26.04 vs noble package resolution, and migration from the chart PVCs.
- Database-dependent narrowing (section 8) is annotated and justified in `container-test.yaml`.
- `docker buildx bake --print` must pass; `VERSION` and `ODOO_RELEASE`/`ODOO_SHA` in bake and Dockerfile must match; no assertion weakened.
