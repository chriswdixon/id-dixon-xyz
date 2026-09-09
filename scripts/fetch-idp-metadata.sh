#!/usr/bin/env bash
# Download Keycloak SAML IdP metadata for wp-simple-saml.
set -euo pipefail

BASE_URL="${KEYCLOAK_URL:-https://id.dixon.xyz}"
REALM="${KEYCLOAK_REALM:-dixon}"
OUT="${1:-idp-metadata/keycloak-idp.xml}"

mkdir -p "$(dirname "$OUT")"
curl -fsSL "${BASE_URL}/realms/${REALM}/protocol/saml/descriptor" -o "$OUT"
echo "Saved IdP metadata to ${OUT}"
