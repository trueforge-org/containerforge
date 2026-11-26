# TrueCharts rsshub values.yaml

Source: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/rsshub (raw values.yaml), fetched 2026-11-26

- image: docker.io/diygod/rsshub, tag latest@sha256:f948f601b55357bd78dd4e97f506dffec4ce2775ad14577634ce120da9a9e1df
- browserlessImage: docker.io/browserless/chrome, tag 1.61.1-chrome-stable@sha256:efac47cfff3830d9a50b27d29f8bbb61949058ae336c823fbe9bd3c0d1debcc8 (sidecar container `browserless`, containerPort 3000)
- service main: port 10191 (PORT env set from it, not 1200)
- dependencies: valkey enabled (REDIS_URL from valkey secret)
- env: PORT=10191 (templated), NODE_ENV=production, CACHE_TYPE=redis, PUPPETEER_WS_ENDPOINT=ws://localhost:3000, NODE_NAME (release-based), DISALLOW_ROBOT=false, TITLE_LENGTH_LIMIT=150, REDIS_URL (secret), HTTP_BASIC_AUTH_NAME="", and secret-backed HTTP_BASIC_AUTH_PASS, BITBUCKET_USERNAME="", BITBUCKET_PASSWORD, GITHUB_ACCESS_TOKEN, GOOGLE_FONTS_API_KEY, YOUTUBE_KEY, TELEGRAM_TOKEN, LASTFM_API_KEY
- securityContext: runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false

## Gotchas
- Chart points PUPPETEER_WS_ENDPOINT at a browserless sidecar on ws://localhost:3000.
- Chart sets PORT to 10191, so the container listens on 10191 in the chart (Dockerfile EXPOSE 1200).
