# Context: headlamp

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/headlamp/values.yaml | truecharts-headlamp.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/headlamp/Chart.yaml | truecharts-headlamp.md |
| https://raw.githubusercontent.com/headlamp-k8s/headlamp/v0.46.0/Dockerfile (also blob URL) | github-headlamp-k8s-headlamp-v0.46.0.md |
| https://github.com/headlamp-k8s/headlamp (main page) | github-headlamp-k8s-headlamp-v0.46.0.md (raw README, main) |
| https://github.com/kubernetes-sigs/headlamp (redirect target) | covered by release page below |
| https://github.com/headlamp-k8s/headlamp/blob/v0.46.0/Dockerfile | same as raw Dockerfile |
| https://raw.githubusercontent.com/headlamp-k8s/headlamp/v0.46.0/container/* | github-headlamp-k8s-headlamp-v0.46.0.md (followed: fetch-plugins.sh, build-manifest.json; this is the upstream `container/` dir) |
| https://api.github.com/repos/headlamp-k8s/headlamp/releases/tags/v0.46.0 | failed (403), see failures |
| https://github.com/headlamp-k8s/headlamp/releases/tag/v0.46.0 | github-headlamp-k8s-headlamp-v0.46.0.md (HTML title only) |
| https://headlamp.dev | fetched (200), marketing page, not summarized |

Skipped categories: `https://github.com/trueforge-org/containers/tree/main/apps/node` (this repo's own node app, read locally if needed; not web-fetched); plugin and in-cluster/desktop install docs on headlamp.dev (budget); Artifact Hub search (not a build input); `kubernetes-sigs/headlamp` raw Dockerfile (same as headlamp-k8s, redirect).

Failures:
- https://api.github.com/repos/headlamp-k8s/headlamp/releases/tags/v0.46.0: 403. One alternative (HTML release page): 200. Asset list not read from it.

## plan.md corrections
- None applied. Upstream facts in plan section 1 match the fetched v0.46.0 Dockerfile (alpine 3.24.2 base, golang 1.26.8, node 22, `EXPOSE 4466`, `USER headlamp`, ENTRYPOINT, `HEADLAMP_STATIC_PLUGINS_DIR`, no VOLUME).
- Unverified conflict (not edited): plan line 58 says `fetch-plugins.sh` and `build-manifest.json` "are not in the release tarball". They do exist in the repo at tag v0.46.0 under `container/`. Whether the tarball includes them remains unverified.
