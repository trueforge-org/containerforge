# Context sources: vlmcsd-kms-server

Fetched 2026-11-26.

## Source URL -> file

| Source URL | File |
| --- | --- |
| https://github.com/Wind4/vlmcsd | github-wind4-vlmcsd.md (repo; README raw fetch failed, see below) |
| https://github.com/Wind4/vlmcsd/releases/tag/svn1113 | github-wind4-vlmcsd.md (release and asset naming) |
| https://raw.githubusercontent.com/Wind4/vlmcsd/svn1113/man/vlmcsd.8 | github-wind4-vlmcsd.md (flags) |
| https://github.com/mikolatero/docker-vlmcsd | github-mikolatero-docker-vlmcsd.md |
| https://github.com/mikolatero/docker-vlmcsd/blob/master/Dockerfile | github-mikolatero-docker-vlmcsd.md (raw Dockerfile) |
| https://hub.docker.com/r/mikolatero/vlmcsd | dockerhub-mikolatero-vlmcsd.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/vlmcsd-kms-server | truecharts-vlmcsd-kms-server.md |

## Skipped

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA page |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json | forgetool schema URL |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge apps/<base> link |
| https://github.com/Wind4/vlmcsd/archive/refs/tags/svn1113.tar.gz, https://github.com/Wind4/vlmcsd/archive/refs/tags/${VERSION}.tar.gz | source tarball download (archive); pattern recorded |
| https://github.com/Wind4/vlmcsd/releases/download/svn1113/binaries.tar.gz | direct binary archive download; contents recorded from draft/plan only |
| ghcr.io/trueforge-org/ubuntu (with digest) | ghcr image ref, not a web page |
| docker.io/mikolatero/vlmcsd:latest | image ref, covered by the Docker Hub page |

## Fetch failures

- https://raw.githubusercontent.com/Wind4/vlmcsd/master/README.md: HTTP 404.
- https://raw.githubusercontent.com/Wind4/vlmcsd/svn1113/README.md: HTTP 404 (alternative tried).
- https://raw.githubusercontent.com/Wind4/vlmcsd/svn1113/LICENSE: HTTP 404 (confirms no license file at the tag).
- Release assets list on https://github.com/Wind4/vlmcsd/releases/tag/svn1113 did not load (names unknown).

## plan.md corrections

Edited: none.

Notes (not edited):
- confirmed: no LICENSE at svn1113 (404), supporting plan.md `NOASSERTION`.
- confirmed: man page flag list (`-D`, `-e`, `-L`, `-t`, `-v`, `-d`, `-r`, `-K`, `-c`, `-o`) and defaults (listen on 0.0.0.0 and :: on 1688).
- confirmed: upstream Dockerfile is the same CMD as plan.md section 1 (`/vlmcsd -D -d -t 3 -e -v`), `EXPOSE 1688/tcp`.
- confirmed: no env vars documented on the man page or Docker Hub.
- unverified: plan.md section 1 `apt` and arm64 claims were not re-checked here (no fetch of Ubuntu package pages).
- unverified: the plan's statement that the upstream README says it is "not meant to activate unlicensed copies". The README was not retrievable. The Docker Hub page says "not a one-click activation or crack tool"; plan.md wording is not confirmed verbatim.
- note: the upstream repo is archived (14 Aug 2024). plan.md does not mention it; Renovate `github-tags` will see no new svn tags. Not an error, just context.
- note: the mikolatero wrapper builds upstream master, not the svn1113 tag. Plan.md pins svn1113 (not a factual error).
