# Context index: cowyo

| Source URL | File |
| --- | --- |
| https://github.com/schollz/cowyo (README via raw) | github-schollz-cowyo-readme.md |
| https://github.com/schollz/cowyo/blob/77f28842c4e9d55c50bcf7aed180be5e9ed9a41c/Dockerfile | github-schollz-cowyo-dockerfile-77f2884.md |
| https://raw.githubusercontent.com/schollz/cowyo/main/Dockerfile | github-schollz-cowyo-dockerfile-main.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/cowyo (raw values.yaml) | truecharts-cowyo-values.md |
| https://github.com/trueforge-org/truecharts/.../charts/stable/cowyo/Chart.yaml | FAILED (see below) |
| https://hub.docker.com/r/schollz/cowyo (+ /v2 JSON repo and tags) | dockerhub-schollz-cowyo.md |

Skipped categories: none.

Failures:
- truecharts cowyo Chart.yaml: raw.githubusercontent.com fetch returned "malformed response stream"; alternative github.com blob URL returned DNS error (EAI_AGAIN). Not retried.

## plan.md corrections
- Unverified conflict: plan.md says main Dockerfile uses `-o /out/cowyo2` and `CMD /usr/local/bin/cowyo2`; fetched main Dockerfile shows `/out/cowyo` and `./cmd/cowyo` (same as 77f2884). Not edited.
- Unverified conflict: plan.md license UNVERIFIED/blocked; README states MIT. Not edited (blocker needs confirmation of license file/tag).
- Consistent: port 8001 upstream, golang 1.26.5, node 24, alpine 3.23.
