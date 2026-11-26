# Context: lingva

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/lingva/values.yaml + Chart.yaml | truecharts-lingva.md |
| https://hub.docker.com/v2/repositories/thedaviddelta/lingva-translate/ (+ tags) | dockerhub-lingva.md |
| https://raw.githubusercontent.com/TheDavidDelta/lingva-translate/0190ea5/Dockerfile (blob variant listed in urls.txt) | github-lingva-dockerfile.md |
| https://raw.githubusercontent.com/TheDavidDelta/lingva-translate/main/README.md (+ LICENSE, repo root) | github-lingva-readme.md |
| https://lingva.ml | lingva-ml.md |

Skipped: CLA, forgetool schemas, containerforge links, templated, binary downloads, image refs: none beyond what urls.txt already removed. Not fetched, redundant: blob/0190ea5 Dockerfile (same as raw), github.com/TheDavidDelta/lingva-translate repo root (covered by raw README and LICENSE).
Shared cache (docs/context/INDEX.md): no hits for this app.

Failed: none.

## plan.md corrections
- None. Checked: License AGPL-3.0 (LICENSE raw), Docker Hub `latest` only, amd64, 2022-10-21 (plan line 20), upstream CMD env mapping (plan line 18), port 3000, UID 1001 (plan line 16).
- Note for author (not an error): chart's `latest` digest refers to an image last pushed 2022-10-21; plan builds from source so this does not block.
- Note for author: upstream CMD runs `yarn build` at container start, which is what plan line 19 says; the plan's build-at-image-time design differs by intent.
