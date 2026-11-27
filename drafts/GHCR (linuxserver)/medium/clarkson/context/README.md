# Context: clarkson

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/clarkson/values.yaml + Chart.yaml | truecharts-clarkson.md |
| https://hub.docker.com/v2/repositories/linuxserver/clarkson/ (not in urls.txt; added per REQUIRED Docker Hub rule) | dockerhub-clarkson.md |
| https://raw.githubusercontent.com/linuxserver/docker-clarkson/a055394e1b15b406965902248118536959e54f1f/Dockerfile | linuxserver-dockerfile.md |
| https://github.com/linuxserver/Clarkson (fallback after 403 on api.github.com repo endpoint) | upstream-repo.md |

Skipped: github.com blob duplicate of the Dockerfile (same content as raw). No CLA, forgetool, containerforge, templated, binary-download or image-ref URLs in list.

Failures: https://api.github.com/repos/linuxserver/Clarkson returned 403; HTML repo page used instead.

## plan.md corrections
- None made. Plan values (MIT, port 3000, Dockerfile contents, v1.1.2) consistent with fetched sources.
- Not in plan, for awareness: Docker Hub and upstream indicate the linuxserver image and project are deprecated/stopped (successor Hammond). Unverified against plan's "latest tag" date 2020-06-19 (not checkable: API 403).
