# Tandoor latest release
- https://api.github.com/repos/TandoorRecipes/recipes (repo metadata): HTTP 403 (failed, not retried)
- https://api.github.com/repos/TandoorRecipes/recipes/releases/latest: not called (skipped after repo API 403)
- Alternative used: `HEAD https://github.com/TandoorRecipes/recipes/releases/latest` -> Location https://github.com/TandoorRecipes/recipes/releases/tag/2.7.8
- Latest tag 2.7.8 (matches chart appVersion 2.7.8 and image tag 2.7.8)
- plan URL releases/tag/2.7.6 is older than latest 2.7.8 (not fetched; left unchanged)
