# quassel-core: context index

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/quassel-core/values.yaml | truecharts-quassel-core.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/quassel-core/Chart.yaml | truecharts-quassel-core.md |
| https://hub.docker.com/v2/repositories/linuxserver/quassel-core/ (+ /tags?page_size=10) | dockerhub-quassel-core.md |
| https://raw.githubusercontent.com/linuxserver/docker-quassel-core/c995ed5491d2/Dockerfile (= blob URL) | github-linuxserver-docker-quassel-core-dockerfile.md |
| https://raw.githubusercontent.com/linuxserver/docker-quassel-core/master/README.md (= repo URL) | github-linuxserver-docker-quassel-core-readme.md |
| https://api.github.com/repos/quassel/quassel/releases/latest | github-quassel-quassel-release.md |
| https://raw.githubusercontent.com/quassel/quassel/master/README.md (= repo URL, release tag page) | github-quassel-quassel-release.md |
| https://packages.ubuntu.com/resolute/quassel-core | ubuntu-packages-quassel-core.md |
| https://quassel-irc.org/about, https://bugs.quassel-irc.org/projects/1/wiki | quassel-irc-website.md (failed) |

## Skipped
- Repo HTML pages https://github.com/quassel/quassel and https://github.com/linuxserver/docker-quassel-core, and tag page https://github.com/quassel/quassel/releases/tag/0.14.0 (covered by raw/API files).
- Dockerfile blob URL (duplicate of raw).
- Base image ghcr.io/linuxserver/baseimage-alpine:3.20 (image ref).
- Quassel LICENSE/COPYING not in the URL list, so not fetched.

## Failures
- quassel-irc.org/about and bugs.quassel-irc.org wiki: HTTPS certificate expired; http:// alternative returns 301 (not followed). Not retried.

## plan.md corrections
- None. Verified against fetched data: release 0.14.0 (2022-01-01), Ubuntu resolute package 1:0.14.0-4ubuntu2, ports 4242 and 10113, Dockerfile base alpine 3.20.
- Unverified in plan, not changed: license (COPYING not fetched).
