# guacamole/guacd (Docker Hub)

**Source URL(s) + fetch date**
- https://hub.docker.com/r/guacamole/guacd
- Fetched 2026-11-26

**What it is**
Native server-side proxy used by Apache Guacamole. Needs to run for Guacamole or any app built on the Guacamole core APIs. 50M+ pulls.

**Tags and size**
- Only `latest` listed. Digest `sha256:f56757d90...`, 125.9 MB. Updated about 9 hours before fetch.
- Chart pins `1.6.0@sha256:8974eaa9ba32f713daf311e7cc8cd7e4cdfba1edea39eed75524e78ef4b08f4f`.

**Architectures**
Not stated on the page.

**Source link**
https://github.com/apache/guacamole-server/ ; bugs in Apache JIRA (GUACAMOLE project).

**Run examples**
- `docker pull guacamole/guacd`
- Linked-only: `docker run --name some-guacd -d guacamole/guacd`
- Exposed: `docker run --name some-guacd -d -p 4822:4822 guacamole/guacd`
- App link: `docker run --name some-app --link some-guacd:guacd -d application-that-uses-guacd`

**Env vars, volumes**
None documented on the page.

**Ports and security**
4822. No authentication; the page warns to limit access to trusted applications.

**Contradictions with plan.md**
- None. plan.md section 10 warns about the lack of authentication; the page says the same.
