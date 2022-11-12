#!/usr/bin/env bash
DATUM=$(date +%Y-%m-%d\ %H:%M:%S)
set -e
if [ -z "${DOMAIN_KEY:-}" ] ; then
    echo
    echo "$DATUM  DOMAIN KEY  - Sie haben keinen DOMAIN Key gesetzt, schauen die unter https://ipv64.net/dyndns.php nach bei  DynDNS Updatehash"
    echo
    exit 1
else
    echo
    echo "$DATUM  DOMAIN KEY  - Sie haben einen DOMAIN Key gesetzt"
    echo
fi

if [ -z "${DOMAIN_IPV64:-}" ] ; then
    echo
    echo "$DATUM  DOMAIN      - Sie haben keine DOMAIN gesetzt, schauen die unter https://ipv64.net/dyndns.php nach bei Domain"
    echo
    exit 1
else
    echo
    echo "$DATUM  DOMAIN      - Sie haben eine DOMAIN gesetzt"
    echo
    echo "$DATUM  DOMAIN      - Deine DOMAIN $DOMAIN_IPV64"
fi

if ! curl -sSL --user-agent "${CURL_USER_AGENT}" --fail https://ipv64.net/ > /dev/null; then
    echo "$DATUM  FEHLER !!!  - 404 Sie haben kein Netzwerk oder Internetzugang"
	exit 1
fi
