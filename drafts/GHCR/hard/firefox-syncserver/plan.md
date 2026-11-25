# firefox-syncserver — implementation plan
> Source: ./draft.md · Target: apps/firefox-syncserver/ · Difficulty: hard · Role: main · Verified on 2026-11-25

**Recommendation: do not port this app.** It is blocked by Python 2.7 end-of-life, by archived upstream repos, and by the lack of a runtime path on the current base. Sections 2 to 8 record the facts and what a port would require, but no `apps/` folder should be created unless the user overrides this.

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Chart tag today | `ghcr.io/crazy-max/firefox-syncserver:1.8.0` (draft). The ghcr tag is UNVERIFIED: ghcr was not fetched. |
| Upstream wrapper repo | `crazy-max/docker-firefox-syncserver` is **archived**, last push 2023-05-04. Latest release `1.8.0-r15`, published 2021-03-04 (https://api.github.com/repos/crazy-max/docker-firefox-syncserver/releases/latest). License MIT. |
| Upstream syncserver repo | `mozilla-services/syncserver` is **archived**, last push 2023-08-30, license MPL-2.0 (https://api.github.com/repos/mozilla-services/syncserver). |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/crazy-max/docker-firefox-syncserver/45fc9e0a5fa863fb109d5f4ae34b5d5e4656ee11/Dockerfile: `FROM python:2.7-alpine3.10` (Alpine, EOL Python 2.7). Clones syncserver and pins `SHA1_COMMIT=5932c464d70ec9cf0344b1d3e970b3711de6a98e`. Entrypoint `/entrypoint.sh`, CMD `gunicorn --paste /opt/syncserver/syncserver.ini`. |
| Ports | `EXPOSE 5000` (same Dockerfile). |
| Volumes | `VOLUME ["/data"]` (same Dockerfile). Chart uses `/config` only (draft). |
| Env (real) | `TZ=UTC`, `PUID=1000`, `PGID=1000` (same Dockerfile). Syncserver's own env names: UNVERIFIED (not fetched). |
| User | No `USER` instruction; `entrypoint.sh` creates a `syncserver` user via `PUID`/`PGID`. |
| Binary per arch | No release asset. Source only, pinned by commit. amd64 and arm64: **no ready-made executable** (draft `no`/`no`, confirmed by the Dockerfile). |
| copy-from | `no`: upstream image is Alpine/musl, Python 2.7. |
| Checksum | None published (source pinned by commit SHA). |

## 2. Target layout

Not applicable: blocked (see section 10). If the user overrides and a port goes ahead, the layout would be the usual five files, but the runtime is not chosen yet.

## 3. Base image

Not applicable. The draft's `ghcr.io/trueforge-org/python:3.15.2` is Python 3.15. Syncserver requires Python 2.7 (upstream), which the current base cannot provide. Closest sibling if a Python runtime were used: `apps/bazarr` (python base, `/app` read-only). A Python 2.7 runtime is not in ContainerForge.

## 4. Dockerfile

Not applicable: no Dockerfile is written while blocked.

## 5. docker-bake.hcl

Not applicable: no bake file while blocked.

## 6. settings.yaml

Not applicable. For reference only: the chart's dependency is `postgresql`, and `apps/postgresql` exists (draft marked ✅). Upstream default storage is SQLite in `/data`; Postgres is optional.

## 7. start.sh

Not applicable.

## 8. container-test.yaml

Not applicable.

## 9. Rootless and read-only-rootfs adaptations

Not applicable while blocked. Reconciled from the draft: the chart runs as UID 0 with `allowPrivilegeEscalation: true`, `readOnlyRootFilesystem: false`. A ContainerForge port would have to drop both, and the upstream `/data` write path would need to move to `/config`.

## 10. Risks, caveats and open questions

- **Blocker: Python 2.7 end-of-life.** Alpine 3.10 and `python:2.7` are not available on the current base. No supported runtime exists in ContainerForge.
- **Blocker: archived upstream.** Both the wrapper and `mozilla-services/syncserver` are archived. There is no upstream security path (fact above).
- **Blocker: no binary per arch.** No release asset exists, and source builds need Python 2.7 toolchains.
- **Draft caveat, confirmed:** Firefox Sync requires HTTPS on a public host, so a reverse proxy with a valid certificate is needed. The container alone does not satisfy this.
- **Draft caveat, confirmed:** default storage is local SQLite in `/data`, which must be on a persistent volume.
- **Successor project (out of scope):** Mozilla's Rust successor `syncstorage-rs` is a different application. A port would be a new app, not this one. The docs link in the draft points to the successor (https://mozilla-services.github.io/syncstorage-rs/).
- **UNVERIFIED:** whether `ghcr.io/crazy-max/firefox-syncserver:1.8.0` still exists and what architectures it has.
- **Decision for the user:** drop this draft, or write a new draft for `syncstorage-rs` and port that instead.

## 11. Build and test steps

Not applicable: do not run `docker buildx bake` or any build for this draft.

## 12. PR checklist

Not applicable: no branch, commit or PR while blocked. If the user later overrides and a port goes ahead, the checklist would be the standard one (`feat/add-firefox-syncserver`, `feat(firefox-syncserver): add new container`, AI notice, CLA notice, honest list of what was not tested).
