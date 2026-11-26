# Context for fireflyiii

Fetched 2026-11-26.

## Source URL -> file

| Source URL | Summary file |
| --- | --- |
| https://github.com/firefly-iii/firefly-iii | github-firefly-iii-firefly-iii.md |
| https://github.com/firefly-iii/firefly-iii/releases/download/v6.7.9/FireflyIII-v6.7.9.tar.gz.sha256 | github-firefly-iii-firefly-iii.md (fetched via CDN redirect) |
| https://github.com/firefly-iii/firefly-iii/releases/download/v${VERSION}/FireflyIII-v${VERSION}.tar.gz | github-firefly-iii-firefly-iii.md (binary archive, not downloaded; pattern recorded) |
| https://raw.githubusercontent.com/firefly-iii/firefly-iii/v6.7.9/.env.example | github-firefly-iii-firefly-iii.md (summary, not verbatim) |
| https://hub.docker.com/r/fireflyiii/core | dockerhub-fireflyiii-core.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/fireflyiii | truecharts-fireflyiii.md |
| https://firefly-iii.org/ | firefly-iii-org.md |

## Skipped URLs

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA link |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json | forgetool schema URL |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge apps/<base> link |
| http://127.0.0.1:8080/, http://localhost:8080 | localhost / loopback |
| ghcr.io/trueforge-org/ubuntu (and :26.04@sha256 variant) | ghcr image refs, not web pages |

## Fetch failures

- https://docs.firefly-iii.org/ returned 403 (plan says the same). Not retried beyond the fetch.
- https://dev.azure.com/Firefly-III/_git/MainImage?path=/Dockerfile&version=GBmain: page rendered no Dockerfile content (only a "Files" heading). Current multi-arch Dockerfile not obtained.
- https://raw.githubusercontent.com/firefly-iii/firefly-iii/v6.7.9/README.md: 404. One alternative tried: https://raw.githubusercontent.com/firefly-iii/firefly-iii/main/README.md: also 404. No README-based cron or upgrade commands obtained.
- https://raw.githubusercontent.com/firefly-iii/firefly-iii/v6.7.9/.env.example returned only a summary (verbatim text refused by the fetch tool's quoting limit); the summary is in the github file.

## plan.md corrections

- Section 1 "Checksum source": the `.sha256` content format was marked UNVERIFIED. Verified: `<sha256> *FireflyIII-v6.7.9.tar.gz` (single line, binary-mode asterisk). Edited in plan.md (wording only; the hash field is the same).
- Unverified (not changed): cron cadence (chart shows `0 3 * * *`; upstream docs 403), archive layout (flat vs top-level), `php8.5-*` extension package names on Ubuntu 26.04, and whether `/healthcheck` exists in the app (chart probes use it; plan's container test uses `/`).
