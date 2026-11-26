# Docker Hub gotenberg/gotenberg

Source URL: https://hub.docker.com/r/gotenberg/gotenberg (fetched)

## Tags
| Variant | Tags |
| --- | --- |
| full | latest, 9 |
| chromium only (~30% smaller) | latest-chromium, 9-chromium |
| libreoffice only (~38% smaller) | latest-libreoffice, 9-libreoffice |
| cloudrun | latest-cloudrun, 9-cloudrun (+ chromium/libreoffice combos) |
| aws-lambda | latest-aws-lambda, 9-aws-lambda (+ combos) |
| dev | edge, edge-chromium, edge-libreoffice (from main) |
- v8 still available as gotenberg/gotenberg:8. Snapshots in gotenberg/snapshot repo.

## Facts
- Exposed port 3000. Run: `docker run --rm -p 3000:3000 gotenberg/gotenberg:9`
- Architectures: amd64, arm64v8, arm32v7, i386, ppc64le
- Env vars/flags: none listed on page (points to v8->v9 upgrade guide)
- Endpoint example: POST /forms/chromium/convert/url
- Source: github.com/gotenberg/gotenberg
