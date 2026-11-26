# Context sources: vikunja

Fetched 2026-11-26.

## Source URL -> file

| Source URL | File |
| --- | --- |
| https://github.com/go-vikunja/vikunja | github-go-vikunja-vikunja.md |
| https://github.com/go-vikunja/vikunja/blob/v2.8.0/Dockerfile | github-go-vikunja-vikunja.md (raw Dockerfile v2.8.0) |
| https://github.com/go-vikunja/vikunja/releases | github-go-vikunja-vikunja.md (version and asset naming) |
| https://hub.docker.com/r/vikunja/vikunja | dockerhub-vikunja-vikunja.md |
| https://vikunja.io/docs/ | docs-vikunja-io.md |
| https://vikunja.io/docs/config-options (followed link) | docs-vikunja-io.md |
| https://vikunja.io/docs/docker-walkthrough (followed link) | docs-vikunja-io.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/vikunja | truecharts-vikunja.md |

## Skipped

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA page |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json | forgetool schema URL |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge apps/<base> link |
| https://github.com/go-vikunja/vikunja/releases/download/v2.8.0/veans-*.apk, veans-*-full.zip | direct binary/archive downloads (veans CLI); naming recorded in the releases summary |
| https://github.com/go-vikunja/vikunja/releases/download/v${V}/${Z} | placeholder download URL |
| https://github.com/go-vikunja/vikunja/releases/download/v2.8.0/vikunja-v2.8.0-linux-*-full.zip | direct archive download; naming recorded in the releases summary |
| https://dl.vikunja.io/vikunja/v2.8.0/vikunja-v2.8.0-linux-... (and .sig) | direct binary download; not fetched |
| http://127.0.0.1:3456/health | localhost / 127.0.0.1 |
| ghcr.io/trueforge-org/ubuntu (with digest) | ghcr image ref, not a web page |
| docker.io/vikunja/vikunja:2.8.0 | image ref, covered by the Docker Hub page |

## Fetch failures

None. The vikunja.io docs landing page gave only relative link paths; the followed config and docker pages were resolved to https://vikunja.io/docs/... .

## plan.md corrections

Edited: none.

Notes (not edited):
- confirmed: upstream Dockerfile at v2.8.0 (scratch, WORKDIR /app/vikunja, ENTRYPOINT, EXPOSE 3456, USER 1000, `VIKUNJA_DATABASE_PATH=/db/vikunja.db`, `GODEBUG=multipathtcp=0`).
- confirmed: env var naming and defaults listed in plan.md section 1 (`VIKUNJA_` prefix, sqlite default, `service.interface :3456`, `service.enableregistration` true, `service.timezone` GMT, `keyvalue.type` memory).
- unverified (kept): plan.md section 1 `VIKUNJA_DATABASE_HOST` default `localhost`, `VIKUNJA_LOG_PATH` default; not stated in fetched docs.
- confirmed: plan.md section 10 claim that `/tmp` must be writable for exports (docs say so). Left as-is.
- noted: the chart uses port 10220 and a config.yaml secret; the plan's use of 3456 and env vars is an independent choice, not a contradiction of upstream.
- unverified: `.sha256`/`.sig` inside the zip and the exact `vikunja-...-full.zip` asset names (not shown on the releases page, which lists only 13 of 69 assets).
