# tauticord — implementation plan
> Source: ./draft.md · Target: apps/tauticord/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Latest stable | `6.2.0`, published 2026-11-14 (https://codeberg.org/api/v1/repos/nwithan8/tauticord/releases/latest). Matches the draft tag. |
| Renovate | UNVERIFIED: the Codeberg datasource is not confirmed on a fetched page. Plan uses the Gitea/Forgejo datasource, to be checked against the Renovate docs before merge: `datasource=gitea depName=codeberg.org/nwithan8/tauticord versioning=semver`. |
| License | GPL-3.0 (LICENSE file at https://codeberg.org/api/v1/repos/nwithan8/tauticord/raw/LICENSE, GNU GPL version 3 text). Repo metadata licence field was not shown. |
| Source URL | https://codeberg.org/nwithan8/tauticord |
| Download | Source archive at the tag (not fetched). Release page has no assets (`assets` list is empty, https://codeberg.org/api/v1/repos/nwithan8/tauticord/releases/latest). Plan builds from the tagged source. Archive URL `https://codeberg.org/nwithan8/tauticord/archive/6.2.0.tar.gz` is UNVERIFIED: not fetched. |
| Checksum source | None published on the release. Pin by tag, and verify the archive checksum once it is fetched (UNVERIFIED: not computed). |
| Upstream Dockerfile reviewed | https://codeberg.org/nwithan8/tauticord/raw/tag/6.2.0/Dockerfile. Single stage `nwithan8/python-node-alpine:04152026_1` (Alpine, musl). `WORKDIR /app`. Copies `requirements.txt`, runs `pip install` into `/app/venv` (with `LIBRARY_PATH=/lib:/usr/lib`), `COPY . .`, `VOLUME ["/config", "/logs"]`, `EXPOSE 8283`, `ENTRYPOINT ["sh", "entrypoint.sh"]`. No `USER` set. |
| Ports | 8283 from upstream `EXPOSE`. The draft says `none`. Whether the app listens on 8283 is UNVERIFIED (`entrypoint.sh` and the app source were not fetched). |
| Env vars (real) | UNVERIFIED: `entrypoint.sh` and app source not fetched. Upstream Dockerfile sets none. |
| Python dependencies | From `requirements.txt` (tag 6.2.0, fetched via Codeberg API): `discord.py==2.5.*`, `asyncio~=3.4`, `tautulli==4.9.*,>=4.9.0.2180`, `confuse==2.0.1`, `PyYAML==6.0.*`, `objectrest~=2.0.0`, `psutil==5.9.8`, `emoji==2.11.1`, `Flask~=3.1.3`, `matplotlib==3.10.8`, `SQLAlchemy~=2.0.25`, `sqlalchemy-utils==0.41.1`, `pydantic>=2.10.0`, `typing-extensions`. |
| Data paths | UNVERIFIED: upstream declares `/config` and `/logs` as volumes; what the app writes there is not confirmed. |

## 2. Target layout

- `apps/tauticord/Dockerfile`
- `apps/tauticord/docker-bake.hcl`
- `apps/tauticord/settings.yaml`
- `apps/tauticord/container-test.yaml`
- `apps/tauticord/start.sh` (replaces upstream `entrypoint.sh`, which is not fetched; the replacement is written after it is read, see section 10)

No `defaults/` yet. Add `defaults/config.yaml` (seeded into `/config` only when missing) only if the app needs a template, which is UNVERIFIED. No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`

Fits because the app is pure Python with pip requirements. The python base ships `/app/venv` (read-only at runtime, per the python runtime rules). The draft's alternative (ubuntu base) is not used: the python base already provides the interpreter and venv. The upstream Alpine (musl) image cannot be used as-is, so the glibc python base is the correct choice. Closest siblings: `apps/bazarr` (python, pip into the app), `apps/budge` and `apps/changedetection` (python-node, for patterns).

## 4. Dockerfile

1. `FROM` line above. `ARG VERSION`, `ARG PIP_VERSION`... only where the Dockerfile uses them (not needed here).
2. `USER root`, `WORKDIR /app`.
3. Fetch source at the tag:
   ```dockerfile
   RUN curl -fsSL -o /tmp/tauticord.tar.gz \
       "https://codeberg.org/nwithan8/tauticord/archive/${VERSION}.tar.gz" \
    && tar xzf /tmp/tauticord.tar.gz -C /app --strip-components=1 \
    && rm /tmp/tauticord.tar.gz
   ```
   The archive URL is UNVERIFIED (see section 1); confirm it before the first build.
4. Install requirements into the base venv at build time (runtime must not write `/app/venv`):
   ```dockerfile
   RUN /app/venv/bin/pip install --no-cache-dir -r /app/requirements.txt --prefer-binary
   ```
   `PIP_NO_CACHE_DIR=1` is already set by the base. Run as root at build time, then `chown -R apps:apps /app && chmod -R 755 /app`.
5. Licence: copy `LICENSE` to `/usr/share/licenses/tauticord/LICENSE`.
6. Tail:
   ```dockerfile
   USER apps
   COPY --chmod=0755 . /

   EXPOSE 8283
   VOLUME /config
   ```
   `EXPOSE 8283` and `VOLUME /logs` are included only if confirmed (section 10). Otherwise leave them out.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "tauticord"
}

variable "VERSION" {
  // renovate: datasource=gitea depName=codeberg.org/nwithan8/tauticord versioning=semver
  default = "6.2.0"
}

variable "LICENSE" {
  default = "GPL-3.0-only"
}

variable "SOURCE" {
  default = "https://codeberg.org/nwithan8/tauticord"
}
```

Then the four standard targets and the default group, copied from `apps/adguardhome-sync/docker-bake.hcl`. The `LICENSE` value is `GPL-3.0-only` from the GPL-3 text; confirm against the repo licence field before merge (it is not shown in the API response, so use `GPL-3.0` if the field is missing). Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://codeberg.org/nwithan8/tauticord"
ports:
  - port: 8283
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

`ports` lists 8283 only once `start.sh` confirms the app binds it (section 10). If the app does not listen on 8283, set `ports: []` and note it. Other env vars are not listed until verified from the source. Dependencies: none in ContainerForge; Tautulli and Discord are external (draft).

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config

cd /app
exec /app/venv/bin/python /app/main.py
```

`/app/main.py` as the entry module is UNVERIFIED (the upstream entrypoint is not fetched). Replace it with the real entry point after reading `entrypoint.sh` from the 6.2.0 tag. Idempotent: creates `/config` only. If the app needs a config file in `/config` (draft caveat), seed it from `/app/defaults/` with `cp -n`, never overwrite. Writes go to `/config` (state) and `/tmp` (scratch). The app must bind `0.0.0.0` when it serves HTTP. Use `exec` so signals reach the process.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
filePaths:
- /app/venv/bin/python
- /app/requirements.txt
- /usr/share/licenses/tauticord/LICENSE
```

If the app listens on 8283 (section 10), add `tcp: [{port: '8283'}]`, and `http` only with a confirmed path. Without a confirmed listener, the suite stays file and process checks only, and the PR says so. The app needs a Tautulli server and Discord credentials to do anything useful; the test runs without env vars, so any code path that needs them is not covered (mention in the PR).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/config` (volume, state) | Kept as `/config`. Created by `start.sh` when missing. |
| `/logs` (upstream volume) | UNVERIFIED whether the app writes logs there. If it does, map logs to `/config/logs` through the app's own log-path setting (name UNVERIFIED). |
| pip and build caches | Build time only, `PIP_NO_CACHE_DIR=1` from the base. No runtime cache. |
| `/app/venv` | Read-only at runtime. Installed at build time only. |

Draft expectations reconciled: the chart runs as root with a read-only rootfs disabled, extra `/logs` and `/monitor` PVCs. This image runs as `apps` (568) and is compatible with `--read-only --tmpfs /tmp`. The `/monitor` PVC is not needed unless the app writes there (UNVERIFIED).

## 10. Risks, caveats and open questions

- Upstream `entrypoint.sh` and the app source were not fetched. The real entry module, env var names, port and write paths are UNVERIFIED. Read them from the 6.2.0 tag (codeberg raw files, `ref=6.2.0`) before writing `start.sh`. Do not guess names.
- Port 8283: upstream `EXPOSE`s it but the draft says `none`. Decide after reading the source. Do not list a port the app does not open.
- Alpine vs glibc: upstream image is musl (Alpine). This plan uses the glibc python base. Wheels for `matplotlib==3.10.8`, `psutil==5.9.8`, `SQLAlchemy`, and `pydantic` must exist for manylinux on both amd64 and arm64; `--prefer-binary` plus pinned versions should cover it, but this is UNVERIFIED for arm64.
- arm64: no published binary. The build must succeed on arm64 through buildx; not verified.
- Renovate datasource for Codeberg (`gitea`) is UNVERIFIED.
- Licence field on Codeberg not shown; `LICENSE` file says GPL-3.0.
- Source is Codeberg only; the release tag is the dependency. Note in the PR.
- No blockers identified beyond the above.

## 11. Build and test steps

```sh
cd apps/tauticord
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name tauticord-probe --read-only --tmpfs /tmp \
  -v tauticord-probe-config:/config tauticord:6.2.0
docker logs -f tauticord-probe
forgetool containers test --image tauticord:6.2.0 --config ./apps/tauticord/container-test.yaml
docker rm -f tauticord-probe; docker volume rm tauticord-probe-config
```

Readiness signal: the process stays running and logs a startup line (exact text UNVERIFIED; take it from the first real run). Expected clean idle behaviour: connection-retry lines for Tautulli or Discord are acceptable only if the process stays alive (protocol rule); no fatal exit. If the app listens on 8283, probe it from the host with `-p 8283:8283`.

## 12. PR checklist

- Branch `feat/add-tauticord`, commit and PR title `feat(tauticord): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only applicable boxes.
- Notes section contains `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is needed (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows the status.
- Say what was not tested: arm64 build and run, the Codeberg archive checksum, the runtime with real Tautulli and Discord credentials, and the musl-to-glibc switch.
- `docker buildx bake --print` must pass; `VERSION` in bake and Dockerfile must match; no assertion weakened.
