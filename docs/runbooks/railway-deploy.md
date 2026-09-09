# Railway deploy — Keycloak @ id.dixon.xyz

Follow [Railway's Keycloak guide](https://docs.railway.com/guides/keycloak-authentication). The most common crash causes are wrong DB URL, wrong healthcheck port, and missing proxy settings.

## 1. Create project

1. [railway.com](https://railway.com) → **New Project → Deploy from GitHub** → `chriswdixon/id-dixon-xyz`
2. **+ New → Database → PostgreSQL**
3. Keycloak service → **Settings → Resources** → set memory to **≥ 1 GB**

## 2. Required variables

In the **Keycloak** service → **Variables**:

| Variable | Value |
|----------|--------|
| `PORT` | `9000` |
| `KC_DB` | `postgres` |
| `KC_DB_URL` | `jdbc:postgresql://${{Postgres.RAILWAY_PRIVATE_DOMAIN}}:5432/${{Postgres.PGDATABASE}}` |
| `KC_DB_USERNAME` | `${{Postgres.PGUSER}}` |
| `KC_DB_PASSWORD` | `${{Postgres.PGPASSWORD}}` |
| `KC_DB_POOL_MAX_SIZE` | `10` |
| `KC_BOOTSTRAP_ADMIN_USERNAME` | `admin` |
| `KC_BOOTSTRAP_ADMIN_PASSWORD` | (strong secret) |
| `KC_HTTP_ENABLED` | `true` |
| `KC_PROXY_HEADERS` | `xforwarded` |
| `KC_PROXY_TRUSTED_ADDRESSES` | `100.64.0.0/10,fd00::/8` |
| `KC_HEALTH_ENABLED` | `true` |
| `KC_HOSTNAME` | `https://YOUR-RAILWAY-DOMAIN.up.railway.app` |

**Do not use** `KEYCLOAK_ADMIN` (deprecated). Use `KC_BOOTSTRAP_ADMIN_*`.

**Do not use** `${{Postgres.DATABASE_URL}}` directly — Keycloak needs **JDBC** format (`jdbc:postgresql://...`).

**Do not set** `KC_HOSTNAME` to `id.dixon.xyz` without `https://` — use the full URL.

## 3. Networking

1. **Settings → Networking → Generate Domain** → target port **8080**
2. Set `KC_HOSTNAME` to that full `https://...` URL and redeploy
3. Healthcheck path: `/health/ready` (already in `railway.toml`)

## 4. Custom domain (optional)

1. Add custom domain `id.dixon.xyz` → target port **8080**
2. Update `KC_HOSTNAME` to `https://id.dixon.xyz` and redeploy

## 5. Verify deploy

Check **Deploy Logs** for:

- `ERROR: KC_DB_URL is not set` → fix JDBC URL (see above)
- `Port(s) already bound: 8080` → remove duplicate `PORT=8080`; use `PORT=9000` only
- `QuarkusBindException` / OOM → increase memory to 1–2 GB
- `Failed to obtain JDBC connection` → Postgres not reachable; use `RAILWAY_PRIVATE_DOMAIN` not public PGHOST

When healthy:

```bash
curl -sS "https://YOUR-DOMAIN/health/ready"
curl -sS "https://YOUR-DOMAIN/realms/dixon/protocol/saml/descriptor" | head
```

Admin console: `https://YOUR-DOMAIN/admin`

## 6. Realm + WordPress client

1. Realm **dixon** is imported on first boot
2. **Clients → wordpress-vip** — set ACS/SLO/entity ID for your VIP site
3. Create your user (registration is off)

## 7. Save money

Stop Keycloak + Postgres when not testing. Use Okta for day-to-day plugin work.

## Troubleshooting

See [railway-troubleshooting.md](./railway-troubleshooting.md).
