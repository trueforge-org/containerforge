# Context: flowise

| Source URL | File |
| --- | --- |
| https://github.com/FlowiseAI/Flowise/blob/a65f81b/docker/Dockerfile (raw variant), https://github.com/FlowiseAI/Flowise | flowise-dockerfile.md |
| https://api.github.com/repos/FlowiseAI/Flowise/releases/latest | flowise-github-api-releases.md |
| https://docs.flowiseai.com | flowise-docs-env-vars.md (intro only, no config facts) |
| https://docs.flowiseai.com/configuration/environment-variables.md (follow-up) | flowise-docs-env-vars.md |
| https://raw.githubusercontent.com/FlowiseAI/Flowise/main/LICENSE.md | flowise-license.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/flowise (+ raw Chart.yaml, values.yaml) | truecharts-flowise.md |
| https://hub.docker.com/r/flowiseai/flowise (+ v2 API repo and tags) | dockerhub-flowise.md |

Skipped: urls.txt has no CLA, forgetool, containerforge, templated, binary or image-ref URLs.

Failures: none. hub.docker.com HTML not fetched; v2 JSON API used.

## plan.md corrections
- No edits. Consistent with fetched sources: version 3.1.4, Node 24 build arg, Apache-2.0 with Commercial enterprise/ exception, PORT 3000, `USER node`, `ENTRYPOINT ["flowise","start"]`, Docker Hub tags latest and 3.1.4 (amd64+arm64).
- Resolves two UNVERIFIED items (not edited): SQLite default DB location is `~/.flowise` (DATABASE_PATH default), and PostgreSQL is optional (DATABASE_TYPE default sqlite), per the docs env-var page.
- Not verified: plan env-var names beyond the docs table (APIKEY_PATH, FLOWISE_USERNAME, FLOWISE_PASSWORD are not on the docs page).
