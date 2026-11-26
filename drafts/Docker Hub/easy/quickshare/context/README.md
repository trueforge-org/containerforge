# quickshare context index

Fetched 2026-11-26.

## Source URL -> file

| Source URL | File | Notes |
| --- | --- | --- |
| https://github.com/ihexxa/quickshare | github-ihexxa-quickshare.md | repo; README via raw master |
| https://raw.githubusercontent.com/ihexxa/quickshare/master/README.md | github-ihexxa-quickshare.md | fetched |
| https://github.com/ihexxa/quickshare/blob/f8216ab/Dockerfile | github-ihexxa-quickshare.md | fetched via raw at f8216ab |
| https://github.com/ihexxa/quickshare/releases/tag/v0.11.4 | github-ihexxa-quickshare.md | fetched; asset names did not render |
| https://hub.docker.com/r/hexxa/quickshare | dockerhub-hexxa-quickshare.md | fetched |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/quickshare | truecharts-quickshare.md | tree page; values via raw |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/quickshare/values.yaml | truecharts-quickshare.md | fetched |

## Skipped URLs

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA link |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json | forgetool schema |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json | forgetool schema |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge apps base link |
| https://github.com/ihexxa/quickshare/releases/download/v${VERSION#v}/quickshare_linux_${TARGETARCH}.zip | contains ${; direct binary download; pattern recorded |
| https://github.com/ihexxa/quickshare/releases/download/v0.11.4/quickshare_linux_amd64.zip | direct binary download; pattern recorded |
| https://github.com/ihexxa/quickshare/releases/download/v0.11.4/quickshare_linux_arm64.zip | direct binary download; pattern recorded |
| https://raw.githubusercontent.com/ihexxa/quickshare/v${VERSION#v}/LICENSE | contains ${ |

## Fetch failures

- None. Release asset list on the v0.11.4 page did not render (not a fetch failure; the page loaded). Asset names taken from plan.md and README examples.

## plan.md corrections

Context shows plan.md's port is already correct (8686, not 3000 as the draft said). No new edits made to plan.md. Nothing in the context clearly contradicts plan.md.

Unverified items (not edited):
- plan.md line 14: binary is dynamic glibc needing GLIBC_2.34 or lower, and the frontend is embedded. Not verified from fetched sources.
- plan.md line 18: `PORT` env var overrides the port (`server.go` reads `ENV.PORT`), `TOKENSECRET` read by `init_deps.go`. Source code not fetched.
- plan.md line 16: `Dockerfile_default` uses `configs/docker.yml`. Not fetched.
- plan.md line 13 and line 13 digests (amd64 `36256309...`, arm64 `b8434a01...`). Asset list did not render; digests not checked.
- plan.md line 10: LGPL-3.0-only license and "or later" question. Not checked.
- Upstream Dockerfile CMD/ADD/COPY path inconsistency (see github-ihexxa-quickshare.md). Plan does not use upstream CMD, so no edit.
