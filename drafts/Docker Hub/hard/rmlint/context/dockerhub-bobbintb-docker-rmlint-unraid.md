# Docker Hub bobbintb/docker-rmlint-unraid

Source: https://hub.docker.com/r/bobbintb/docker-rmlint-unraid (API https://hub.docker.com/v2/repositories/bobbintb/docker-rmlint-unraid), fetched 2026-11-26

| Field | Value |
| --- | --- |
| description | Docker container for rmlint in UnRAID using Guacamole for the GUI |
| pull_count / star_count | 49526 / 0 |
| last_updated | 2025-08-19T18:50:06Z |
| storage_size | 5742795257 bytes (as reported by Hub) |

## Full description (summary)
- Built on the LinuxServer Guacamole GUI base image.
- Says rmlint is compiled from source to stay current (Ubuntu repo version is old).
- Links to sahib/rmlint and this repo.
- Gotcha: the Dockerfile installs a prebuilt amd64 .deb from this repo's latest release; it does not compile from source.
