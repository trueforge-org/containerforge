# Context index: archivebox

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/archivebox/values.yaml + Chart.yaml | truecharts-archivebox.md |
| https://raw.githubusercontent.com/ArchiveBox/ArchiveBox/289d6a5904642b02c618e77f225aa28bd201a145/Dockerfile (+ release redirect https://github.com/ArchiveBox/ArchiveBox/releases/latest) | github-archivebox-dockerfile.md |
| https://pypi.org/pypi/archivebox/json | pypi-archivebox.md |

Skipped categories: api.github.com repo metadata (same rate limit, not needed), blob Dockerfile URL (same as raw), github repo/wiki pages (not needed for build), templated wheel URL `files.pythonhosted.org/.../archivebox-0.9.77-py3-none-any.whl`, archivebox.io homepage (marketing), Docker Hub (image is GHCR, no Docker Hub URL listed).

Failures:
- https://api.github.com/repos/ArchiveBox/ArchiveBox/releases/latest: 403 (rate limit). Alternative used: HTML releases/latest redirect (v0.9.77).
- https://docs.archivebox.io: fetched, only table of contents and "Docker / Docker Compose" headings, no config content. Not summarised.

## plan.md corrections
- None. Plan's version 0.9.77 and tag agree with the release redirect and PyPI.
