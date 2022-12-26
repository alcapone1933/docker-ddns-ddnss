#!/usr/bin/env bash
DATUM=$(date +%Y-%m-%d\ %H:%M:%S)
if ! curl -sSL --user-agent "${CURL_USER_AGENT}" --fail "https://ddnss.de" > /dev/null; then
    echo "$DATUM  FEHLER !!!  - 404 Sie haben kein Netzwerk oder Internetzugang oder die Webseite ddnss.de ist nicht erreichbar"
	exit 0
fi
