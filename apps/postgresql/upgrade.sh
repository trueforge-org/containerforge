#!/usr/bin/env bash
set -euo pipefail

get_bin_path() {
  local version=$1
  echo "/usr/lib/postgresql/$version/bin"
}

OLD_VERSION=${UPGRADE_REQ}
TARGET_VERSION=${PG_MAJOR}
echo "Current version: $OLD_VERSION"
echo "Target version: $TARGET_VERSION"

if [ "$OLD_VERSION" -lt $((TARGET_VERSION - 1)) ]; then
    echo "Upgrade spans more than one major version! Need intermediate upgrades."
    exit 1
else
    echo "Safe to upgrade in one step."
fi

export OLD_PG_BINARY=$(get_bin_path "$OLD_VERSION")
export NEW_PG_BINARY=$(get_bin_path "$TARGET_VERSION")

OLD_PGDATA=${PGDATA_PARENT}/${OLD_VERSION}
NEW_PGDATA=${PGDATA}

echo "Using new pg_upgrade [$NEW_PG_BINARY/pg_upgrade]"

echo "Checking upgrade compatibility of $OLD_VERSION to $TARGET_VERSION..."
"$NEW_PG_BINARY"/pg_upgrade \
  --old-bindir="$OLD_PG_BINARY" \
  --new-bindir="$NEW_PG_BINARY" \
  --old-datadir="$OLD_PGDATA" \
  --new-datadir="$NEW_PGDATA" \
  --socketdir /var/run/postgresql \
  --check

echo "Compatibility check passed."
echo "Upgrading from $OLD_VERSION to $TARGET_VERSION using --link..."
"$NEW_PG_BINARY"/pg_upgrade \
  --old-bindir="$OLD_PG_BINARY" \
  --new-bindir="$NEW_PG_BINARY" \
  --old-datadir="$OLD_PGDATA" \
  --new-datadir="$NEW_PGDATA" \
  --socketdir /var/run/postgresql \
  --link

echo "Upgrade complete."
echo "Copying old pg_hba.conf to new pg_hba.conf"
cp -f "$OLD_PGDATA/pg_hba.conf" "$NEW_PGDATA/pg_hba.conf"

echo "Upgrade finished successfully."
