# Keycloak IdP for id.dixon.xyz — Railway / local Docker
FROM quay.io/keycloak/keycloak:26.0.7 AS builder

ENV KC_DB=postgres
RUN /opt/keycloak/bin/kc.sh build

FROM quay.io/keycloak/keycloak:26.0.7

COPY --from=builder /opt/keycloak/ /opt/keycloak/
COPY realm/ /opt/keycloak/data/import/

ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true
ENV KC_HTTP_ENABLED=true

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
CMD ["start", "--import-realm"]
