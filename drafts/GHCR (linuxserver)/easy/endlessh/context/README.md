# Context: endlessh

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/endlessh/values.yaml + Chart.yaml | truecharts-endlessh.md |
| https://hub.docker.com/v2/repositories/linuxserver/endlessh/ | dockerhub-linuxserver-endlessh.md |
| https://raw.githubusercontent.com/linuxserver/docker-endlessh/master/Dockerfile (+ commit blob) | github-linuxserver-docker-endlessh.md |
| https://raw.githubusercontent.com/skeeto/endlessh/master/README.md (+ repo, tags, UNLICENSE) | github-skeeto-endlessh.md |
| https://packages.ubuntu.com/resolute/endlessh | ubuntu-packages-endlessh.md |

Skipped: none of the listed categories present in urls.txt (already filtered). Duplicate: linuxserver commit-pinned Dockerfile blob URL.

## Failures
- https://api.github.com/repos/skeeto/endlessh/tags: 403; HTML tags page used (recovered).
- https://github.com/skeeto/endlessh/blob/master/UNLICENSE: 503; raw UNLICENSE used (recovered).

## plan.md corrections
- None made. Linuxserver Dockerfile facts (EXPOSE 2222, no VOLUME, `make`, `COPY /root /`) match plan.md.
- For reference: upstream base is baseimage-alpine 3.18; ContainerForge plan uses ubuntu (design choice, not a correction).
