# Context README: pretend-youre-xyzzy

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/pretend-youre-xyzzy/values.yaml | truecharts-pretend-youre-xyzzy.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/pretend-youre-xyzzy/Chart.yaml | truecharts-pretend-youre-xyzzy.md |
| https://hub.docker.com/v2/repositories/cyb3rjak3/dockeryourxyzzy/ | dockerhub-pretend-youre-xyzzy.md |
| https://hub.docker.com/v2/repositories/cyb3rjak3/dockeryourxyzzy/tags?page_size=10 | dockerhub-pretend-youre-xyzzy.md |
| https://raw.githubusercontent.com/Cyb3r-Jak3/DockerYourXyzzy/fade38c9e0b94c1294360a1f4697ab167dbd3d09/Dockerfile | github-pretend-youre-xyzzy.md |
| https://api.github.com/repos/ajanata/PretendYoureXyzzy/releases/latest | github-ajanata-pretend-youre-xyzzy.md (HTTP 404) |
| https://raw.githubusercontent.com/ajanata/PretendYoureXyzzy/master/README.md | github-ajanata-pretend-youre-xyzzy.md |

Skipped: CLA/none; forgetool schemas/none; containerforge apps links/none; templated URLs/none; binary downloads/none (Maven tarball, WAR); image refs/none; GitHub API repo pages for Cyb3r-Jak3 and ajanata (budget); GitHub HTML pages (budget).

Failures:
- https://api.github.com/repos/ajanata/PretendYoureXyzzy/releases/latest: HTTP 404 (expected, no releases). Recorded in github-ajanata-pretend-youre-xyzzy.md; no retry.

## plan.md corrections
- None. Verified: Cyb3r Dockerfile base `alpine-tomcat:11-jdk-10.1.17`, `MAVEN_VERSION=3.9.6`, prebuilt `jetty:11-jre11-slim`, `ZY.war`; upstream README build command; no releases (404); chart `on-demand-v2.1.1`, port 8080.
- Unverified conflict (not edited): upstream README says Tomcat 7 only; plan notes the conflict and keeps it open (section 10). Unchanged.
- Plan line 11 (renovate git-refs) and plan line 12 (BSD-2-Clause) not contradicted by fetched sources.
