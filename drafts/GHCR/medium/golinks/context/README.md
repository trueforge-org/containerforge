# Context: golinks

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/golinks/values.yaml | truecharts-golinks.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/golinks/Chart.yaml | truecharts-golinks.md |
| https://git.mills.io/prologic/golinks/raw/branch/master/Dockerfile | git-mills-golinks.md |
| https://git.mills.io/prologic/golinks/raw/branch/master/.dockerfiles/start.sh | git-mills-golinks.md |
| https://git.mills.io/prologic/golinks/raw/branch/master/Makefile | git-mills-golinks.md (not in urls.txt; followed as build reference) |
| https://git.mills.io/prologic/golinks/raw/branch/master/go.mod | git-mills-golinks.md |
| https://git.mills.io/prologic/golinks/raw/branch/master/README.md | git-mills-golinks.md (main page; HTML repo page replaced by raw) |
| https://git.mills.io/prologic/golinks (HTML) | covered by raw README above |
| https://api.github.com/repos/prologic/golinks | not fetched; GitHub mirror has no tags (plan note) |
| https://git.mills.io/api/v1/repos/prologic/golinks/releases?limit=3 | git-mills-golinks.md |
| https://github.com/prologic/golinks | not fetched; pointer README per plan |

Skipped categories: LICENSE and main.go raw (not needed for build; not fetched); CI/homebrew/github-mirror links; `suggestqueries.google.com` and `google.com` search URLs (defaults in start.sh, not sources); `github.com/nicholaswilde/docker-golinks` (packaging repo, not fetched, budget); `git.mills.io/prologic/golinks/archive/v0.0.7.tar.gz` (binary archive, not fetched).

Failures: none.

## plan.md corrections
- `plan.md` line 13 (Per-arch download): "None. No release assets." -> v0.0.7 has release assets `_0.0.7_linux_amd64.tar.gz`, `_0.0.7_linux_arm64.tar.gz`, `_0.0.7_darwin_amd64.tar.gz`. Source: releases API above (fetched 2026-11-27). Applied. The build-from-source decision is kept.
- `plan.md` line 14 (Checksum source): "None published. UNVERIFIED: no checksum on the release." -> `_0.0.7_checksums.txt` (+ `.sig`) is on the v0.0.7 release. Contents not read. Applied.
- Unverified conflict (not edited): plan says upstream Dockerfile/start flow; the fetched Dockerfile and start.sh are from master, not the v0.0.7 tag. Tag contents unverified.
- Unverified conflict (not edited): chart mounts `/data` but upstream `start.sh` default `DBPATH=/search.db`. Chart does not set `DBPATH`. Decide in plan.
