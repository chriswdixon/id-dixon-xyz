# Okta Integrator Free — SAML IdP for WordPress VIP

Use Okta first. It is always on and needs no Railway.

## 1. Create org

1. Go to [developer.okta.com](https://developer.okta.com) → **Create free account**
2. Choose **Integrator Free Plan** org (e.g. `dev-12345678.okta.com`)

## 2. Create SAML app (WordPress = SP)

1. **Applications → Create App Integration**
2. **SAML 2.0** → Next
3. **General Settings**
   - App name: `WordPress VIP SSO`
4. **Configure SAML**

| Field | Value |
|-------|--------|
| Single sign-on URL | `https://your-vip-site.com/sso/verify` |
| Audience URI (SP Entity ID) | `https://your-vip-site.com/` |
| Name ID format | EmailAddress |
| Application username | Email |

5. **Attribute Statements** (match wp-simple-saml mapping):

| Name | Value |
|------|--------|
| `uid` | `user.login` |
| `email` | `user.email` |
| `givenName` | `user.firstName` |
| `familyName` | `user.lastName` |

6. Finish → **Assign** app to **only your user**

## 3. Download IdP metadata

1. App → **Sign On** tab → **SAML Signing Certificates**
2. **Actions → View IdP metadata**
3. Save XML as `okta-idp.xml`

Upload to VIP: `.private/sso/okta-idp.xml`

## 4. VIP environment

```bash
vip @app.production -- wp config set VIP_SAML_IDP okta
```

Or set `VIP_SAML_IDP=okta` in VIP environment variables.

Set `VIP_SAML_ALLOWED_EMAIL=you@dixon.xyz`.

## 5. Test

1. Visit WP login with SSO link enabled (or force redirect)
2. Redirect to Okta → sign in as your assigned user
3. Land back on WP authenticated

## 6. Negative test

- Assign app to nobody → login should fail
- Wrong metadata cert on WP → signature verify fails

## Notes

- Okta preview URL: `https://dev-XXXXX.okta.com`
- No custom domain required for testing
- Same ACS/entity ID pattern as Keycloak — proves plugin is IdP-agnostic
