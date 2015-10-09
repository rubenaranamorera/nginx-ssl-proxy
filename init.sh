#!/bin/bash

SECRETS_PATH="/etc/secrets"

if [ ! -f "$SECRETS_PATH/dhparam" ]; then
  openssl dhparam -out "$SECRETS_PATH/dhparam" 2048
fi

if [ ! -f "$SECRETS_PATH/proxykey" ]; then
    openssl genrsa -out "$SECRETS_PATH/proxykey" 2048
fi

if [ -z "${DOMAIN+x}" ]; then
  DOMAIN="local.dev"
fi

if [ ! -f "$SECRETS_PATH/proxycert" ]; then
    openssl req -new \
      -x509 \
      -nodes \
      -days 365 \
      -subj "/C=GB/ST=London/L=Fulham/O=Local/OU=Development/CN=*.$DOMAIN/emailAddress=email@$DOMAIN" \
      -key "$SECRETS_PATH/proxykey" \
      -out "$SECRETS_PATH/proxycert"
fi

if [ ! -f "$SECRETS_PATH/htpasswd" ] && [ -n "${HTPSSWD_USER+x}" ] && [ -n "${HTPSSWD_PW+x}" ]; then
    htpasswd -nb $HTPSSWD_USER $HTPSSWD_PW > "$SECRETS_PATH/htpasswd"
fi
