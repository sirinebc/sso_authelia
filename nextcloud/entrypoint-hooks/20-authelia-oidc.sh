#!/bin/sh
set -eu

run_occ() {
  if [ "$(id -u)" = "0" ]; then
    su -s /bin/sh www-data -c "php occ $*"
  else
    sh -c "php occ $*"
  fi
}

echo "==> Trusting local root CA for Authelia"
update-ca-certificates >/dev/null 2>&1 || true

if ! run_occ 'status >/dev/null 2>&1'; then
  echo "==> Nextcloud not installed yet, skipping OIDC bootstrap"
  exit 0
fi

echo "==> Ensuring Nextcloud OIDC app is installed"
run_occ 'app:install user_oidc >/dev/null 2>&1 || true'
run_occ 'app:enable user_oidc >/dev/null 2>&1 || true'

echo "==> Configuring Authelia as OIDC provider"
run_occ 'user_oidc:provider authelia \
  --clientid=nextcloud \
  --clientsecret-file=/run/secrets/nextcloud_oidc_secret \
  --discoveryuri=https://auth.test.local/.well-known/openid-configuration \
  --scope="openid profile email groups" \
  --mapping-uid=preferred_username \
  --mapping-display-name=name \
  --mapping-email=email \
  --mapping-groups=groups \
  --group-provisioning=1 >/dev/null 2>&1 || true'

run_occ 'config:app:set --type=integer --value=0 user_oidc allow_multiple_user_backends >/dev/null 2>&1 || true'
run_occ 'config:system:set --type=bool --value=true allow_local_remote_servers >/dev/null 2>&1 || true'
run_occ 'config:system:set --type=bool --value=true hide_login_form >/dev/null 2>&1 || true'

echo "==> Nextcloud OIDC bootstrap completed"
