# Context: filestash

| Source URL | File |
| --- | --- |
| https://github.com/mickael-kerjean/filestash (+ docker/Dockerfile raw, master) | mickael-kerjean-filestash-dockerfile.md |
| https://www.filestash.app/docs | filestash-docs-install.md |
| https://www.filestash.app/docs/install-and-upgrade/ | filestash-docs-install.md |
| https://www.filestash.app | filestash-docs-install.md (landing page; no install content, see docs file) |
| https://www.filestash.app/docs/guide/configuration.html (follow-up) | filestash-config-guide.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/filestash (+ raw Chart.yaml, values.yaml) | truecharts-filestash.md |
| https://hub.docker.com/r/machines/filestash (+ v2 API repo and tags) | dockerhub-filestash.md |

Skipped: urls.txt has no CLA, forgetool, containerforge, templated, binary or image-ref URLs. hub.docker.com HTML not fetched; v2 JSON API used.

Failures: https://api.github.com/repos/mickael-kerjean/filestash/releases/latest returned 404; fallback github.com releases/latest page fetched: no releases (tags only). Note: the www.filestash.app root URL was not fetched separately; /docs landing covered it.

## plan.md corrections
- No edits. Consistent with fetched sources: 3-stage Dockerfile (alpine/git, golang:1.27.0-trixie, debian:stable-slim), runtime packages, user `filestash`, `CMD ["/app/filestash"]`, `EXPOSE 8334`, `/app/data/state/` path, state/config default.
- Resolved UNVERIFIED item (not edited, for plan author): plan.md line 168 says ADMIN_PASSWORD format is unverified. The install docs (https://www.filestash.app/docs/install-and-upgrade/) state `ADMIN_PASSWORD` should be set to a bcrypt hash.
- Not verified by fetched sources: `FILESTASH_PATH`, `CONFIG_SECRET`, `/healthz` (not on fetched pages). Plan's pinned master commit not checked.
- Docker Hub `machines/filestash:latest` now shows last_updated 2026-11-26 (plan says 2026-11-24). Later update, not a factual conflict; no edit.
- Chart persistence `/app/data/state` and chart env `APPLICATION_URL` recorded; not conflicting with plan.
