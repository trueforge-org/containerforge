# fabulinus context index

Fetched 2026-11-26. Summaries of every web source referenced by draft.md and plan.md. (Plan marks this app as blocked; the summaries support that decision.)

## Sources

| Source URL | Summary file |
| --- | --- |
| https://github.com/titanml/takeoff-community | github-titanml-takeoff-community.md |
| https://hub.docker.com/r/tytn/fabulinus | dockerhub-tytn-fabulinus.md |
| https://docs.titanml.co/ | docs-titanml-co-takeoff.md (TLS handshake failure; no content) |
| https://www.titanml.co/ | docs-titanml-co.md (301 to resources.doubleword.ai, followed) |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/fabulinus | truecharts-fabulinus.md (directory not fetched; values.yaml fetched via raw URL) |

## Skipped URLs

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA link (not a source) |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge apps/<base> link |

## Fetch failures

- https://github.com/titanml/takeoff-communitys (draft "Source code repository"; the plan calls it a typo): HTTP 404. Not retried; the correct repo is takeoff-community (fetched).
- https://docs.titanml.co/: TLS handshake failure (`SSLV3_ALERT_HANDSHAKE_FAILURE`). Not retried.
- https://www.titanml.co/: redirected (301) to https://resources.doubleword.ai/, which was followed once; the redirected site does not describe Takeoff.

## plan.md corrections

- Section 1, Ports row: the plan said the Hub example shows port 8000 and that the actual listening port is UNVERIFIED. The Hub run example maps host 8000 to container port 80 (`-p 8000:80`), so the container listens on 80. Edited. Source: dockerhub-tytn-fabulinus.md, truecharts-fabulinus.md (targetPort 80).
- Section 6, "Do not invent ports or env vars. The only facts available are..." -> more facts now: Hub env TAKEOFF_MODEL_NAME and TAKEOFF_DEVICE; TrueCharts env TAKEOFF_QUANT_TYPE, TAKEOFF_MAX_BATCH_SIZE, TAKEOFF_DISABLE_BATCHING. Edited (the blocked status stays). Source: dockerhub-tytn-fabulinus.md, truecharts-fabulinus.md.
- Section 10, staleness bullet: the repo is archived (2024-01-22) and marked no longer maintained by its README. Edited. Source: github-titanml-takeoff-community.md.

## plan.md unverified (not edited)

- Section 1, Version row: "newest push 2023-11-17" and the tag list (`<git-sha>-cpu`, `buildcache-cpu/gpu`): the Hub page shows only `latest` and "updated about 3 years ago"; the date and other tags are not confirmed. Source: dockerhub-tytn-fabulinus.md.
- Section 1, Per-arch: "Hub tags published for amd64 only" is not confirmed; the Hub page lists no architectures. Source: dockerhub-tytn-fabulinus.md.
- Section 1, License: no license text on the repo or Hub; the community repo is archived. Treat as proprietary (plan's default) remains unverified. Source: github-titanml-takeoff-community.md.
- Section 1, Paths: `/code/models` confirmed by TrueCharts; the Hub page documents no volumes. Source: truecharts-fabulinus.md.
- GPU: the Hub's GPU run example uses `tytn/fabulinus:latest` with `--gpus all`, while TrueCharts pins `latest-gpu` (same digest as Hub `latest`). Source: dockerhub-tytn-fabulinus.md, truecharts-fabulinus.md.
