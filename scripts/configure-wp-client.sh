#!/usr/bin/env bash
# Replace WordPress SP placeholders in realm export before deploy/import.
set -euo pipefail

WP_SITE="${WP_SP_ENTITY_ID:-}"
WP_SITE="${WP_SITE%/}" # strip trailing slash for URL building

if [[ -z "$WP_SITE" ]]; then
  echo "Set WP_SP_ENTITY_ID (e.g. https://your-vip-site.com/)"
  exit 1
fi

ENTITY_ID="${WP_SITE}/"
ACS_URL="${WP_SITE}/sso/verify"
SLO_URL="${WP_SITE}/sso/logout"

REALM_FILE="${1:-realm/dixon-realm.json}"

sed \
  -e "s|https://REPLACE-WP-SITE/|${ENTITY_ID}|g" \
  -e "s|https://REPLACE-WP-SITE|${WP_SITE}|g" \
  "$REALM_FILE"

echo "Configured SP: entity=${ENTITY_ID} acs=${ACS_URL} slo=${SLO_URL}" >&2
