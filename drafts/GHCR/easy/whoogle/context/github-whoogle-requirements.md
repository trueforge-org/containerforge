# Upstream requirements: benbusby/whoogle-search @ v1.2.4 (requirements.txt)

Source URL(s) + date: https://raw.githubusercontent.com/benbusby/whoogle-search/v1.2.4/requirements.txt (fetched 2026-11-27)

## Pins (all ==, except where noted)
- Flask==3.1.3, Werkzeug==3.1.6, Jinja2==3.1.6, MarkupSafe==3.0.2, itsdangerous==2.2.0, click==8.3.0
- beautifulsoup4==4.13.5, soupsieve==2.8, cssutils==2.11.1, defusedxml==0.7.1
- cryptography==46.0.7, pyOpenSSL==26.0.0, cffi==2.0.0, pycparser==2.22
- httpx[http2,socks]==0.28.1; httpcore>=1.0.9; h11>=0.16.0
- stem==1.8.2 (Tor control), validators==0.35.0, waitress==3.0.2, python-dotenv==1.1.1
- brotli==1.2.0, cachetools==6.2.0, certifi==2025.8.3, idna==3.10, attrs==25.3.0, packaging==25.0, pluggy==1.6.0, pyparsing==3.2.5, python-dateutil==2.9.0.post0, more-itertools==10.8.0, wcwidth==0.2.14
- Test/dev pins included: pytest==9.0.3, pycodestyle==2.14.0

## Gotchas
- cryptography and pyOpenSSL pinned to modern versions; ARMv7 needs alternate pins (see Dockerfile comment).
- Builder stage needs build-base and -dev headers for compiled wheels.
