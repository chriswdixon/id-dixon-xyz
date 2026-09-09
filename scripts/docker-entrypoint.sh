#!/usr/bin/env bash
set -euo pipefail

# Railway healthchecks use $PORT. Keycloak exposes /health/* on 9000, not 8080.
export PORT="${PORT:-9000}"

# KC_HOSTNAME must be a full URL in production (https://...)
if [[ -n "${KC_HOSTNAME:-}" && "${KC_HOSTNAME}" != http://* && "${KC_HOSTNAME}" != https://* ]]; then
  export KC_HOSTNAME="https://${KC_HOSTNAME}"
fi

# Accept mis-set Railway DATABASE_URL (postgresql://) and convert to JDBC.
if [[ -z "${KC_DB_URL:-}" && -n "${DATABASE_URL:-}" ]]; then
  if [[ "${DATABASE_URL}" == postgresql://* ]]; then
    export KC_DB_URL="jdbc:${DATABASE_URL}"
  elif [[ "${DATABASE_URL}" == postgres://* ]]; then
    export KC_DB_URL="jdbc:${DATABASE_URL/postgres:/postgresql:}"
  fi
fi

if [[ -n "${KC_DB_URL:-}" && "${KC_DB_URL}" == postgresql://* ]]; then
  export KC_DB_URL="jdbc:${KC_DB_URL}"
fi

if [[ -z "${KC_DB_URL:-}" ]]; then
  echo "ERROR: KC_DB_URL is not set. Use:" >&2
  echo '  jdbc:postgresql://${{Postgres.RAILWAY_PRIVATE_DOMAIN}}:5432/${{Postgres.PGDATABASE}}' >&2
  exit 1
fi

if [[ -z "${KC_DB_USERNAME:-}" || -z "${KC_DB_PASSWORD:-}" ]]; then
  echo "ERROR: KC_DB_USERNAME and KC_DB_PASSWORD must be set (use Railway Postgres references)." >&2
  exit 1
fi

exec /opt/keycloak/bin/kc.sh "$@"
