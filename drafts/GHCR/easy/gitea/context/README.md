# gitea context README

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/gitea/values.yaml + Chart.yaml | truecharts-gitea.md |
| Docker Hub | none (image is GHCR only: ghcr.io/go-gitea/gitea) |
| https://raw.githubusercontent.com/go-gitea/gitea/v28.4.0/Dockerfile.rootless + docker/rootless/usr/local/bin/docker-entrypoint.sh | gitea-dockerfile-rootless.md |
| https://docs.gitea.com/installation/install-with-docker-rootless | gitea-docs-rootless.md |

Skipped categories: about.gitea.com and gitea.com/gitea/helm-chart (marketing/chart reference), github.com blob/repo HTML duplicates of raw files, Dockerfile.rootless blob URL (duplicate).
Not fetched: docs.gitea.com env/cheat-sheet pages (budget), releases API (version pinned in plan).

Failures: none.

## plan.md corrections

- None. Plan's Dockerfile, ports (3000/2222), env, UID 1000 and entrypoint facts match fetched sources.
- Note (not a plan error): truecharts values.yaml contains a hardcoded admin password; not recorded in context files.
