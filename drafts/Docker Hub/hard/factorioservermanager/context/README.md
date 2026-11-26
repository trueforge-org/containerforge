# factorioservermanager context index

Fetched 2026-11-26. Summaries of every web source referenced by draft.md and plan.md.

## Sources

| Source URL | Summary file |
| --- | --- |
| https://github.com/OpenFactorioServerManager/factorio-server-manager | github-openfactorioservermanager-factorio-server-manager.md |
| https://github.com/OpenFactorioServerManager/factorio-server-manager/blob/master/docker/Dockerfile (fetched as raw) | github-openfactorioservermanager-factorio-server-manager.md (Dockerfile section) |
| raw master/docker/entrypoint.sh (plan's entrypoint facts) | github-openfactorioservermanager-factorio-server-manager.md (entrypoint section) |
| https://github.com/OpenFactorioServerManager/factorio-server-manager/wiki/Installation-and-Usage | github-openfactorioservermanager-factorio-server-manager.md (wiki and flags sections) |
| https://hub.docker.com/r/ofsm/ofsm | dockerhub-ofsm-ofsm.md |
| https://factorio.com/api/latest-releases | docs-factorio-com-latest-releases.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/factorioservermanager | truecharts-factorioservermanager.md (directory not fetched; values.yaml fetched via raw URL) |
| https://raw.githubusercontent.com/OpenFactorioServerManager/factorio-server-manager/master/LICENSE | github-openfactorioservermanager-factorio-server-manager.md (404; LICENSE.md noted) |

## Skipped URLs

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA link (not a source) |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json | forgetool schema URL |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge apps/<base> link |
| https://github.com/OpenFactorioServerManager/factorio-server-manager/releases/download/0.10.1/factorio-server-manager-linux-0.10.1.zip | direct binary download (asset naming and pinned sha256 recorded in plan; not downloaded) |
| https://raw.githubusercontent.com/OpenFactorioServerManager/factorio-server-manager/${VERSION}/LICENSE | contains `${` (template; master LICENSE 404 noted above) |
| https://www.factorio.com/get-download/<version (draft) | contains `<` (template) |
| https://www.factorio.com/get-download/${v}/headless/linux64 | contains `${` (template; URL pattern recorded from the entrypoint) |
| http://localhost:8080/ | localhost |

## Fetch failures

- https://raw.githubusercontent.com/OpenFactorioServerManager/factorio-server-manager/master/LICENSE: HTTP 404. Not retried; the repo README says the license file is `LICENSE.md`.

## plan.md corrections

- Section 1, Binary flags row: `--bind` is not a documented flag; `--host` (default `0.0.0.0`) is the listen-address flag, `--port` default is 8080 in the wiki (80 in a newer table). Edited. Source: github-openfactorioservermanager-factorio-server-manager.md.
- Section 4 step 5: license path `LICENSE` -> `LICENSE.md` (master `LICENSE` returned 404). Edited. Source: github-openfactorioservermanager-factorio-server-manager.md.
- Section 7 note on listening interface: `--bind` replaced by the wiki's `--host` default `0.0.0.0`; confirm in the run test. Edited. Source: github-openfactorioservermanager-factorio-server-manager.md.
- Section 10, default login: "UNVERIFIED" -> Hub (for `ofsm/ofsm`, not the repo's own image) documents `ADMIN_USER` admin and `ADMIN_PASS` factorio. Edited. Source: dockerhub-ofsm-ofsm.md.
- Section 10, cookie key: "UNVERIFIED whether FSM generates one" -> Hub says a random key is generated when empty (for `ofsm/ofsm`); repo image still UNVERIFIED. Edited. Source: dockerhub-ofsm-ofsm.md.
- Section 10, `--bind`/0.0.0.0 bullet: replaced by `--host` default per wiki. Edited. Source: github-openfactorioservermanager-factorio-server-manager.md.

## plan.md unverified (not edited)

- Section 1, Version: FSM 0.10.1 "published 2021-03-09" and "last commit on master 2024-07-13": neither the release page nor commit history was fetched here; the repo page shows no release version. Source: github-openfactorioservermanager-factorio-server-manager.md.
- Section 1, Factorio 2.x compatibility: no statement in the wiki or repo. Source: github-openfactorioservermanager-factorio-server-manager.md.
- Section 1, zip contents and ELF/glibc notes: not verified in this pass (zip not downloaded).
- Section 4 step 5: the zip ships no license file is unverified; `LICENSE.md` exists in the repo.
- Section 1 Ports: the draft's 27015 RCON was not checked against any source here beyond the Hub/TrueCharts silence; the TrueCharts values list only 34197/udp and 8888->80.
- Section 9: "/app/.local" path claim (from the plan) not checked.
- Section 6/9: the Hub `ofsm/ofsm` image (compose-based, with `ADMIN_*` env) is not the same packaging as this repo's `docker/Dockerfile`; the plan's env list is built for the repo Dockerfile. Source: dockerhub-ofsm-ofsm.md, github-openfactorioservermanager-factorio-server-manager.md.
