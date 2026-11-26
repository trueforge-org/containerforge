# Context sources: plex-auto-languages

| Source URL | Summary file |
| --- | --- |
| https://github.com/RemiRigal/Plex-Auto-Languages | github-remirigal-plex-auto-languages.md |
| https://github.com/remirigal/plex-auto-languages (lowercase, from draft) | github-remirigal-plex-auto-languages.md (same repo) |
| https://github.com/remirigal/plex-auto-languages/blob/104ead7b2093a8ece5afa00440b6060f7d5e455f/Dockerfile | github-remirigal-plex-auto-languages.md (release v1.2.3 Dockerfile read instead; master blob not fetched) |
| https://raw.githubusercontent.com/RemiRigal/Plex-Auto-Languages/v1.2.3/README.md | github-remirigal-plex-auto-languages.md |
| https://raw.githubusercontent.com/RemiRigal/Plex-Auto-Languages/v1.2.3/config/default.yaml | github-remirigal-plex-auto-languages.md |
| https://raw.githubusercontent.com/RemiRigal/Plex-Auto-Languages/v1.2.3/requirements.txt | github-remirigal-plex-auto-languages.md |
| https://github.com/RemiRigal/Plex-Auto-Languages/releases/tag/v1.2.3 | github-remirigal-plex-auto-languages.md (via API) |
| https://api.github.com/repos/RemiRigal/Plex-Auto-Languages/releases/tags/v1.2.3 | github-remirigal-plex-auto-languages.md |
| https://hub.docker.com/r/remirigal/plex-auto-languages | dockerhub-remirigal-plex-auto-languages.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/plex-auto-languages | truecharts-plex-auto-languages.md |

## Skipped URLs

- https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu (containerforge `apps/<base>` link)
- https://github.com/trueforge-org/containerforge/tree/main/apps/python (containerforge `apps/<base>` link)
- https://cla-assistant.io/trueforge-org/containerforge (CLA link; noted for reference)
- https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json (forgetool schema URL)
- https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json (forgetool schema URL)
- ghcr.io/trueforge-org/python:3.15.2@sha256:... and ghcr.io/trueforge-org/ubuntu (image refs, not web pages)
- docker.io/remirigal/plex-auto-languages:latest (image ref; covered by the Docker Hub and chart entries)
- https://github.com/RemiRigal/Plex-Auto-Languages/releases/tag/v1.2.3 is fetched via API only; the release page itself was not fetched.
- https://github.com/RemiRigal/Plex-Auto-Languages/blob/HEAD/requirements.txt (draft/plan link to HEAD; tag v1.2.3 requirements read instead)
- https://github.com/RemiRigal/Plex-Auto-Languages/archive/refs/tags/v1.2.3.tar.gz (source archive; direct archive download, pattern recorded)

## Fetch failures

- None.

## plan.md corrections

- None made. Checked against source: `python:3.8-alpine` upstream base, `CONTAINERIZED True`, `VOLUME /config`, HEALTHCHECK on `localhost:9880`, `ENTRYPOINT` with tini and `-c /config/config.yaml`, requirements (lower bounds only), `config/default.yaml` values (`update_level: show`, `update_strategy: next`, `trigger_on_play` true, `trigger_on_scan` true, `trigger_on_activity` false, `refresh_library_on_scan` true, `ignore_tags: [PAL_IGNORE]`, `scheduler` enable true and `02:00`, `notifications` disabled, `debug` false), release `v1.2.3` (2023-08-11, not prerelease, commit `7c8e936`), MIT license.
- Unverified (not edited): plan says the upstream health server also serves `/health` and `/ready` returning 200/400. Only the upstream HEALTHCHECK path `/` was read.
- Unverified (not edited): plan says the app starts the health server before config parsing, and the cache is at `/config/cache/<server id>`; source not read here.
- Unverified (not edited): plan's "Draft caveat confirmed" (test only against a copy). The app does change audio/subtitle tracks (README), but the README gives no "test on a copy" advice.
- Noted (not edited, plan already uses source value): README and Docker Hub say `update_strategy` default `all`; `default.yaml` at v1.2.3 says `next`. Plan follows `default.yaml`.
- Noted (not edited): the chart's digest for `latest` matches the Docker Hub `latest` digest (`54bd9cf5...`); which commit that image was built from was not confirmed.
