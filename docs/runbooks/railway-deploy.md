# Railway deploy — Keycloak @ id.dixon.xyz

## 1. Create project

1. Sign up at [railway.com](https://railway.com) (use $5 trial credit)
2. **New Project → Deploy from GitHub repo** → `chriswdixon/id-dixon-xyz`
3. Add **PostgreSQL** to the project

## 2. Configure Keycloak service

In the Keycloak service **Variables**, set:

| Variable | Value |
|----------|--------|
| `KEYCLOAK_ADMIN` | `admin` |
| `KEYCLOAK_ADMIN_PASSWORD` | (strong secret) |
| `KC_DB` | `postgres` |
| `KC_DB_URL` | `${{Postgres.DATABASE_URL}}` → convert to JDBC: `jdbc:postgresql://HOST:PORT/railway` |
| `KC_DB_USERNAME` | `${{Postgres.PGUSER}}` |
| `KC_DB_PASSWORD` | `${{Postgres.PGPASSWORD}}` |
| `KC_HOSTNAME` | `id.dixon.xyz` |
| `KC_HOSTNAME_STRICT` | `true` |
| `KC_PROXY` | `edge` |
| `KC_HTTP_ENABLED` | `true` |

Railway Postgres URL is often `postgresql://user:pass@host:port/railway`. Keycloak needs JDBC:

```
jdbc:postgresql://HOST:PORT/railway
```

## 3. Custom domain

1. Railway service → **Settings → Networking → Custom Domain** → `id.dixon.xyz`
2. Add DNS CNAME per Railway instructions
3. Wait for TLS

## 4. First login

1. Open `https://id.dixon.xyz/admin`
2. Create your user in realm **dixon** (registration is off)
3. **Clients → wordpress-vip** — update ACS/SLO/entity ID for your VIP site URL
4. **Identity providers** — add Google/GitHub if desired
5. **Realm settings → Email** — SMTP for OTP/magic link

## 5. IdP metadata for WordPress

```bash
curl -o keycloak-idp.xml \
  'https://id.dixon.xyz/realms/dixon/protocol/saml/descriptor'
```

Upload to VIP: `.private/sso/keycloak-idp.xml`

## 6. Save money — stop when done

Railway bills per second while services run:

- **Stop** Keycloak + Postgres in Railway dashboard when not testing
- Cold start ~30–90s after restart
- Use **Okta** for daily plugin work without starting Railway

## 7. WordPress SP URLs (wp-simple-saml)

| Setting | Value |
|---------|--------|
| Entity ID | `https://your-vip-site.com/` (trailing slash required) |
| ACS URL | `https://your-vip-site.com/sso/verify` |
| SLO URL | `https://your-vip-site.com/sso/logout` |
