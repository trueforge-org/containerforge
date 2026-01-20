#!/usr/bin/env bash
set -e

cd /app

SERVER_DIR="/app/Server"

echo "[INFO] Starting Hytale container..."

# ----------------------------------------
# Auto update: overlay server files
# ----------------------------------------
HYTALE_AUTO_UPDATE=${HYTALE_AUTO_UPDATE:-false}
HYTALE_PORT=${HYTALE_PORT:-5520}
HYTALE_ALLOW_OP=${HYTALE_ALLOW_OP:-true}
HYTALE_BACKUP_ENALBED=${HYTALE_BACKUP_ENABLED:-false}
HYTALE_BACKUP_DIR=${HYTALE_BACKUP_DIR:-/app/backups}
HYTALE_BACKUP_FREQ=${HYTALE_BACKUP_FREQ:-30}
HYTALE_EXTRA_ARGS=${HYTALE_EXTRA_ARGS:-""}
HYTALE_JAVA_ARGS=${HYTALE_JAVA_ARGS:-""}

# ----------------------------------------
# Cleanup any leftover zip files before starting
# ----------------------------------------
echo "[INFO] Cleaning up old rogue zip files..."
for old_zip in *.zip; do
    if [ "$old_zip" != "Assets.zip" ] && [ -f "$old_zip" ]; then
        echo "[INFO] Removing old zip: $old_zip"
        rm -f "$old_zip"
    fi
done

if [ "$HYTALE_AUTO_UPDATE" = "true" ] || [ ! -f "HytaleServer.jar" ]; then
    echo "[INFO] Running downloader (AUTO_UPDATE=$HYTALE_AUTO_UPDATE)"

    hytale-downloader

    # Find the newest zip in the current folder
    ZIP_FILE="$(ls -t *.zip 2>/dev/null | head -n 1 || true)"

    if [ -z "$ZIP_FILE" ]; then
        echo "[ERROR] No zip file found after download"
        exit 1
    fi

    echo "[INFO] Extracting server files from $ZIP_FILE"
    # Extract zip on top of /app (zip contains Server folder)
    unzip -o -q "$ZIP_FILE" -d /app

    # Delete the downloaded zip
    echo "[INFO] Removing downloaded zip $ZIP_FILE"
    rm -f "$ZIP_FILE"
	
	# Move everything from /Server to /app, overwriting files and merging directories
if [ -d "$SERVER_DIR" ]; then
    echo "[INFO] Moving files from $SERVER_DIR to /app"
    # -a: archive (preserve permissions), -v: verbose, --remove-source-files: delete originals
    # --ignore-existing: optional, we want to overwrite, so omit it
    rsync -r --remove-source-files "$SERVER_DIR"/ /app/
    # Remove empty directories left in /Server
    find "$SERVER_DIR" -type d -empty -delete
    rm -rf "$SERVER_DIR"
fi
else
    echo "[INFO] Existing server detected and AUTO_UPDATE=false, skipping download"
fi

# ----------------------------------------
# Sanity check
# ----------------------------------------
if [ ! -f "HytaleServer.jar" ]; then
    echo "[ERROR] HytaleServer.jar not found"
    exit 1
fi

# Ensure backup directory exists if backup is enabled
if [ "$BACKUP" = "true" ]; then
    echo "[INFO] Ensuring backup directory exists at $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
fi

# ----------------------------------------
# Server Args
# ----------------------------------------

SERVER_ARGS="--assets Assets.zip"

if [ "$HYTALE_ALLOW_OP" = "true" ]; then
    SERVER_ARGS="$SERVER_ARGS --allow-op"
fi

if [ "$HYTALE_BACKUP_ENALBED" = "true" ]; then
    SERVER_ARGS="$SERVER_ARGS --backup --backup-dir $HYTALE_BACKUP_DIR --backup-frequency $HYTALE_BACKUP_FREQ"
fi

# ----------------------------------------
# Start server
# ----------------------------------------
echo "[INFO] Starting Hytale server..."
exec java $HYTALE_JAVA_ARGS -XX:AOTCache=HytaleServer.aot -jar HytaleServer.jar \
	$SERVER_ARGS \
	--bind 0.0.0.0:$HYTALE_PORT \
	$HYTALE_EXTRA_ARGS
