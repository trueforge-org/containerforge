# Context: shorturl

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/shorturl/values.yaml + Chart.yaml | truecharts-shorturl.md |
| https://raw.githubusercontent.com/nicholaswilde/docker-shorturl/9362206/Dockerfile (+ blob variant) | nicholaswilde-docker-shorturl-dockerfile.md |
| https://git.mills.io/prologic/shorturl (HTML repo page) | prologic-shorturl-repo.md |

Skipped (not fetched): Docker Hub (image on GHCR); github.com/nicholaswilde/docker-shorturl HTML (raw Dockerfile used); prologic/shorturl tarball archive URL (checksum not on a fetched page); CLA; forgetool schemas; containerforge app links; image refs.

Failures:
- https://github.com/prologic/shorturl: 404 (matches plan line 9). The canonical repo HTML on git.mills.io was used instead.

## plan.md corrections
- None applied.
- Confirmed by fetch: GitHub path 404 (plan line 9). git.mills.io repo page loads over plain HTTP GET (plan line 17 says raw URLs get a proof-of-work page; the HTML repo page did not).
- Unverified (not edited): plan line 8 "marked Latest" for v0.1.0 is not confirmed by the fetched page, which shows v0.1.0 and 2017-09-02 timestamps only.
- Add (not an edit): the git.mills.io page documents the default DB path (`db` under the working directory) and `-dbpath` flag, relevant to plan lines 18 and 86 (plan leaves the flag UNVERIFIED).
