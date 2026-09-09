# Match Railway's official Keycloak template: official image + runtime augment (no pre-build).
# https://railway.com/deploy/keycloak-iam
FROM quay.io/keycloak/keycloak:26.7.1

COPY realm/ /opt/keycloak/data/import/
COPY --chmod=755 scripts/docker-entrypoint.sh /docker-entrypoint.sh

ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true
ENV KC_HTTP_ENABLED=true
ENV JAVA_OPTS_APPEND="-XX:MaxRAMPercentage=70.0"

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["start", "--import-realm"]
