# TandoorRecipes/recipes Dockerfile at 89c07f2
Source URL: https://raw.githubusercontent.com/TandoorRecipes/recipes/89c07f26bb168221e41d409224976960cf344289/Dockerfile (fetched 2026-11-27)

## Base and packages
- `FROM python:3.14-alpine3.24`
- apk runtime: postgresql-libs postgresql-client gettext zlib libjpeg libwebp libxml2-dev libxslt-dev openldap git libgcc libstdc++ nginx tini envsubst nodejs npm
- ENV PYTHONUNBUFFERED=1, DOCKER=true
- EXPOSE 80 8080 (comment: 8080 used by gunicorn)

## Build steps
1. mkdir /opt/recipes; WORKDIR /opt/recipes
2. COPY requirements.txt; `sed -i '/# Development/,$d' requirements.txt` (drops dev deps)
3. build deps (.build-deps: gcc musl-dev postgresql-dev zlib-dev jpeg-dev libwebp-dev openssl-dev libffi-dev cargo openldap-dev python3-dev xmlsec-dev xmlsec build-base g++ curl rust) installed, then:
   - python -m venv venv (/opt/recipes/venv); pip upgrade
   - pip install wheel==0.48.0, setuptools_rust==1.13.0, -r requirements.txt --no-cache-dir
   - apk del .build-deps
4. COPY . ./
5. nginx: rm -rf /etc/nginx/http.d; ln -s /opt/recipes/http.d /etc/nginx/http.d; chmod 1777 /opt/recipes/http.d/ (sticky bit; boot.sh templates conf); symlink nginx access/error logs to /dev/stdout, /dev/stderr
6. HEALTHCHECK commented out (upstream issue 3478); would probe http://127.0.0.1:8080/openapi
7. `/opt/recipes/venv/bin/python version.py` (collects git info), then `find . -type d -name .git | xargs rm -rf`
8. chmod +x boot.sh
- ENTRYPOINT ["/sbin/tini", "--", "/opt/recipes/boot.sh"]

## Runtime
- No USER line: runs as root (chart sets runAsUser 0)
- Venv path /opt/recipes/venv; app dir /opt/recipes; media/static under /opt/recipes/{mediafiles,staticfiles} per chart

## Gotchas
- Python/pip venv is built during image build; requirements.txt is copied from repo root.
