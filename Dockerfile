FROM alcapone1933/alpine:latest

LABEL maintainer="alcapone1933 <alcapone1933@cosanostra-cloud.de>" \
      org.opencontainers.image.created="$(date +%Y-%m-%d\ %H:%M)" \
      org.opencontainers.image.authors="alcapone1933 <alcapone1933@cosanostra-cloud.de>" \
      org.opencontainers.image.url="https://hub.docker.com/r/alcapone1933/ddns-ddnss" \
      org.opencontainers.image.version="v0.0.2" \
      org.opencontainers.image.ref.name="alcapone1933/ddns-ddnss" \
      org.opencontainers.image.title="DDNS Updater ddnss.de" \
      org.opencontainers.image.description="DDNS Updater fuer ddnss.de ONLY IPV4"

ENV TZ=Europe/Berlin \
    CRON_TIME="*/15 * * * *" \
    CRON_TIME_DIG="*/30 * * * *" \
    VERSION="v0.0.2" \
    CURL_USER_AGENT="docker-ddns-ipv64/version=v0.0.2 github.com/alcapone1933/docker-ddns-ddnss" \
    SHOUTRRR_URL=""
RUN apk add --update --no-cache tzdata curl bash tini bind-tools jq && \
    rm -rf /var/cache/apk/*

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN mkdir -p /data /usr/local/bin/ /etc/cron.d/
COPY data /data
COPY --from=alcapone1933/shoutrrr:latest /usr/local/bin/shoutrrr /usr/local/bin/shoutrrr
RUN cd /data && chmod +x *.sh &&  mv /data/entrypoint.sh /usr/local/bin/entrypoint.sh && \
    mv /data/cronjob /etc/cron.d/container_cronjob && mv /data/healthcheck.sh /usr/local/bin/healthcheck.sh  && touch /var/log/cron.log

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/entrypoint.sh"]
