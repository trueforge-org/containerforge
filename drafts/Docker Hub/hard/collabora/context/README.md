# collabora: source context (fetched 2026-11-26)

## Sources fetched

| Source URL | Summary file |
| --- | --- |
| https://www.collaboraonline.com/code/ | collaboraonline-code-page.md |
| https://collaboraonline.com | collaboraonline-code-page.md |
| https://www.collaboraonline.com/code/docker/ (via 301 redirects from https://www.collaboraoffice.com/code/docker/) | collaboraonline-code-docker.md |
| https://hub.docker.com/r/collabora/code | collabora-hub-code.md |
| https://github.com/CollaboraOnline/online (via raw README) | github-collaboraonline-online.md |
| https://raw.githubusercontent.com/CollaboraOnline/Docker-CODE/master/Dockerfile (plan.md reference) | github-collaboraonline-docker-code.md |
| https://raw.githubusercontent.com/CollaboraOnline/Docker-CODE/master/scripts/start-collabora-online.sh (plan.md reference) | github-collaboraonline-docker-code.md |
| https://www.collaboraoffice.com/repos/CollaboraOnline/CODE-deb/Packages (plan.md apt repo) | cdn-collabora-deb-repo.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/collabora (values.yaml) | truecharts-collabora.md |

## Skipped URLs

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA link (never fetched) |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge base app link |
| http://127.0.0.1:9980/hosting/discovery | localhost-type URL (test endpoint, not a source) |
| https://collaboraoffice.com/downloads/gpg/collaboraonline-release-keyring.gpg | binary keyring download |
| https://example.com:443, https://cloud.example.com:443 | example placeholders from plan.md, not sources |
| https://www.collaboraoffice.com/repos/CollaboraOnline/CODE-deb | apt repo root (listing); its Packages index was fetched instead |

## Fetch failures

- https://www.collaboraoffice.com/code/docker/: 301 redirect chain; final page fetched (see above).
- SDK docs (sdk.collaboraonline.com, CODE_Docker_image.html and the admin/config pages): plan.md says behind a bot challenge; not re-attempted here (the Docker page links to them).
- `coolwsd` stanza of the apt Packages index: beyond the first 100 000 characters of a 4.4 MB page; version, Depends and SHA256 not read.
- Seccomp profile in the online repo: no URL in the draft; not fetched.

## plan.md corrections

- Section 1 Upstream Dockerfile (legacy script): plan says the legacy script rewrites `coolwsd.xml` and starts `coolwsd --version ...`. The legacy script rewrites `/etc/loolwsd/loolwsd.xml` and runs `/usr/bin/loolwsd --version --o:sys_template_path=/opt/lool/systemplate --o:child_root_path=/opt/lool/child-roots --o:file_server_root_path=/usr/share/loolwsd --o:user_interface.mode=notebookbar ${extra_params}`. Source: github-collaboraonline-docker-code.md.
- Section 10 (CODE cap): "CODE is capped at roughly 20 connections / 10 documents" -> marked UNVERIFIED and added the "not recommended for production" note from Collabora. Source: collaboraonline-code-page.md.

## Checked, no change needed

- Section 1 Version (`26.04.6.2.1`): matches the chart pin (truecharts-collabora.md).
- Section 1 Port `9980` and `/hosting/discovery`: confirmed by the Seafile example (collaboraonline-code-page.md).
- Section 1 Packages: `code-brand` 26.04.6-2 confirmed, with `Depends: coolwsd (>= 1.6.10)` (cdn-collabora-deb-repo.md).

## Unverified (plan.md left as-is)

- `coolwsd` apt version (plan 26.04.6.2-1), Depends list (plan), SHA256: not read (see fetch failures). `code-brand` 26.04.6-2 confirmed (its `Depends: coolwsd (>= 1.6.10)`).
- Env var names: plan section 1 lists `aliasgroup1`, `aliasgroupN`, `extra_params`, `username`, `password`, `dictionaries`, `server_name`, `DONT_GEN_SSL_CERT`, `cert_domain`. The chart uses `aliasgroup1`, `username`, `password`, `dictionaries`, `server_name`, `extra_params`, `ssl_enable`, `ssl_termination`, `no_gen_ssl`, `interface`. The legacy script reads `DONT_GEN_SSL_CERT`, `cert_domain`, `domain`, `username`, `password`, `server_name`, `dictionaries`, `extra_params`. Whether the current image reads `no_gen_ssl` or `DONT_GEN_SSL_CERT` is unknown.
- Rootless/capability mode: no page fetched mentions unprivileged or rootless running (collaboraonline Docker page: none). The `security.capabilities=false` and seccomp notes remain unverified.
- `coolwsd-systemplate-setup` path and `--disable-cool-user-checking`, `--use-env-vars` flags: not in any fetched source.

## Notes (not edited)

- Collabora describes CODE as **not recommended for production** (collaboraonline-code-page.md). plan.md does not state this; the PR should say so.
- Licence of CODE is not stated on the pages fetched. The plan's `MPL-2.0` remains UNVERIFIED for this page (the COPYING check was not done).
- The plan's "capped at roughly 20 connections / 10 documents" is not supported by any fetched source (UNVERIFIED).
- Chart comment and plan: `aliasgroup1` is required for real WOPI hosts; no source disputes this.
