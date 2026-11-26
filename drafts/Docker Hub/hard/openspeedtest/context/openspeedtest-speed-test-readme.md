# openspeedtest/Speed-Test README

Source URL(s): https://github.com/openspeedtest/Speed-Test (raw master README) · fetched 2026-11-26

- Vanilla JS HTML5 speed test (XHR, HTML, CSS, JS, SVG); no third-party libs; <8 kB gzipped.
- License: MIT (copyright 2013–2023 OpenSpeedTest).
- Client: browser, IE10+.
- Server: any web server handling HTTP/1.1+; serves static files. Needs GET/POST/HEAD/OPTIONS with 200; POST to static file returns 200; body limit >= 35 MB (also reverse proxies); timeout > 60 s; access logs off recommended.
- Multiple servers in index.html; client picks lowest latency.
- URL params: Run, Stress, Clean, XHR, Host, Test, Out, Ping.
- Packaging: NGINX preferred; Express compatible.
- Docker on Linux preferred; macOS/Windows development only.
