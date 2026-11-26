# Context: monero-node

Fetched 2026-11-26. Sources taken from draft.md and plan.md.

## Summarised sources

| Source URL | File |
| --- | --- |
| https://github.com/monero-project/monero/releases/tag/v0.18.5.4 | github-monero-project-monero.md |
| https://raw.githubusercontent.com/monero-project/monero/v0.18.5.4/LICENSE | github-monero-project-monero.md |
| https://github.com/monero-project/monero (repo root, not fetched directly; covered by the release and LICENSE pages) | github-monero-project-monero.md |
| https://getmonero.org/downloads/hashes.txt | getmonero-downloads-hashes.md |
| https://getmonero.org | getmonero-org-home.md |
| https://github.com/sethforprivacy/simple-monerod-docker/blob/08e993d/Dockerfile | github-sethforprivacy-simple-monerod-docker.md |
| https://raw.githubusercontent.com/sethforprivacy/simple-monerod-docker/08e993d/Dockerfile | github-sethforprivacy-simple-monerod-docker.md |
| https://raw.githubusercontent.com/sethforprivacy/simple-monerod-docker/08e993d/entrypoint.sh | github-sethforprivacy-simple-monerod-docker.md (followed) |
| https://raw.githubusercontent.com/sethforprivacy/simple-monerod-docker/08e993d/healthcheck.sh | github-sethforprivacy-simple-monerod-docker.md (followed) |
| https://github.com/kannix/monero-full-node | github-kannix-monero-full-node.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/monero-node | truecharts-monero-node.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/monero-node/values.yaml | truecharts-monero-node.md |

## Skipped

| URL | Reason |
| --- | --- |
| https://downloads.getmonero.org/cli/monero-linux-x64-v0.18.5.4.tar.bz2 | Direct archive download. Pattern and expected sizes recorded in github-monero-project-monero.md. |
| https://downloads.getmonero.org/cli/monero-linux-armv8-v0.18.5.4.tar.bz2 | Direct archive download. Recorded in github-monero-project-monero.md. |
| https://downloads.getmonero.org/cli/hashes.txt | HTTP 404 (plan.md). Canonical list used instead: https://getmonero.org/downloads/hashes.txt. |
| https://ghcr.io/sethforprivacy/simple-monerod | GHCR image reference, not a web page. The chart and wrapper are summarised. |
| ghcr.io/trueforge-org/ubuntu:26.04@sha256:... | Image reference. |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | ContainerForge `apps/<base>` link. |
| https://github.com/trueforge-org/forgetool/... (container-settings.schema.json, container-test.schema.json) | forgetool schema URL. |
| https://cla-assistant.io/trueforge-org/containerforge | CLA link. |
| https://github.com/monero-project/monero-site | Linked from getmonero.org; not needed for the build. |
| https://github.com/Boog900/monero-ban-list (ban list, cloned by the upstream Dockerfile) | Not referenced by draft or plan; not fetched. Mentioned in github-sethforprivacy-simple-monerod-docker.md. |
| https://getmonero.org/downloads/ and /resources/... links | Not needed for the build. |
| docs/project-fireball.md, apps/adguardhome-sync, apps/kasmvnc, apps/steamcmd | Repo-internal files, not web sources. |

## Fetch failures and partial results

- https://github.com/monero-project/monero/releases/tag/v0.18.5.4: page loaded; the asset names did not load ("2 assets"). Names come from the release notes download links.
- https://getmonero.org: summary only (no CLI docs on the homepage).
- PGP signature on hashes.txt: not verified in this session. Only the signed text was read.
- The Boog900 ban list and its signatures: not fetched (upstream wrapper only).
