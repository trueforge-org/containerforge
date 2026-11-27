# Context: hammond

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/hammond/values.yaml | truecharts-hammond.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/hammond/Chart.yaml | truecharts-hammond.md |
| https://api.github.com/repos/AlfHou/hammond/contents/Dockerfile?ref=c167642b889a7d939e6087d9bda9854d4346ee5c and https://github.com/AlfHou/hammond/blob/c167642b889a7d939e6087d9bda9854d4346ee5c/Dockerfile | github-alfhou-hammond.md (raw Dockerfile) |
| https://github.com/AlfHou/hammond (main page) | github-alfhou-hammond.md (raw README, master) |
| https://api.github.com/repos/AlfHou/hammond/releases/latest | failed (403); alternative https://github.com/AlfHou/hammond/releases/tag/v0.0.24 used, in github-alfhou-hammond.md |
| https://api.github.com/repos/AlfHou/hammond/tags | failed (403); alternative https://github.com/AlfHou/hammond/tags used, in github-alfhou-hammond.md |
| https://github.com/alfhou/hammond/pkgs/container/hammond | not fetched (GHCR package page, image ref only) |

Skipped categories: image-ref (GHCR package page); docs/ubuntu-install.md (native install, not container build); djjudas21 Helm chart and compose links (not build inputs); screenshots.

Failures:
- api.github.com releases/latest: 403. One alternative (HTML release page): 200.
- api.github.com tags: 403. One alternative (HTML tags page): 200.

## plan.md corrections
- None. Plan values match the fetched sources: `GO_VERSION=1.20.6`, `EXPOSE 3000`, `ENTRYPOINT ./app`, `VOLUME /config /assets`, `CONFIG`/`DATA` env, tag v0.0.24 (release page title).
- Unverified (not edited): plan says the release tag resolves to commit c167642b; not checked (tags API 403, HTML tags page did not show SHA).
