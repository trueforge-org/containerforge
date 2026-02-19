# Sweep Status

- Timestamp (UTC): 2026-02-19T23:40:27Z
- Build: fail
- Forgetool test: skip
- Run status: not running
- Timeout for build/test: 120 seconds
- Forgetool path: /tmp/forgetool-bin/forgetool

## Last build log tail
```
#8 0.522 [1/4] Resolving packages...
#8 1.073 [2/4] Fetching packages...
#8 ...

#9 [buildserver 1/1] RUN   echo "*** install your_spotify server ***" &&   cd /app/www &&   rm -rf /app/www/apps/client &&   yarnpkg --frozen-lockfile &&   cd /app/www/apps/server &&   yarnpkg build &&   rm -rf /app/www/node_modules &&   yarnpkg cache clean
#9 0.183 *** install your_spotify server ***
#9 0.502 yarn install v1.22.22
#9 0.629 [1/4] Resolving packages...
#9 0.857 [2/4] Fetching packages...
#9 13.29 [3/4] Linking dependencies...
#9 13.29 warning "workspace-aggregator-3b0a5256-068d-4daf-b30e-bef1c281c9dc > @your_spotify/dev > ts-node@10.9.2" has unmet peer dependency "@types/node@*".
#9 16.38 [4/4] Building fresh packages...
#9 16.49 Done in 15.99s.
#9 16.72 yarn run v1.22.22
#9 16.78 $ tsc && cp -r src/public lib/
#9 22.70 Done in 5.98s.
#9 23.54 yarn cache v1.22.22
#9 24.94 success Cleared cache.
#9 24.94 Done in 1.41s.
#9 DONE 25.4s

#8 [buildclient 1/1] RUN   echo "*** install your_spotify client ***" &&   cd /app/www &&   rm -rf /app/www/apps/server &&   yarnpkg --frozen-lockfile &&   cd /app/www/apps/client &&   yarnpkg build &&   rm -rf /app/www/node_modules &&   yarnpkg cache clean
#8 44.57 [3/4] Linking dependencies...
#8 44.57 warning "workspace-aggregator-6fb94165-142c-46a7-9d29-65c449605d2f > @your_spotify/client > react-copy-to-clipboard@5.1.0" has incorrect peer dependency "react@^15.3.0 || 16 || 17 || 18".
#8 44.57 warning "workspace-aggregator-6fb94165-142c-46a7-9d29-65c449605d2f > @your_spotify/client > @types/react-dom@19.1.2" has unmet peer dependency "@types/react@^19.0.0".
#8 44.57 warning "workspace-aggregator-6fb94165-142c-46a7-9d29-65c449605d2f > @your_spotify/dev > ts-node@10.9.2" has unmet peer dependency "@types/node@*".
#8 44.57 warning "workspace-aggregator-6fb94165-142c-46a7-9d29-65c449605d2f > @your_spotify/client > @mui/material > @types/react-transition-group@4.4.12" has unmet peer dependency "@types/react@*".
#8 44.57 warning "workspace-aggregator-6fb94165-142c-46a7-9d29-65c449605d2f > @your_spotify/client > react-scripts > eslint-config-react-app > eslint-plugin-flowtype@8.0.3" has unmet peer dependency "@babel/plugin-syntax-flow@^7.14.5".
#8 44.57 warning "workspace-aggregator-6fb94165-142c-46a7-9d29-65c449605d2f > @your_spotify/client > react-scripts > eslint-config-react-app > eslint-plugin-flowtype@8.0.3" has unmet peer dependency "@babel/plugin-transform-react-jsx@^7.14.9".
#8 44.58 warning "workspace-aggregator-6fb94165-142c-46a7-9d29-65c449605d2f > @your_spotify/client > react-scripts > react-dev-utils > fork-ts-checker-webpack-plugin@6.5.3" has unmet peer dependency "typescript@>= 2.7".
#8 44.58 warning "workspace-aggregator-6fb94165-142c-46a7-9d29-65c449605d2f > @your_spotify/client > react-scripts > eslint-config-react-app > @typescript-eslint/eslint-plugin > tsutils@3.21.0" has unmet peer dependency "typescript@>=2.8.0 || >= 3.2.0-dev || >= 3.3.0-dev || >= 3.4.0-dev || >= 3.5.0-dev || >= 3.6.0-dev || >= 3.6.0-beta || >= 3.7.0-dev || >= 3.7.0-beta".
#8 63.18 [4/4] Building fresh packages...
#8 64.19 Done in 63.78s.
#8 64.37 yarn run v1.22.22
#8 64.40 $ DISABLE_ESLINT_PLUGIN=true react-scripts build
#8 65.49 Creating an optimized production build...
#8 65.62 Browserslist: browsers data (caniuse-lite) is 10 months old. Please run:
#8 65.62   npx update-browserslist-db@latest
#8 65.62   Why you should do it regularly: https://github.com/browserslist/update-db#readme
ERROR: failed to solve: Canceled: context canceled
```
