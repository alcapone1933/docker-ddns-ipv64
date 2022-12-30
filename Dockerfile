FROM alcapone1933/alpine:latest
# ipv64.net 
LABEL maintainer="alcapone1933 <alcapone1933@cosanostra-cloud.de>" \
      org.opencontainers.image.created="$(date +%Y-%m-%d\ %H:%M)" \
      org.opencontainers.image.authors="alcapone1933 <alcapone1933@cosanostra-cloud.de>" \
      org.opencontainers.image.url="https://hub.docker.com/r/alcapone1933/ddns-ipv64" \
      org.opencontainers.image.version="v0.1.0" \
      org.opencontainers.image.ref.name="alcapone1933/ddns-ipv64" \
      org.opencontainers.image.title="DDNS Updater ipv64.net" \
      org.opencontainers.image.description="Community DDNS Updater fuer ipv64.net"

ENV TZ=Europe/Berlin \
    CRON_TIME="*/15 * * * *" \
    CRON_TIME_DIG="*/30 * * * *" \
    VERSION="v0.1.0" \
    CURL_USER_AGENT="docker-ddns-ipv64/version=$VERSION github.com/alcapone1933/docker-ddns-ipv64" \
    SHOUTRRR_URL=""

RUN apk add --update --no-cache tzdata curl bash tini bind-tools jq && \
    rm -rf /var/cache/apk/*

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    mkdir -p /data /usr/local/bin/ /etc/cron.d/
COPY data /data
COPY --from=alcapone1933/shoutrrr:latest /usr/local/bin/shoutrrr /usr/local/bin/shoutrrr
RUN cd /data && chmod +x *.sh && mv /data/entrypoint.sh /usr/local/bin/entrypoint.sh && \
    mv /data/cronjob /etc/cron.d/container_cronjob && mv /data/healthcheck.sh /usr/local/bin/healthcheck.sh && touch /var/log/cron.log
# VOLUME [ "/data" ]

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/entrypoint.sh"]
# HEALTHCHECK --interval=5s --timeout=30s --start-period=5s --retries=3 CMD curl -sSL --user-agent "${CURL_USER_AGENT}" --fail "https://ipv64.net" > /dev/null || exit 1
# HEALTHCHECK --interval=5s --timeout=30s --start-period=5s --retries=2 CMD /usr/local/bin/healthcheck.sh
