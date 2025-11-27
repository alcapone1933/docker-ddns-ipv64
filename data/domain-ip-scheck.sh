#!/usr/bin/env bash
DATUM=$(date +%Y-%m-%d\ %H:%M:%S)

# IPv6 support variables
IPV4_ENABLED=${IPV4_ENABLED:-"yes"}
IPV6_ENABLED=${IPV6_ENABLED:-"no"}

# Check IPv6 availability if IPv6 is enabled
if [[ "${IPV6_ENABLED}" =~ (YES|yes|Yes) ]]; then
    # Check if IPv6 is available on the system
    if ! ip -6 addr show scope global 2>/dev/null | grep -q "inet6"; then
        echo "$DATUM  WARNING !!! - IPv6 ist im System nicht verfügbar, deaktiviere IPv6-Funktionalität"
        echo "$DATUM  INFO    !!! - IPv6_ENABLED wird automatisch auf 'no' gesetzt"
        export IPV6_ENABLED="no"
    else
        echo "$DATUM  INFO    !!! - IPv6 ist verfügbar und aktiviert"
    fi
else
    echo "$DATUM  INFO    !!! - IPv6 ist deaktiviert (IPV6_ENABLED=${IPV6_ENABLED})"
fi


if [[ "$NETWORK_CHECK" =~ (YES|yes|Yes) ]] ; then
    # if ! curl -4sf --user-agent "${CURL_USER_AGENT}" "https://ipv64.net" 2>&1 > /dev/null; then
    if ! curl -4sf --user-agent "${CURL_USER_AGENT}" "https://ipv64.net/ipcheck.php" 2>&1 > /dev/null; then
        echo "$DATUM  FEHLER !!!  - 404 Sie haben kein Netzwerk oder Internetzugang oder die Webseite ipv64.net ist nicht erreichbar"
        echo "=============================================================================================="
        exit 1
    fi
    STATUS="OK"
    NAMESERVER_CHECK=$(dig +timeout=1 @${NAME_SERVER} 2>/dev/null)
    echo "$NAMESERVER_CHECK" | grep -s -q "timed out" && { NAMESERVER_CHECK="Timeout" ; STATUS="FAIL" ; }
    if [ "${STATUS}" = "FAIL" ] ; then
        echo "$DATUM  FEHLER !!!  - 404 NAMESERVER ${NAME_SERVER} ist nicht ist nicht erreichbar. Sie haben kein Netzwerk oder Internetzugang"
        echo "=============================================================================================="
        exit 1
    fi
else
    echo > /dev/null
fi

if [[ "${DOMAIN_PRAEFIX_YES}" =~ (YES|yes|Yes) ]] ; then
    for DOMAIN in $(echo "${DOMAIN_IPV64}" | sed -e "s/,/ /g"); do
        FULL_DOMAIN="${DOMAIN_PRAEFIX}.${DOMAIN}"
        
        # Check IPv4 A record
        if [[ "$IPV4_ENABLED" =~ (YES|yes|Yes) ]] ; then
            IPV4_RESULT=$(dig +short ${FULL_DOMAIN} A @${NAME_SERVER})
            echo "`date +%Y-%m-%d\ %H:%M:%S`  IPv4 CHECK  - Domain ${FULL_DOMAIN} hat IPv4: ${IPV4_RESULT:-"KEINE"}" >> /data/log/cron.log 2>&1
        fi
        
        # Check IPv6 AAAA record
        if [[ "$IPV6_ENABLED" =~ (YES|yes|Yes) ]] ; then
            IPV6_RESULT=$(dig +short ${FULL_DOMAIN} AAAA @${NAME_SERVER})
            echo "`date +%Y-%m-%d\ %H:%M:%S`  IPv6 CHECK  - Domain ${FULL_DOMAIN} hat IPv6: ${IPV6_RESULT:-"KEINE"}" >> /data/log/cron.log 2>&1
        fi
    done
else
    for DOMAIN in $(echo "${DOMAIN_IPV64}" | sed -e "s/,/ /g"); do
        # Check IPv4 A record
        if [[ "$IPV4_ENABLED" =~ (YES|yes|Yes) ]] ; then
            IPV4_RESULT=$(dig +short ${DOMAIN} A @${NAME_SERVER})
            echo "`date +%Y-%m-%d\ %H:%M:%S`  IPv4 CHECK  - Domain ${DOMAIN} hat IPv4: ${IPV4_RESULT:-"KEINE"}" >> /data/log/cron.log 2>&1
        fi
        
        # Check IPv6 AAAA record
        if [[ "$IPV6_ENABLED" =~ (YES|yes|Yes) ]] ; then
            IPV6_RESULT=$(dig +short ${DOMAIN} AAAA @${NAME_SERVER})
            echo "`date +%Y-%m-%d\ %H:%M:%S`  IPv6 CHECK  - Domain ${DOMAIN} hat IPv6: ${IPV6_RESULT:-"KEINE"}" >> /data/log/cron.log 2>&1
        fi
    done
fi
echo "=============================================================================================="
