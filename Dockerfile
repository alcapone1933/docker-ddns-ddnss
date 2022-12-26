FROM alpine:latest

LABEL maintainer="alcapone1933 <alcapone1933@cosanostra-cloud.de>" \
      org.opencontainers.image.created="$(date +%Y-%m-%d\ %H:%M)" \
      org.opencontainers.image.authors="alcapone1933 <alcapone1933@cosanostra-cloud.de>" \
      org.opencontainers.image.url="https://hub.docker.com/r/alcapone1933/ddns-ddnss" \
      org.opencontainers.image.version="v0.0.1" \
      org.opencontainers.image.ref.name="alcapone1933/ddns-ddnss" \
      org.opencontainers.image.title="DDNS Updater ddnss.de" \
      org.opencontainers.image.description="DDNS Updater fuer ddnss.de ONLY IPV4"

ENV TZ=Europe/Berlin
ENV CRON_TIME="*/15 * * * *"
ENV CRON_TIME_DIG="*/30 * * * *"
ENV VERSION="v0.0.1"
ENV CURL_USER_AGENT="docker-ddns-ipv64/version=$VERSION github.com/alcapone1933/docker-ddns-ddnss"
RUN apk add --update --no-cache tzdata curl bash tini bind-tools && \
    rm -rf /var/cache/apk/*

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN mkdir -p /data /usr/local/bin/ /etc/cron.d/
COPY data /data
RUN mv /data/entrypoint.sh /usr/local/bin/entrypoint.sh && mv /data/cronjob /etc/cron.d/container_cronjob && mv /data/healthcheck.sh /usr/local/bin/healthcheck.sh  && \
    chmod 755 /data/ddns-update.sh && chmod 755 /usr/local/bin/entrypoint.sh && chmod 755 /usr/local/bin/healthcheck.sh && \
    chmod 755 /etc/cron.d/container_cronjob && touch /var/log/cron.log

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/entrypoint.sh"]
