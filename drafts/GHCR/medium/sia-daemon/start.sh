#!/usr/bin/env bash


mkdir -p /config/sia

# Upstream ENTRYPOINT passes --disable-api-security; it is not passed here, so the API keeps its auth (decision R2 in plan.md).
# Gateway and RHP ports (9981-9983) use siad defaults (UNVERIFIED for this commit).
# SIA_WALLET_PASSWORD is read from the environment by siad and is never echoed here.
exec /app/siad/siad -d /config/sia --api-addr ":9980"
