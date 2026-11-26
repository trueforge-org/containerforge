# Context: genea

Fetched 2026-11-26.

## Sources

| Source URL | Summary file |
| --- | --- |
| https://github.com/genea-app/genea-app | github-genea-app-genea-app.md |
| https://raw.githubusercontent.com/genea-app/genea-app/master/README.md | github-genea-app-genea-app.md |
| https://raw.githubusercontent.com/genea-app/genea-app/master/index.html | github-genea-app-genea-app.md |
| https://raw.githubusercontent.com/genea-app/genea-app/master/LICENSE | github-genea-app-genea-app.md |
| https://github.com/genea-app/genea-app/tags | github-genea-app-genea-app.md |
| https://www.genea.app/ | docs-genea-app.md |
| https://hub.docker.com/r/biggiesize/genea-app | dockerhub-biggiesize-genea-app.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/genea | truecharts-genea.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/genea/values.yaml | truecharts-genea.md |

Shared index (`/workspaces/containers/docs/context/INDEX.md`): no matches.

## Skipped

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA link, not a source |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu, apps/nginx, apps/it-tools (plan.md) | containerforge apps links |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json | forgetool schema URL |
| ghcr.io/trueforge-org/nginx, ghcr.io/trueforge-org/ubuntu | ghcr image refs, not web pages |
| https://github.com/genea-app/genea-app/archive/<sha>.tar.gz | direct archive download (planned, not fetched) |
| https://github.com/genea-app/genea-app/releases | no releases exist (tags page checked instead) |
| https://github.com/genea-app/genea-app/blob/main/PRIVACY.md, https://www.gedcom.org/, https://unpkg.com/..., https://cors.isomorphic-git.org | linked from fetched pages; not needed for the container build |
| https://play.google.com (Android app) | not relevant to the container |

## Fetch failures

None.

## plan.md corrections

- plan.md section 4 step 2 (publish list): added `resources modals img favicon.ico` to `index.html js css components`. The app needs `resources/` (Vue, wasm, Materialize, Google icons CSS), `modals/`, `img/` and `favicon.ico`. Source: `github-genea-app-genea-app.md` (index.html).
- plan.md section 10 (CDN line): old "Possible external CDN fetches at runtime (Vue, Materialize) UNVERIFIED". New: only `isomorphic-git@beta` and `lightning-fs` load from unpkg.com; Vue, Materialize and Graphviz wasm are local. Source: `github-genea-app-genea-app.md`.

## Checked, not edited

- plan.md section 1 license MIT: confirmed by LICENSE file (`MIT License, Copyright (c) 2021 Genea.app`).
- plan.md section 1 "no releases, pin a commit SHA": confirmed, tags page says no releases.

## Unverified / contradictions (no edit)

- Pull count: plan.md section 1 says 47,034 pulls and "last updated 2021-08-17". Docker Hub page shows 10K+ pulls and "over 5 years ago". Not in the correction list; left as is.
- Port: TrueCharts chart sets the service to port 3181 (target 3181). The draft and plan.md say 80 (inferred) or 8080 for our nginx. The image's own listening port is not documented by upstream or Docker Hub.
- Architectures of `biggiesize/genea-app` are not stated on Docker Hub; copy-from arm64 stays unverified.
