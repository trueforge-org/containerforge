# Context: neko

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/neko/values.yaml + Chart.yaml | truecharts-neko.md |
| https://raw.githubusercontent.com/m1k1o/neko/92420ca8.../apps/firefox/Dockerfile | neko-firefox-dockerfile.md |
| https://raw.githubusercontent.com/m1k1o/neko/92420ca8.../apps/chromium/Dockerfile | neko-chromium-dockerfile.md |
| apps/{brave,google-chrome,microsoft-edge,remmina,tor-browser,vivaldi,vlc,xfce}/Dockerfile (commit 92420ca8) | neko-other-app-dockerfiles.md |
| https://api.github.com/repos/m1k1o/neko/releases/latest (403) -> https://github.com/m1k1o/neko/releases/latest | neko-release-latest.md |
| https://raw.githubusercontent.com/m1k1o/neko/92420ca8.../README.md | neko-readme.md |
| https://neko.m1k1o.net (site, homepage links only) and /docs/v3/quick-start + master docker-compose.yaml | neko-docs-v3-quickstart.md |
| https://aus1.torproject.org/.../download-linux-x86_64.json | summarized inside neko-other-app-dockerfiles.md (tor-browser row); JSON not parsed further |

Skipped (not build sources or binary/marketing): https://code.videolan.org/videolan/vlc, https://github.com/FreeRDP/Remmina, https://github.com/brave/brave-browser, https://github.com/m1k1o/neko (repo root), https://github.com/m1k1o/neko/releases (covered by releases/latest), https://github.com/mozilla-firefox/firefox, https://gitlab.torproject.org/..., https://gitlab.xfce.org/xfce, https://dist.torproject.org/... tarball (binary), https://ftp.mozilla.org/... tarballs (binary), https://download.mozilla.org/... (redirect), https://packages.microsoft.com/... (.deb), https://vivaldi.com, https://www.chromium.org, https://www.google.com/chrome, https://www.microsoft.com/edge (marketing pages). No Docker Hub source (GHCR images).

Failures:
- https://api.github.com/repos/m1k1o/neko/releases/latest: HTTP 403; one alternative (github.com releases/latest) used.

## plan.md corrections
- No edit made. UNVERIFIED conflict: plan.md ports line (8080 and 52000-52100/udp "draft inferences") is consistent with master docker-compose.yaml (8080, 52000-52100/udp) but the chart uses 10294 (http) and mux 52100. Env var names in the chart (NEKO_BIND, NEKO_SCREEN, NEKO_PASSWORD, NEKO_TCPMUX) differ from master compose (NEKO_DESKTOP_SCREEN, NEKO_WEBRTC_EPR, NEKO_MEMBER_MULTIUSER_*). Not resolvable from fetched sources for tag v3.2.0.
