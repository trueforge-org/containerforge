# Context sources: icloudpd

Fetched 2026-11-26.

| Source URL | Summary file |
| --- | --- |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/icloudpd (values.yaml raw) | truecharts-icloudpd.md |
| https://github.com/icloud-photos-downloader/icloud_photos_downloader (README and docs/authentication.md raw at tag v1.34.0; release API) | github-icloud-photos-downloader.md |
| https://github.com/icloud-photos-downloader/icloud_photos_downloader/releases/latest | github-icloud-photos-downloader.md |
| https://icloud-photos-downloader.github.io/icloud_photos_downloader/ | docs-icloud-photos-downloader-github-io.md |
| https://github.com/boredazfcuk/docker-icloudpd/blob/master/icloudpd.dockerfile | github-boredazfcuk-docker-icloudpd.md |
| https://hub.docker.com/r/boredazfcuk/icloudpd | dockerhub-boredazfcuk-icloudpd.md |

## Skipped
- https://github.com/icloud-photos-downloader/icloud_photos_downloader/releases/download/v1.33.1/icloud-1.33.1-linux-amd64 and -arm64: direct binary downloads (skip rule). Asset pattern and the wrong-tool finding are recorded in github-icloud-photos-downloader.md.
- https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu and .../apps/python: containerforge apps/<base> links (skip rule).
- ghcr.io/trueforge-org/ubuntu, ghcr.io/trueforge-org/python: image refs (skip rule).
- https://cla-assistant.io/trueforge-org/containerforge: CLA link (skip rule).
- https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json and .../pkg/containers/test/container-test.schema.json: forgetool schema URLs (skip rule).
- https://icloud-photos-downloader.github.io/icloud_photos_downloader/ sub-pages (authentication.html etc.): not followed (listed in docs summary, authentication content read from raw markdown instead).

## Fetch failures
- https://raw.githubusercontent.com/icloud-photos-downloader/icloud_photos_downloader/main/README.md: 404. Retried at tag v1.34.0, OK.
- https://raw.githubusercontent.com/icloud-photos-downloader/icloud_photos_downloader/main/docs/authentication.md: 404. Retried at tag v1.34.0, OK.
- https://github.com/icloud-photos-downloader/icloud_photos_downloader/releases/latest: asset list did not load in the fetch. Asset list taken from the GitHub API for tag v1.34.0 instead.
