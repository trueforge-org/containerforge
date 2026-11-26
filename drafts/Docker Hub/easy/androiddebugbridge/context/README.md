# androiddebugbridge: context sources

| Source URL | File |
| --- | --- |
| https://github.com/BLBurgess/adb-hass-androidtv | github-blburgess-adb-hass-androidtv.md |
| https://raw.githubusercontent.com/BLBurgess/adb-hass-androidtv/v1.1.0/README.md | github-blburgess-adb-hass-androidtv.md |
| https://raw.githubusercontent.com/BLBurgess/adb-hass-androidtv/v1.1.0/files/androidtv-connect.sh | github-blburgess-adb-hass-androidtv.md |
| https://raw.githubusercontent.com/BLBurgess/adb-hass-androidtv/main/Dockerfile | github-blburgess-adb-hass-androidtv.md |
| https://github.com/BLBurgess/adb-hass-androidtv/blob/main/Dockerfile | github-blburgess-adb-hass-androidtv.md |
| https://github.com/BLBurgess/adb-hass-androidtv/releases/tag/v1.1.0 | github-blburgess-adb-hass-androidtv.md |
| https://hub.docker.com/r/barnybbb/adb-hass-androidtv | dockerhub-barnybbb-adb-hass-androidtv.md |
| https://www.home-assistant.io/integrations/androidtv/ | docs-home-assistant-androidtv.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/androiddebugbridge | truecharts-androiddebugbridge.md |

## Skipped
- https://cla-assistant.io/trueforge-org/containerforge: CLA link (skip rule).
- https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu: containerforge `apps/<base>` link (skip rule).
- https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json: forgetool schema URL (skip rule).
- ghcr.io/trueforge-org/ubuntu:26.04@sha256:...: image reference (skip rule).
- barnybbb/adb-hass-androidtv:latest: image reference covered by the Docker Hub page above.
- https://raw.githubusercontent.com/BLBurgess/adb-hass-androidtv/v${VERSION#v}/files/androidtv-connect.sh and .../LICENSE: templated versions of the v1.1.0 URLs above; fetched at v1.1.0 only. LICENSE at the tag was not fetched; MIT is recorded from the script header and the Docker Hub page.
- https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 and https://dl.google.com/android/repository/platform-tools-latest-linux.zip: direct binary downloads from the upstream Dockerfile (skip rule); recorded as runtime deps in the github summary.

## Fetch failures
- https://github.com/BLBurgess/adb-hass-androidtv/releases/tag/v1.1.0 loaded, but its asset file names did not render (page showed an error in the assets area). Not a hard failure; no names recorded.
