# Railway CLI / API — automate Keycloak setup

You do not need to paste variables in the dashboard. Use the **Railway CLI** (recommended) or the **GraphQL API**.

## One-time install + login

```bash
brew install railway
railway login
```

## Option A — existing project (you already deployed from GitHub)

```bash
cd ~/Documents/GitHub/id-dixon-xyz
railway link                    # pick project + keycloak service
./scripts/railway-configure.sh  # sets all vars + redeploys
```

With a custom domain already attached:

```bash
KC_HOSTNAME=https://id.dixon.xyz ./scripts/railway-configure.sh
```

Optional overrides:

```bash
RAILWAY_SERVICE=keycloak \
RAILWAY_POSTGRES_SERVICE=Postgres \
KC_BOOTSTRAP_ADMIN_PASSWORD='your-secret' \
KC_HOSTNAME=https://id.dixon.xyz \
./scripts/railway-configure.sh
```

## Option B — brand-new project from scratch

```bash
cd ~/Documents/GitHub/id-dixon-xyz
./scripts/railway-bootstrap.sh
```

Creates project, Postgres, GitHub service, domain, and applies Keycloak env vars.

## What the configure script sets

| Variable | Value |
|----------|--------|
| `PORT` | `9000` (healthcheck on management port) |
| `KC_DB_URL` | `jdbc:postgresql://${{Postgres.RAILWAY_PRIVATE_DOMAIN}}:5432/${{Postgres.PGDATABASE}}` |
| `KC_DB_USERNAME` / `KC_DB_PASSWORD` | `${{Postgres.PGUSER}}` / `${{Postgres.PGPASSWORD}}` |
| `KC_PROXY_HEADERS` | `xforwarded` |
| `KC_HOSTNAME` | full `https://...` URL |
| `KC_BOOTSTRAP_ADMIN_*` | generated unless you pass a password |

## Useful CLI commands

```bash
railway status                          # linked project/service
railway service list                    # all services
railway variable list --service keycloak --kv
railway logs --service keycloak
railway redeploy --service keycloak -y
railway domain list --service keycloak
railway open                            # dashboard
```

## GraphQL API (CI / custom tooling)

- Endpoint: `https://backboard.railway.app/graphql/v2`
- Token: Railway dashboard → Account → **Tokens** (or project token for deploy-only)

Example — set a variable:

```bash
curl -sS -X POST https://backboard.railway.app/graphql/v2 \
  -H "Authorization: Bearer $RAILWAY_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"query":"mutation { variableUpsert(input: { projectId: \"PROJECT_ID\", environmentId: \"ENV_ID\", serviceId: \"SERVICE_ID\", name: \"PORT\", value: \"9000\" }) }"}'
```

Explore the schema:

```bash
railway api search variableUpsert
railway api describe variableUpsert
```

## Infrastructure as Code (advanced)

Railway can manage the whole project from code:

```bash
npm install railway
railway config init          # creates .railway/railway.ts
railway config pull          # import current dashboard state
railway config plan          # preview changes
railway config apply --yes   # apply
```

See [Railway Infrastructure as Code](https://docs.railway.com/guides/infrastructure-as-code).

## CI deploy token

For GitHub Actions without interactive login:

```bash
RAILWAY_TOKEN=xxx railway up --service keycloak
```

Create project tokens in Railway → Project → Settings → Tokens.
