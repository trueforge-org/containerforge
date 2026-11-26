# genea-app/genea-app (application source)

Source URL(s) + fetch date:
- https://github.com/genea-app/genea-app (repo, referenced by draft and plan; root not fetched directly)
- https://raw.githubusercontent.com/genea-app/genea-app/master/README.md (2026-11-26, WebFetch summary)
- https://raw.githubusercontent.com/genea-app/genea-app/master/index.html (2026-11-26, WebFetch summary)
- https://raw.githubusercontent.com/genea-app/genea-app/master/LICENSE (2026-11-26)
- https://github.com/genea-app/genea-app/tags (2026-11-26): "There aren't any releases here." No tags.

What it is: Genea.app, a browser-based family tree editor. Reads and saves GEDCOM (5.5.5) files. No server-side components. Vue.js (v2), Graphviz compiled to WebAssembly (hpcc-js-wasm) draws the tree, Materialize CSS UI.

Install/build steps:
- README: "unpack the files into a directory and serve them over HTTPS". No build or npm step is documented. No file layout described.
- Repo has no Dockerfile.

Runtime deps: none server-side. Browser needs JS.

Files/asset layout (from index.html, all paths relative):
- Local scripts: `resources/vuejs/vue.js`, `resources/wasm/index.min.js` (exposes @hpcc-js/wasm), `js/tags.js`, `js/gedcom.js`, `js/stamboom.js`, `components/tree.js`, `components/personaldetails.js`, `components/relations.js`, `components/debug.js`, `modals/new-person.js`, `resources/materialize/js/materialize.min.js` (end of body).
- Local stylesheets: `resources/googlefonts/materialicons.css`, `resources/materialize/css/materialize.min.css`, `css/style.css`.
- Favicon: `favicon.ico`.
- Folders referenced: `resources/` (vuejs, wasm, googlefonts, materialize), `css/`, `js/`, `components/`, `modals/`, `img/` (`unknown.png`), `screenshots/` (`doe_family.mp4`, `doe_family.png`), `sample/` (`royal92.png`, `pres2020.png`, `harrypotter.png`, `empty.ged`, `gedcom1.ged`, `royal92.ged`, `pres2020.ged`, `harrypotter.ged`).

External network (runtime, browser side):
- `https://unpkg.com/@isomorphic-git/lightning-fs` (no version pinned)
- `https://unpkg.com/isomorphic-git@beta` (beta tag) and `https://unpkg.com/isomorphic-git@beta/http/web/index.js` (ES module import)
- Git CORS proxy default `https://cors.isomorphic-git.org` (only for Git save/load)

Versions: no explicit version numbers for Vue, Materialize or wasm libs. unpkg URLs are unversioned or use `beta`.

License: MIT, "Copyright (c) 2021 Genea.app" (LICENSE file). README itself does not state a license.

Gotchas:
- Contradicts plan.md section 10: Vue and Materialize are loaded locally, not from a CDN. Only isomorphic-git and lightning-fs come from unpkg.com (at runtime, for Git features).
- Contradicts plan.md section 4 step 2 partially: the publish list must include `resources/`, `modals/`, `img/` and `favicon.ico`, not just `index.html js css components`. Without `resources/` the Vue/wasm/Materialize assets are missing.
- Repo has no tags/releases; plan.md pins a commit SHA as the planned approach, which matches.
- Data is kept in the browser or in a user-chosen Git repo; the app makes no writes on the server.

Failed to fetch: none.
