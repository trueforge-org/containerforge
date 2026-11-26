# Context index: passwordpusherephemeral

| Source URL | File |
| --- | --- |
| https://github.com/pglombardo/PasswordPusher/blob/0590f8d12e5a59f210542fb7d86348c6e7f06a85/containers/docker/pwpush-ephemeral/Dockerfile | ephemeral-dockerfile.md |
| https://github.com/pglombardo/PasswordPusher/blob/master/containers/docker/Dockerfile (follow-up, raw) | upstream-dockerfile.md |
| https://github.com/pglombardo/PasswordPusher (README via raw) | readme-passwordpusher.md |
| https://docs.pwpush.com | docs-pwpush.md (landing had no install content) |
| https://docs.pwpush.com/docs/installation/ (follow-up) | docs-pwpush.md |
| https://hub.docker.com/r/pglombardo/pwpush-ephemeral | dockerhub-pwpush-ephemeral.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/passwordpusherephemeral (values.yaml via raw) | truecharts-chart-values.md |
| https://eu.pwpush.com | eu-pwpush-hosted.md |

Skipped categories: none (no CLA, forgetool, containerforge, templated, binary or image-ref URLs in the list).

## Failures
- https://docs.pwpush.com: landing page only, no install/env content (installation page used instead).

## plan.md corrections
- None applied. Note for the plan (not a correction, unverified against plan text): the ephemeral image is archived/deprecated (Docker Hub says replace with pglombardo/pwpush); its Dockerfile is a shim over pwpush:latest that adds an end-of-support banner.
