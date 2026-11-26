# Context index: blog

| Source URL | File |
| --- | --- |
| https://github.com/m1k1o/blog | github-m1k1o-blog-readme.md |
| https://github.com/m1k1o/blog/blob/f778915ab85f7ea86e1f35e60e5acecfbc90a15f/Dockerfile | github-m1k1o-blog-dockerfile.md |
| https://github.com/m1k1o/blog/releases/tag/v1.5.0 (via releases/latest API) | github-release-m1k1o-blog-latest.md |
| https://github.com/nicholaswilde/docker-blog | github-nicholaswilde-docker-blog-dockerfile.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/blog (raw values.yaml) | truecharts-blog-values.md |
| https://hub.docker.com/r/m1k1o/blog (HTML) + https://hub.docker.com/v2/repositories/m1k1o/blog/ and /tags | dockerhub-m1k1o-blog.md |
| https://raw.githubusercontent.com/.../charts/stable/blog/Chart.yaml | truecharts-blog-values.md (Chart.yaml section) |

Skipped categories: none.

Failures: none.

## plan.md corrections
- Unverified conflict: plan.md "Version" row says 1.5.0 is the latest GitHub release (verified 2026-11-23). GitHub API now returns latest `v1.5.1` (published 2026-11-25), and Docker Hub JSON lists tag 1.5.1 (2026-11-25). Not edited: pinning choice is the plan author's call. Confirm before build.
- Unverified: plan.md says reviewed Dockerfile at v1.5.0 uses php:8.5-apache-trixie; fetched commit f778915 uses the same base, consistent.
- Docs conflict (not plan): Docker Hub says manual install PHP 7.4, README says PHP 8.0+.
