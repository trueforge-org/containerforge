#!/usr/bin/env bash

# an empty LIBREDDIT_* variable counts as unset so the app's own default applies
# UNVERIFIED: whether libreddit fails on empty values; keep the guard unless the README says otherwise
for var in $(env | grep -o '^LIBREDDIT_[A-Za-z0-9_]*'); do
  if [ -z "${!var}" ]; then
    unset "${var}"
  fi
done

cd /app/libreddit || exit 1
exec /app/libreddit/libreddit
