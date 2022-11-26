#!/usr/bin/env bash
DATUM=$(date +%Y-%m-%d\ %H:%M:%S)
set -e
if [[ "${DOMAIN_PRAEFIX_YES}" =~ (YES|yes|Yes) ]] ; then
    if [ -z "${DOMAIN_PRAEFIX:-}" ] ; then
        echo "$DATUM  PRAEFIX     - Sie haben kein DOMAIN PRAEFIX gesetzt, schauen die unter https://ipv64.net/dyndns.php nach bei Domain"
        exit 1
    else
        echo "$DATUM  PRAEFIX     - Sie haben ein DOMAIN PRAEFIX gesetzt"
    fi
    if [ -z "${DOMAIN_IPV64:-}" ] ; then
        echo "$DATUM  DOMAIN      - Sie haben keine DOMAIN gesetzt, schauen die unter https://ipv64.net/dyndns.php nach bei Domain"
        exit 1
    else
        echo "$DATUM  DOMAIN      - Sie haben eine DOMAIN gesetzt"
        for DOMAIN in $(echo "${DOMAIN_IPV64}" | sed -e "s/,/ /g"); do echo "$DATUM  DOMAIN      - Deine DOMAIN mit PRAEFIX ${DOMAIN_PRAEFIX}.${DOMAIN}"; done
    fi
else
    if [ -z "${DOMAIN_IPV64:-}" ] ; then
        echo "$DATUM  DOMAIN      - Sie haben keine DOMAIN gesetzt, schauen die unter https://ipv64.net/dyndns.php nach bei Domain"
        exit 1
    else
        echo "$DATUM  DOMAIN      - Sie haben eine DOMAIN gesetzt"
        # echo "$DATUM  DOMAIN      - Deine DOMAIN $DOMAIN_IPV64"
        for DOMAIN in $(echo "${DOMAIN_IPV64}" | sed -e "s/,/ /g"); do echo "$DATUM  DOMAIN      - Deine DOMAIN ${DOMAIN}"; done
    fi
fi

if [ -z "${DOMAIN_KEY:-}" ] ; then
    echo "$DATUM  DOMAIN KEY  - Sie haben keinen DOMAIN Key gesetzt, schauen die unter https://ipv64.net/dyndns.php nach bei  DynDNS Updatehash"
    exit 1
else
    echo "$DATUM  DOMAIN KEY  - Sie haben einen DOMAIN Key gesetzt"
fi

if ! curl -sSL --user-agent "${CURL_USER_AGENT}" --fail https://ipv64.net/ > /dev/null; then
    echo "$DATUM  FEHLER !!!  - 404 Sie haben kein Netzwerk oder Internetzugang oder die Webseite ipv64.net ist nicht erreichbar"
    exit 0
fi
