# id.dixon.xyz — Personal SAML IdP

Self-hosted Keycloak on Railway plus a free Okta Integrator dev tenant, for testing a WordPress VIP SAML plugin based on [Human Made wp-simple-saml](https://github.com/humanmade/wp-simple-saml).

**Not part of Cesco.** Separate from `cesco-marketing`.

## Architecture

```
WordPress VIP (SAML SP — your plugin)
        │
        ├── Keycloak @ id.dixon.xyz  (Railway — start/stop for testing)
        └── Okta Integrator Free     (always on — primary test IdP)
```

Switch IdPs on VIP with `VIP_SAML_IDP=okta|keycloak`. See `examples/vip-mu-plugin/sso-config.php`.

## Quick start (local)

```bash
docker compose up --build
```

- Keycloak admin: http://localhost:8080/admin (`admin` / `admin`)
- Realm: `dixon`
- IdP metadata: http://localhost:8080/realms/dixon/protocol/saml/descriptor

Before first deploy, set your WordPress SP URLs:

```bash
export WP_SP_ENTITY_ID=https://your-vip-site.com/
./scripts/configure-wp-client.sh realm/dixon-realm.json > realm/dixon-realm-configured.json
```

## Railway deploy

See [docs/runbooks/railway-deploy.md](docs/runbooks/railway-deploy.md). If deploy crashes, see [railway-troubleshooting.md](docs/runbooks/railway-troubleshooting.md).

1. Create Railway project from this repo
2. Add PostgreSQL plugin
3. Set Keycloak env vars from `.env.example`
4. Attach custom domain `id.dixon.xyz`
5. **Stop services when not testing** to save credits

## Okta dev tenant

See [docs/runbooks/okta-setup.md](docs/runbooks/okta-setup.md). Use Okta first — no Railway needed.

## VIP plugin integration

See [docs/runbooks/vip-plugin-integration.md](docs/runbooks/vip-plugin-integration.md).

## Docs

- [Design spec](docs/specs/2026-09-09-idp-design.md)

## License

MIT — personal infrastructure repo.
