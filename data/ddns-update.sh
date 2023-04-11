#!/usr/bin/env bash
PFAD="/data"
DATUM=$(date +%Y-%m-%d\ %H:%M:%S)
if ! curl -4sf --user-agent "${CURL_USER_AGENT}" "https://ddnss.de" 2>&1 > /dev/null; then
    echo "$DATUM  FEHLER !!!  - 404 Sie haben kein Netzwerk oder Internetzugang oder die Webseite ddnss.de ist nicht erreichbar"
    STATUS="OK"
    NAMESERVER_CHECK=$(dig +timeout=1 @ns1.ddnss.de 2> /dev/null)
    echo "$NAMESERVER_CHECK" | grep -s -q "timed out" && { NAMESERVER_CHECK="Timeout" ; STATUS="FAIL" ; }
    if [ "${STATUS}" = "FAIL" ] ; then
        echo "$DATUM  FEHLER !!!  - 404 NAMESERVER ns1.ddnss.de ist nicht ist nicht erreichbar. Sie haben kein Netzwerk oder Internetzugang"
        echo "============================================================================================="
    fi
    if ! curl -4sf "https://google.de" 2>&1 > /dev/null; then
        echo "$DATUM  FEHLER !!!  - 404 Sie haben kein Netzwerk oder Internetzugang oder die Webseite google.de ist nicht erreichbar"
        echo "============================================================================================="
        exit 1
    else
        IP_INFO=$(curl -4sf "https://ipinfo.io/ip" 2>&1)
        UPDIP=$(cat $PFAD/updip.txt)
        echo "$DATUM    INFO !!!  - Die Webseite google.de ist erreichbar. Ihre Aktuelle IP laut IPINFO.IO=$IP_INFO"
        if [ "$IP_INFO" = "$UPDIP" ]; then
            echo > /dev/null
        else
            if [ -z "${SHOUTRRR_URL:-}" ] ; then
                echo > /dev/null
            else
                echo "$DATUM  SHOUTRRR    - SHOUTRRR NACHRICHT wird gesendet"
                DOMAIN_NOTIFY=$(for DOMAIN in $(echo "${DOMAIN_DDNSS}" | sed -e "s/,/ /g"); do echo "DOMAIN: ${DOMAIN} "; done)
                if ! /usr/local/bin/shoutrrr send --url "${SHOUTRRR_URL}" --message "`echo -e "$DATUM    INFO !!! \n\nDDNSS.DE IST NICHT ERREICHBAR \nIHRE Aktuelle IP laut IPINFO.IO=$IP_INFO \n${DOMAIN_NOTIFY}"`" 2> /dev/null; then
                    echo "$DATUM  FEHLER !!!  - SHOUTRRR NACHRICHT konnte nicht gesendet werden"
                else
                    echo "$DATUM  SHOUTRRR    - SHOUTRRR NACHRICHT wurde gesendet"
                fi
            fi
        fi
        echo "$IP_INFO" > $PFAD/updip.txt
        echo "============================================================================================="
        exit 1
    fi
fi

# IP=$(curl -4sSL --user-agent "${CURL_USER_AGENT}" "https://ddnss.de/meineip.php" | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}')
IP=$(curl -4sSL --user-agent "${CURL_USER_AGENT}" "https://ddnss.de/meineip.php" | grep "IP:" | cut -d ">" -f2 | cut -d "<" -f1)
UPDIP=$(cat $PFAD/updip.txt)
sleep 1

function SHOUTRRR_NOTIFY() {
echo "$DATUM  SHOUTRRR    - SHOUTRRR NACHRICHT wird gesendet"
NOTIFY="
DOCKER DDNS UPDATER DDNSS.DE - IP UPDATE !!!
\n
`for DOMAIN in $(echo "${DOMAIN_DDNSS}" | sed -e "s/,/ /g"); do echo "$DATUM  UPDATE !!! \nUpdate IP=$IP - Alte-IP=$UPDIP  \nDOMAIN: ${DOMAIN} \n"; done`"

if ! /usr/local/bin/shoutrrr send --url "${SHOUTRRR_URL}" --message "`echo -e "${NOTIFY}"`" 2> /dev/null; then
    echo "$DATUM  FEHLER !!!  - SHOUTRRR NACHRICHT konnte nicht gesendet werden"
else
    echo "$DATUM  SHOUTRRR    - SHOUTRRR NACHRICHT wurde gesendet"
fi
}

if [ "$IP" == "$UPDIP" ]; then
    echo "$DATUM  KEIN UPDATE - Aktuelle IP=$UPDIP"
else
    echo "$DATUM  UPDATE !!! ..."
    echo "$DATUM  UPDATE !!!  - Update IP=$IP - Alte-IP=$UPDIP"
    sleep 1
    UPDATE_IP=$(curl -4sSLi --user-agent "${CURL_USER_AGENT}" "https://ddnss.de/upd.php?key=${DOMAIN_KEY}&host=${DOMAIN_DDNSS}" | grep -o "good" | tail -n1)
    if [ "$UPDATE_IP" = "good" ]; then
        echo "$DATUM  UPDATE !!!  - UPDATE IP=$IP WURDE AN DDNSS.DE GESENDET"
        if [ -z "${SHOUTRRR_URL:-}" ] ; then
            echo > /dev/null
        else
            SHOUTRRR_NOTIFY
        fi
        echo "$IP" > $PFAD/updip.txt
    else
        echo "$DATUM  FEHLER !!!  - UPDATE IP=$IP WURDE NICHT AN DDNSS.DE GESENTET"
        if [ -z "${SHOUTRRR_URL:-}" ] ; then
             echo > /dev/null
        else
            echo "$DATUM  SHOUTRRR    - SHOUTRRR NACHRICHT wird gesendet"
            DOMAIN_NOTIFY=$(for DOMAIN in $(echo "${DOMAIN_DDNSS}" | sed -e "s/,/ /g"); do echo "DOMAIN: ${DOMAIN} "; done)
            if ! /usr/local/bin/shoutrrr send --url "${SHOUTRRR_URL}" --message "`echo -e "$DATUM    INFO !!! \n\nUPDATE IP=$IP WURDE NICHT AN DDNSS.DE GESENTET \n${DOMAIN_NOTIFY}"`" 2> /dev/null; then
                echo "$DATUM  FEHLER !!!  - NACHRICHT konnte nicht gesendet werden"
            else
                echo "$DATUM  SHOUTRRR    - SHOUTRRR NACHRICHT wurde gesendet"
            fi
        fi
    fi
fi
echo "============================================================================================="
sleep 5
# Nachpruefung ob der DOMAIN Eintrag richtig gesetzt ist
function CHECK_A_DOMAIN() {
DATUM=$(date +%Y-%m-%d\ %H:%M:%S)
UPDIP=$(cat $PFAD/updip.txt)
# IP=$(curl -4sSL --user-agent "${CURL_USER_AGENT}" "https://ddnss.de/meineip.php" | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}')
IP=$(curl -4sSL --user-agent "${CURL_USER_AGENT}" "https://ddnss.de/meineip.php" | grep "IP:" | cut -d ">" -f2 | cut -d "<" -f1)
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
        echo "$DATUM  UPDATE !!!  - UPDATE IP=$IP WURDE AN DDNSS.DE GESENDET"
        if [ -z "${SHOUTRRR_URL:-}" ] ; then
            echo > /dev/null
        else
            SHOUTRRR_NOTIFY
        fi
        echo "$IP" > $PFAD/updip.txt
        sleep 15
        for DOMAIN in $(echo "${DOMAIN_DDNSS}" | sed -e "s/,/ /g"); do echo "$DATUM  NACHEINTRAG - DOMAIN HAT DEN A-RECORD=`dig +noall +answer ${DOMAIN} A @ns1.ddnss.de`"; done
    else
        echo "$DATUM  FEHLER !!!  - UPDATE IP=$IP WURDE NICHT AN DDNSS.DE GESENTET"
        if [ -z "${SHOUTRRR_URL:-}" ] ; then
             echo > /dev/null
        else
            echo "$DATUM  SHOUTRRR    - SHOUTRRR NACHRICHT wird gesendet"
            DOMAIN_NOTIFY=$(for DOMAIN in $(echo "${DOMAIN_DDNSS}" | sed -e "s/,/ /g"); do echo "DOMAIN: ${DOMAIN} "; done)
            if ! /usr/local/bin/shoutrrr send --url "${SHOUTRRR_URL}" --message "`echo -e "$DATUM    INFO !!! \n\nUPDATE IP=$IP WURDE NICHT AN DDNSS.DE GESENTET \n${DOMAIN_NOTIFY}"`" 2> /dev/null; then
                echo "$DATUM  FEHLER !!!  - NACHRICHT konnte nicht gesendet werden"
            else
                echo "$DATUM  SHOUTRRR    - SHOUTRRR NACHRICHT wurde gesendet"
            fi
        fi
    fi
fi
}

if [[ "$IP_CHECK" =~ (YES|yes|Yes) ]] ; then
    CHECK_A_DOMAIN
else
    echo > /dev/null
fi

echo "============================================================================================="
