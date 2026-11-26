# TrueCharts chart: gokapi

**Source URL(s) + fetch date**
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/gokapi/values.yaml
- Fetched 2026-11-26 (chart directory listing not fetched in this run)

**What it is**
TrueCharts chart `gokapi` (main image `f0rc3/gokapi`).

**Container image (values.yaml)**
- repository: `docker.io/f0rc3/gokapi`
- tag: `v2.2.4@sha256:43cd93b9e1f02d760923f67f6e74e1c4d4a9cccb9b08fa42ad60770333f231eb`
- pullPolicy: `IfNotPresent`

**Security**
- No securityContext in the fetched content (chart defaults apply; not visible here).

**Service ports**
- Service `main`, port `main`: `53842`, protocol `http`.

**Persistence**
- `config` at `/app/config`, `data` at `/app/data` (both enabled).

**Env (main container)**
- `GOKAPI_LENGTH_ID`: `15`
- `GOKAPI_MAX_FILESIZE`: `102400`
- `GOKAPI_MAX_MEMORY_UPLOAD`: `20`
- `GOKAPI_USERNAME`: `admin`
- `GOKAPI_PASSWORD`: from secret `env-secrets`, key `GOKAPI_PASSWORD` (value not recorded here).

**Contradictions with plan.md**
- plan.md section 9 says the chart's two PVCs (`/app/config`, `/app/data`) collapse into one `/config` volume. Matches the chart's mount paths.
- plan.md section 1 lists the GOKAPI_* names; `GOKAPI_USERNAME` and `GOKAPI_PASSWORD` in the chart are not in Environment.go at v2.2.4. Whether the chart's admin credentials take effect is unverified; plan.md's first-run plan (web setup) is not affected by this, but the PR should note it.
- `GOKAPI_MAX_MEMORY_UPLOAD` is `20` in the chart and `50` in plan.md's default. Chart value, not a plan error.
