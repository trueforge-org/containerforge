#!/usr/bin/env bash

cd /app/go-playground || exit 1
exec /app/go-playground/server -addr=:8000
