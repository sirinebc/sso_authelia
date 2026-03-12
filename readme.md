1)	Ajouter les domaines dans /etc/hosts (pour accéder aux servers_name exposés sur le localhost au port 443 (et 80) )

```
127.0.0.1	auth.test.local
127.0.0.1	app.test.local
```

3)	Ajouter les certs (pour accéder en https car authelia n’accepte pas http)
Installer mkcert
Faire mkcert -install (mkcert va devenir un CA chez l’host)
Créer le dossier /sso/certs/
Et mettre le cert du proxy ainsi que la clé privée (signés par le CA de mkcert) : 
mkcert "*.test.local"

4)	Lancer docker compose up au même niveau du fichier docker-compose.yml

5)	Essayer d’aller à https://app.test.local sur l’host -> On obtient un code 500 (Unauthorized access) car on a pas de cookie (on est pas authentifié)

6)	Aller à https://auth.test.local, entrer test et password -> on est bien redirigé vers « l’app » ( https://app.test.local ) (juste la page def de nginx)


