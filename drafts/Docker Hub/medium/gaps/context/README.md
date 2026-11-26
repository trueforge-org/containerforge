# Context: gaps

| Source URL | File |
| --- | --- |
| https://github.com/JasonHHouse/gaps (+ raw Dockerfile, README, start.sh, LICENSE @ v0.10.4) | jasonhhouse-gaps.md |
| https://api.github.com/repos/JasonHHouse/gaps/releases/latest | gaps-github-api-releases.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/gaps (+ raw Chart.yaml, values.yaml) | truecharts-gaps.md |
| https://hub.docker.com/r/housewrecker/gaps (+ v2 API repo and tags) | dockerhub-gaps.md |

Skipped: urls.txt has no CLA, forgetool, containerforge, templated, binary or image-ref URLs.

Failures: none. hub.docker.com HTML not fetched; v2 JSON API used.

## plan.md corrections
- No edits. Consistent with fetched sources: v0.10.4, MIT (Copyright 2019 Jason H House), port 8484, `/usr/data`, env JAR_FILE/ENABLE_SSL/ENABLE_LOGIN/BASE_URL, Docker Hub tags (x64, arm, arm32v7, risc, ppc64le, s390x), release asset GapsAsJar-0.10.4.zip, root user.
- Resolved UNVERIFIED item (not edited): plan line 15 profile names. start.sh uses ssl, ssl-no-login, no-ssl, no-ssl-no-login (selected by ENABLE_SSL and ENABLE_LOGIN).
- Still unverified: jar name inside GapsAsJar zip (plan line 57); whether the zip contains movieIds.json (not checked, zip not downloaded).
