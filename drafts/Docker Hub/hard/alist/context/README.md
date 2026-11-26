# alist context

Summaries of the web sources referenced by `draft.md` and `plan.md`. Fetched 2026-11-26.

| Source URL | Summary file |
| --- | --- |
| https://github.com/AlistGo/alist (README, Dockerfile, entrypoint.sh, releases/latest) | github-alistgo-alist.md |
| https://github.com/AlistGo/with_aria2 (Dockerfile @ 12a215e) | github-alistgo-with-aria2.md |
| https://alistgo.com/guide/ and /guide/install/docker.html | alistgo-docs.md |
| https://hub.docker.com/r/xhofe/alist-aria2 | dockerhub-xhofe-alist-aria2.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/alist | truecharts-alist.md |

## Skipped
- https://cla-assistant.io/trueforge-org/containerforge: CLA link.
- https://raw.githubusercontent.com/trueforge-org/forgetool/... (2 schema URLs): forgetool schema.
- https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu: ContainerForge base-app link.
- https://github.com/AlistGo/alist/releases/download/... (alist-linux-${TARGETARCH}.tar.gz, alist-linux-amd64.tar.gz, alist-linux-arm64.tar.gz, md5.txt, v3.41.0 variants): direct binary/archive downloads. Asset naming pattern and md5 policy recorded in github-alistgo-alist.md.
- https://raw.githubusercontent.com/AlistGo/alist/v${VERSION}/LICENSE: raw licence file, not fetched. AGPL-3.0 stated by README and docs.
- https://github.com/AlistGo/alist/ (trailing slash) and https://alistgo.com/ (site root, covered by docs summary): deduped.
- https://github.com/Xhofe/alist (old repo name, redirects to the AlistGo/alist project per the docs; the docs point to alist-org/alist): not fetched separately.
- https://hub.docker.com/r/xhofe/alist and `ghcr.io/trueforge-org/*`, `xhofe/alist-aria2`, `docker.io/xhofe/alist-aria2` image refs: not web pages (Hub page for alist-aria2 fetched as above).

## Fetch failures
- Release asset list at https://github.com/AlistGo/alist/releases/latest did not load ("There was an error while loading"). Asset names not confirmed.

## plan.md corrections
None made. Items checked against sources:
- plan.md section 1 "First-run admin ... logs it": not supported by the docs (see unverified below). Left as is.

## Unverified (not changed in plan.md)
- plan.md section 1 "First-run admin": alist generating and logging a random admin password on first start. Docs describe `./alist admin` and `./alist admin random` / `admin set` instead, with no first-run log mention. Recheck in the run step.
- plan.md section 1 release assets `alist-linux-amd64.tar.gz`, `alist-linux-arm64.tar.gz`, `md5.txt`, and musl variants: asset list did not load.
- Draft `copy-from` value `xhofe/alist-aria2:v3.41.0`: the Hub page lists only `latest`.
- plan.md section 1 `ALIST_*` env prefix and `config.go` details: not in fetched sources (upstream entrypoint uses `--no-prefix`).
- LICENSE is `AGPL-3.0-only` in plan.md; the fetched sources say `AGPL-3.0` without the `-only` qualifier.
