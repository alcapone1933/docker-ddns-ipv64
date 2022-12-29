#!/usr/bin/env bash
DATUM=$(date +%Y-%m-%d\ %H:%M:%S)
set -e
if ! curl -sSL --user-agent "${CURL_USER_AGENT}" --fail "https://ipv64.net" 2>&1 > /dev/null; then
    echo "$DATUM  FEHLER !!!  - 404 Sie haben kein Netzwerk oder Internetzugang oder die Webseite ipv64.net ist nicht erreichbar"
    exit 0
fi
