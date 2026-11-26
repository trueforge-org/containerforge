# Context: haste-server

Fetched 2026-11-26. Sources taken from draft.md and plan.md.

## Summarised sources

| Source URL | File |
| --- | --- |
| https://github.com/nzzane/haste-server | github-nzzane-haste-server.md |
| https://raw.githubusercontent.com/nzzane/haste-server/8c45a370a79cc5caaf446ba0088574dfcb489694/Dockerfile | github-nzzane-haste-server.md |
| https://raw.githubusercontent.com/nzzane/haste-server/8c45a370a79cc5caaf446ba0088574dfcb489694/docker-entrypoint.sh (followed) | github-nzzane-haste-server.md |
| https://raw.githubusercontent.com/nzzane/haste-server/8c45a370a79cc5caaf446ba0088574dfcb489694/docker-entrypoint.js (followed) | github-nzzane-haste-server.md |
| https://raw.githubusercontent.com/nzzane/haste-server/8c45a370a79cc5caaf446ba0088574dfcb489694/config.js (followed) | github-nzzane-haste-server.md |
| https://raw.githubusercontent.com/nzzane/haste-server/8c45a370a79cc5caaf446ba0088574dfcb489694/server.js (followed) | github-nzzane-haste-server.md |
| https://registry.npmjs.org/haste-server/latest | npm-haste-server.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/haste-server | truecharts-haste-server.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/haste-server/values.yaml | truecharts-haste-server.md |

## Skipped

| URL | Reason |
| --- | --- |
| https://ghcr.io/k8s-at-home/haste-server | GHCR image reference, not a web page. Chart's digest is in truecharts-haste-server.md. |
| https://ghcr.io/k8s-at-home/haste-server:latest | Image reference. |
| https://api.github.com/repos/nzzane/haste-server/contents/Dockerfile | Same file as the raw Dockerfile above (API variant of a fetched source). |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu, apps/python-node | ContainerForge `apps/<base>` links. |
| https://github.com/trueforge-org/forgetool/... (container-settings.schema.json, container-test.schema.json) | forgetool schema URL. |
| https://cla-assistant.io/trueforge-org/containerforge | CLA link. |
| ghcr.io/trueforge-org/python-node:3.15.2@sha256:... | Image reference. |
| node:14.8.0-stretch | Upstream base image reference (fork Dockerfile FROM). |
| docs/project-fireball.md, apps/kasm, apps/budge, apps/tvheadend, apps/adguardhome-sync | Repo-internal files, not web sources. |

## Fetch failures

- https://github.com/seejohnrun/haste-server (upstream): HTTP 404. Web Archive alternative is not fetchable here. No summary file written; upstream facts unverified.
- https://github.com/k8s-at-home/container-images (draft "source code repository"): HTTP 404. Web Archive alternative is not fetchable here. The k8s-at-home image still appears in the TrueCharts values (truecharts-haste-server.md).
- https://web.archive.org/...: not fetchable (tool refuses web.archive.org) for both repos above.
- https://registry.npmjs.org/haste-server/latest: fetched, but it describes the jirutka fork, not the nzzane fork the draft uses.
- Draft's "binary: npm:haste-server" resolved to the npm package above; the nzzane fork is not published to npm.
