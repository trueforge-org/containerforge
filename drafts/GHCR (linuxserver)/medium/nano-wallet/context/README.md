# Context sources: nano-wallet

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/nano-wallet/values.yaml | truecharts-nano-wallet.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/nano-wallet/Chart.yaml | truecharts-nano-wallet.md |
| https://hub.docker.com/v2/repositories/linuxserver/nano-wallet/ | dockerhub-nano-wallet.md |
| https://raw.githubusercontent.com/linuxserver/docker-nano-wallet/120b82f4d1ba/Dockerfile | linuxserver-dockerfile.md |
| https://api.github.com/repos/linuxserver/nano-wallet/releases/latest | upstream-release.md |
| https://raw.githubusercontent.com/linuxserver/nano-wallet/master/LICENSE | upstream-source-build.md |
| https://api.github.com/repos/linuxserver/nano-wallet/contents/package.json | upstream-source-build.md |
| https://api.github.com/repos/linuxserver/nano-wallet/readme | upstream-source-build.md |
| https://api.github.com/repos/linuxserver/docker-nano-wallet/contents/root/nginx.conf | upstream-nginx.md |
| https://github.com/linuxserver-archive/docker-nano-wallet | upstream-archive-repo.md |

Skipped categories:
- Duplicates: github.com blob/repo-root URLs (linuxserver/nano-wallet, linuxserver/docker-nano-wallet, LICENSE blob), releases/tag/1.3.2 (covered by API).
- Binary: source tarball (`archive/refs/tags`, not fetched).
- Templated/other: none in list.

Failures: none.

## plan.md corrections
- Line 15 (Upstream Dockerfile reviewed): base image `baseimage-alpine:3.12` -> `lsiobase/alpine:3.12` (both stages). Source: linuxserver-dockerfile.md (raw Dockerfile at 120b82f4d1ba).
- Unverified, not changed: plan's "last tag 1.3.2-ls39" and "master HEAD bad0055" not checked by these sources.
