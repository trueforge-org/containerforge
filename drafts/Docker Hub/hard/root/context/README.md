# Context: root

| Source URL | File |
| --- | --- |
| https://github.com/BGameiro2000/dockerfile/blob/master/arch-cern-root/Dockerfile | bgameiro-arch-cern-root-dockerfile.md |
| https://github.com/root-project/root | root-project-root-readme.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/root | truecharts-root-values.md |
| https://hub.docker.com/r/bgameiro/arch-cern-root | dockerhub-bgameiro-arch-cern-root.md |
| https://root.cern | root-cern-site.md (install page merged) |
| https://root.cern/manual | root-cern-manual.md |

Skipped categories: `http://...:8888` is a templated placeholder (not a URL), not fetched. Remaining list was pre-filtered.
Failures: none.

## plan.md corrections
- None made. Checked plan.md against fetched facts: port 8888 (upstream EXPOSE and --port=8888), LGPL-2.1-or-later (README badge LGPL v2.1+), Arch-based upstream with pacman jupyter + root, chart port 9999 -> 8888, /appdata volume in upstream and chart.
- Unverified conflict (left unchanged): plan line 8 says v6-40-04 is the current release. root.cern home lists 6.42.00 and 6.42.00-rc1 as latest releases, while root.cern/install says "latest stable ROOT release is 6.40.04". Check the GitHub release list before pinning.
- Stale plan text (not an error in version/path/port/env/licence, left unchanged): plan line 16 says the bgameiro Dockerfile was "not fetched"; it is now summarised in bgameiro-arch-cern-root-dockerfile.md. Upstream also runs `root --notebook` (ROOT's server) rather than standalone Jupyter.
