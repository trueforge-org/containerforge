# plex-utills: source context

Fetched 2026-11-26.

## Source URL -> file

| Source URL | File |
| --- | --- |
| https://github.com/jkirkcaldy/plex-utills | github-jkirkcaldy-plex-utills.md |
| https://raw.githubusercontent.com/jkirkcaldy/plex-utills/master/README.md | github-jkirkcaldy-plex-utills.md |
| https://raw.githubusercontent.com/jkirkcaldy/plex-utills/master/Dockerfile | github-jkirkcaldy-plex-utills.md |
| https://github.com/jkirkcaldy/plex-utills/blob/e945c0c/Dockerfile | github-jkirkcaldy-plex-utills.md (same file, raw master used) |
| https://raw.githubusercontent.com/jkirkcaldy/plex-utills/master/requirements.txt | github-jkirkcaldy-plex-utills.md |
| https://github.com/jkirkcaldy/plex-utills/blob/HEAD/requirements.txt | github-jkirkcaldy-plex-utills.md (same file) |
| https://github.com/jkirkcaldy/plex-utills/releases/tag/0.21.12 | github-jkirkcaldy-plex-utills.md (via releases list) |
| https://github.com/jkirkcaldy/plex-utills/releases | github-jkirkcaldy-plex-utills.md |
| https://github.com/jkirkcaldy/plex-utills/wiki (+ wiki/Installation, wiki/Config-Settings) | github-jkirkcaldy-plex-utills.md |
| https://hub.docker.com/r/jkirkcaldy/plex-utills | dockerhub-jkirkcaldy-plex-utills.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/plex-utills | truecharts-plex-utills.md |
| https://github.com/AnthonyBloomer/tmdbv3api.git | github-anthonybloomer-tmdbv3api.md |

## Skipped

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA link |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json | forgetool schema URL |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json | forgetool schema URL |
| https://github.com/trueforge-org/containerforge/tree/main/apps/python | containerforge apps/<base> link |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge apps/<base> link |
| https://github.com/jkirkcaldy/plex-utills/archive/${COMMIT}.tar.gz | contains `${`; source archive (binary/archive download). Pattern recorded in github-jkirkcaldy-plex-utills.md: `archive/<commit>.tar.gz`, pure Python |
| http://0.0.0.0:5000 | contains 0.0.0.0 (bind address, not a source) |
| http://<container-ip>:5000 | placeholder with `<ip>` |

## Fetch failures

None.

## plan.md corrections

None made. Context did not show a clear factual error in plan.md. Items left as unverified:
- unverified: plan.md (sections 1 and 4) says port 80 (nginx) is not needed and the app serves on 5000 only. The wiki (`-p 80:80`), TrueCharts (service target port 80), and the Dockerfile `EXPOSE 80 5000` disagree about the UI port. Decide whether nginx is dropped.
- unverified: plan.md says the draft's `UID`/`GID` are not read by code. The wiki and Docker Hub document `PUID`/`PGID` (Docker Hub also has a `PGUI` typo). Code-side claim not checked here.
- unverified: the Docker Hub `latest` tag and the TrueCharts pinned digest (sha256:33ca56a9...) may differ from the `master` commit the plan pins; not compared here.
