# Keycloak IdP for id.dixon.xyz — Railway / local Docker
# Railway guide: https://docs.railway.com/guides/keycloak-authentication
FROM quay.io/keycloak/keycloak:26.3.3 AS builder

ENV KC_DB=postgres
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true
RUN /opt/keycloak/bin/kc.sh build

FROM quay.io/keycloak/keycloak:26.3.3

COPY --from=builder /opt/keycloak/ /opt/keycloak/
COPY realm/ /opt/keycloak/data/import/
COPY --chmod=755 scripts/docker-entrypoint.sh /docker-entrypoint.sh

ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true
ENV KC_HTTP_ENABLED=true
ENV KC_HTTP_PORT=8080

# Keycloak 26+ serves /health/* on management port 9000 (not 8080).
# Railway probes $PORT — set PORT=9000 in Railway service variables.
ENV PORT=9000

# Fit small Railway instances (adjust if you scale up)
ENV JAVA_OPTS_APPEND="-XX:MaxRAMPercentage=70.0 -XX:InitialRAMPercentage=50.0"

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["start", "--import-realm", "--optimized"]
