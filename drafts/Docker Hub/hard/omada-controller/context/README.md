# omada-controller context

| Source URL | File |
| --- | --- |
| https://github.com/mbentley/docker-omada-controller (raw README) | mbentley-omada-controller-readme.md |
| https://github.com/mbentley/docker-omada-controller/blob/master/Dockerfile | mbentley-omada-controller-dockerfile.md |
| https://omada-controller-url.mbentley.net/hooks/omada_ver_to_url?omada-ver=6.3.0.111 | mbentley-omada-version-resolver.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/omada-controller (values.yaml) | truecharts-omada-controller-values.md |
| https://hub.docker.com/r/mbentley/omada-controller | dockerhub-mbentley-omada-controller.md |
| https://www.omadanetworks.com | omadanetworks-home.md |
| https://www.omadanetworks.com/en/support | omadanetworks-support.md |
| https://www.tp-link.com/en/omada-sdn (redirect followed) | omada-sdn-product-page.md |
| https://www.tp-link.com/en/support/download/omada-software-controller (redirect followed) | support-omadanetworks-software-controller.md |

Skipped: none (all urls.txt entries in scope; the two TP-Link URLs were followed through their redirects, one request each).

Failures: none.

## plan.md corrections
- None made. Conflict (not edited): plan says "tags 6/6.3 = 6.3.0.111" (line 8), but the mbentley README lists 6.3 as 6.3.0.112 and the Dockerfile default INSTALL_VER is 6.3.0.112. TP-Link listing shows v6.3.0.112 (.tar.gz and .deb) dated 2026-11-25. The plan's VERSION, OMADA_URL and SHA256 are all for 6.3.0.111, so they were left unchanged; a bump needs a new resolver URL and sha256 (not fetched).
- Plan's Java 17 and MongoDB 8.0 claims not checkable from fetched sources (install.sh not fetched).
