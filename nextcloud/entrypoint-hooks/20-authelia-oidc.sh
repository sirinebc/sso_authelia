#!/bin/sh
set -e

# Ce script configure l'app user_oidc Nextcloud avec Authelia si Nextcloud est installé.
# Il est idempotent (ne s'exécute qu'une seule fois via le drapeau de lock /tmp).

NEXTCLOUD_LOCK_FILE="/tmp/nextcloud_oidc_configured"
if [ -f "$NEXTCLOUD_LOCK_FILE" ]; then
  echo "Nextcloud OIDC déjà configuré"
  exit 0
fi

# Vérifie que Nextcloud est bien installé
if [ ! -f "/var/www/html/config/config.php" ]; then
  echo "Nextcloud non installé, configuration OIDC différée"
  exit 0
fi

run_occ() {
  if [ "$(id -u)" -eq 0 ]; then
    runuser -u www-data -- php /var/www/html/occ --no-interaction "$@"
  else
    php /var/www/html/occ --no-interaction "$@"
  fi
}

if ! run_occ app:install user_oidc; then
  run_occ app:enable user_oidc
fi

# Client OIDC Authelia
if [ ! -f "/run/secrets/nextcloud_oidc_secret" ]; then
  echo "Secret nextcloud_oidc_secret introuvable"
  exit 1
fi

run_occ user_oidc:provider authelia \
  --clientid="nextcloud" \
  --clientsecret-file="/run/secrets/nextcloud_oidc_secret" \
  --discoveryuri="https://auth.test.local/.well-known/openid-configuration" \
  --scope="openid profile email groups" \
  --mapping-uid="preferred_username" \
  --mapping-display-name="name" \
  --mapping-email="email" \
  --mapping-groups="groups" \
  --group-provisioning=1

run_occ config:system:set allow_local_remote_servers --type=bool --value=true
run_occ config:app:set --type=integer --value=0 user_oidc allow_multiple_user_backends

# Marque la configuration comme effectuée
touch "$NEXTCLOUD_LOCK_FILE"

echo "Nextcloud OIDC configuré avec succès"
