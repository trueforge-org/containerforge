# mattermost — implementation plan
> Source: ./draft.md · Target: apps/mattermost/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | 12.1.0 (latest stable GitHub release, published 2026-11-05). The draft's 9.6.3 is stale. `v12.2.0-rc1` is a prerelease only: do not use. The chart pins `mattermost/mattermost-enterprise-edition:release-9.6`, so the version choice is a decision to confirm (section 10). |
| Renovate | Tarball: `datasource=github-releases depName=mattermost/mattermost versioning=semver`. UNVERIFIED: no renovate config checked. |
| License | GitHub reports `NOASSERTION` (mixed: AGPL-3.0 server core, enterprise files separate). UNVERIFIED: the SPDX value for the edition shipped in the tarball. The bake `LICENSE` must not be set until confirmed. |
| Source URL | https://github.com/mattermost/mattermost |
| Per-arch download | amd64: `https://releases.mattermost.com/12.1.0/mattermost-12.1.0-linux-amd64.tar.gz` (HTTP 200). arm64: `https://releases.mattermost.com/12.1.0/mattermost-12.1.0-linux-arm64.tar.gz` (HTTP 200). |
| Checksum source | None found on the release (no `.sha256` asset). Release assets are `sbom-mattermost-v12.1.0.json` and `slsa-provenance.intoto.jsonl`. UNVERIFIED: the provenance subjects list the tarballs, so they may be used to check the digest. Until then, the digest is UNVERIFIED. |
| Edition in tarball | UNVERIFIED: whether `mattermost-<v>-linux-<arch>.tar.gz` is the Enterprise or Team build. The upstream Dockerfile default `MM_PACKAGE` is `https://latest.mattermost.com/mattermost-enterprise-linux`. |
| Upstream Dockerfile reviewed | `server/build/Dockerfile` at v12.1.0: stage 1 `ubuntu:noble-20251013` (apt: ca-certificates, curl, media-types, mailcap, unrtf, wv, poppler-utils, tidy, tzdata), downloads `MM_PACKAGE` to `/mattermost`, user and group `mattermost` with `PUID`/`PGID` default 2000. Final `gcr.io/distroless/base-debian12`. `ENV PATH=/mattermost/bin MM_SERVICESETTINGS_ENABLELOCALMODE=true MM_INSTALL_TYPE=docker`. `CMD ["/mattermost/bin/mattermost"]`, `WORKDIR /mattermost`, `EXPOSE 8065 8067 8074`. `VOLUME /mattermost/data /mattermost/logs /mattermost/config /mattermost/plugins /mattermost/client/plugins`. No ENTRYPOINT. `server/build/entrypoint.sh` exists at v12.1.0 but is not referenced by this Dockerfile. |
| Port | 8065 (web UI and API, `EXPOSE`). 8067 and 8074 are also `EXPOSE`d in v12.1.0; their purpose is UNVERIFIED. The 9.x Dockerfile also lists 8075 (UNVERIFIED for 12.x). |
| Health endpoint | `/api/v4/system/ping`, from the 9.x Dockerfile health check (UNVERIFIED for 12.x). |
| Env vars (real, from Dockerfile) | `MM_SERVICESETTINGS_ENABLELOCALMODE=true`, `MM_INSTALL_TYPE=docker`. |
| Env vars (database, site URL) | UNVERIFIED: not fetched from docs.mattermost.com. Do not list any name in `settings.yaml` until it is confirmed there or in the code. |
| Write paths (upstream) | `/mattermost/data`, `/mattermost/logs`, `/mattermost/config`, `/mattermost/plugins`, `/mattermost/client/plugins` (VOLUME). `/mattermost/bleve-indexes` is a chart PVC, not in the upstream VOLUME list (UNVERIFIED whether 12.x uses it). |
| Dependency containers | PostgreSQL, a hard dependency (draft; UNVERIFIED from docs). `apps/postgresql` exists. |

## 2. Target layout

- `apps/mattermost/Dockerfile`
- `apps/mattermost/docker-bake.hcl`
- `apps/mattermost/settings.yaml`
- `apps/mattermost/container-test.yaml`
- `apps/mattermost/start.sh`
- `apps/mattermost/defaults/` only if the shipped `config/config.json` must be seeded into `/config` (section 7). Reason: the server writes its config on admin changes, so `/app` cannot hold it at runtime.

No `root/`. No `DOWNSTREAM_CHANGES.md` (not used as a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` for the final stage. No runtime sibling is needed: the Go server and the webapp come in the tarball.

Fits because the upstream final image is distroless (no shell, no apt), which does not suit `start.sh`. The tarball is unpacked onto the ubuntu base, as the draft says. Closest sibling: `apps/pwndrop` (ubuntu base, app unpacked under `/app/<app>/`, `WORKDIR /config`, `VOLUME /config`). Go and the bundled webapp need no runtime package.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Packages the app needs (apt, not in base; `ca-certificates` and `curl` are inferred as present or needed):
   `apt-get install -y --no-install-recommends ca-certificates mailcap media-types` (libraries). Optional, for file previews as upstream does: `unrtf wv poppler-utils tidy`. Include only if previews are wanted (UNVERIFIED use case). Then `rm -rf /var/lib/apt/lists/*`.
3. Download and unpack the arch-specific tarball into `/app/mattermost`:

```dockerfile
RUN set -eux; \
    mkdir -p /app/mattermost; \
    curl -fsSL -o /tmp/mattermost.tar.gz \
        "https://releases.mattermost.com/${VERSION}/mattermost-${VERSION}-linux-${TARGETARCH}.tar.gz"; \
    echo "<sha256>  /tmp/mattermost.tar.gz" | sha256sum -c -; \
    tar xzf /tmp/mattermost.tar.gz -C /app/mattermost --strip-components=1; \
    rm -f /tmp/mattermost.tar.gz
```

   `<sha256>` is UNVERIFIED: take it from the provenance file or compute it from a download and check it against the provenance subjects. Do not ship the placeholder.
4. Writable paths are symlinks into `/config`, so `/app` stays read-only:

```dockerfile
RUN set -eux; \
    rm -rf /app/mattermost/data /app/mattermost/logs /app/mattermost/plugins /app/mattermost/client/plugins; \
    ln -s /config/data /app/mattermost/data; \
    ln -s /config/logs /app/mattermost/logs; \
    ln -s /config/plugins /app/mattermost/plugins; \
    ln -s /config/client-plugins /app/mattermost/client/plugins; \
    chown -R root:root /app && chmod -R 755 /app
```

   Ship the license: after unpacking, `mkdir -p /usr/share/licenses/mattermost` and copy the tarball's license file (file name UNVERIFIED; check the tarball root, e.g. `NOTICE.txt`/`LICENSE.txt`) to `/usr/share/licenses/mattermost/LICENSE`, since `container-test.yaml` asserts that path.

   `/config/client-plugins` is a new path name, so the client-plugins symlink target is a choice, not upstream behaviour. Symlink targets are created by `start.sh` (`mkdir -p`), not in the image.
5. Tail (same as siblings):

```dockerfile
ENV MM_SERVICESETTINGS_ENABLELOCALMODE=true \
    MM_INSTALL_TYPE=docker

USER apps
COPY --chmod=0755 . /

WORKDIR /config
EXPOSE 8065
VOLUME /config
```

   Only `8065` is `EXPOSE`d here. Add `8067` and `8074` only after `ss -ltn` inside the running container shows them listening and their purpose is known.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "mattermost"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=mattermost/mattermost versioning=semver
  default = "12.1.0"
}

variable "LICENSE" {
  default = "UNVERIFIED"   // must be set to the confirmed SPDX value of the tarball edition before merge
}

variable "SOURCE" {
  default = "https://github.com/mattermost/mattermost"
}
```

Then the standard `group "default"`, `image`, `image-local` and `image-all` targets from `apps/adguardhome-sync/docker-bake.hcl`. `VERSION` must equal the Dockerfile `ARG VERSION`. Validate with `docker buildx bake --print` in `apps/mattermost/`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/mattermost/mattermost"
ports:
  - port: 8065
    protocol: tcp
    required: false
env:
  - name: MM_SERVICESETTINGS_ENABLELOCALMODE
    default: "true"
    required: false
  - name: MM_INSTALL_TYPE
    default: "docker"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies:
  - name: postgresql
```

Database and site URL variables are added only after they are confirmed (section 1). A required DB variable must have a default that `start.sh` honours (`required: true` rule), so these lines are not final until then. `postgresql` is in `dependencies` because it is a hard dependency; the `apps/postgresql` default names (`POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD`) must match what `start.sh` passes on.

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config/data /config/logs /config/plugins /config/client-plugins /config/config

# seed the shipped config only when missing (UNVERIFIED file name)
[ -s /config/config/config.json ] || cp /defaults/config.json /config/config/config.json

# DB settings applied on every start from the environment.
# PLACEHOLDER, not final: the Mattermost variable names and the input names
# (DB_* here) are UNVERIFIED and must be confirmed before this is written.
# export MM_SQLSETTINGS_DRIVERNAME=postgres
# export MM_SQLSETTINGS_DATASOURCE="<dsn built from the confirmed inputs>"

cd /app/mattermost
exec /app/mattermost/bin/mattermost
```

- Upstream's shipped config file name and the variable that points the server at `/config/config/config.json` (e.g. `MM_CONFIG`) are UNVERIFIED. Confirm both from the tarball (`config/`) and the docs before writing the seed line. Until confirmed, use `defaults/` only for the file found in the tarball.
- The DSN contains a password, so it is passed via the environment only, never written to a file or a command line, per the start-script rules. Note that it is visible in `/proc/<pid>/environ` to the same user.
- Idempotent: `mkdir -p` and `cp` only when missing. Nothing is written under `/app`.
- Bind: confirm the server listens on `0.0.0.0:8065` (UNVERIFIED default; the `ServiceSettings` listen address is not read yet).
- `exec` so the server gets signals as PID 1.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '8065'
http:
- port: '8065'
  path: /api/v4/system/ping
filePaths:
- /app/mattermost/bin/mattermost
- /app/mattermost/client
- /usr/share/licenses/mattermost/LICENSE
```

- `timeoutSeconds: 180` follows `apps/healthchecks`, a DB-using app with a slow start; confirm against Mattermost startup time.
- The ping path is from the 9.x Dockerfile; confirm it on 12.x (UNVERIFIED).
- PostgreSQL narrowing (protocol exception): the app has a hard `dependencies:` on `postgresql`, and it is expected not to start without the DB (UNVERIFIED, must be tested). Whether a sidecar DB can be wired into `container-test.yaml` with the forgetool primitives is UNVERIFIED. If that is not possible, the exception applies: keep the `tcp` and `http` probes above, and add a comment near the narrowed assertions, e.g. `# narrowed: requires external postgresql; full functional test not feasible in single-container suite`. Run step 3 with a PostgreSQL container on the same network (section 11).
- Do not add a `# narrowed` comment if the full probes pass without the DB.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/mattermost/data` (FileSettings, UNVERIFIED key) | `/config/data` (symlink) |
| `/mattermost/logs` | `/config/logs` (symlink) |
| `/mattermost/config` (config.json, writable from the admin console) | `/config/config` (seeded from `defaults/` when missing) |
| `/mattermost/plugins`, `/mattermost/client/plugins` | `/config/plugins`, `/config/client-plugins` (symlinks) |
| `/mattermost/bleve-indexes` (chart PVC) | UNVERIFIED whether 12.x writes it. If it does, add a `/config/bleve-indexes` symlink. |
| `PUID`/`PGID` 2000 (upstream distroless user) | Not used. The image runs as `apps` (UID 568), so `/config` must be owned by 568 for existing volumes (UNVERIFIED impact). |

Draft expectations reconciled: the chart's `/mattermost/config`, `data`, `logs`, `plugins`, `client/plugins` PVCs map to the `/config` tree here, not to separate PVCs, so existing chart data needs a move. The chart expects `readOnlyRootFilesystem: true` and runs non-root (568), both compatible. Not privileged.

## 10. Risks, caveats and open questions

- Version decision: the draft's 9.6.3 is stale, and the chart pins `release-9.6`. This plan targets 12.1.0. Confirm the upgrade path from a 9.6 database to 12.x (UNVERIFIED; migrations may be one-way). Do not point a 12.x image at a 9.6 database without this check.
- Edition and license: the Docker Hub reference is Enterprise, the tarball may be another edition, and the GitHub license is `NOASSERTION`. Confirm the edition, then the bake `LICENSE` (blocker for the PR).
- Checksum: no upstream checksum asset. Digest is UNVERIFIED until checked against the SLSA provenance (blocker for the Dockerfile `sha256sum -c` line).
- Database envs, site URL and config-file location names are UNVERIFIED (not fetched from docs). The `settings.yaml` env list is incomplete until they are confirmed.
- PostgreSQL is a hard dependency; the protocol exception may apply (section 8).
- `arm64`: the tarball exists (HTTP 200 for 12.1.0). The Docker Hub EE tags `release-12`, `release-12.2`, `12.2.0-rc1` list amd64 only, so there is no `copy-from arm64`.
- `copy-from amd64`: `mattermost/mattermost-enterprise-edition:release-12` is glibc (distroless), amd64 only. Not used: the plan downloads the tarball.
- Blockers: the license, the checksum, the DB variable names and the edition decision. None is a musl or GPU issue. No privileged need.

## 11. Build and test steps

```sh
cd apps/mattermost
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker network create mattermost-probe-net
docker run --rm -d --name mattermost-probe-db --network mattermost-probe-net \
  -e POSTGRES_PASSWORD=probe -e POSTGRES_DB=mattermost -e POSTGRES_USER=mattermost \
  postgresql:<tag>      # image built from apps/postgresql (tag from its docker-bake.hcl)
docker run --rm -d --name mattermost-probe --network mattermost-probe-net --read-only --tmpfs /tmp \
  -p 8065:8065 -v mattermost-probe-config:/config mattermost:12.1.0
docker logs -f mattermost-probe
curl -fsS http://localhost:8065/api/v4/system/ping
forgetool containers test --image mattermost:12.1.0 --config ./apps/mattermost/container-test.yaml
docker rm -f mattermost-probe mattermost-probe-db; docker volume rm mattermost-probe-config; docker network rm mattermost-probe-net
```

- The PostgreSQL image tag for the probe is taken from `apps/postgresql/docker-bake.hcl` (not fixed here). The `docker run` line above is a template.
- Expected readiness signal: a server start line that names the listen address on port 8065 (exact text UNVERIFIED; read it from the first run), and no fatal DB error once the DB is reachable.
- Test empty-`/config` startup with a fresh volume, then restart with the same volume and confirm the data survives.
- Also check `ss -ltn` inside the container for 8067 and 8074 before deciding on them.
- Round limit: 10 rounds per the build-test protocol.

## 12. PR checklist

- Branch `feat/add-mattermost`, commit and PR title `feat(mattermost): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, check only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- CLA notice: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it. The `license/cla` check shows the status.
- Untested, to state honestly in the PR: the 12.x startup and DB migration, the arm64 image, the ping path on 12.x, `--read-only` behaviour, the plugin paths, the edition choice and license, and the checksum.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; no assertion weakened; `LICENSE` and the checksum confirmed before merge.
