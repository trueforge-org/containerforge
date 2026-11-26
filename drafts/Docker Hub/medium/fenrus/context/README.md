# Context: fenrus

| Source URL | File |
| --- | --- |
| https://github.com/revenz/Fenrus (+ blob/raw Dockerfile @ fc8f57a, README via master) | revenz-fenrus.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/fenrus (+ raw Chart.yaml, values.yaml) | truecharts-fenrus.md |
| https://hub.docker.com/r/revenz/fenrus (+ v2 API repo and tags) | dockerhub-fenrus.md |

Skipped: urls.txt has no CLA, forgetool, containerforge, templated, binary or image-ref URLs. hub.docker.com HTML not fetched; v2 JSON API used.

Failures: none.

## plan.md corrections
- No edits. Consistent with fetched sources (Dockerfile, README; chart values show port 3000 and /app/data): aspnet:10.0 base, `COPY ./build`, ENV Docker=1, ENTRYPOINT docker-entrypoint.sh, PORT default 3000 (README), /app/data, reverse-proxy variables.
- Not verified by fetched sources (left as-is): PROTOCOL and DetailedErrors env vars (not in README or Dockerfile), and the docker-entrypoint.sh body (not fetched). Pinned commit in plan (c52d496) differs from the draft commit (fc8f57a) fetched here; not a conflict, plan pins its own commit.
