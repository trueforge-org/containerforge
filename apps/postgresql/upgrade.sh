#!/usr/bin/env bash
set -euo pipefail

export OLD_VERSION=${UPGRADE_REQ}
export TARGET_VERSION=${PG_MAJOR}

export OLD_PGDATA=${PGDATA_PARENT}/${OLD_VERSION}
export NEW_PGDATA=${PGDATA}

get_bin_path() {
  local version=$1
  echo "/usr/lib/postgresql/$version/bin"
}

export OLD_PG_BINARY=$(get_bin_path "$OLD_VERSION")
export NEW_PG_BINARY=$(get_bin_path "$TARGET_VERSION")

fix_checksum() {
  echo "Checking checksums..."
  # TODO: Remove
  echo "checksumcheck $OLD_PGDATA using $OLD_PG_BINARY"
  $OLD_PG_BINARY/pg_checksums --version
  $OLD_PG_BINARY/pg_checksums
  echo "checksumcheck $NEW_PGDATA using $NEW_PG_BINARY"
  $NEW_PG_BINARY/pg_checksums --version
  $NEW_PG_BINARY/pg_checksums
  OLD_STATUS=$("$OLD_PG_BINARY/pg_checksums" --check --data-directory="$OLD_PGDATA" 2>&1 | grep -q "disabled" && echo "--disable" || echo "--enable")
  NEW_STATUS=$("$NEW_PG_BINARY/pg_checksums" --check --data-directory="$NEW_PGDATA" 2>&1 | grep -q "disabled" && echo "--disable" || echo "--enable")
  echo "Old data checksums: ${OLD_STATUS#--}d"
  echo "New data checksums: ${NEW_STATUS#--}d"
  if [[ "$OLD_STATUS" != "$NEW_STATUS" ]]; then
    echo "Setting checksums on old data to match new..."
    "$OLD_PG_BINARY/pg_checksums" "$NEW_STATUS" --data-directory="$OLD_PGDATA" -P || exit 1
  else
    echo "Checksum state matches — nothing to do."
  fi
}



echo "Current version: $OLD_VERSION"
echo "Target version: $TARGET_VERSION"

if [ "$OLD_VERSION" -lt $((TARGET_VERSION - 1)) ]; then
    echo "Upgrade spans more than one major version! Need intermediate upgrades."
    exit 1
else
    echo "Safe to upgrade in one step."
fi



fix_checksum

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
