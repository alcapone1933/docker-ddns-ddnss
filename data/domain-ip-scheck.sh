#!/usr/bin/env bash
# set -e
DATUM=$(date +%Y-%m-%d\ %H:%M:%S)
if ! curl -4sf --user-agent "${CURL_USER_AGENT}" "https://ddnss.de" 2>&1 > /dev/null; then
    echo "$DATUM  FEHLER !!!  - 404 Sie haben kein Netzwerk oder Internetzugang oder die Webseite ddnss.de ist nicht erreichbar"
    exit 1
fi
STATUS="OK"
NAMESERVER_CHECK=$(dig +timeout=1 @ns1.ddnss.de 2> /dev/null)
echo "$NAMESERVER_CHECK" | grep -s -q "timed out" && { NAMESERVER_CHECK="Timeout" ; STATUS="FAIL" ; }
if [ "${STATUS}" = "FAIL" ] ; then
    echo "$DATUM  FEHLER !!!  - 404 NAMESERVER ns1.ddnss.de ist nicht ist nicht erreichbar. Sie haben kein Netzwerk oder Internetzugang"
    exit 1
fi

for DOMAIN in $(echo "${DOMAIN_DDNSS}" | sed -e "s/,/ /g");
do
    echo "$DATUM  IP CHECK    - Deine DOMAIN ${DOMAIN} HAT DIE IP=`dig +short ${DOMAIN} A @ns1.ddnss.de`" >> /var/log/cron.log 2>&1
done
echo "============================================================================================="
