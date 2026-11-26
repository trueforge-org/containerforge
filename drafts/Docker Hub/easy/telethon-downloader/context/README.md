# context/ for telethon-downloader

Fetched 2026-11-26.

## Sources

| Source URL | Summary file |
| --- | --- |
| https://github.com/jsavargas/telethon_downloader (README, Dockerfile @ed9710a, requirements.txt, src/env_config.py, src/app.py, License.md @ed9710a, releases) | github-jsavargas-telethon-downloader.md |
| https://hub.docker.com/r/jsavargas/telethon_downloader | dockerhub-jsavargas-telethon-downloader.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/telethon-downloader (values.yaml) | truecharts-telethon-downloader.md |
| https://docs.telethon.dev | docs-telethon-dev.md |

## Skipped

- https://cla-assistant.io/trueforge-org/containerforge: CLA page, not a source.
- https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json: forgetool schema URL.
- https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json: forgetool schema URL.
- https://github.com/trueforge-org/containerforge/tree/main/apps/python and .../apps/ubuntu: containerforge base links.
- https://github.com/jsavargas/telethon_downloader/archive/refs/heads/master.zip: direct archive download (repo summary records the source archive pattern).
- https://github.com/jsavargas/telethon_downloader/blob/ed9710a/Dockerfile, https://github.com/jsavargas/telethon_downloader/blob/HEAD/requirements.txt: same content as the raw files in the GitHub summary (fetched raw).
- Local reference `docs/project-fireball.md`: local file, not web.

## Fetch failures

- None. Notes: the GitHub tags page was not fetched; the Docker Hub page showed only the `latest` tag.

## plan.md corrections

None made. Items left as unverified (not edited):
- Licence `GPL-3.0-only` vs `GPL-3.0-or-later`: unverified (License.md has no such clause; source file notices not fetched).
- Version tag `jsavargas/telethon_downloader:4.0.15`: plan.md states it exists on Docker Hub, but the fetched Docker Hub page shows only `latest`. Its digest `sha256:f9ad5f0c...` matches the `latest` digest, so this is unverified.
- Plan.md says the GitHub repo has no git tags beyond `v3.1.9`: the releases page has no releases, and the tags page was not fetched. Unverified.
