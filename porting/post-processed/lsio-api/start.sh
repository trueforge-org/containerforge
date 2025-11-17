#!/usr/bin/env bash




exec 
    cd /app  fastapi run --workers 4 api.py





exec 
    cd /app  python -u /app/updater.py

