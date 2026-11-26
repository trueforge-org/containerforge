# browserless/chrome README (master)

Source: https://raw.githubusercontent.com/browserless/chrome/master/README.md (repo https://github.com/browserless/chrome), fetched 2026-11-26

- Current master README: product is "browserless" (ghcr.io/browserless/chromium), not the old browserless/chrome image.
- Run: `docker run -p 3000:3000 ghcr.io/browserless/chromium`; endpoint ws://localhost:3000; interactive debugger at http://localhost:3000/.
- Other images: ghcr.io/browserless/firefox, ghcr.io/browserless/multi (Firefox/WebKit).
- ARM64 supported (Edge amd64 only).
- Token: `?token=YOUR_TOKEN` on API calls (BQL endpoint example).
- License line: SPDX-License-Identifier: SSPL-1.0 OR Browserless Commercial License. Commercial use in closed-source or CI needs a commercial license.
