# glauth/glauth (Docker Hub)

**Source URL(s) + fetch date**
- https://hub.docker.com/r/glauth/glauth
- Fetched 2026-11-26

**What it is**
Lightweight LDAP authentication server (Go). Page lists 10M+ pulls.

**Tags listed**
- Only `latest` under recent tags (digest `sha256:075172abb...`, 24.3 MB). Last pushed 5 days before fetch.

**Architectures**
Not listed. Page says only linux 64-bit is tested in CI; other platforms are cross-compiled and provided as-is.

**Source link**
github.com/glauth/glauth (PRs target `dev`).

**Run examples**
No `docker run` example on the page. Binary examples: `./glauth64 -c sample-simple.cfg`, `glauth -c glauth.cfg`, `glauth -c s3://bucketname/glauth.cfg`. Testing example: `ldapsearch` against `ldap://localhost:3893`.

**Env vars**
`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` (S3 config).

**Volumes and ports**
None documented on the page. Port examples: LDAP 3893; `--ldap`, `--ldaps`, `--ldaps-cert`, `--ldaps-key` set listeners and TLS.

**Contradictions with plan.md**
- None. plan.md says env vars are not documented for the server; the page documents only the AWS variables for S3.
