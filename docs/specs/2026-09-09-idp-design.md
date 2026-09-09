# Personal IdP Design — id.dixon.xyz

**Date:** 2026-09-09  
**Scope:** Personal SAML identity provider for WordPress VIP plugin development. 100% outside Cesco.

## Goals

- SAML 2.0 IdP for a Human Made–based wp-simple-saml plugin on WordPress VIP
- Self-hosted Keycloak (Railway, start/stop for testing)
- Free Okta Integrator dev tenant (always on, IdP-agnostic testing)
- Single user only — no public registration

## Architecture

```
WordPress VIP plugin (SAML SP)
        │
        ├── Keycloak @ id.dixon.xyz (Railway)
        └── Okta Integrator Free (SAML app)
```

VIP plugin switches IdP via `VIP_SAML_IDP` env + metadata file in `.private/sso/`.

## Data flow (SP-initiated)

1. User hits WP login → plugin sends AuthnRequest to active IdP
2. User authenticates at IdP (allowlisted email only)
3. IdP POSTs signed assertion to `{WP_HOME}/sso/verify`
4. Plugin verifies signature, maps `uid` / `email`, sets auth cookie
5. Logout v1: WP-only (SLO optional later)

## Keycloak (Railway)

- Realm `dixon`, registration disabled
- Login: password, email OTP, passkeys, Google/GitHub, TOTP (configure in admin)
- SAML client `wordpress-vip` with ACS `/sso/verify`, entity ID `{home}/`
- Postgres on Railway, Keycloak Docker image
- Stop services between test sessions

## Okta (Integrator Free)

- SAML 2.0 app assigned to single user
- Metadata XML saved to VIP `.private/sso/okta-idp.xml`
- Same attribute mapping as Keycloak

## Error handling

| Case | Behavior |
|------|----------|
| Keycloak stopped | Clear error, no password fallback if SSO forced |
| Bad signature | Reject login |
| Email not allowlisted | Reject, no JIT user |
| Clock skew | 60s tolerance |

## Testing order

1. Okta (always available)
2. Keycloak on Railway
3. Switch metadata env without code changes
4. Negative: wrong cert, stopped IdP, wrong email

## Repos

| Repo | Role |
|------|------|
| `id-dixon-xyz` (this) | Keycloak infra, realm, runbooks, VIP mu-plugin example |
| Your VIP plugin repo | SAML SP implementation |
