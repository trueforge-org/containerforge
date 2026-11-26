# Context: goaccess

| Source URL | File |
| --- | --- |
| https://github.com/gregyankovoy/docker-goaccess/blob/efd688b/Dockerfile (raw variant) | gregyankovoy-docker-goaccess-dockerfile.md |
| https://github.com/allinurl/goaccess (+ api releases/latest, releases page) | allinurl-goaccess-releases.md |
| https://goaccess.io | goaccess-io.md |
| https://goaccess.io/man | goaccess-man.md |
| https://raw.githubusercontent.com/allinurl/goaccess/v1.12/COPYING | goaccess-copying.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/goaccess (+ raw Chart.yaml, values.yaml) | truecharts-goaccess.md |
| https://hub.docker.com/r/gregyankovoy/goaccess (+ v2 API repo and tags) | dockerhub-goaccess.md |

Skipped: urls.txt has no CLA, forgetool, containerforge, templated or image-ref URLs.

Failures: https://api.github.com/repos/allinurl/goaccess/releases/latest returned 403 (not retried); releases page fallback reported no releases (conflicts with plan.md v1.12 release claim). hub.docker.com HTML not fetched; v2 JSON API used.

## plan.md corrections
- No edits. Consistent with fetched sources: upstream Dockerfile (alpine-base, GoAccess v1.4 build, EXPOSE 7889, VOLUME /config and /opt/log, CMD goaccess.sh, root), MIT license, Docker Hub tags latest (2020-10-02) and 1.4 (2020-08-20), chart values (7889, /opt/log, runAsUser 0).
- Resolved UNVERIFIED (not edited): plan line 10 says the v1.12 COPYING is unverified; the raw v1.12 COPYING fetched above is MIT (Copyright 2009-2022 Gerardo Orellana), so the tag exists and the license is MIT.
- Unverified conflict (not edited): plan line 8 cites a GitHub v1.12 release dated 2026-09-16. The API returned 403 and the releases page reported no releases, so the release claim could not be confirmed.
- Plan line 18/section 7: the man page documents goaccess's own WebSocket `--port` default as 7890 (nginx front is 7889); this is relevant to the UNVERIFIED WebSocket port in plan line 18.
