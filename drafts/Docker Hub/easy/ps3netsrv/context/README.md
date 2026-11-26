# ps3netsrv context index

Fetched 2026-11-26.

## Source URL -> file

| Source URL | File | Notes |
| --- | --- | --- |
| https://github.com/aldostools/ps3netsrv | github-aldostools-ps3netsrv.md | repo; README via raw master |
| https://github.com/aldostools/ps3netsrv/releases | github-aldostools-ps3netsrv.md | fetched; asset names not rendered |
| https://github.com/aldostools/webMAN-MOD/tree/master/_Projects_/ps3netsrv | github-aldostools-webman-mod-ps3netsrv.md | fetched |
| https://github.com/shawly/docker-ps3netsrv/blob/0585a23954e9b3ca27cc978ddc479af10e363ad1/alpine.Dockerfile | github-shawly-docker-ps3netsrv.md | fetched via raw at pinned commit |
| https://github.com/shawly/docker-ps3netsrv | github-shawly-docker-ps3netsrv.md | README via raw master |
| https://hub.docker.com/r/shawly/ps3netsrv | dockerhub-shawly-ps3netsrv.md | fetched |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/ps3netsrv | truecharts-ps3netsrv.md | tree page; values via raw |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/ps3netsrv/values.yaml | truecharts-ps3netsrv.md | fetched |

## Skipped URLs

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA link |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json | forgetool schema |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json | forgetool schema |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge apps base link (ubuntu is not an app FROM here; plan notes it) |
| https://api.github.com/repos/aldostools/ps3netsrv/releases/tags/${VERSION} | contains ${ |
| https://github.com/aldostools/ps3netsrv/archive/refs/tags/20261110.tar.gz | direct archive download; naming pattern recorded in github-aldostools-ps3netsrv.md |
| https://github.com/aldostools/ps3netsrv/releases/download/20261110/ps3netsrv_20261110_linux.zip | direct archive download; pattern recorded |
| https://raw.githubusercontent.com/aldostools/ps3netsrv/${VERSION}/LICENSE.TXT | contains ${ |

## Fetch failures

- Release asset list on https://github.com/aldostools/ps3netsrv/releases did not render (shows "Loading"). Asset names taken from plan.md and the release zip URL pattern; not verified from the page.
- https://raw.githubusercontent.com/shawly/docker-ps3netsrv/master/README.md and alpine.Dockerfile at pinned commit: fetched fine (no failures).

## plan.md corrections

No edits made. No factual mistake was clearly shown by the context.

Unverified items (not edited):
- plan.md line 8 says the draft tag `v2.0.1` is the shawly wrapper tag. Docker Hub and the TrueCharts values now show `v2.1.0` (`v2.1.0-alpine3.24` on Docker Hub). Could not confirm `v2.0.1` details.
- plan.md line 15 says the shawly pinned commit `0585a23` was not fetched. It has now been fetched (github-shawly-docker-ps3netsrv.md) and its env vars match plan.md (`PS3NETSRV_PORT`, `PS3NETSRV_WHITELIST`, `PS3NETSRV_BINARY`, `/games`, EXPOSE 38008).
- plan.md says amd64 binary is statically linked and arm64 is built static. Not verified from sources here.
- plan.md says the release zip contains `ps3netsrv_20261110/ps3netsrv_ubuntu-latest_amd64.deb`. Release asset list did not render; not verified.
- plan.md says the tag tarball has `Makefile.linux` at root. Consistent with the webMAN-MOD subtree listing `Makefile.linux`, not a direct check of the tag tarball.
