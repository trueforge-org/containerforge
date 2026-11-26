# thomseddon/traefik-forward-auth (application source, Dockerfile, releases)

**Source URL(s) + fetch date**
- https://github.com/thomseddon/traefik-forward-auth (repo root)
- https://raw.githubusercontent.com/thomseddon/traefik-forward-auth/83f06df/Dockerfile (fetched 2026-11-26)
- https://raw.githubusercontent.com/thomseddon/traefik-forward-auth/master/README.md (fetched 2026-11-26)
- https://raw.githubusercontent.com/thomseddon/traefik-forward-auth/v2.3.0/cmd/main.go (fetched 2026-11-26)
- https://raw.githubusercontent.com/thomseddon/traefik-forward-auth/v2.3.0/internal/config.go (fetched 2026-11-26)
- https://github.com/thomseddon/traefik-forward-auth/releases (fetched 2026-11-26)
- https://github.com/thomseddon/traefik-forward-auth/archive/refs/tags/v2.3.0.tar.gz: direct source archive, not fetched; recorded below.
- https://github.com/thomseddon/traefik-forward-auth/releases/download/v2.3.0/traefik-forward-auth_amd64: direct binary, not fetched; recorded below.

**What it is**
Forward-auth service for Traefik. It provides Google, OpenID Connect (OIDC) and generic OAuth2 login, and checks sessions for Traefik's `forwardAuth` middleware. Written in Go. Stateless beyond cookies. Module path `github.com/thomseddon/traefik-forward-auth`.

**Install/build steps and build deps (upstream Dockerfile at 83f06df)**
- Builder: `FROM golang:1.25-alpine as builder`, `apk add --no-cache git`, adds the source to `/go/src/github.com/thomseddon/traefik-forward-auth`.
- `CGO_ENABLED=0 GOOS=linux GOARCH=amd64 GO111MODULE=on go build -a -installsuffix nocgo -o /traefik-forward-auth github.com/thomseddon/traefik-forward-auth/cmd`. `GOARCH` is hard-coded to amd64 (so the arm64 image needs a change).
- Final: `FROM scratch`, copies `/etc/ssl/certs/ca-certificates.crt` and the binary, `ENTRYPOINT ["./traefik-forward-auth"]`.
- No ARG, ENV, EXPOSE, USER or CMD.

**Runtime deps**
None beyond the static binary. CA bundle is needed for HTTPS calls to providers.

**Binaries/entrypoint/CLI flags**
- Binary: `traefik-forward-auth` (main package at `cmd/main.go`, v2.3.0).
- `cmd/main.go`: `internal.NewGlobalConfig()`, `internal.NewDefaultLogger()`, `config.Validate()`, `internal.NewServer()`, one route `/` (`server.RootHandler`), then `http.ListenAndServe(fmt.Sprintf(":%d", config.Port), nil)`, logging `Listening on :<port>`.
- Flags (README table, each with an env name in upper case; precedence: flags, then env, then INI file):

| Flag | Env | Default | Meaning |
|---|---|---|---|
| `--log-level` | `LOG_LEVEL` | `warn` | trace/debug/info/warn/error/fatal/panic |
| `--log-format` | `LOG_FORMAT` | `text` | text/json/pretty |
| `--auth-host` | `AUTH_HOST` | none | single host for provider return; no protocol or path |
| `--config` | `CONFIG` | none | config file path; repeatable |
| `--cookie-domain` | `COOKIE_DOMAIN` | none | auth cookie domain; repeatable |
| `--insecure-cookie` | `INSECURE_COOKIE` | off | omits `Secure` attribute |
| `--cookie-name` | `COOKIE_NAME` | `_forward_auth` | auth cookie name |
| `--csrf-cookie-name` | `CSRF_COOKIE_NAME` | `_forward_auth_csrf` | CSRF cookie name |
| `--default-action` | `DEFAULT_ACTION` | `auth` | `auth` or `allow` when no rule matches |
| `--default-provider` | `DEFAULT_PROVIDER` | `google` | google, oidc or generic-oauth |
| `--domain` | `DOMAIN` | none | permitted email domains; repeatable |
| `--lifetime` | `LIFETIME` | `43200` | session seconds |
| `--logout-redirect` | `LOGOUT_REDIRECT` | none | redirect after logout |
| `--url-path` | `URL_PATH` | `/_oauth` | callback path |
| `--secret` | `SECRET` | none (required) | signs cookies; `openssl rand -hex 16` suggested |
| `--whitelist` | `WHITELIST` | none | permitted exact emails; repeatable |
| `--port` | `PORT` | `4181` | listen port |
| `--rule.<name>.<param>` | none | none | `action`, `rule`, `provider`, `domains`, `whitelist` |
| `match-whitelist-or-domain` | none listed | `false` | allow users matching either whitelist or domain |

- Legacy names read by `config.go`: `COOKIE_SECRET` (falls back to `SECRET`, logs a deprecation message), `CLIENT_ID`, `CLIENT_SECRET`, `PROMPT` (legacy Google).

**Env vars (providers, from README)**
- Google: `PROVIDERS_GOOGLE_CLIENT_ID`, `PROVIDERS_GOOGLE_CLIENT_SECRET`, `PROVIDERS_GOOGLE_PROMPT` (space-separated OpenID prompts).
- OIDC: `PROVIDERS_OIDC_ISSUER_URL`, `PROVIDERS_OIDC_CLIENT_ID`, `PROVIDERS_OIDC_CLIENT_SECRET`, `PROVIDERS_OIDC_RESOURCE` (optional).
- Generic OAuth2: `PROVIDERS_GENERIC_OAUTH_AUTH_URL`, `_TOKEN_URL`, `_USER_URL`, `_CLIENT_ID`, `_CLIENT_SECRET`, `_SCOPE` (default `profile, email`), `_TOKEN_STYLE` (`header` default, or `query`), `_RESOURCE` (optional).
- Lists use `env-delim:","` (go-flags).

**Ports**
4181/tcp (`PORT`). `ListenAndServe` binds all interfaces (`:4181`).

**Volumes/paths and persistent data**
None. The binary writes no files. Config file (INI) is read only if `CONFIG` is set. Example INI key: `url-path = _oauthpath`.

**User/UID & permissions**
No USER directive upstream (scratch image, runs as whatever user the runtime sets).

**Config files and formats**
INI (`--config`/`CONFIG`), read in order when repeated. Precedence: flags, env, file.

**Healthcheck/readiness endpoints**
None documented. README does not mention one. The only registered route is `/`. The logout endpoint is `<url-path>/logout` (`/_oauth/logout`) and only clears the cookie.

**Version/release info and asset naming**
- Latest tag `v2.3.0` (releases page shows "06 May", year not shown; plan.md says 2024-05-06). Earlier: v2.2.0 (29 Jun), v2.1.0 (10 Feb), v2.0.0 (10 Jun), v0.1.1 (10 Jun), 0.1.0 (29 Oct).
- v2.3.0 release shows "Assets 4". The asset list did not load, so names are unconfirmed. Plan.md names `traefik-forward-auth_amd64` and `traefik-forward-auth_arm`. Four assets is consistent with two binaries plus GitHub's auto source archives, but this is UNVERIFIED.
- README: "Standalone binaries are attached to GitHub releases after 2.2.0."
- Source archive pattern: `https://github.com/thomseddon/traefik-forward-auth/archive/refs/tags/v<version>.tar.gz` (plan.md; not fetched).

**Arch support**
Docker Hub README: ARM variant tags use the suffix `-arm` or `-arm64` (e.g. `2-arm`, `2.1-arm64`). Upstream Dockerfile hard-codes `GOARCH=amd64`. Asset `_arm` vs `_arm64` not confirmed (asset list failed).

**Licence**
MIT (per plan.md; `LICENSE.md` not fetched). UNVERIFIED here.

**Validation / startup behaviour (verified in `internal/config.go` v2.3.0)**
- `Validate()`: if `Secret` is empty, `log.Fatal("\"secret\" option must be set")`.
- `Validate()`: `setupProvider(DefaultProvider)` error goes to `log.Fatal(err)`. Errors come from `GetProvider` (`Unknown provider: %s`) or the provider's `Setup()`. The provider package was not fetched, so the exact missing-client-id message is UNVERIFIED.
- Each rule: `Validate` returns `invalid rule action, must be "auth" or "allow"` on a bad action; any error goes to `log.Fatal`.
- Empty env values: not handled explicitly in this file; parsed by go-flags. Whether go-flags skips empty env values is UNVERIFIED.

**Gotchas**
- `GOARCH=amd64` is hard-coded in the upstream Dockerfile, so an arm64 image needs a source change or an `ARG`.
- The `WHITELIST`/`DOMAIN` interplay: when both are set only `whitelist` applies unless `match-whitelist-or-domain` is enabled. The README table gives no env name for `match-whitelist-or-domain`.
- Redirect URI registered with the provider must be host plus `url-path` (e.g. `https://app.test.com/_oauth`), or just the auth host in auth-host mode.
- `INSECURE_COOKIE=true` is needed without HTTPS (README example says "not for production").
- Shared cookie domain across instances: use distinct `cookie-name` values or the same secret.
- An `allow` rule that matches the redirect URI can break login.

**plan.md consistency**
- Matches: Dockerfile content (`golang:1.25-alpine`, `GOARCH=amd64`, scratch final, ENTRYPOINT); port 4181; env names and defaults; `cmd` build path (`cmd/main.go` exists at v2.3.0); provider env names; `ListenAndServe(":<port>")`; no health endpoint in README; `SECRET` required; config precedence.
- Not verified: the `go 1.22` toolchain in go.mod, commit `26e7995`, MIT `LICENSE.md`, the `Setup()` behaviour of the Google provider, the release asset names and count.
- Not supported: plan.md's `MATCH_WHITELIST_OR_DOMAIN` env entry in settings.yaml. The README table lists no env name for `match-whitelist-or-domain` (noted as unverified in plan corrections).
