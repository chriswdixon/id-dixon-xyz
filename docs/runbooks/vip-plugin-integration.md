# WordPress VIP — SAML SP integration

For a plugin based on [humanmade/wp-simple-saml](https://github.com/humanmade/wp-simple-saml).

## SP endpoints (Human Made convention)

| Endpoint | URL |
|----------|-----|
| Entity ID | `{home_url}/` — **trailing slash required** |
| ACS | `{home_url}/sso/verify` |
| SLO | `{home_url}/sso/logout` |

## Metadata storage on VIP

Store IdP XML in a non-web-accessible path:

```
.private/sso/okta-idp.xml
.private/sso/keycloak-idp.xml
```

VIP `.private` is outside the web root.

## Mu-plugin example

Copy `examples/vip-mu-plugin/sso-config.php` to `client-mu-plugins/sso-config.php`.

## Environment variables

| Variable | Example | Purpose |
|----------|---------|---------|
| `VIP_SAML_IDP` | `okta` or `keycloak` | Which metadata file to load |
| `VIP_SAML_ALLOWED_EMAIL` | `you@dixon.xyz` | Fail closed — only you |

Set via [VIP environment variables](https://docs.wpvip.com/infrastructure/environments/manage-environment-variables/) or `vip config`.

## Attribute mapping

```php
[
    'user_login' => 'uid',
    'user_email' => 'email',
    'first_name' => 'givenName',
    'last_name'  => 'familyName',
]
```

Both Okta and Keycloak realm export in this repo emit these attribute names.

## Switching IdPs (no code change)

1. Fetch metadata from Okta or Keycloak
2. Save to `.private/sso/{idp}-idp.xml`
3. Set `VIP_SAML_IDP=okta` or `keycloak`
4. Redeploy or refresh env on VIP

## Pre-create WordPress user

With registration off on both IdPs, ensure a WP user exists with the same email as your IdP account. Disable JIT provisioning in plugin settings or enforce via `wpsimplesaml_match_user` (see example mu-plugin).

## Debugging on VIP

```bash
vip @app.develop -- wp saml-auth ...   # if using WP SAML Auth CLI
# or enable plugin debug filters / runtime logs
```

Check VIP runtime logs for SAML validation errors.

## Force SSO (optional)

```php
add_filter( 'wpsimplesaml_force', '__return_true' );
```

Only enable after Okta path is verified — Keycloak downtime blocks login.
