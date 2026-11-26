# Context: livestreamdvr

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/livestreamdvr/values.yaml + Chart.yaml | truecharts-livestreamdvr.md |
| https://hub.docker.com/v2/repositories/mrbrax/twitchautomator/ (+ tags) | dockerhub-twitchautomator.md |
| https://raw.githubusercontent.com/MrBrax/LiveStreamDVR/1cd7e8f.../Dockerfile (+ docker/fetch-tdl.sh, docker/fetch-ttv-lol.sh) | github-livestreamdvr-dockerfile.md |
| https://raw.githubusercontent.com/MrBrax/LiveStreamDVR/1cd7e8f.../README.md (+ master LICENSE) | github-livestreamdvr-readme.md |

Skipped: CLA, forgetool schemas, containerforge links, templated, binary downloads, image refs: none beyond what urls.txt already removed. Not fetched, redundant: blob/1cd7e8f Dockerfile (same as raw), github.com/MrBrax/LiveStreamDVR repo root (covered by raw README and LICENSE).
Shared cache (docs/context/INDEX.md): no hits for this app.

Failed:
- https://api.github.com/repos/MrBrax/LiveStreamDVR/releases/latest: API rate limit (403), not retried. plan.md cites release `LiveStreamDVR-2025-01-21-c2.4.3-s1.7.5.1-d1.1.2-v2.3.2.1`; not re-verified here.

## plan.md corrections
- None proven wrong. Checked: License MIT (master LICENSE, plan line 11), upstream `USER node` commented out (plan line 16), EXPOSE 8080 (plan line 21), TwitchDownloader TD_VERSION 1.54.3 and arch map (plan line 19), Docker Hub master 2025-01-21 / develop 2025-05-05 (plan line 9), chart version 11.0.0 (plan line 25).
- Not verified here: per-arch checksums for TwitchDownloader (none in script, plan says UNVERIFIED; consistent).
