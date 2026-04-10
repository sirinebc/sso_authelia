# Jira + Authelia

Cette stack ajoute `Jira` sur `https://jira.test.local`.

## Fonctionnement

- `Jira` est publié derrière `Nginx`.
- L’accès web est protégé par `Authelia` via le reverse proxy.
- Le premier accès demande donc une authentification `Authelia` avant d’ouvrir Jira.

## Démarrage

```powershell
docker compose up -d jira reverse-proxy authelia
```

Puis ouvrir :

```text
https://jira.test.local
```

## Initialisation

Au premier démarrage, terminer l’assistant d’installation Jira dans le navigateur.

## Note SSO

- Cette intégration protège déjà l’accès à Jira avec `Authelia` au niveau du proxy.
- Le conteneur Jira fait maintenant confiance au certificat local de `auth.test.local`.
- Le secret `secrets/jira_oidc_secret` est monté dans Jira sur `/run/secrets/jira_oidc_secret`.
- Les en-têtes d’identité `Remote-User`, `Remote-Groups`, `Remote-Name` et `Remote-Email` sont aussi transmis par `Nginx` après authentification `Authelia`.

## OIDC natif côté Jira

`Jira` n’embarque pas d’authentification OIDC native dans l’image standard Atlassian : il faut toujours installer un plugin OIDC/SAML compatible depuis l’administration Jira.

Une fois le plugin installé après l’assistant initial, utiliser les valeurs suivantes :

- **Discovery URI** : `https://auth.test.local/.well-known/openid-configuration`
- **Client ID** : `jira`
- **Client secret** : contenu de `/run/secrets/jira_oidc_secret`
- **Scopes** : `openid profile email groups`
- **Username / login claim** : `preferred_username`
- **Display name claim** : `name`
- **Email claim** : `email`
- **Groups claim** : `groups`
