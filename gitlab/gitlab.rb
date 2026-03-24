external_url 'https://gitlab.test.local'
nginx['listen_https'] = false
nginx['listen_port'] = 80

gitlab_rails['omniauth_allow_single_sign_on'] = ['openid_connect']
gitlab_rails['omniauth_block_auto_created_users'] = false
gitlab_rails['omniauth_auto_link_user'] = ['openid_connect']

gitlab_rails['omniauth_enabled'] = true
gitlab_rails['omniauth_providers'] = [
  {
    name: 'openid_connect',
    label: 'Authelia',
    args: {
      name: 'openid_connect',
      scope: ['openid', 'profile', 'email', 'groups'],
      response_type: 'code',
      issuer: 'https://auth.test.local',
      client_auth_method: 'basic',
      discovery: true,
      client_options: {
        identifier: 'gitlab',
        secret: File.read('/run/secrets/gitlab_oidc_secret'), # partagé avec authelia
        redirect_uri: 'https://gitlab.test.local/users/auth/openid_connect/callback'
      }
    }
}
]