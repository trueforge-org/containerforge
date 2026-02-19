# Sweep Status

- Timestamp (UTC): 2026-02-19T14:11:34Z
- Build: fail
- Forgetool test: skip
- Run status: not running
- Timeout for build/test: 120 seconds
- Forgetool path: /tmp/forgetool-bin/forgetool

## Last build log tail
```
#7 110.3 
#7 110.3 Paperclip is now compatible with aws-sdk-s3.
#7 110.3 
#7 110.3 If you are using S3 storage, aws-sdk-s3 requires you to make a few small
#7 110.3 changes:
#7 110.3 
#7 110.3 * You must set the `s3_region`
#7 110.3 * If you are explicitly setting permissions anywhere, such as in an initializer,
#7 110.3   note that the format of the permissions changed from using an underscore to
#7 110.3   using a hyphen. For example, `:public_read` needs to be changed to
#7 110.3   `public-read`.
#7 110.3 
#7 110.3 For a walkthrough of upgrading from 4 to *5* (not 6) and aws-sdk >= 2.0 you can watch
#7 110.3 http://rubythursday.com/episodes/ruby-snack-27-upgrade-paperclip-and-aws-sdk-in-prep-for-rails-5
#7 110.3 Post-install message from vite_ruby:
#7 110.3 Thanks for installing Vite Ruby!
#7 110.3 
#7 110.3 If you upgraded the gem manually, please run:
#7 110.3 	bundle exec vite upgrade
#7 110.3 5 installed gems you directly depend on are looking for funding.
#7 110.3   Run `bundle fund` for details
#7 111.2 
#7 111.2 changed 1 package in 668ms
#7 111.4 ! Corepack is about to download https://repo.yarnpkg.com/4.10.3/packages/yarnpkg-cli/bin/yarn.js
#7 112.2 ➤ YN0000: · Yarn 4.10.3
#7 112.2 ➤ YN0000: ┌ Resolution step
#7 112.4 ➤ YN0085: │ - @aashutoshrathi/word-wrap@npm:1.2.6, @adobe/css-tools@npm:4.3.3, @adobe/css-tools@npm:4.4.3, @ampproject/remapping@npm:2.3.0, and 591 more.
#7 112.4 ➤ YN0000: └ Completed
#7 112.4 ➤ YN0000: ┌ Post-resolution validation
#7 112.4 ➤ YN0060: │ react is listed by your project with version 18.3.1 (p68bdc1), which doesn't satisfy what emoji-mart-lazyload and other dependencies request (but they have non-overlapping ranges!).
#7 112.4 ➤ YN0002: │ @mastodon/mastodon@workspace:. doesn't provide postcss (pfe5f4d), requested by postcss-preset-env.
#7 112.4 ➤ YN0002: │ @mastodon/mastodon@workspace:. doesn't provide redux (p7bebfc), requested by react-redux-loading-bar and other dependencies.
#7 112.4 ➤ YN0002: │ @mastodon/mastodon@workspace:. doesn't provide rollup (p04c650), requested by @optimize-lodash/rollup-plugin and other dependencies.
#7 112.4 ➤ YN0002: │ @mastodon/mastodon@workspace:. doesn't provide stylelint (p6b534b), requested by @csstools/stylelint-formatter-github.
#7 112.4 ➤ YN0002: │ @mastodon/mastodon@workspace:. doesn't provide terser (pf7324a), requested by @vitejs/plugin-legacy and other dependencies.
#7 112.4 ➤ YN0086: │ Some peer dependencies are incorrectly met by your project; run yarn explain peer-requirements <hash> for details, where <hash> is the six-letter p-prefixed code.
#7 112.4 ➤ YN0000: └ Completed
#7 112.4 ➤ YN0000: ┌ Fetch step
#7 CANCELED
ERROR: failed to solve: Canceled: context canceled
```
