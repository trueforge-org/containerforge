# rickroll context index

Fetched 2026-11-26.

## Source URL -> file

| Source URL | File | Notes |
| --- | --- | --- |
| https://github.com/modem7/docker-rickroll | github-modem7-docker-rickroll.md | repo; README via raw master |
| https://raw.githubusercontent.com/modem7/docker-rickroll/master/README.md | github-modem7-docker-rickroll.md | fetched |
| https://raw.githubusercontent.com/modem7/docker-rickroll/40cce76bf9f796d5171584624793f62db4bc9e84/Dockerfile | github-modem7-docker-rickroll.md | fetched (draft cites blob/40cce76.../Dockerfile) |
| https://github.com/modem7/docker-rickroll/releases/tag/video-assets-v1 | github-modem7-docker-rickroll.md | fetched; only 2 names rendered |
| https://hub.docker.com/r/modem7/docker-rickroll | dockerhub-modem7-docker-rickroll.md | fetched |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/rickroll | truecharts-rickroll.md | tree page; values via raw |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/rickroll/values.yaml | truecharts-rickroll.md | fetched |

## Skipped URLs

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA link |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json | forgetool schema |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json | forgetool schema |
| https://github.com/trueforge-org/containerforge/tree/main/apps/nginx | containerforge apps base link |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge apps base link |
| http://localhost:8080/ | localhost address |
| http://localhost:8080/video.mp4 | localhost address |
| https://raw.githubusercontent.com/modem7/docker-rickroll/${VERSION}/LICENCE.txt | contains ${ |
| https://github.com/modem7/docker-rickroll/releases/download/video-assets-v1/video-1080p.mp4 | direct video download; the release URL pattern is recorded (video-assets-v1 names listed in github file). Not fetched. |
| https://github.com/modem7/docker-rickroll/releases/download/video-assets-v1/video.mp4 | direct download; not fetched |
| https://github.com/modem7/docker-rickroll/releases/download/video-assets-v1/${VIDEO_NAME} | contains ${ |
| https://github.com/modem7/docker-rickroll/releases/download/video-assets-v1/<name | placeholder with unbalanced `<`; not a source |

## Fetch failures

- None.

## plan.md corrections

No edits made.

Conflict (not edited):
- plan.md section 1 (Current upstream Dockerfile row, and the Upstream Dockerfile row) says the draft's pinned commit `40cce76b` "is older and used `video.mp4`". The fetched Dockerfile at 40cce76 shows `ARG VIDEO_URL=.../video-assets-v1/video-1080p.mp4` (1080p default), nginx-unprivileged 1.31.7-alpine, and the same HEALTHCHECK on 9090 `/healthz` as plan.md's description of master. The fetch came through a summarizing model, so the verbatim check is not certain. Recorded as unverified; the correction needs a human check against the raw file.

Other unverified items (not edited):
- plan.md section 1 gives asset sizes and sha256 values (video.mp4, video-1080p.mp4). Release asset list did not render; not checked.
- plan.md section 1 gives HEAD of master as db8d928c7a6af1b7cd4b4b12653ef5f1ec161fee (2026-11-25). Not checked.
- plan.md section 1 says script `40-roll.sh` sed-expands lyrics and `70-nginx.sh` writes nginx.conf. Scripts not fetched.
- plan.md section 1 says the project default branch is master, last push 2026-11-14. Not checked.
- plan.md section 1 says the video content license is unstated. Not checked.
- plan.md section 1 says the repo has one release, `video-assets-v1`. The repo page was not fetched.
