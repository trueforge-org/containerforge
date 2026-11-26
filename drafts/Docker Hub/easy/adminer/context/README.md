# Context: adminer

Fetched 2026-11-26. Sources taken from draft.md and plan.md.

## Summarised sources

| Source URL | File |
| --- | --- |
| https://github.com/vrana/adminer | github-vrana-adminer.md |
| https://raw.githubusercontent.com/vrana/adminer/master/README.md | github-vrana-adminer.md |
| https://github.com/vrana/adminer/releases | github-vrana-adminer.md (partial, see failures) |
| https://www.adminer.org/ | docs-adminer-org-home.md |
| https://hub.docker.com/_/adminer | dockerhub-adminer.md |
| https://github.com/TimWolla/docker-adminer/blob/6d83dde54e9e8a76c9e003eb494e296808a2a627/6/Dockerfile | github-timwolla-docker-adminer.md |
| https://raw.githubusercontent.com/TimWolla/docker-adminer/6d83dde54e9e8a76c9e003eb494e296808a2a627/6/Dockerfile | github-timwolla-docker-adminer.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/adminer | truecharts-adminer.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/adminer/values.yaml | truecharts-adminer.md |

## Skipped

| URL | Reason |
| --- | --- |
| https://github.com/vrana/adminer/releases/download/v6.3.1/adminer-6.3.1.php | Direct binary download. Asset pattern recorded in github-vrana-adminer.md. |
| https://raw.githubusercontent.com/vrana/adminer/v${VERSION#v}/LICENSE | Contains `${`, templated. License recorded in github-vrana-adminer.md. |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | ContainerForge `apps/<base>` link. |
| https://github.com/trueforge-org/forgetool/... (container-settings.schema.json and container-test.schema.json) | forgetool schema URL. |
| https://cla-assistant.io/trueforge-org/containerforge | CLA link. |
| ghcr.io/trueforge-org/ubuntu:26.04@sha256:... | Image reference, not a web page. |
| docs/project-fireball.md, apps/phpmyadmin, apps/adguardhome-sync | Repo-internal files, not web sources. |

## Fetch failures and partial results

- https://github.com/vrana/adminer/releases: the page loaded the v6.3.1 tag and metadata, but the asset file list did not load. Asset names (`adminer-6.3.1.php`, `-en`, `-mysql`, `-mysql-en`, `.zip`, `editor-6.3.1.php`) come from plan.md's own verification, not from this fetch.
- No hard failures (no 403 or 404).
