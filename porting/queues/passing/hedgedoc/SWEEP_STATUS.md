# Sweep Status

- Timestamp (UTC): 2026-02-19T13:12:10Z
- Build: fail
- Forgetool test: skip
- Run status: not running
- Timeout for build/test: 120 seconds

## Last build log tail
```
#7 100.1         [1] ./node_modules/css-loader/dist/cjs.js!./public/css/slide-preview.css 2.72 KiB {0} [built]
#7 100.9 ➤ YN0000: · Yarn 4.9.0
#7 100.9 ➤ YN0000: ┌ Resolution step
#7 101.0 ➤ YN0085: │ - @babel/code-frame@npm:7.26.2, @babel/helper-validator-identifier@npm:7.25.9, @braintree/sanitize-url@npm:6.0.4, @discoveryjs/json-ext@npm:0.5.7, and 1060 more.
#7 101.0 ➤ YN0000: └ Completed
#7 101.0 ➤ YN0000: ┌ Post-resolution validation
#7 101.0 ➤ YN0060: │ sequelize is listed by your project with version 5.22.5 (p8bdd7), which doesn't satisfy what connect-session-sequelize requests (>=6.1.0).
#7 101.0 ➤ YN0002: │ HedgeDoc@workspace:. doesn't provide webpack (p19746), requested by clean-webpack-plugin.
#7 101.0 ➤ YN0086: │ Some peer dependencies are incorrectly met by your project; run yarn explain peer-requirements <hash> for details, where <hash> is the six-letter p-prefixed code.
#7 101.0 ➤ YN0000: └ Completed
#7 101.0 ➤ YN0000: ┌ Fetch step
#7 101.2 ➤ YN0000: └ Completed
#7 101.2 ➤ YN0000: ┌ Link step
#7 104.8 ➤ YN0008: │ bufferutil@npm:4.0.9 must be rebuilt because its dependency tree changed
#7 104.8 ➤ YN0008: │ sqlite3@npm:5.1.7 [77177] must be rebuilt because its dependency tree changed
#7 104.8 ➤ YN0008: │ utf-8-validate@npm:6.0.5 must be rebuilt because its dependency tree changed
#7 105.0 ➤ YN0000: └ Completed in 3s 747ms
#7 105.0 ➤ YN0000: · Done with warnings in 4s 88ms
#7 105.0 **** cleanup ****
#7 105.5 ➤ YN0000: Done in 0s 80ms
#7 105.5 Reading package lists...
#7 106.3 Building dependency tree...
#7 106.4 Reading state information...
#7 106.6 0 upgraded, 0 newly installed, 0 to remove and 2 not upgraded.
#7 DONE 106.9s

#8 [3/5] COPY . /
#8 DONE 0.2s

#9 [4/5] COPY ./root /
#9 DONE 0.0s

#10 [5/5] WORKDIR /config
#10 DONE 0.1s

#11 exporting to image
#11 exporting layers
#11 exporting layers 12.2s done
#11 CANCELED
ERROR: failed to solve: Canceled: context canceled
```
