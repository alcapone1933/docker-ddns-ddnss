#!/usr/bin/env bash
# set -x
set -e
DATUM=$(date +%Y-%m-%d\ %H:%M:%S)
# cleanup
cleanup() {
    echo "================================  STOP DDNS UPDATER DDNSS.DE ================================"
}

# Trap SIGTERM
trap 'cleanup' SIGTERM

echo -n "" > /var/log/cron.log
sleep 10
echo "================================ START DDNS UPDATER DDNSS.DE ================================"

if [ -z "${DOMAIN_DDNSS:-}" ] ; then
    echo "$DATUM  DOMAIN      - Sie haben keine DOMAIN gesetzt, schauen die unter https://ddnss.de/ua/vhosts_list.php nach bei vHostname"
    exit 1
else
    echo "$DATUM  DOMAIN      - Sie haben eine DOMAIN gesetzt"
    for DOMAIN in $(echo "${DOMAIN_DDNSS}" | sed -e "s/,/ /g"); do echo "$DATUM  DOMAIN      - Deine DOMAIN ${DOMAIN}"; done
fi

if [ -z "${DOMAIN_KEY:-}" ] ; then
    echo "$DATUM  DOMAIN KEY  - Sie haben keinen DOMAIN Key gesetzt, schauen die unter https://ddnss.de/ua/index.php nach bei Update Key"
    exit 1
else
    echo "$DATUM  DOMAIN KEY  - Sie haben einen DOMAIN Key gesetzt"
fi

if ! curl -sSL --user-agent "${CURL_USER_AGENT}" --fail "https://ddnss.de" > /dev/null; then
    echo "$DATUM  FEHLER !!!  - 404 Sie haben kein Netzwerk oder Internetzugang oder die Webseite ddnss.de ist nicht erreichbar"
	exit 0
fi

# IP=$(curl -4ssL --user-agent "${CURL_USER_AGENT}" "https://ddnss.de/meineip.php" | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}')
IP=$(curl -4ssL --user-agent "${CURL_USER_AGENT}" "https://ddnss.de/meineip.php" | grep "IP:" | cut -d ">" -f2 | cut -d "<" -f1)

function Domain_default() {
CHECK=$(curl -4sSLi --user-agent "${CURL_USER_AGENT}" "https://ddnss.de/upd.php?key=${DOMAIN_KEY}&host=${DOMAIN_DDNSS}" | grep -o "good" | tail -n1)
if [ "$CHECK" = "good" ] ; then
    echo "$DATUM  CHECK       - Die Angaben sind richtig gesetzt: DOMAIN und DOMAIN KEY"
    sleep 5
    for DOMAIN in $(echo "${DOMAIN_DDNSS}" | sed -e "s/,/ /g"); do echo "$DATUM  IP CHECK    - Deine DOMAIN ${DOMAIN} HAT DIE IP=`dig +short ${DOMAIN} A @ns1.ddnss.de`"; done
else
    echo "$DATUM  FEHLER !!!  - Die Angaben sind falsch  gesetzt: DOMAIN oder DOMAIN KEY"
    exit 1
fi
echo "${CRON_TIME} /bin/bash /data/ddns-update.sh >> /var/log/cron.log 2>&1" > /etc/cron.d/container_cronjob
echo "$CRON_TIME_DIG" 'sleep 20 && for DOMAIN in $(echo "${DOMAIN_DDNSS}" | sed -e "s/,/ /g"); do echo "`date +%Y-%m-%d\ %H:%M:%S`  IP CHECK    - Deine DOMAIN ${DOMAIN} HAT DIE IP=`dig +short ${DOMAIN} A @ns1.ddnss.de`" >> /var/log/cron.log 2>&1; done' >> /etc/cron.d/container_cronjob
}

Domain_default

echo "${IP}" > /data/updip.txt
sleep 2

/usr/bin/crontab /etc/cron.d/container_cronjob
/usr/sbin/crond

set tail -f /var/log/cron.log "$@"
exec "$@" &

wait $!
