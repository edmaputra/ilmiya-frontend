#!/bin/sh
set -e

CONFIG_FILE="/usr/share/nginx/html/assets/config.json"
mkdir -p /usr/share/nginx/html/assets

# If Vault injected configuration exists, copy it as default asset
if [ -f "/vault/secrets/config.json" ]; then
    echo "==> Synced HashiCorp Vault secrets from /vault/secrets/config.json to ${CONFIG_FILE}"
    cp /vault/secrets/config.json "${CONFIG_FILE}"
elif [ -n "$ILMIYA_API_BASE_URL" ] || [ -n "$ILMIYA_DEFAULT_TENANT_ID" ]; then
    echo "==> Generating runtime configuration from container environment variables"
    cat <<EOF > "${CONFIG_FILE}"
{
  "apiBaseUrl": "${ILMIYA_API_BASE_URL:-https://ilmiya.localhost}",
  "defaultTenantId": "${ILMIYA_DEFAULT_TENANT_ID:-tenant-lincoln-high-001}",
  "mockMode": ${ILMIYA_MOCK_MODE:-false}
}
EOF
fi

exec "$@"
