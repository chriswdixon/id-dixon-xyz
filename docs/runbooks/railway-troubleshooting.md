# Railway Keycloak — troubleshooting crashes

## Crash: `KC_DB_URL is not set` / JDBC errors

**Cause:** Postgres variables missing or wrong format.

**Fix:** Set exactly:

```
KC_DB_URL=jdbc:postgresql://${{Postgres.RAILWAY_PRIVATE_DOMAIN}}:5432/${{Postgres.PGDATABASE}}
KC_DB_USERNAME=${{Postgres.PGUSER}}
KC_DB_PASSWORD=${{Postgres.PGPASSWORD}}
```

Use Railway **reference variables** (`${{Postgres.*}}`), not raw `DATABASE_URL`.

---

## Crash: `Port(s) already bound: 8080`

**Cause:** Railway `PORT` conflicts with Keycloak HTTP port.

**Fix:**

- Set `PORT=9000` (healthcheck only)
- Do **not** set `KC_HTTP_PORT` to Railway's dynamic PORT
- Domain **target port** stays **8080**

---

## Deploy loops / healthcheck never passes

**Cause:** Healthcheck probes port 8080 but Keycloak 26+ serves `/health/ready` on **9000**.

**Fix:** `PORT=9000` + healthcheck path `/health/ready`.

---

## Crash: `Failed to obtain JDBC connection`

**Cause:** Using public Postgres host instead of private network.

**Fix:** Use `${{Postgres.RAILWAY_PRIVATE_DOMAIN}}` in `KC_DB_URL`.

Ensure Postgres and Keycloak are in the **same Railway project/environment**.

---

## Crash: OOM / exit 137 / JVM killed

**Cause:** Keycloak JVM needs ~512MB–1GB minimum.

**Fix:** Keycloak service → Settings → Resources → **1 GB RAM** (2 GB if still failing).

---

## Crash: strict hostname / redirect loops

**Cause:** `KC_HOSTNAME` doesn't match the URL you open.

**Fix:**

1. Use full URL: `https://your-app.up.railway.app` (not bare hostname)
2. Match custom domain exactly after DNS cutover
3. Temporarily set `KC_HOSTNAME_STRICT=false` while debugging

---

## Crash: `HTTP relative path` / production mode refuses HTTP

**Cause:** Missing proxy settings behind Railway TLS edge.

**Fix:**

```
KC_HTTP_ENABLED=true
KC_PROXY_HEADERS=xforwarded
KC_PROXY_TRUSTED_ADDRESSES=100.64.0.0/10,fd00::/8
```

---

## Realm import warnings

`--import-realm` only creates the realm on **first** boot. Re-import failures on redeploy are usually safe to ignore.

To reset: delete Postgres volume / recreate database (destroys all Keycloak data).

---

## Still stuck?

Paste the last ~30 lines of **Deploy Logs** from Railway — look for the first `ERROR` line from `org.keycloak` or `Quarkus`.
