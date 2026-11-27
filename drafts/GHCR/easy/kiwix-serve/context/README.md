# kiwix-serve context README

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/kiwix-serve/values.yaml + Chart.yaml | truecharts-kiwix-serve.md |
| Docker Hub | none (image is GHCR: ghcr.io/kiwix/kiwix-serve) |
| https://github.com/kiwix/kiwix-tools/blob/3.8.2/docker/server/Dockerfile (raw variant fetched) | kiwix-upstream-dockerfile-startsh.md |
| https://github.com/kiwix/kiwix-tools/blob/3.8.2/docker/server/start.sh (raw variant fetched) | kiwix-upstream-dockerfile-startsh.md |
| https://api.github.com/repos/kiwix/kiwix-tools/releases/latest | kiwix-upstream-dockerfile-startsh.md |
| https://packages.ubuntu.com/resolute/kiwix-tools | ubuntu-kiwix-tools-package.md |
| https://archive.ubuntu.com/ubuntu | ubuntu-archive.md (cache copy from docs/context) |

Skipped categories: api.github.com/repos/kiwix/kiwix-tools (repo metadata), github.com blob/repo HTML duplicates, docs.readthedocs / kiwix.org / wiki.kiwix.org (docs and marketing; budget), packages.ubuntu.com arm64 download page (listed in plan.md; not fetched), github.com/kiwix/kiwix-tools/blob/master/docker/server (moving branch, not pinned).

Failures: none.

## plan.md corrections

- No edits made.
- Verified: Ubuntu package `kiwix-tools 3.7.0-1.1build2` (plan section 1 matches). Upstream Dockerfile/start.sh facts (EXPOSE 8080, VOLUME /data, DOWNLOAD, PORT default 8080, uid 1001) match plan section 1 and section 4 inputs.
- Note: plan says upstream Dockerfile's `user` is not copied; plan rewrites start.sh for /config. No conflict.
