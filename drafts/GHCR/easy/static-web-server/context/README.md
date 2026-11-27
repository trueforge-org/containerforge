# static-web-server context README

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/static-web-server/values.yaml | truecharts-sws-values.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/static-web-server/Chart.yaml | truecharts-sws-chart.md |
| https://github.com/static-web-server/static-web-server/blob/501cb7f.../docker/scratch/Dockerfile (raw) | sws-dockerfile-501cb7f.md |
| https://github.com/static-web-server/static-web-server (README, raw master) | sws-readme-master.md |
| https://github.com/static-web-server/static-web-server/releases/latest (alt. for API 403) | github-html-sws-releases-latest.md (asset names not loaded) |
| https://static-web-server.net | sws-website.md (landing page, examples only) |
| https://api.github.com/repos/static-web-server/static-web-server | failed: 403 |
| https://api.github.com/repos/static-web-server/static-web-server/releases/latest | failed: 403 (HTML alternative used) |

Skipped: none by category. No CLA, forgetool, containerforge app, templated, binary download or image-ref URLs were in the list. Release tarballs and SHA256SUM are binary downloads, not fetched. No Docker Hub source in urls.txt (GHCR app); README and website name Docker Hub `joseluisq/static-web-server` as a mirror.

Failures: 2 (both GitHub API endpoints returned 403; HTML release page used as one alternative, assets still not listed).

## plan.md corrections
- Edit 1, plan.md line 10 (License row): `Apache-2.0 (GitHub SPDX)` -> `MIT OR Apache-2.0 (dual-licensed per upstream README, files LICENSE-MIT and LICENSE-APACHE)`. Source: sws-readme-master.md. The GitHub API SPDX could not be fetched (403).
- Edit 2, plan.md line 45 (step 5): `ship the Apache-2.0 license file` -> `ship the MIT and Apache-2.0 license files`. Source: sws-readme-master.md.
- Edit 3, plan.md line 75 (bake LICENSE variable): `default = "Apache-2.0"` -> `default = "MIT OR Apache-2.0"`. Source: sws-readme-master.md.
- Caveat for the edits: the README was read from master (v3 dev), not from the v2.44.3 tag. The v2.44.3 LICENSE files were not checked.
- Unverified conflict: plan line 45 says the repo has a root `LICENSE` file to curl from `v${VERSION}`. The README names `LICENSE-MIT` and `LICENSE-APACHE`. Root `LICENSE` presence not verified. Not edited.
- Verified, no edit: `docker/scratch/Dockerfile` facts (`FROM scratch`, EXPOSE 80, ENTRYPOINT `/static-web-server`, no USER); version v2.44.3 published 15 Nov (plan line 8); chart appVersion 2.44.3.
