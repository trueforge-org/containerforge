# deepstack: source context (fetched 2026-11-26)

## Sources fetched

| Source URL | Summary file |
| --- | --- |
| https://github.com/johnolafenwa/DeepStack (README via raw) | github-johnolafenwa-deepstack.md |
| https://github.com/johnolafenwa/DeepStack/releases | github-johnolafenwa-deepstack.md |
| https://raw.githubusercontent.com/johnolafenwa/DeepStack/master/LICENSE | github-johnolafenwa-deepstack.md |
| https://raw.githubusercontent.com/johnolafenwa/DeepStack/73b6f7ab0f9a8acc8f7a49c6f13594fe470de042/LICENSE (plan's commit; master copy used) | github-johnolafenwa-deepstack.md |
| https://github.com/johnolafenwa/DeepStack/blob/73b6f7ab0f9a8acc8f7a49c6f13594fe470de042/Dockerfile.cpu (raw master Dockerfile.cpu used) | github-johnolafenwa-deepstack.md |
| https://deepstack.readthedocs.io/ | deepstack-readthedocs.md |
| https://hub.docker.com/r/deepquestai/deepstack | dockerhub-deepquestai-deepstack.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/deepstack (values.yaml) | truecharts-deepstack.md |

## Skipped URLs

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA link (never fetched) |
| https://github.com/trueforge-org/containerforge/tree/main/apps/python | containerforge base app link |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge base app link |
| https://deepquest.sfo2.digitaloceanspaces.com/deepstack/shared-files/sharedfiles.zip | direct archive download; plan.md reports HTTP 403; not retried |
| https://raw.githubusercontent.com/trueforge-org/forgetool/... (schema) | not in this app's draft; not used |
| https://github.com/johnolafenwa/DeepStack (repo root) | covered by README and releases fetches |

## Fetch failures

- https://docs.deepstack.cc: DNS ENOTFOUND. Replaced by https://deepstack.readthedocs.io/ (linked from the Docker Hub page; fetched).
- https://www.deepstack.cc and https://deepstack.cc (draft "Website"): www.deepstack.cc DNS ENOTFOUND; deepstack.cc not separately fetched.
- https://raw.githubusercontent.com/johnolafenwa/DeepStack/master/.gitattributes: empty response (LFS status unknown).
- GitHub releases: first attempt DNS error, second succeeded.
- Not fetched: `deepquestai/deepstack-base` (base image; not in repo).

## plan.md corrections

- Section 1 Version row: "Docker Hub `cpu-2022.01.1` ... Docker tags `cpu-2022.01.1`, `gpu-2022.01.1`, `arm64-2022.01.1`, `jetpack-2022.01.1`" -> `jetpack-2021.01.1` per the release notes (not 2022.01.1). Source: github-johnolafenwa-deepstack.md.
- Section 1 Renovate: "real git tag name UNVERIFIED" -> the git tag is `2022.01.1` (release title is "DeepStack 2022.01.1 Release"). Source: github-johnolafenwa-deepstack.md.
- Section 1 Binary / artifacts row: "The model weights are NOT in the git repo: ... Only the published Docker image still contains them." -> the upstream README says `git lfs pull` fetches the large repo files, and Dockerfile.cpu COPYs `./sharedfiles/*.pt` from the repo. Whether the weights are LFS objects in the repo is UNVERIFIED (.gitattributes could not be read). Source: github-johnolafenwa-deepstack.md.
- Section 1 Packages/docs: the draft's docs URL `docs.deepstack.cc` does not resolve (DNS), documented in fetch failures; plan.md does not cite it, so no plan edit.
- Section 4 step 2 digest: "digest UNVERIFIED" for `cpu-2022.01.1` -> the TrueCharts chart pins `sha256:4320be73987468b3040b2ca63daf2d3935c4d469b53aa40efb6176858488b500` (confirm with `docker buildx imagetools inspect`). Source: truecharts-deepstack.md.

## Unverified / notes (plan.md left as-is)

- The chart's `gpuImage` is the CPU tag (not a GPU build).
- Chart enables VISION-DETECTION, VISION-FACE, VISION-SCENE, VISION-ENHANCE (plan defaults them to False).
- Weight licences (plan: UNVERIFIED) not stated anywhere fetched.
- Python 3.7 and torch 1.6 requirements confirmed for the local run (README), consistent with plan.md's blocker analysis.
- DeepQuest AI states it maintains the project (README, docs home), while the Docker Hub page says last updated almost 5 years ago and the release is 2022. Plan's "unmaintained" label is an inference from dates.
