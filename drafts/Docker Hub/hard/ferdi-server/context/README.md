# Context for ferdi-server

Fetched 2026-11-26.

## Source URL -> file

| Source URL | Summary file |
| --- | --- |
| https://github.com/ferdium/ferdium-server | github-ferdium-ferdium-server.md |
| https://github.com/ferdium/ferdium-server/tags | github-ferdium-ferdium-server.md |
| https://github.com/ferdium/ferdium-server/releases | github-ferdium-ferdium-server.md (tags page used; no release entries shown) |
| https://raw.githubusercontent.com/ferdium/ferdium-server/v2.0.14/Dockerfile | github-ferdium-ferdium-server.md |
| https://raw.githubusercontent.com/ferdium/ferdium-server/v2.0.14/README.md | github-ferdium-ferdium-server.md |
| https://raw.githubusercontent.com/ferdium/ferdium-server/v2.0.14/docker/entrypoint.sh | github-ferdium-ferdium-server.md |
| https://raw.githubusercontent.com/ferdium/ferdium-server/v2.0.14/.env.example | github-ferdium-ferdium-server.md |
| https://raw.githubusercontent.com/ferdium/ferdium-server/v2.0.14/LICENSE | github-ferdium-ferdium-server.md |
| https://github.com/ferdium/ferdium-recipes | github-ferdium-ferdium-recipes.md |
| https://github.com/getferdi/server | github-getferdi-server.md (404) |
| https://hub.docker.com/r/getferdi/ferdi-server | dockerhub-getferdi-ferdi-server.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/ferdi-server | truecharts-ferdi-server.md |
| https://ferdium.org | ferdium-org.md |
| https://github.com/ferdium/ferdium-server/archive/refs/tags/v2.0.14.tar.gz | not fetched (binary archive; asset pattern in github-ferdium-ferdium-server.md) |

## Skipped URLs

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA link |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json | forgetool schema URL |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge apps/<base> link |
| http://localhost:${PORT}/health, http://localhost:3333/health | localhost |
| ghcr.io/trueforge-org/python-node, ghcr.io/trueforge-org/ubuntu | ghcr image refs, not web pages |

## Fetch failures

- https://github.com/getferdi/server returned 404.
- https://github.com/ferdium/ferdium-recipes: fetched, but the page does not show a tag list or a server-side usage note. Not a failure.
- Hub page for getferdi shows no architectures.

## plan.md corrections

- Section 1 "Recipes path": plan says the README `docker create` and compose mount `/app/build/recipes`. Fetched README (v2.0.14) mounts `/app/recipes`, and entrypoint clones to `/app/recipes`. Changed in plan.md: yes (see below).
- Section 1 "Postgres driver value": UNVERIFIED for 2.x upstream. Not changed; the TrueCharts chart uses `DB_CONNECTION: pg` with the old 1.3.2 image. Left as unverified.
- License MIT: confirmed by LICENSE file; no change needed.
