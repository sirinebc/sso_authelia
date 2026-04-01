1)	Ajouter les domaines dans /etc/hosts (pour accéder aux servers_name exposés sur le localhost au port 443 (et 80) )

```
127.0.0.1	auth.test.local

```

3)	Ajouter les certs (pour accéder en https car authelia n’accepte pas http)
```
Installer mkcert
Faire mkcert -install (mkcert va devenir un CA chez l’host)
Créer le dossier /sso/certs/
Et mettre le cert du proxy ainsi que la clé privée (signés par le CA de mkcert) : 
mkcert "*.test.local"
```

4)	Ajouter les secrets dans secrets/ 
```
nextcloud_oidc_secret = "un_secret_partage"
jira_oidc_secret = "un_secret_partage"
nextcloud_admin_password = "mot_de_passe_admin_nextcloud"
authelia_storage_key = "you_must_generate_a_random_string_of_more_than_twenty_chars_and_configure_this"
authelia_jwt_secret = "a_very_important_secret"
authelia_session_secret = "insecure_session_secret"

authelia_oidc_key => openssl genrsa -out authelia_oidc_key 2048
```

5)	Lancer docker compose up au même niveau du fichier docker-compose.yml

6)	Initialiser Nextcloud puis activer l’OIDC Authelia
```
# Le premier démarrage peut maintenant être automatisé si le fichier
# secrets/nextcloud_admin_password est présent.

# Vérifier l’état de Nextcloud.
docker compose exec --user www-data nextcloud php occ status

# En cas de reconfiguration manuelle, réactiver l'application OIDC.
docker compose exec --user www-data nextcloud php occ app:enable user_oidc

# Déclarer Authelia comme fournisseur OpenID Connect.
docker compose exec --user www-data nextcloud php occ user_oidc:provider authelia --clientid="nextcloud" --clientsecret-file="/run/secrets/nextcloud_oidc_secret" --discoveryuri="https://auth.test.local/.well-known/openid-configuration" --scope="openid profile email groups" --mapping-uid="preferred_username" --mapping-display-name="name" --mapping-email="email" --mapping-groups="groups" --group-provisioning=1

# Optionnel : rendre la connexion OIDC prioritaire sur la page de login.
docker compose exec --user www-data nextcloud php occ config:app:set --type=integer --value=0 user_oidc allow_multiple_user_backends
```

7)	Jira est aussi disponible sur `https://jira.test.local`
```
L’accès Jira est protégé par Authelia au niveau du proxy Nginx.
Le conteneur Jira est maintenant prêt pour un plugin OIDC natif (CA locale importée, secret /run/secrets/jira_oidc_secret et client OIDC `jira` déclaré dans Authelia).
Après l’assistant d’installation Jira, installer un plugin SSO/OIDC compatible Atlassian puis renseigner :
- Discovery URI : https://auth.test.local/.well-known/openid-configuration
- Client ID : jira
- Client secret : contenu du fichier /run/secrets/jira_oidc_secret
- Scopes : openid profile email groups
```


