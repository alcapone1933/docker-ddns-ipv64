#!/usr/bin/env bash
PFAD="/data"
DATUM=$(date +%Y-%m-%d\ %H:%M:%S)

# IPv6 support variables
IPV4_ENABLED=${IPV4_ENABLED:-"yes"}
IPV6_ENABLED=${IPV6_ENABLED:-"no"}

# set -e
# Check IPv6 availability if IPv6 is enabled
if [[ "${IPV6_ENABLED}" =~ (YES|yes|Yes) ]]; then
    # Check if IPv6 is available on the system
    if ! ip -6 addr show scope global 2>/dev/null | grep -q "inet6"; then
        echo "$DATUM  WARNING !!!  - IPv6 ist im System nicht verfügbar, deaktiviere IPv6-Funktionalität"
        echo "$DATUM  INFO    !!!  - IPv6_ENABLED wird automatisch auf 'no' gesetzt"
        export IPV6_ENABLED="no"
    else
        echo "$DATUM  INFO    !!!  - IPv6 ist verfügbar und aktiviert"
    fi
else
    echo "$DATUM  INFO    !!!  - IPv6 ist deaktiviert (IPV6_ENABLED=${IPV6_ENABLED})"
fi

if [[ "$NETWORK_CHECK" =~ (YES|yes|Yes) ]] ; then
    # if ! curl -4sf --user-agent "${CURL_USER_AGENT}" "https://ipv64.net" 2>&1 > /dev/null; then
    if ! curl -4sf --user-agent "${CURL_USER_AGENT}" "https://ipv64.net/ipcheck.php" 2>&1 > /dev/null; then
        echo "$DATUM  FEHLER !!!  - 404 Sie haben kein Netzwerk oder Internetzugang oder die Webseite ipv64.net ist nicht erreichbar"
        STATUS="OK"
        NAMESERVER_CHECK=$(dig +timeout=1 @${NAME_SERVER} 2>/dev/null)
        echo "$NAMESERVER_CHECK" | grep -s -q "timed out" && { NAMESERVER_CHECK="Timeout" ; STATUS="FAIL" ; }
        if [ "${STATUS}" = "FAIL" ] ; then
            echo "$DATUM  FEHLER !!!  - 404 NAMESERVER ${NAME_SERVER} ist nicht ist nicht erreichbar. Sie haben kein Netzwerk oder Internetzugang"
            echo "=============================================================================================="
        fi
        if ! curl -4sf "https://google.de" 2>&1 > /dev/null; then
            echo "$DATUM  FEHLER !!!  - 404 Sie haben kein Netzwerk oder Internetzugang oder die Webseite google.de ist nicht erreichbar"
            echo "=============================================================================================="
            exit 1
        else
            IP_INFO=$(curl -4sf "https://ipinfo.io/ip" 2>/dev/null)
            UPDIP=$(cat $PFAD/updip.txt)
            echo "$DATUM    INFO !!!  - Die Webseite google.de ist erreichbar. Ihre Aktuelle IP laut IPINFO.IO=$IP_INFO"
            if [ "$IP_INFO" = "$UPDIP" ]; then
                echo > /dev/null
            else
                if [ -z "${SHOUTRRR_URL:-}" ] ; then
                    echo > /dev/null
                else
                    echo "$DATUM  SHOUTRRR    - SHOUTRRR NACHRICHT wird gesendet"
                    DOMAIN_NOTIFY=$(for DOMAIN in $(echo "${DOMAIN_IPV64}" | sed -e "s/,/ /g"); do echo "DOMAIN mit PRAEFIX: ${DOMAIN_PRAEFIX}.${DOMAIN} "; done)
                    if ! /usr/local/bin/shoutrrr send --url "${SHOUTRRR_URL}" --message "`echo -e "$DATUM    INFO !!! \n\nIPV64.NET IST NICHT ERREICHBAR \nIHRE Aktuelle IP laut IPINFO.IO=$IP_INFO \n${DOMAIN_NOTIFY}"`" 2>/dev/null; then
                        echo "$DATUM  FEHLER !!!  - SHOUTRRR NACHRICHT konnte nicht gesendet werden"
                    else
                        echo "$DATUM  SHOUTRRR    - SHOUTRRR NACHRICHT wurde gesendet"
                    fi
                fi
            fi
            echo "$IP_INFO" > $PFAD/updip.txt
            echo "=============================================================================================="
            exit 1
        fi
    fi
else
    echo > /dev/null
fi

# IPv4 IP detection sources
PRIMARY_IP_SOURCES=(
    "https://ipinfo.io/ip"
    "https://ifconfig.me"
    "https://ifconfig.co/ip"
    "https://icanhazip.com"
    "https://api.ipify.org"
    "https://ipecho.net/plain"
    "https://ident.me"
    "https://checkip.amazonaws.com"
    "https://myexternalip.com/raw"
    "https://wtfismyip.com/text"
    "https://ip.tyk.nu"
    "https://ipv4.icanhazip.com"
    "https://ipv64.net/ipcheck.php?ipv4"
)

# IPv6 IP detection sources
IPV6_SOURCES=(
    "https://ipv6.icanhazip.com"
    "https://api64.ipify.org"
    "https://ipv6.ident.me"
    "https://v6.ident.me"
    "https://ipv64.net/ipcheck.php?ipv6"
    "https://ifconfig.co/ipv6"
)

# Detect IPv4 address
IP=""
IP_SOURCE=""
if [[ "$IPV4_ENABLED" =~ (YES|yes|Yes) ]] ; then
    echo "$DATUM    INFO !!!  - IPv4 Detection gestartet..."
    for url_ip in "${PRIMARY_IP_SOURCES[@]}"; do
        response=$(curl -4sSL --connect-timeout 2 --max-time 3 --user-agent "${CURL_USER_AGENT}" "$url_ip" 2>/dev/null)
        if [[ "$response" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            export IP_SOURCE="$url_ip"
            IP="$response"
            echo "$DATUM    INFO !!!  - IPv4 gefunden: $IP (Quelle: $IP_SOURCE)"
            break
        fi
    done
    
    if [ -z "$IP" ]; then
        echo "$DATUM  WARNUNG !!!  - Keine gültige IPv4-Adresse gefunden"
    fi
else
    echo "$DATUM    INFO !!!  - IPv4 ist deaktiviert"
fi

# Detect IPv6 address
IP6=""
IP6_SOURCE=""
if [[ "$IPV6_ENABLED" =~ (YES|yes|Yes) ]] ; then
    echo "$DATUM    INFO !!!  - IPv6 Detection gestartet..."
    for url_ip6 in "${IPV6_SOURCES[@]}"; do
        response=$(curl -6sSL --connect-timeout 2 --max-time 3 --user-agent "${CURL_USER_AGENT}" "$url_ip6" 2>/dev/null)
        # IPv6 regex pattern - basic validation
        if [[ "$response" =~ ^[0-9a-fA-F:]+$ ]] && [[ "$response" == *":"* ]]; then
            export IP6_SOURCE="$url_ip6"
            IP6="$response"
            echo "$DATUM    INFO !!!  - IPv6 gefunden: $IP6 (Quelle: $IP6_SOURCE)"
            break
        fi
    done
    
    if [ -z "$IP6" ]; then
        echo "$DATUM  WARNUNG !!!  - Keine gültige IPv6-Adresse gefunden"
    fi
else
    echo "$DATUM    INFO !!!  - IPv6 ist deaktiviert"
fi

# Read stored IP addresses
UPDIP=""
UPDIP6=""
if [ -f "$PFAD/updip.txt" ]; then
    UPDIP=$(cat $PFAD/updip.txt)
fi
if [ -f "$PFAD/updip6.txt" ]; then
    UPDIP6=$(cat $PFAD/updip6.txt)
fi
sleep 1

function SHOUTRRR_NOTIFY() {
echo "$DATUM  SHOUTRRR    - SHOUTRRR NACHRICHT wird gesendet"
NOTIFY="
DOCKER DDNS UPDATER IPV64.NET - IP UPDATE !!!
\n
`for DOMAIN in $(echo "${DOMAIN_IPV64}" | sed -e "s/,/ /g"); do 
    echo "$DATUM  UPDATE !!! \n"
    [ -n "$IP" ] && echo "Update IPv4=$IP - Alte-IPv4=$UPDIP  \n"
    [ -n "$IP6" ] && echo "Update IPv6=$IP6 - Alte-IPv6=$UPDIP6  \n"
    echo "DOMAIN mit PRAEFIX: ${DOMAIN_PRAEFIX}.${DOMAIN} \n"
done`"

if ! /usr/local/bin/shoutrrr send --url "${SHOUTRRR_URL}" --message "`echo -e "${NOTIFY}"`" 2>/dev/null; then
    echo "$DATUM  FEHLER !!!  - SHOUTRRR NACHRICHT konnte nicht gesendet werden"
else
    echo "$DATUM  SHOUTRRR    - SHOUTRRR NACHRICHT wurde gesendet"
fi
}

# Check if update is needed
UPDATE_NEEDED=false
if [ -n "$IP" ] && [ "$IP" != "$UPDIP" ]; then
    UPDATE_NEEDED=true
    echo "$DATUM  IPv4 UPDATE ERFORDERLICH - Aktuelle IPv4=$IP - Alte IPv4=$UPDIP"
fi

if [ -n "$IP6" ] && [ "$IP6" != "$UPDIP6" ]; then
    UPDATE_NEEDED=true
    echo "$DATUM  IPv6 UPDATE ERFORDERLICH - Aktuelle IPv6=$IP6 - Alte IPv6=$UPDIP6"
fi

if [ "$UPDATE_NEEDED" = false ]; then
    echo "$DATUM  KEIN UPDATE - IPv4=$IP IPv6=$IP6"
else
    echo "$DATUM  UPDATE !!! ..."
    [ -n "$IP" ] && echo "$DATUM  UPDATE !!!  - Update IPv4=$IP - Alte-IPv4=$UPDIP"
    [ -n "$IP6" ] && echo "$DATUM  UPDATE !!!  - Update IPv6=$IP6 - Alte-IPv6=$UPDIP6"
    sleep 1
    
    # Construct API URL with both IPv4 and IPv6 parameters
    API_URL="https://ipv64.net/nic/update?key=${DOMAIN_KEY}&domain=${DOMAIN_IPV64}&praefix=${DOMAIN_PRAEFIX}"
    
    # Add IP addresses to URL
    if [ -n "$IP" ]; then
        API_URL="${API_URL}&ip=${IP}"
    fi
    
    if [ -n "$IP6" ]; then
        API_URL="${API_URL}&ip6=${IP6}"
    fi
    
    API_URL="${API_URL}&output=min"
    
    UPDATE_RESPONSE=$(curl -sSL --user-agent "${CURL_USER_AGENT}" "${API_URL}" 2>/dev/null)
    # Check response
    if [[ "$UPDATE_RESPONSE" =~ (nochg|good|ok) ]] ; then
        echo "$DATUM  UPDATE !!!  - UPDATE ERFOLGREICH AN IPV64.NET GESENDET"
        [ -n "$IP" ] && echo "$DATUM  UPDATE !!!  - IPv4 $IP wurde aktualisiert"
        [ -n "$IP6" ] && echo "$DATUM  UPDATE !!!  - IPv6 $IP6 wurde aktualisiert"
        if [ -z "${SHOUTRRR_URL:-}" ] ; then
            echo > /dev/null
        else
            SHOUTRRR_NOTIFY
        fi
        # Save updated IP addresses
        [ -n "$IP" ] && echo "$IP" > $PFAD/updip.txt
        [ -n "$IP6" ] && echo "$IP6" > $PFAD/updip6.txt
    else
        echo "$DATUM  FEHLER !!!  - UPDATE IP=$IP WURDE NICHT AN IPV64.NET GESENDET"
        CHECK_INTERVALL=$(curl -4sSL --user-agent "${CURL_USER_AGENT}" "https://ipv64.net/update.php?key=${DOMAIN_KEY}&domain=${DOMAIN_IPV64}&praefix=${DOMAIN_PRAEFIX}&ip=${IP}" | grep -o "Updateintervall")
        if [ "$CHECK_INTERVALL" == "Updateintervall" ]; then
            echo "$DATUM  FEHLER !!!  - Dein DynDNS Update Limit ist wohl erreicht"
            echo "$DATUM    INFO !!!  - Es kann erst wieder ein Update gesedet werden wenn dein DynDNS Update Limit im grünen Bereich ist"
        fi
        if [ -z "${SHOUTRRR_URL:-}" ] ; then
             echo > /dev/null
        else
            echo "$DATUM  SHOUTRRR    - SHOUTRRR NACHRICHT wird gesendet"
            DOMAIN_NOTIFY=$(for DOMAIN in $(echo "${DOMAIN_IPV64}" | sed -e "s/,/ /g"); do echo "DOMAIN mit PRAEFIX: ${DOMAIN_PRAEFIX}.${DOMAIN} "; done)
            if ! /usr/local/bin/shoutrrr send --url "${SHOUTRRR_URL}" --message "`echo -e "$DATUM    INFO !!! \n\nUPDATE IP=$IP WURDE NICHT AN IPV64.NET GESENDET \n${DOMAIN_NOTIFY}"`" 2>/dev/null; then
                echo "$DATUM  FEHLER !!!  - SHOUTRRR NACHRICHT konnte nicht gesendet werden"
            else
                echo "$DATUM  SHOUTRRR    - SHOUTRRR NACHRICHT wurde gesendet"
            fi
        fi
    fi
    # curl -4sSL https://ipv64.net/update.php?key=${DOMAIN_KEY}&domain=${DOMAIN_IPV64}praefix=${DOMAIN_PRAEFIX}&ip=<ipaddr>&ip6=<ip6addr>&output=min
fi

echo "=============================================================================================="
