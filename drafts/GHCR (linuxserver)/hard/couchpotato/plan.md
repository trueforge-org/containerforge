# couchpotato — implementation plan
> Source: ./draft.md · Target: apps/couchpotato/ · Difficulty: hard · Role: main · Verified on 2026-11-25

Status: BLOCKED on a Python 3 runtime decision. The upstream code and the linuxserver image are Python 2 only, and no verified Python 3 port was found in this batch. The project is archived. Do not start `apps/couchpotato/` until a Python 3 source is chosen and verified (section 10).

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Latest GitHub release is `build/3.0.1` ("V3.0.1", published 2015-08-31, not a prerelease). https://api.github.com/repos/CouchPotato/CouchPotatoServer/releases/tags/build%2F3.0.1 (read with `gh api`). The linuxserver image does not use this release. It downloads a source tarball of a commit (`COUCHPOTATO_RELEASE`, defaulting to the latest `master` SHA). |
| Release assets | Windows and macOS only: `CouchPotato-3.0.1.macosx-10_6-intel.zip`, `CouchPotato-3.0.1.win-amd64.installer.exe`, `CouchPotato-3.0.1.win-amd64.zip`, `CouchPotato-3.0.1.win32.installer.exe`, `CouchPotato-3.0.1.win32.zip`. No Linux or arm64 asset. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/linuxserver/docker-couchpotato/273f98c4d935e5c5629b3978685c4066402c8490/Dockerfile |
| Upstream FROM | `ghcr.io/linuxserver/baseimage-alpine:3.13` (musl Alpine, not glibc). |
| Upstream install | `apk add --no-cache curl python2 unrar unzip`; `ENV PYTHONIOENCODING=UTF-8`; `WORKDIR /app/couchpotato`; downloads `https://github.com/CouchPotato/CouchPotatoServer/archive/${COUCHPOTATO_RELEASE}.tar.gz` and extracts with `--strip-components=1`; `COPY root/ /`; `EXPOSE 5050`; `VOLUME /config`. No ENTRYPOINT, CMD, USER or arch logic. |
| Python | Python 2 (`python2` Alpine package). No Python 3 support confirmed. |
| Renovate | UNVERIFIED. If a commit is pinned: `datasource=git-refs depName=https://github.com/CouchPotato/CouchPotatoServer currentValue=master`, as in the fenrus plan (`apps/fenrus` does not exist yet; UNVERIFIED precedent, `apps/tvheadend` is the cited git-refs precedent there). A Python 3 fork would need its own depName (UNVERIFIED which). |
| License | GPL-3.0 (https://api.github.com/repos/CouchPotato/CouchPotatoServer, `gh api`). |
| Repo status | `archived: true`, last push 2021-08-04 (same source). |
| Source URL | https://github.com/CouchPotato/CouchPotatoServer |
| Per-arch download | Source tarball is architecture independent: `https://github.com/CouchPotato/CouchPotatoServer/archive/<commit-sha>.tar.gz`. The pinned SHA is not yet chosen (UNVERIFIED). |
| Checksum source | None published. Release has no checksum asset. The tarball is pinned by commit SHA only. |
| Ports | `5050` (EXPOSE 5050, confirmed by upstream Dockerfile). |
| Data / config paths | `/config` (VOLUME /config). App code at `/app/couchpotato`. Exact state files under `/config` (config.ini, database): UNVERIFIED (the `root/` overlay was not fetched). |
| Env vars | `PYTHONIOENCODING=UTF-8` (set by upstream image). No other env confirmed. Do not invent any. |
| arm64 | Source is arch independent, but the Python 3 runtime is UNVERIFIED. The upstream image copy-from is `no` (alpine musl build, not glibc Ubuntu). |
| Python 3 port | No fetched source confirms a Python 3 port exists. UNVERIFIED. |

## 2. Target layout

If the blocker in section 10 is cleared:

- `apps/couchpotato/Dockerfile`
- `apps/couchpotato/docker-bake.hcl`
- `apps/couchpotato/settings.yaml`
- `apps/couchpotato/container-test.yaml`
- `apps/couchpotato/start.sh`
- `apps/couchpotato/defaults/` only if the app needs a seeded `config.ini` (reason: UNVERIFIED that it does; decide after reading `root/` in the upstream image).

Never use `root/`. No `DOWNSTREAM_CHANGES.md`: not a `FROM` base.

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`, as the draft proposes, for the final stage. Reason: a Python app on the ContainerForge python base. This is valid only if the source runs on Python 3 (section 10). The Python 2 interpreter from upstream is not carried over.

Closest sibling: `apps/bazarr` (python base, a python app with a config in `/config`). Confirm the sibling's layout when the plan is executed.

## 4. Dockerfile

Only after section 10's decision. Steps:

1. Build stage `FROM <python> AS build`, `ARG VERSION` (pinned commit SHA of the chosen source), `USER root`.
2. `curl -fL https://github.com/CouchPotato/CouchPotatoServer/archive/${VERSION}.tar.gz | tar xz -C /tmp/src --strip-components=1` (or the Python 3 fork's URL).
3. Final stage `FROM <python>`, `USER root` only if an apt step is needed (`unrar`/`unzip` optional helpers, check whether the base has them; do not install what the base already has).
4. `COPY --from=build /tmp/src /app/couchpotato`, licence to `/usr/share/licenses/couchpotato/LICENSE` (GPL-3.0 text from the source tree).
5. `COPY --chmod=0755 . /`, `EXPOSE 5050`, `VOLUME /config`, `WORKDIR /app/couchpotato`, final `USER apps`.

Downloads: verify the tarball against the pinned SHA (content-addressed). No separate checksum is published (section 1).

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "couchpotato" }
variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/CouchPotato/CouchPotatoServer currentValue=master
  default = "<pin a verified commit SHA of the chosen source>"
}
variable "LICENSE" { default = "GPL-3.0" }
variable "SOURCE" { default = "https://github.com/CouchPotato/CouchPotatoServer" }
```

Four standard targets and the default group copied from `apps/adguardhome-sync`. Validate with `docker buildx bake --print`. `VERSION` must equal the Dockerfile `ARG VERSION`.

## 6. settings.yaml

Schema header per the settings rules, `schema_version: 1`, `upstream_env_url: "https://github.com/CouchPotato/CouchPotatoServer"`.

- `ports`: `5050/tcp`, `required: false`.
- `env`: none confirmed to be read by the app. `PYTHONIOENCODING` is set in the image, not user input, so do not list it as a setting. Do not invent variables.
- `volumes`: `/config`, `required: true` (state persists).
- `dependencies`: none (draft says none, nothing fetched contradicts it).

## 7. start.sh

Idempotent. Seed `/config` only when the state directory or config file is missing. Never write to `/app/couchpotato`. Caches in `/tmp`. Bind the web UI to `0.0.0.0` (CouchPotato's default bind address is UNVERIFIED; check `couchpotato.py`'s `--host`/config option). Finish with `exec python <entry> --data_dir /config ...` (entry file and flags UNVERIFIED for the chosen source).

## 8. container-test.yaml

Schema header per forgetool. `timeoutSeconds` from a Python sibling (UNVERIFIED which). `tcp` and `http` probe on `5050` at `/`. `filePaths`: the entry script (`CouchPotato.py` or the fork's equivalent, UNVERIFIED), and `/usr/share/licenses/couchpotato/LICENSE`. No env-required path.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/config` (state, config.ini, database, logs) | Keep as the only persistent path. Seed only when missing. |
| `/app/couchpotato` (code) | Read-only at runtime. Any runtime write (cache, pyc) must go to `/tmp` (set `PYTHONDONTWRITEBYTECODE=1` or a `PYTHONPYCACHEPREFIX=/tmp/pycache`; UNVERIFIED that it is needed). |
| Downloads and unrar temp | `/tmp` (UNVERIFIED which path the app uses). |

Draft security expectations reconciled: the chart runs as UID 0 and `readOnlyRootFilesystem` is the chart default (`true`). This image must run as `apps` and work with `--read-only --tmpfs /tmp`. Draft's "non-root possible, read-only possible" becomes a requirement, not an option.

## 10. Risks, caveats and open questions

- Blocker 1: the upstream code is Python 2. No Python 3 port was verified in this batch. Decision needed: (a) a verified Python 3 fork (name, URL and licence unknown), or (b) drop the app. Do not run Python 2 under the python base.
- Blocker 2: the project is archived (2021-08-04). The GitHub release is from 2015 and has no Linux asset. A commit SHA of `master` would be the only source.
- Caveat: the linuxserver image is Alpine/musl. Its copy-from result is `no`, so it cannot be reused on glibc Ubuntu.
- Caveat: indexer and downloader connections must be set in the web UI by hand (draft, inferred; UNVERIFIED).
- Caveat: an unmaintained app: security exposure on port 5050 (web UI). Confirm the auth settings before publishing.

## 11. Build and test steps

Only after section 10 is decided:

```sh
cd apps/couchpotato
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name couchpotato-probe --read-only --tmpfs /tmp \
  -v couchpotato-probe-config:/config couchpotato:<VERSION>
docker logs -f couchpotato-probe
forgetool containers test --image couchpotato:<VERSION> --config ./apps/couchpotato/container-test.yaml
docker rm -f couchpotato-probe; docker volume rm couchpotato-probe-config
```

Readiness signal: UNVERIFIED (CouchPotato's startup line for the chosen source).

## 12. PR checklist

- Branch `feat/add-couchpotato`, commit and PR title `feat(couchpotato): add new container`, target `main`.
- Notes section includes `🤖 This PR is AI generated.`
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only applicable boxes.
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows the status.
- Say that this plan has not been built or run, and state the Python 3 source, port and arm64 status as unverified.
