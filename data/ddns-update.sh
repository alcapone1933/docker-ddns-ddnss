#!/usr/bin/env bash
set -e
DATUM=$(date +%Y-%m-%d\ %H:%M:%S)
if ! curl -sSL --user-agent "${CURL_USER_AGENT}" --fail "https://ddnss.de" > /dev/null; then
    echo "$DATUM  FEHLER !!!  - 404 Sie haben kein Netzwerk oder Internetzugang oder die Webseite ddnss.de ist nicht erreichbar"
	exit 0
fi
PFAD="/data"
# IP=$(curl -4ssL --user-agent "${CURL_USER_AGENT}" "https://ddnss.de/meineip.php" | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}')
IP=$(curl -4ssL --user-agent "${CURL_USER_AGENT}" "https://ddnss.de/meineip.php" | grep "IP:" | cut -d ">" -f2 | cut -d "<" -f1)
UPDIP=$(cat $PFAD/updip.txt)

sleep 1

if [ "$IP" == "$UPDIP" ]; then
    echo "$DATUM  KEIN UPDATE - Aktuelle IP=$UPDIP"
else
    echo "$DATUM  UPDATE !!! ..."
    echo "$DATUM  UPDATE !!!  - Update IP=$IP - Alte-IP=$UPDIP"
    sleep 1
    echo "$IP" > $PFAD/updip.txt
    UPDATE_IP=$(curl -4sSLi --user-agent "${CURL_USER_AGENT}" "https://ddnss.de/upd.php?key=${DOMAIN_KEY}&host=${DOMAIN_DDNSS}" | grep -o "good" | tail -n1)
    if [ "$UPDATE_IP" = "good" ]; then
        echo "$DATUM  UPDATE !!!  - UPDATE IP=$IP AN DDNSS.DE GESENDET"
    else
        echo "$DATUM  UPDATE !!!  - UPDATE IP=$IP NICHT GESENTET"
    fi
fi
sleep 5
# Nachpruefung ob der DOMAIN Eintrag richtig gesetzt ist
function CHECK_A_DOMAIN() {
DATUM=$(date +%Y-%m-%d\ %H:%M:%S)
UPDIP=$(cat $PFAD/updip.txt)
# IP=$(curl -4ssL --user-agent "${CURL_USER_AGENT}" "https://ddnss.de/meineip.php" | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}')
IP=$(curl -4ssL --user-agent "${CURL_USER_AGENT}" "https://ddnss.de/meineip.php" | grep "IP:" | cut -d ">" -f2 | cut -d "<" -f1)
DOMAIN_CHECK=$(for DOMAIN in $(echo "${DOMAIN_DDNSS}" | sed -e "s/,/ /g"); do dig +short ${DOMAIN} A @ns1.ddnss.de; done | tail -n 1)
sleep 1
if [ "$IP" == "$DOMAIN_CHECK" ]; then
    for DOMAIN in $(echo "${DOMAIN_DDNSS}" | sed -e "s/,/ /g"); do echo "$DATUM  CHECK       - DOMAIN HAT DEN A-RECORD=`dig +noall +answer ${DOMAIN} A @ns1.ddnss.de`"; done
else
    echo "$DATUM  UPDATE !!! ..."
    echo "$DATUM  UPDATE !!!  - NACHEINTRAG DIE IP WIRD NOCH EINMAL GESETZT"
    echo "$DATUM  UPDATE !!!  - Update IP=$IP - Alte-IP=$UPDIP"
    sleep 5
    UPDATE_IP=$(curl -4sSLi --user-agent "${CURL_USER_AGENT}" "https://ddnss.de/upd.php?key=${DOMAIN_KEY}&host=${DOMAIN_DDNSS}" | grep -o "good" | tail -n1)
    if [ "$UPDATE_IP" = "good" ]; then
        echo "$DATUM  UPDATE !!!  - UPDATE IP=$IP AN DDNSS.DE GESENDET"
    else
        echo "$DATUM  UPDATE !!!  - UPDATE IP=$IP NICHT GESENTET"
    fi
    sleep 15
    for DOMAIN in $(echo "${DOMAIN_DDNSS}" | sed -e "s/,/ /g"); do echo "$DATUM  NACHEINTRAG - DOMAIN HAT DEN A-RECORD=`dig +noall +answer ${DOMAIN} A @ns1.ddnss.de`"; done
fi
}
CHECK_A_DOMAIN
