#!/usr/bin/env bash
DATUM=$(date +%Y-%m-%d\ %H:%M:%S)

# IPv6 support variables

IPV4_ENABLED=${IPV4_ENABLED:-"yes"}
IPV6_ENABLED=${IPV6_ENABLED:-"no"}

# set -e

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

# Health check status
HEALTH_STATUS="OK"

# Check IPv4 connectivity
if [[ "$IPV4_ENABLED" =~ (YES|yes|Yes) ]] ; then
    if ! curl -4sf --user-agent "${CURL_USER_AGENT}" "https://ipv64.net/ipcheck.php" 2>&1 > /dev/null; then
        echo "$DATUM  WARNUNG !!! - IPv4 Verbindung zu ipv64.net nicht möglich"
        HEALTH_STATUS="PARTIAL"
    else
        echo "$DATUM  OK !!!      - IPv4 Verbindung zu ipv64.net funktioniert"
    fi
fi

# Check IPv6 connectivity
if [[ "$IPV6_ENABLED" =~ (YES|yes|Yes) ]] ; then
    if ! curl -6sf --user-agent "${CURL_USER_AGENT}" "https://ipv64.net/ipcheck.php" 2>&1 > /dev/null; then
        echo "$DATUM  WARNUNG !!! - IPv6 Verbindung zu ipv64.net nicht möglich"
        if [ "$HEALTH_STATUS" = "PARTIAL" ]; then
            HEALTH_STATUS="FAIL"
        else
            HEALTH_STATUS="PARTIAL"
        fi
    else
        echo "$DATUM  OK !!!      - IPv6 Verbindung zu ipv64.net funktioniert"
    fi
fi

# Check DNS server
STATUS="OK"
NAMESERVER_CHECK=$(dig +timeout=1 @${NAME_SERVER} 2>/dev/null)
echo "$NAMESERVER_CHECK" | grep -s -q "timed out" && { NAMESERVER_CHECK="Timeout" ; STATUS="FAIL" ; }
if [ "${STATUS}" = "FAIL" ] ; then
    echo "$DATUM  FEHLER !!!  - NAMESERVER ${NAME_SERVER} ist nicht erreichbar"
    HEALTH_STATUS="FAIL"
else
    echo "$DATUM  OK !!!      - NAMESERVER ${NAME_SERVER} ist erreichbar"
fi

# Final health check result
case "$HEALTH_STATUS" in
    "OK")
        echo "$DATUM  HEALTH      - Alle Verbindungen funktionieren"
        exit 0
        ;;
    "PARTIAL")
        echo "$DATUM  HEALTH      - Teilweise Verbindungsprobleme (IPv4 oder IPv6)"
        exit 0  # Still considered healthy if at least one IP version works
        ;;
    "FAIL")
        echo "$DATUM  HEALTH      - Kritische Verbindungsprobleme"
        exit 1
        ;;
esac
