1)	Ajouter les domaines dans /etc/hosts (pour accéder aux servers_name exposés sur le localhost au port 443 (et 80) )

```
127.0.0.1	auth.test.local
127.0.0.1	app.test.local
```

3)	Ajouter les certs (pour accéder en https car authelia n’accepte pas http)
```
Installer mkcert
Faire mkcert -install (mkcert va devenir un CA chez l’host)
Créer le dossier /sso/certs/
Et mettre le cert du proxy ainsi que la clé privée (signés par le CA de mkcert) : 
mkcert "*.test.local"
```

4)	Ajouter les secrets dans secrets/ (sans saut de ligne à la fin)
gitlab_oidc_secret = "un_secret_partage"
jenkins_oidc_secret = "un_secret_partage"
authelia_storage_key = "you_must_generate_a_random_string_of_more_than_twenty_chars_and_configure_this"
authelia_hmac_secret = "this_is_a_secret_abc123abc123abc"
authelia_jwt_secret = "a_very_important_secret"
authelia_session_secret = "insecure_session_secret"

authelia_oidc_key -> openssl genrsa -out authelia_oidc_key 2048

5)	Lancer docker compose up au même niveau du fichier docker-compose.yml

6)	Essayer d’aller à https://app.test.local sur l’host -> On obtient un code 500 (Unauthorized access) car on a pas de cookie (on est pas authentifié)

7)	Aller à https://auth.test.local, entrer test et password -> on est bien redirigé vers « l’app » ( https://app.test.local ) (juste la page def de nginx)



