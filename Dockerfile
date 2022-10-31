FROM alpine:latest
# ipv64.net 
LABEL maintainer="alcapone1933 <alcapone1933@cosanostra-cloud.de>" \
      org.opencontainers.image.created="$(date +%Y-%m-%d\ %H:%M)" \
      org.opencontainers.image.authors="alcapone1933 <alcapone1933@cosanostra-cloud.de>" \
      org.opencontainers.image.url="https://hub.docker.com/r/alcapone1933/ddns-ipv64" \
      org.opencontainers.image.version="v0.0.3" \
      org.opencontainers.image.ref.name="alcapone1933/ddns-ipv64" \
      org.opencontainers.image.title="DDNS Updater ipv64.net" \
      org.opencontainers.image.description="Community DDNS Updater fuer ipv64.net"

ENV TZ=Europe/Berlin
ENV CRON_TIME="*/15 * * * *"
ENV CRON_TIME_DIG="*/30 * * * *"
RUN apk add --update --no-cache tzdata curl bash tini bind-tools && \
    rm -rf /var/cache/apk/*

RUN mkdir -p /data /usr/local/bin/ /etc/cron.d/
COPY data /data
RUN mv /data/entrypoint.sh /usr/local/bin/entrypoint.sh && mv /data/cronjob /etc/cron.d/container_cronjob && mv /data/healthcheck.sh /usr/local/bin/healthcheck.sh  && \
    chmod 755 /data/ddns-update.sh &&  chmod 755 /usr/local/bin/entrypoint.sh && chmod 755 /usr/local/bin/healthcheck.sh && \
    chmod 755 /etc/cron.d/container_cronjob && touch /var/log/cron.log
# VOLUME [ "/data" ]

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/entrypoint.sh"]
HEALTHCHECK --interval=5s --timeout=30s --start-period=5s --retries=3 CMD curl -sSL --fail https://ipv64.net/ > /dev/null || exit 1
# HEALTHCHECK --interval=5s --timeout=30s --start-period=5s --retries=2 CMD /usr/local/bin/healthcheck.sh
