# Docker Hub: mikolatero/vlmcsd

Source URL(s) + fetch date: https://hub.docker.com/r/mikolatero/vlmcsd · fetched 2026-11-26

## What it is
- "Portable open-source KMS Emulator in C", built on Alpine from the Wind4 source. Pitched for always-on devices (routers, NAS). Page says it is "not a one-click activation or crack tool".
- 10M+ pulls, 297 stars, last updated 11 months before capture.

## Run
- `docker run -d -p 1688:1688 --restart=always --name vlmcsd mikolatero/vlmcsd`
- Client setup: slmgr.vbs (Windows) and ospp.vbs (Office) with `DOCKER_IP`. Links to Microsoft GVLK key lists.

## Env vars, volumes
- None documented.

## Ports
- 1688 (mapped 1688:1688 in the example).

## Version/release info
- Only `latest` tag shown, size 3.7 MB. Digest `sha256:aadb2a38...`.

## Arch support
- Not listed.

## Gotchas
- The page's client instructions are Microsoft-activation oriented; the plan's license and policy caveat (plan.md section 10) applies.
