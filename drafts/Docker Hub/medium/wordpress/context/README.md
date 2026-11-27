# Context index: wordpress

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/wordpress/values.yaml + Chart.yaml | truecharts-wordpress.md |
| https://hub.docker.com/v2/repositories/bitnamisecure/wordpress/ + tags?page_size=10 | dockerhub-bitnamisecure-wordpress.md |
| https://raw.githubusercontent.com/bitnami/containers/9da424411c57f30d7bdc8409eabcce6e5709c9f3/bitnami/wordpress/7/debian-12/Dockerfile (also blob URL) | bitnami-wordpress-dockerfile.md |
| https://api.wordpress.org/core/version-check/1.7 | wordpress-version-check.md |
| https://downloads.wordpress.org/release/wordpress-7.1.5.zip.sha1 | wordpress-zip-sha1.md |

Skipped (one line): https://github.com/WordPress/WordPress (repo HTML; source not needed, the versioned zip is used), https://wordpress.org, https://wordpress.org/documentation, https://www.wordpress.org (marketing and docs, not build inputs). No CLA, forgetool, containerforge, templated, binary-download (zip itself) or image-ref URLs in this list beyond the Dockerfile's FROM line.
Failures: none.

## plan.md corrections
- No in-place edits.
- Checked and matching fetched sources: version 7.1.5 (version-check), SHA-1 `d7d004a0...` (plan.md quotes the same value), Bitnami Dockerfile components (apache 2.4.71, php 8.4.28, wordpress 7.1.5-1), `EXPOSE 8080 8443`, `USER 1001`, ENTRYPOINT and CMD, no VOLUME.
- Unverified: plan.md's zip size 37245999 bytes and the `application/zip` content type were not re-checked (zip not downloaded).
- Docker Hub tags API (first page): no version tag such as `7.1.5` is listed; `latest` is shown only as `latest-metadata`. Digest `549b3984...` (the chart's pinned `latest`) is listed as a `sha256-` entry. Not a plan error.
