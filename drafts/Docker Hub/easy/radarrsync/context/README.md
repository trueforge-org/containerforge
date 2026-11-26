# radarrsync context index

Fetched 2026-11-26.

## Source URL -> file

| Source URL | File | Notes |
| --- | --- | --- |
| https://github.com/dairefinn/RadarrSync | github-dairefinn-radarrsync.md | fork the image is built from; README via raw master |
| https://raw.githubusercontent.com/dairefinn/RadarrSync/master/README.md | github-dairefinn-radarrsync.md | fetched |
| https://raw.githubusercontent.com/dairefinn/RadarrSync/master/Dockerfile | github-dairefinn-radarrsync.md | fetched (draft cites blob/master/Dockerfile) |
| https://raw.githubusercontent.com/dairefinn/RadarrSync/master/requirements.txt | github-dairefinn-radarrsync.md | fetched |
| https://raw.githubusercontent.com/dairefinn/RadarrSync/master/startup.sh | github-dairefinn-radarrsync.md | fetched |
| https://raw.githubusercontent.com/dairefinn/RadarrSync/master/RadarrSync.py | github-dairefinn-radarrsync.md | fetched |
| https://github.com/Sperryfreak01/RadarrSync | github-sperryfreak01-radarrsync.md | original project; repo page not fetched, requirements and release fetched |
| https://raw.githubusercontent.com/Sperryfreak01/RadarrSync/HEAD/requirements.txt | github-sperryfreak01-radarrsync.md | fetched (draft cites blob/HEAD) |
| https://github.com/Sperryfreak01/RadarrSync/releases/tag/v1.0 | github-sperryfreak01-radarrsync.md | fetched; assets did not render |
| https://hub.docker.com/r/dmanius/radarrsync-docker | dockerhub-dmanius-radarrsync-docker.md | fetched |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/radarrsync | truecharts-radarrsync.md | tree page; values via raw |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/radarrsync/values.yaml | truecharts-radarrsync.md | fetched |

## Skipped URLs

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA link |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json | forgetool schema |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json | forgetool schema |
| https://github.com/trueforge-org/containerforge/tree/main/apps/python | containerforge apps base link |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge apps base link |
| http://127.0.0.1:1 | localhost address |
| https://github.com/dairefinn/RadarrSync/archive/${VERSION}.tar.gz | contains ${; direct archive download |
| https://github.com/dairefinn/RadarrSync/archive/7546e59b7c6ca50f42460e919ebd86eb254a2c57.tar.gz | direct archive download; sha256 in plan.md |

## Fetch failures

- None.

## plan.md corrections

No edits made. Context confirms plan.md's main points: the image is built from the dairefinn fork (env-var config), `requests==2.20.0` in the fork requirements, `VER = '1.0.1'`, env var names, `./Output.txt` log path, `sh /startup.sh` loop with 15 minute sleep.

Unverified items (not edited):
- plan.md line 19 says the script uses the "Radarr v0.2 API". Source shows unversioned `/api/...` paths; the v0.2 label was not confirmed from any source.
- plan.md section 10 says current Radarr (apps/radarr 7.x) serves `/api/v3` and that each sync would fail with 404. Not verified against a live Radarr or Radarr docs.
- plan.md section 1 says the fork has no license. Not checked beyond the GitHub page (not fetched here).
- plan.md section 1 says the fork's last commit is 7546e59b (2021-01-28). Not checked; archive link not fetched.
