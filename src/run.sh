#!/bin/sh
set -euo pipefail

SECRETS_FILE=${1-/run/secrets/secrets.env}

function log {
    echo "$(date -Iseconds) event=\"$*\""
}

# Create nginx.conf from template file and secrets file mounted at runtime
env $(paste "$SECRETS_FILE") \
    envsubst "$(printf '${%s} ' $(cut -d= -f1 "$SECRETS_FILE"))" \
    </etc/nginx/nginx.conf.tmpl > /etc/nginx/nginx.conf
log "Created /etc/nginx/nginx.conf from template and environment"

nginx -g 'daemon off;'
