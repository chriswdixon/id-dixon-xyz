#!/usr/bin/env bash
# Apply Keycloak env vars to a linked Railway project via CLI.
# Usage:
#   railway login          # once
#   railway link           # pick your id-dixon-xyz project + keycloak service
#   KC_HOSTNAME=https://your-app.up.railway.app ./scripts/railway-configure.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

SERVICE="${RAILWAY_SERVICE:-}"
POSTGRES_SERVICE="${RAILWAY_POSTGRES_SERVICE:-Postgres}"
ENVIRONMENT="${RAILWAY_ENVIRONMENT:-}"

if ! command -v railway >/dev/null 2>&1; then
  echo "Install Railway CLI: brew install railway" >&2
  exit 1
fi

if ! railway whoami >/dev/null 2>&1; then
  echo "Not logged in. Run: railway login" >&2
  exit 1
fi

if [[ -z "$SERVICE" ]]; then
  if [[ -f .railway/config.json ]]; then
    SERVICE="$(railway status --json 2>/dev/null | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('service',{}).get('name','') or '')" 2>/dev/null || true)"
  fi
fi

if [[ -z "$SERVICE" ]]; then
  echo "Set RAILWAY_SERVICE to your Keycloak service name, or run: railway link --service <name>" >&2
  exit 1
fi

KC_HOSTNAME="${KC_HOSTNAME:-}"
if [[ -z "$KC_HOSTNAME" ]]; then
  echo "Generating Railway domain for service ${SERVICE} (port 8080)..." >&2
  DOMAIN_JSON="$(railway domain --service "$SERVICE" --port 8080 --json 2>/dev/null || true)"
  if [[ -n "$DOMAIN_JSON" ]]; then
    DOMAIN="$(echo "$DOMAIN_JSON" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('domain') or d.get('hostname') or '')" 2>/dev/null || true)"
    if [[ -n "$DOMAIN" ]]; then
      KC_HOSTNAME="https://${DOMAIN}"
    fi
  fi
fi

if [[ -z "$KC_HOSTNAME" ]]; then
  echo "Set KC_HOSTNAME=https://your-app.up.railway.app (or attach a domain first)" >&2
  exit 1
fi

if [[ "$KC_HOSTNAME" != http://* && "$KC_HOSTNAME" != https://* ]]; then
  KC_HOSTNAME="https://${KC_HOSTNAME}"
fi

ADMIN_USER="${KC_BOOTSTRAP_ADMIN_USERNAME:-admin}"
ADMIN_PASS="${KC_BOOTSTRAP_ADMIN_PASSWORD:-$(openssl rand -base64 24)}"

echo "Configuring service: ${SERVICE}" >&2
echo "KC_HOSTNAME: ${KC_HOSTNAME}" >&2
echo "Bootstrap admin: ${ADMIN_USER} / (password printed at end)" >&2

ENV_FLAGS=()
if [[ -n "$ENVIRONMENT" ]]; then
  ENV_FLAGS+=(--environment "$ENVIRONMENT")
fi

# Reference vars use Postgres service name (default: Postgres)
DB_REF_DOMAIN='${{'"${POSTGRES_SERVICE}"'.RAILWAY_PRIVATE_DOMAIN}}'
DB_REF_NAME='${{'"${POSTGRES_SERVICE}"'.PGDATABASE}}'
DB_REF_USER='${{'"${POSTGRES_SERVICE}"'.PGUSER}}'
DB_REF_PASS='${{'"${POSTGRES_SERVICE}"'.PGPASSWORD}}'

railway variable set --service "$SERVICE" "${ENV_FLAGS[@]}" --skip-deploys \
  PORT=9000 \
  KC_DB=postgres \
  "KC_DB_URL=jdbc:postgresql://${DB_REF_DOMAIN}:5432/${DB_REF_NAME}" \
  "KC_DB_USERNAME=${DB_REF_USER}" \
  "KC_DB_PASSWORD=${DB_REF_PASS}" \
  KC_DB_POOL_MAX_SIZE=10 \
  KC_HTTP_ENABLED=true \
  KC_PROXY_HEADERS=xforwarded \
  KC_PROXY_TRUSTED_ADDRESSES='100.64.0.0/10,fd00::/8' \
  KC_HEALTH_ENABLED=true \
  "KC_HOSTNAME=${KC_HOSTNAME}" \
  "KC_BOOTSTRAP_ADMIN_USERNAME=${ADMIN_USER}" \
  "KC_BOOTSTRAP_ADMIN_PASSWORD=${ADMIN_PASS}"

echo "" >&2
echo "Variables set. Redeploying ${SERVICE}..." >&2
railway redeploy --service "$SERVICE" "${ENV_FLAGS[@]}" -y

echo "" >&2
echo "Done." >&2
echo "  Admin console: ${KC_HOSTNAME}/admin" >&2
echo "  SAML metadata: ${KC_HOSTNAME}/realms/dixon/protocol/saml/descriptor" >&2
echo "  Health:        ${KC_HOSTNAME}/health/ready (via management port 9000 internally)" >&2
echo "" >&2
echo "Bootstrap credentials (save these):" >&2
echo "  ${ADMIN_USER} / ${ADMIN_PASS}" >&2
