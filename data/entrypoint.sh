#!/usr/bin/env bash
# set -x
# set -e
DATUM=$(date +%Y-%m-%d\ %H:%M:%S)
# cleanup
cleanup() {
    echo "============================================================================================="
    echo "================================  STOP DDNS UPDATER DDNSS.DE ================================"
    echo "============================================================================================="
    echo "=========================  ######     #######    #######    #######  ========================"
    echo "=========================  #     #       #       #     #    #     #  ========================"
    echo "=========================  #             #       #     #    #     #  ========================"
    echo "=========================   #####        #       #     #    ######   ========================"
    echo "=========================        #       #       #     #    #        ========================"
    echo "=========================  #     #       #       #     #    #        ========================"
    echo "=========================   #####        #       #######    #        ========================"
    echo "============================================================================================="
    echo "============================================================================================="
}

# Trap SIGTERM
trap 'cleanup' SIGTERM
sleep 5
echo "=============================================================================================="
echo "================================ START DDNS UPDATER DDNSS.DE ================================"
echo "============================================================================================="
echo "================  ########     ########     ##    ##     ######      ######   ==============="
echo "================  ##     ##    ##     ##    ###   ##    ##    ##    ##    ##  ==============="
echo "================  ##     ##    ##     ##    ####  ##    ##          ##        ==============="
echo "================  ##     ##    ##     ##    ## ## ##     ######      ######   ==============="
echo "================  ##     ##    ##     ##    ##  ####          ##          ##  ==============="
echo "================  ##     ##    ##     ##    ##   ###    ##    ##    ##    ##  ==============="
echo "================  ########     ########     ##    ##     ######      ######   ==============="
echo "============================================================================================="

# echo -n "" > /data/log/cron.log
sleep 5
################################
# Set user and group ID
if [ "$PUID" != "0" ] || [ "$PGID" != "0" ]; then
    chown -R "$PUID":"$PGID" /data
    if [ ! -d "/data/log" ]; then
        install -d -o $PUID -g $PGID -m 755 /data/log
    fi
    if [ ! -f "/data/log/cron.log" ]; then
        install -o $PUID -g $PGID -m 644 /dev/null /data/log/cron.log
    fi
    if [ ! -f "/data/updip.txt" ]; then
        install -o $PUID -g $PGID -m 644 /dev/null /data/updip.txt
    fi
    echo "$DATUM  RECHTE      - Ornder /data UID: $PUID and GID: $PGID"
fi
if [ ! -d "/data/log" ]; then
    install -d -o $PUID -g $PGID -m 755 /data/log
fi
if [ ! -f "/data/log/cron.log" ]; then
    install -o $PUID -g $PGID -m 644 /dev/null /data/log/cron.log
fi
################################
MAX_LINES=1 /usr/local/bin/log-rotate.sh
################################
if [ -z "${DOMAIN_DDNSS:-}" ] ; then
    echo "$DATUM  DOMAIN      - Sie haben keine DOMAIN gesetzt, schauen die unter https://ddnss.de/ua/vhosts_list.php nach bei vHostname"
    sleep infinity
else
    echo "$DATUM  DOMAIN      - Sie haben eine DOMAIN gesetzt"
    for DOMAIN in $(echo "${DOMAIN_DDNSS}" | sed -e "s/,/ /g"); do echo "$DATUM  DOMAIN      - Deine DOMAIN ${DOMAIN}"; done
fi

if [ -z "${DOMAIN_KEY:-}" ] ; then
    echo "$DATUM  DOMAIN KEY  - Sie haben keinen DOMAIN Key gesetzt, schauen die unter https://ddnss.de/ua/index.php nach bei Update Key"
    sleep infinity
else
    echo "$DATUM  DOMAIN KEY  - Sie haben einen DOMAIN Key gesetzt"
fi

if [ -z "${CRON_TIME:-}" ] ; then
    echo "$DATUM  FEHLER !!!  - Sie haben die Environment CRON_TIME nicht gesetzt"
    sleep infinity
fi

if [ -z "${CRON_TIME_DIG:-}" ] ; then
    echo "$DATUM  FEHLER !!!  - Sie haben die Environment CRON_TIME_DIG nicht gesetzt"
    sleep infinity
fi

while true; do
    if ! curl -4sf --user-agent "${CURL_USER_AGENT}" "https://ddnss.de" 2>&1 > /dev/null; then
        echo "$DATUM  FEHLER !!!  - 404 Sie haben kein Netzwerk oder Internetzugang oder die Webseite ddnss.de ist nicht erreichbar"
        sleep 900
        echo "============================================================================================="
    else
        break
    fi
done
while true; do
    STATUS="OK"
    NAMESERVER_CHECK=$(dig +timeout=1 @${NAME_SERVER} 2> /dev/null)
    echo "$NAMESERVER_CHECK" | grep -s -q "timed out" && { NAMESERVER_CHECK="Timeout" ; STATUS="FAIL" ; }
    if [ "${STATUS}" = "FAIL" ] ; then
        echo "$DATUM  FEHLER !!!  - 404 NAMESERVER ${NAME_SERVER} ist nicht ist nicht erreichbar. Sie haben kein Netzwerk oder Internetzugang"
        sleep 900
        echo "============================================================================================="
    else
        break
    fi
done

if [ -z "${SHOUTRRR_URL:-}" ] ; then
    echo "$DATUM  SHOUTRRR    - Sie haben keine SHOUTRRR URL gesetzt"
else
    echo "$DATUM  SHOUTRRR    - Sie haben eine  SHOUTRRR URL gesetzt"
    if [[ "${SHOUTRRR_SKIP_TEST}" =~ (NO|no|No) ]] ; then
        if ! /usr/local/bin/shoutrrr send --url "${SHOUTRRR_URL}" --message "`echo -e "$DATUM  TEST !!! \nDDNS Updater in Docker fuer Free DynDNS DDNSS.DE"`" 2> /dev/null; then
            echo "$DATUM  FEHLER !!!  - Die Angaben sind falsch  gesetzt: SHOUTRRR URL"
            echo "$DATUM    INFO !!!  - Schaue unter https://containrrr.dev/shoutrrr/ nach dem richtigen URL Format"
            echo "$DATUM    INFO !!!  - Stoppen sie den Container und Starten sie den Container mit den richtigen Angaben erneut"
            sleep infinity
        else
            echo "$DATUM  CHECK       - Die Angaben sind richtig gesetzt: SHOUTRRR URL"
        fi
    else
        echo "$DATUM  SHOUTRRR    - Sie haben die Shoutrrr Testnachricht übersprungen."
    fi
fi

# IP=$(curl -4sSL --user-agent "${CURL_USER_AGENT}" "https://ddnss.de/meineip.php" | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}')
IP=$(curl -4sSL --user-agent "${CURL_USER_AGENT}" "https://ddnss.de/meineip.php" | grep "IP:" | cut -d ">" -f2 | cut -d "<" -f1)

function Domain_default() {
if [ -f /etc/.firstrun ]; then
    CHECK=$(curl -4sSLi --user-agent "${CURL_USER_AGENT}" "https://ddnss.de/upd.php?key=${DOMAIN_KEY}&host=${DOMAIN_DDNSS}" | grep -o "good" | tail -n1)
    if [ "$CHECK" = "good" ] ; then
        echo "$DATUM  CHECK       - Die Angaben sind richtig gesetzt: DOMAIN und DOMAIN KEY"
        sleep 5
        if [[ "$IP_CHECK" =~ (YES|yes|Yes) ]] ; then
            for DOMAIN in $(echo "${DOMAIN_DDNSS}" | sed -e "s/,/ /g"); do echo "$DATUM  IP CHECK    - Deine DOMAIN ${DOMAIN} HAT DIE IP=`dig +short ${DOMAIN} A @${NAME_SERVER}`"; done
        else
            echo > /dev/null
        fi   
        echo "${IP}" > /data/updip.txt
        sleep 2
        rm /etc/.firstrun
    else
        echo "$DATUM  FEHLER !!!  - Die Angaben sind falsch  gesetzt: DOMAIN oder DOMAIN KEY"
        echo "$DATUM    INFO !!!  - Stoppen sie den Container und Starten sie den Container mit den richtigen Angaben erneut"
        return
    fi
else
    echo "$DATUM  CHECK       - Die Angaben sind richtig gesetzt: DOMAIN und DOMAIN KEY"
fi

echo "${CRON_TIME} /bin/bash /usr/local/bin/ddns-update.sh >> /data/log/cron.log 2>&1" > /etc/cron.d/container_cronjob
if [[ "$IP_CHECK" =~ (YES|yes|Yes) ]] ; then
    echo "${CRON_TIME_DIG} sleep 20 && /bin/bash /usr/local/bin/domain-ip-scheck.sh >> /data/log/cron.log 2>&1" >> /etc/cron.d/container_cronjob
else
    echo > /dev/null
fi
# echo "$CRON_TIME_DIG" 'sleep 20 && for DOMAIN in $(echo "${DOMAIN_DDNSS}" | sed -e "s/,/ /g"); do echo "`date +%Y-%m-%d\ %H:%M:%S`  IP CHECK    - Deine DOMAIN ${DOMAIN} HAT DIE IP=`dig +short ${DOMAIN} A @${NAME_SERVER}`" >> /data/log/cron.log 2>&1; done' >> /etc/cron.d/container_cronjob
}

Domain_default

echo "*/30 * * * * /usr/local/bin/log-rotate.sh" >> /etc/cron.d/container_cronjob

/usr/bin/crontab /etc/cron.d/container_cronjob
/usr/sbin/crond
echo "============================================================================================="
set tail -f /data/log/cron.log "$@"
exec "$@" &

wait $!
