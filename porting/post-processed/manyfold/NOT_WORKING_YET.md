# manyfold: porting status

This container remains in `/porting/post-processed` for now.

## Why it is not marked working in `/apps` yet
- Not yet migrated into `/apps`, so it is not covered by the normal app build/test workflow.
- No app-specific `container-test.yaml` exists yet for CI runtime verification after migration.

## Next step
- Finish app-specific runtime validation and add `apps/<app>/container-test.yaml` before moving this container into `/apps`.

## AMD64 build check (2026-02-16)
- Command: `docker buildx bake --set image-local.platform=linux/amd64 image-local`
- Result: FAIL
- Reason: failed to solve: process "/bin/bash -o pipefail -c apt-get update &&     apt-get install -y --no-install-recommends         libassimp-dev         file         imagemagick         libheif-dev         libjpeg-dev         libwebp-dev         libjemalloc-dev         libarchive-dev         libmariadb3         pciutils         postgresql-client         ruby         bundler &&     apt-get install -y --no-install-recommends --no-install-suggests         build-essential         libffi-dev         libmariadb-dev         libpq-dev         ruby-dev         libyaml-dev &&     echo \"**** install manyfold ****\" &&     mkdir -p /app/www &&     curl -sX GET \"https://api.github.com/repos/manyfold3d/manyfold/git/matching-refs/tags/v${VERSION}\"         | jq -r '.[].object.sha' > /app/www/GIT_SHA &&     curl -s -o         /tmp/manyfold.tar.gz -L         \"https://github.com/manyfold3d/manyfold/archive/v${VERSION}.tar.gz\" &&     tar xf         /tmp/manyfold.tar.gz -C         /app/www/ --strip-components=1 &&     cd /app/www &&     npm install -g corepack &&     corepack enable &&     yarn install &&     gem install foreman &&     RUBY=$(apt-get list ruby | grep -oP '.*-\\K(\\d\\.\\d\\.\\d)') &&     sed -i \"s/\\d.\\d.\\d/${RUBY}/\" .ruby-version &&     bundle config set --local deployment 'true' &&     bundle config set --local without 'development test' &&     bundle config force_ruby_platform true &&     bundle install &&     touch db/schema.rb &&     DATABASE_URL=\"nulldb://user:pass@localhost/db\"     SECRET_KEY_BASE=\"placeholder\"     APP_VERSION=v${VERSION}     bundle exec rake assets:precompile &&     rm db/schema.rb &&     echo \"**** cleanup ****\" &&     yarn cache clean &&     apt-get purge -y --auto-remove         build-essential         libffi-dev         libmariadb-dev         libpq-dev         ruby-dev         libyaml-dev &&     apt-get clean &&     rm -rf         /var/lib/apt/lists/*         $HOME/.bundle/cache         $HOME/.cache         $HOME/.npm         $HOME/.yarn         /app/www/node_modules/         /app/www/tmp/cache/         /app/www/vendor/bundle/ruby/3.3.0/cache/*         /tmp/*" did not complete successfully: exit code: 5
