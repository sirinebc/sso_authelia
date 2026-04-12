1)	Ajouter les domaines dans /etc/hosts (pour accéder aux servers_name exposés sur le localhost au port 443 et 80)

```
127.0.0.1	auth.test.local
127.0.0.1	nextcloud.test.local
127.0.0.1	jira.test.local

```

3)	Ajouter les certs (pour accéder en https car authelia n’accepte pas http)
```
Installer mkcert
Faire mkcert -install (mkcert va devenir un CA chez l’host)
Créer le dossier /sso/certs/
Et mettre le cert du proxy ainsi que la clé privée (signés par le CA de mkcert) : 
mkcert "*.test.local"

# Le certificat racine mkcert doit aussi être disponible dans certs/rootCA.pem
# pour être monté dans les conteneurs et injecté dans le store système.
```

4)	Ajouter les secrets dans secrets/ 
```
nextcloud_oidc_secret = "CHANGE_ME_NEXTCLOUD_OIDC_SECRET_32PLUS"
jira_oidc_secret = "CHANGE_ME_JIRA_OIDC_SECRET_32PLUS"
nextcloud_admin_password = "CHANGE_ME_NEXTCLOUD_ADMIN_PASSWORD"
authelia_storage_key = "CHANGE_ME_AUTHELIA_STORAGE_KEY_32PLUS"
authelia_jwt_secret = "CHANGE_ME_AUTHELIA_JWT_SECRET_32PLUS"
authelia_session_secret = "CHANGE_ME_AUTHELIA_SESSION_SECRET_32PLUS"

authelia_oidc_key => openssl genrsa -out authelia_oidc_key 2048
```

5)	Lancer docker compose up au même niveau du fichier docker-compose.yml

6)	Initialiser Nextcloud puis activer l’OIDC Authelia
```
# Le premier démarrage peut maintenant être automatisé si le fichier
# secrets/nextcloud_admin_password est présent.

# Le conteneur Nextcloud exécute aussi un entrypoint custom
# (nextcloud/docker-entrypoint.sh) qui recharge le CA local au démarrage.

# Vérifier l’état de Nextcloud.
docker compose exec --user www-data nextcloud php occ status

# En cas de reconfiguration manuelle, réactiver l'application OIDC.
docker compose exec --user www-data nextcloud php occ app:enable user_oidc

# Déclarer Authelia comme fournisseur OpenID Connect.
docker compose exec --user www-data nextcloud php occ user_oidc:provider authelia --clientid="nextcloud" --clientsecret-file="/run/secrets/nextcloud_oidc_secret" --discoveryuri="https://auth.test.local/.well-known/openid-configuration" --scope="openid profile email groups" --mapping-uid="preferred_username" --mapping-display-name="name" --mapping-email="email" --mapping-groups="groups" --group-provisioning=1

# Optionnel : rendre la connexion OIDC prioritaire sur la page de login.
docker compose exec --user www-data nextcloud php occ config:app:set --type=integer --value=0 user_oidc allow_multiple_user_backends

# Obligatoire pour autoriser Nextcloud à joindre auth.test.local en local.
docker compose exec --user www-data nextcloud php occ config:system:set allow_local_remote_servers --type=bool --value=true
```

Le hook nextcloud/entrypoint-hooks/20-authelia-oidc.sh configure maintenant automatiquement user_oidc avec Authelia si Nextcloud est déjà installé. Il est idempotent et ne crée son fichier de lock qu’après succès.

Validation effectuée:
- Le flow OIDC complet vers Nextcloud est valide et aboutit sur le dashboard.
- L’URL de login Nextcloud redirige bien vers user_oidc puis vers Authelia.
- La confiance TLS locale est persistée au redémarrage du conteneur Nextcloud.

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

Validation effectuée:
- L’accès à Jira derrière Authelia fonctionne avec une session authentifiée.
- Le test aboutit actuellement sur l’écran d’installation Jira, ce qui est cohérent tant que Jira n’est pas configuré.

8)	Comptes de démo validés (mot de passe unique)
```
Mot de passe pour tous les comptes : TEST

Utilisateurs:
- alice.dupont
- bob.martin
- claire.leroy
- david.moreau
- eva.bernard
- francois.petit
- gabrielle.rousseau
- hugo.lefebvre
- isabelle.fontaine
- julien.gaillard
- test.user
```

9)	Mini check sécurité avant partage
```
- Les dossiers/fichiers sensibles ne sont pas versionnés (certs/, secrets/, authelia/users_database.yml, jira/data/, etc.).
- Les secrets d'exemple sont des placeholders et doivent être remplacés localement.
- Pour une démo publique, éviter d'exposer des mots de passe réels dans la documentation.
```


