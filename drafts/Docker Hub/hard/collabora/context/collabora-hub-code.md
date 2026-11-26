# hub.docker.com/r/collabora/code (draft "Container image")

Source URL(s) + fetch date:
- https://hub.docker.com/r/collabora/code · fetched 2026-11-26

## What it is
"Collabora Online Development Edition (CODE)": image for self-hosting an online office suite, aimed at home users; newest development work; meant to plug into a file sync and share (FSS) solution.

## Tags / digest
- Only `latest` listed (digest `sha256:a2f5d4e88…`, 476.1 MB, updated 6 days before fetch). 100M+ pulls.
- Chart pins `26.04.6.2.1` (see truecharts-collabora.md); the versioned tag is not on the Docker Hub page as fetched.

## Architectures
Not stated on the Docker Hub page (the collaboraonline.com Docker page says x86-64, ppc64, arm64).

## Run / env / ports / volumes
- Only `docker pull collabora/code`. No run example, env names, ports, volumes or capabilities on this page.
- Dockerfile and build scripts: GitHub mirror `CollaboraOnline/online.mirror` (docker/ dir); the nightly image is built from `docker/from-source-gh-action/` in the online repo (see github-collaboraonline-online.md).
- Usage limits: not stated.

## Support
Bug reports: https://github.com/CollaboraOnline/online/issues. Forum: https://forum.collaboraonline.com/.
