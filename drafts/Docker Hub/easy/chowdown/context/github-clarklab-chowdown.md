# clarklab/chowdown (upstream source)

Source URL(s) + fetch date:
- https://github.com/clarklab/chowdown (fetched 2026-11-26)
- https://raw.githubusercontent.com/clarklab/chowdown/gh-pages/README.md (404, see README.md)
- https://github.com/clarklab/chowdown/blob/gh-pages/README.md (404)

## What it is
"Simple recipes in Markdown format", described as "A simple, plaintext recipe database for hackers". Site: https://chowdown.io. Default branch is `gh-pages`; the repo has no releases and no tags.

## Install/build steps and build deps
- The project is a Jekyll build. Per README: `gem install bundler jekyll`, then clone/download and run `jekyll serve` (local view at http://127.0.0.1:4000/).
- Stock Jekyll is enough: no Gemfile/plugins were found in the repo root (see plan.md section 1).

## Runtime deps
- Ruby + Jekyll (for the build/serve step). Output is static HTML once built.

## Config files and formats
- `_config.yml` (Jekyll config, see plan.md for partial read), `_layouts`, `_includes`, `_components`, `_recipes`.
- Recipes are Markdown files in `_recipes` with frontmatter: title, image, layout "recipe", ingredients, directions. Component recipes combine smaller recipes from `_components`.

## Version/release info and asset naming
- No releases, no tags. Branch `gh-pages` (226 commits on that branch per the repo page).
- Archive URLs (direct downloads, not fetched):
  - `https://github.com/clarklab/chowdown/archive/refs/heads/gh-pages.zip` (moving branch zip; the archive extracts to `chowdown-gh-pages/`)
  - `https://github.com/clarklab/chowdown/archive/<sha>.tar.gz` (commit-pinned pattern, used by the plan)

## License
Unlicense (LICENSE file in repo root).

## Gotchas
- The README describes `jekyll serve`, i.e. the source is NOT a pre-built static site. Serving the zip contents with nginx as-is would not produce HTML. Contradicts draft.md ("static site with no runtime code, served by nginx") and agrees with plan.md's correction.
- Repo page: gh-pages is the default branch.
