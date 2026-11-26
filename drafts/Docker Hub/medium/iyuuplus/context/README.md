# Context: iyuuplus

| Source URL | File |
| --- | --- |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/iyuuplus | truecharts-iyuuplus.md |
| https://hub.docker.com/r/iyuucn/iyuuplus | dockerhub-iyuuplus.md |
| https://github.com/ledccn/iyuuplus-dev | github-ledccn-iyuuplus-repo.md |
| https://github.com/ledccn/iyuuplus-dev/blob/HEAD/docker/Dockerfile | github-ledccn-iyuuplus-dockerfile.md |
| https://raw.githubusercontent.com/ledccn/iyuuplus-dev/HEAD/docker/Dockerfile | github-ledccn-iyuuplus-dockerfile.md (same file) |
| https://raw.githubusercontent.com/ledccn/iyuuplus-dev/HEAD/LICENSE | github-ledccn-iyuuplus-license.md |
| http://doc.iyuu.cn | iyuu-doc-site.md |
| https://www.iyuu.cn | iyuu-website.md (no usable content) |
| (follow-up: docker/rootfs nginx.conf) | github-ledccn-iyuuplus-nginx.md |
| (follow-up: s6 init-config/run) | github-ledccn-iyuuplus-init-config.md |
| (follow-up: s6 svc-iyuu/run) | github-ledccn-iyuuplus-svc-iyuu.md |

Skipped: none.
Failures: none hard; https://www.iyuu.cn returned no parseable content (recorded).

## plan.md corrections
- plan.md line 15 (Port row): "The draft's `8787` is inferred and conflicts with upstream" -> nginx listens 8780 and proxies to 127.0.0.1:8787 (internal PHP app); 8787 is not a conflict. Source: https://raw.githubusercontent.com/ledccn/iyuuplus-dev/HEAD/docker/rootfs/etc/nginx/nginx.conf (github-ledccn-iyuuplus-nginx.md).
- Unverified: none checked against plan beyond the port row.
