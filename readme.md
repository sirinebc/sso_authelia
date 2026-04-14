1)	Ajouter les domaines dans /etc/hosts 

```
127.0.0.1	auth.test.local
127.0.0.1	jenkins.test.local
127.0.0.1	gitlab.test.local
127.0.0.1	rocket.test.local
127.0.0.1	confluence.test.local
127.0.0.1	jira.test.local
127.0.0.1	nextcloud.test.local
```

3)	Ajouter les certificats dans sso/certs/
```
Installer mkcert
Faire mkcert -install 

Créer le certificat dans le dossier sso/certs/ :
mkcert "*.test.local"

Aussi y ajouter le certificat rootCA.pem
```

4)	Ajouter les secrets dans secrets/
```
gitlab_oidc_secret = "un_secret_partage"
jenkins_oidc_secret = "un_secret_partage"
confluence_oidc_secret = "JM9MmjABTflg9R5QTP.xXytHBNhJUu3M4rndMNDjuF5AQxxDR32LapkTDCa15vMZrOJ91KDJ"
rocket_oidc_secret = "kRJ-pRKPf03.taHj6NJUigubSD2Lsrpi1SQm7WIXRNHmk3VK.hGf1TmENCKo6Tnmr3Y3jSpO"
jira_oidc_secret = "un_secret_partage"
nextcloud_oidc_secret = "un_secret_partage"
nextcloud_admin_password = "admin"
authelia_storage_key = "you_must_generate_a_random_string_of_more_than_twenty_chars_and_configure_this"
authelia_jwt_secret = "a_very_important_secret"
authelia_session_secret = "insecure_session_secret"
authelia_hmac_secret ="this_is_a_secret_abc123abc123abc"

authelia_oidc_key => openssl genrsa -out authelia_oidc_key 2048
```

5) Créer les volumes et y mettre le contenu des archives
```
jira_db_data
nextcloud_data
mongo_data
confluence_data
confluence_pg_data
```
 
6)	Lancer docker compose up au même niveau du fichier docker-compose.yml