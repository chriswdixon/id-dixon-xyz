#!/usr/bin/env bash
# Create a new Railway project with Postgres + this repo (interactive steps minimized).
# Usage: ./scripts/railway-bootstrap.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
REPO="${RAILWAY_REPO:-chriswdixon/id-dixon-xyz}"
PROJECT_NAME="${RAILWAY_PROJECT_NAME:-id-dixon-xyz}"
SERVICE_NAME="${RAILWAY_SERVICE:-keycloak}"

if ! railway whoami >/dev/null 2>&1; then
  echo "Run: railway login" >&2
  exit 1
fi

echo "Creating Railway project: ${PROJECT_NAME}" >&2
railway init --name "$PROJECT_NAME"

echo "Adding PostgreSQL..." >&2
railway add --database postgres

echo "Adding GitHub repo service: ${REPO} as ${SERVICE_NAME}..." >&2
railway add --repo "$REPO" --service "$SERVICE_NAME" || {
  echo "Repo service may already exist — link manually if needed." >&2
}

railway link --service "$SERVICE_NAME" 2>/dev/null || railway service link "$SERVICE_NAME"

echo "Generating public domain (port 8080)..." >&2
railway domain --service "$SERVICE_NAME" --port 8080 || true

echo "Applying Keycloak variables..." >&2
export RAILWAY_SERVICE="$SERVICE_NAME"
exec "$ROOT/scripts/railway-configure.sh"
