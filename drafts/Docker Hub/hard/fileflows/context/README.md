# Context for fileflows

Fetched 2026-11-26.

## Source URL -> file

| Source URL | Summary file |
| --- | --- |
| https://fileflows.com/ | fileflows-com.md |
| https://fileflows.com/docs | fileflows-com.md (docs index) |
| https://fileflows.com/docs/installation/docker | fileflows-docs-docker.md |
| https://fileflows.com/docs/installation/linux | fileflows-docs-linux.md |
| https://fileflows.com/downloads/tarxz | fileflows-docs-linux.md (binary archive, not downloaded; referenced) |
| https://github.com/revenz/FileFlows | github-revenz-fileflows.md (404) |
| https://hub.docker.com/r/revenz/fileflows | dockerhub-revenz-fileflows.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/fileflows | truecharts-fileflows.md |

## Skipped URLs

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA link |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json | forgetool schema URL |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge apps/<base> link |
| http://0.0.0.0:5000, http://localhost:5000/ | localhost / bind address |
| ghcr.io/trueforge-org/ubuntu, ghcr.io/trueforge-org/ubuntu:26.04@sha256:... | ghcr image refs, not web pages |
| ghcr.io/trueforge-org/ (draft) | ghcr prefix only |

## Fetch failures

- https://github.com/revenz/FileFlows: 404 (repo not public at this URL).
- https://fileflows.com/* and github: DNS resolution (EAI_AGAIN) on first attempts; succeeded on retry. No content lost.

## plan.md corrections

- None made. Checked: port 5000 and host 19200 (docs), ffmpeg via variable `/usr/bin/ffmpeg` (docs), Docker tag `latest` only on Hub page (plan lists more tags; not visible here, left as is).
- Unverified (not changed): Linux docs list the prerequisite as ".NET 10 SDK" whereas plan installs runtime packages (runtime is sufficient for run; left); plan's `/config/Data` symlinks (no server data path documented on the Linux page).
