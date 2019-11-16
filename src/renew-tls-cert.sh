#!/bin/sh
set -euo pipefail

domain="$1"
cert="/etc/letsencrypt/www.$domain/www.$domain.crt"

# Backup existing certificate
cp "$cert" "${cert}.$(date '+%Y%m%d_%H%M%S')"

# Renew
python3 acme_tiny.py \
    --account-key /etc/letsencrypt/account.key \
    --csr /etc/letsencrypt/www.$domain/www.$domain.csr \
    --acme-dir /usr/share/nginx/acme-challenge/ \
    > /tmp/www.$domain.crt

mv /tmp/www.$domain.crt "$cert"
