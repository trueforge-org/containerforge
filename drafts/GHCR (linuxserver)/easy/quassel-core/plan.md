# quassel-core — implementation plan
> Source: ./draft.md · Target: apps/quassel-core/ · Difficulty: easy · Role (main/sidecar): main · Verified on 2026-11-25

Note: the draft says Ubuntu noble, but the ContainerForge base is Ubuntu 26.04 (resolute). Checked on packages.ubuntu.com: `quassel-core` `1:0.14.0-4ubuntu2` exists in resolute for amd64 and arm64, so the apt path is viable and no source build is needed (difficulty stays easy). The source-build fallback below is kept only in case the package disappears.

## 1. Verified upstream facts

| Item | Value | Source |
| --- | --- | --- |
| Latest stable | `0.14.0`, published 2022-01-01 (no newer stable release on GitHub) | https://api.github.com/repos/quassel/quassel/releases/latest (fetched via `gh api`); https://github.com/quassel/quassel/releases/tag/0.14.0 |
| Release assets | `quassel-0.14.0.tar.xz`, `quassel-0.14.0.tar.xz.sha256sum` (checksum source) | same |
| Draft container tag | `ghcr.io/linuxserver/quassel-core:0.14.0` | draft.md |
| Renovate | `datasource=github-releases depName=quassel/quassel versioning=loose` (tags like `0.14-rc1` exist, so loose) | GitHub tags |
| License | GitHub metadata NOASSERTION; SPDX (GPL-2.0-or-later per upstream COPYING): UNVERIFIED, check COPYING before setting LICENSE | GitHub API |
| Source | https://github.com/quassel/quassel | draft.md |
| Per-arch download | Architecture-neutral source tarball `https://github.com/quassel/quassel/releases/download/0.14.0/quassel-0.14.0.tar.xz`, built per arch | release assets |
| Upstream Dockerfile | linuxserver/docker-quassel-core@c995ed5491d2: `baseimage-alpine:3.20` (build and runtime); build stage apk: boost-dev, build-base, cmake, dbus-dev, icu-dev, openssl-dev, openldap-dev, qt5-qtbase-dev, qt5-qtscript-dev, qt5-qtbase-postgresql, qt5-qtbase-sqlite, qca-dev, zlib-dev; runtime apk: icu-libs, openssl, qt5-qtbase, qt5-qtbase-postgresql, qt5-qtbase-sqlite, qt5-qtscript, libqca-qt5, openldap; `EXPOSE 4242 10113`; `VOLUME /config`; `ENV HOME=/config` | https://raw.githubusercontent.com/linuxserver/docker-quassel-core/c995ed5491d2/Dockerfile |
| Ports | 4242/tcp (core protocol), 10113 (ident) | upstream EXPOSE |
| Ubuntu apt package | `quassel-core` `1:0.14.0-4ubuntu2` in resolute (26.04), amd64 and arm64 (note the `1:` epoch) | https://packages.ubuntu.com/resolute/quassel-core |

## 2. Target layout

`apps/quassel-core/`:
- `Dockerfile`, `docker-bake.hcl`, `settings.yaml`, `container-test.yaml`, `start.sh`.
- `defaults/` only if a default `quasselcore` config is seeded (with reason).
- No `root/`. No `DOWNSTREAM_CHANGES.md` (not a FROM base).

## 3. Base image

- FROM `ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` (no runtime image needed; draft agrees).
- Closest sibling: `apps/valkey` (single daemon, pinned apt version pattern) for layout; check `apps/postgresql` for the optional DB dependency.

## 4. Dockerfile

Preferred path (apt, verified on resolute for both arches):
1. `ARG VERSION`, `ENV HOME=/config`, `USER root`.
2. `apt-get install --no-install-recommends quassel-core=<pinned version>` (pin as `1:0.14.0-4ubuntu2` including the epoch; upstream version part matches `VERSION=0.14.0`; if resolute ships a different version, the image would not contain the tagged version: stop and use the source path).
3. `rm -rf /var/lib/apt/lists/*`.

Fallback path (source build, if apt is missing or wrong version):
1. Build stage on ubuntu base: apt install cmake, build-essential, qt6 or qt5 dev packages that exist on resolute, libboost-dev, libssl-dev, libicu-dev, zlib1g-dev, libqca-qt5-dev (names UNVERIFIED on resolute).
2. Download `quassel-0.14.0.tar.xz` from the release; verify with `sha256sum -c` against `quassel-0.14.0.tar.xz.sha256sum`; build with cmake for core only (`-DWITH_CORE=ON -DWITH_QTCLIENT=OFF -DWITH_OIDENTD=OFF` etc., flags UNVERIFIED against 0.14.0).
3. Runtime stage: copy the installed binary to `/usr/local/bin` or `/usr/bin` and runtime libs via apt.
4. Ship the upstream license in `/usr/share/licenses/quassel-core/`.

Common steps:
- `COPY --chmod=0755 . /`, `USER apps`, `WORKDIR /config`.
- `EXPOSE 4242 10113` (expose only the ports the daemon binds; confirm 10113 with the app, see caveats).
- `VOLUME /config`.

## 5. docker-bake.hcl

- `APP = "quassel-core"`, `VERSION = "0.14.0"` with renovate annotation `// renovate: datasource=github-releases depName=quassel/quassel versioning=loose`.
- `LICENSE` set to the verified SPDX (UNVERIFIED: see facts). `SOURCE = "https://github.com/quassel/quassel"`.
- Standard targets: `docker-metadata-action`, `image`, `image-local`, `image-all` (amd64, arm64), `group "default"`.
- Validate: `cd apps/quassel-core && docker buildx bake --print`.

## 6. settings.yaml

- Schema header and `schema_version: 1`; `upstream_env_url: https://github.com/quassel/quassel`.
- `ports`: 4242 tcp (required). 10113 (ident): include only if the daemon actually binds it.
- `env`: only what start.sh and the daemon read. Likely none required; do not invent names.
- `volumes`: `/config`.
- `dependencies`: `postgresql` (optional, see blocker below); list under `opt_dependencies` (field exists, e.g. `apps/airsonic-advanced/settings.yaml`), not `dependencies`, because the daemon runs on SQLite by default.

## 7. start.sh

- Idempotent. Create `/config/quasselcore` data dir only when missing.
- Database: SQLite in `/config` by default. If PostgreSQL is chosen later, apply the DB password from env on every start.
- Bind the core to `0.0.0.0` on port 4242 (`--listen` option, check the daemon's default; do not assume localhost).
- Run with `--configdir=/config` (UNVERIFIED: flag spelling; check `quasselcore --help`). UNVERIFIED: whether a `--nofork` flag exists; quasselcore is believed to stay in the foreground by default, so confirm and do not pass a flag that is not in `--help`.
- `exec` the daemon.
- Readiness line: UNVERIFIED (check core log on first start: "listening" string).

## 8. container-test.yaml

- forgetool header from sibling.
- `tcp` probe on 4242 (and 10113 if declared). `timeoutSeconds` from a sibling daemon app (UNVERIFIED which).
- `filePaths`: `/config` directory existence after first start.

## 9. Rootless and read-only-rootfs adaptations

- Runs as `apps` (UID 568). All state in `/config`; no writes to `/usr`.
- The daemon may write a PID or socket file: keep those in `/tmp` or `/config`, not `/app`.
- Draft's security expectations: non-root possible; read-only true possible (confirm no write outside `/config` and `/tmp`); privileged no.
- Draft's note "database in /config" conflicts with the chart's CNPG PostgreSQL. Decide: SQLite in `/config` for the ContainerForge default, PostgreSQL only if the user wants the chart's behaviour.

## 10. Risks, caveats and open questions

- apt `quassel-core` on resolute is `1:0.14.0-4ubuntu2` (verified); the Debian revision can change, so the pin needs maintenance.
- Upstream release is from 2022; no newer stable tag exists on GitHub. Ubuntu package may be older.
- Database backend choice (SQLite vs PostgreSQL) must be settled before deployment. Chart uses CNPG PostgreSQL.
- Ident port 10113: needs confirming as a real listener.
- First user is created with a Quassel client; no web setup. Cannot be tested by `container-test.yaml` beyond ports.
- License SPDX UNVERIFIED (GitHub shows NOASSERTION).

## 11. Build and test steps

1. `cd apps/quassel-core && docker buildx bake --print`.
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. `docker run --rm -d --name quassel-core-probe --read-only --tmpfs /tmp -v quassel-core-probe-config:/config quassel-core:0.14.0`; `docker logs -f quassel-core-probe`. Expected: process alive, listening on 4242 (readiness string UNVERIFIED).
4. Cleanup: `docker rm -f quassel-core-probe; docker volume rm quassel-core-probe-config`.
5. `forgetool containers test --image quassel-core:0.14.0 --config ./apps/quassel-core/container-test.yaml`.
6. Database-dependent exception: applies only if PostgreSQL is a hard dependency; as drafted (SQLite default) it is not, so no narrowing.

## 12. PR checklist

- Branch `feat/add-quassel-core`, commit `feat(quassel-core): add new container`.
- PR body from `.github/PULL_REQUEST_TEMPLATE.md`; keep sections and checkboxes; check only what applies.
- Notes section: `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- State untested items (arm64, forgetool run, runtime flags) honestly.
