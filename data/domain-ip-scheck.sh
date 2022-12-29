#!/usr/bin/env bash
if ! curl -sSL --user-agent "${CURL_USER_AGENT}" --fail "https://ipv64.net" 2>&1 > /dev/null; then
    echo "$DATUM  FEHLER !!!  - 404 Sie haben kein Netzwerk oder Internetzugang oder die Webseite ipv64.net ist nicht erreichbar"
    exit 1
fi

if [[ "${DOMAIN_PRAEFIX_YES}" =~ (YES|yes|Yes) ]] ; then
    for DOMAIN in $(echo "${DOMAIN_IPV64}" | sed -e "s/,/ /g"); do
        echo "`date +%Y-%m-%d\ %H:%M:%S`  IP CHECK    - Deine DOMAIN ${DOMAIN} HAT DIE IP=`dig +short ${DOMAIN} A @ns1.ipv64.net`" >> /var/log/cron.log 2>&1
    done
else
    for DOMAIN in $(echo "${DOMAIN_IPV64}" | sed -e "s/,/ /g"); do
        echo "`date +%Y-%m-%d\ %H:%M:%S`  IP CHECK    - Deine DOMAIN mit PRAEFIX ${DOMAIN_PRAEFIX}.${DOMAIN} HAT DIE IP=`dig +short ${DOMAIN_PRAEFIX}.${DOMAIN} A @ns1.ipv64.net`" >> /var/log/cron.log 2>&1
    done
fi
