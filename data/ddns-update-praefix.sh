#!/usr/bin/env bash
PFAD="/data"
DATUM=$(date +%Y-%m-%d\ %H:%M:%S)
# set -e
# if ! curl -4sf --user-agent "${CURL_USER_AGENT}" "https://ipv64.net" 2>&1 > /dev/null; then
if ! curl -4sf --user-agent "${CURL_USER_AGENT}" "https://ipv64.net/ipcheck.php" 2>&1 > /dev/null; then
    echo "$DATUM  FEHLER !!!  - 404 Sie haben kein Netzwerk oder Internetzugang oder die Webseite ipv64.net ist nicht erreichbar"
    STATUS="OK"
    NAMESERVER_CHECK=$(dig +timeout=1 @ns1.ipv64.net 2> /dev/null)
    echo "$NAMESERVER_CHECK" | grep -s -q "timed out" && { NAMESERVER_CHECK="Timeout" ; STATUS="FAIL" ; }
    if [ "${STATUS}" = "FAIL" ] ; then
        echo "$DATUM  FEHLER !!!  - 404 NAMESERVER ns1.ipv64.net ist nicht ist nicht erreichbar. Sie haben kein Netzwerk oder Internetzugang"
        echo "=============================================================================================="
    fi
    if ! curl -4sf "https://google.de" 2>&1 > /dev/null; then
        echo "$DATUM  FEHLER !!!  - 404 Sie haben kein Netzwerk oder Internetzugang oder die Webseite google.de ist nicht erreichbar"
        echo "=============================================================================================="
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
                DOMAIN_NOTIFY=$(for DOMAIN in $(echo "${DOMAIN_IPV64}" | sed -e "s/,/ /g"); do echo "DOMAIN mit PRAEFIX: ${DOMAIN_PRAEFIX}.${DOMAIN} "; done)
                if ! /usr/local/bin/shoutrrr send --url "${SHOUTRRR_URL}" --message "`echo -e "$DATUM    INFO !!! \n\nIPV64.NET IST NICHT ERREICHBAR \nIHRE Aktuelle IP laut IPINFO.IO=$IP_INFO \n${DOMAIN_NOTIFY}"`" 2> /dev/null; then
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

# IP=$(curl -4sSL --user-agent "${CURL_USER_AGENT}" "https://ipv64.net/update.php?howismyip" | jq -r 'to_entries[] | "\(.value)"')
IP=$(curl -4sSL --user-agent "${CURL_USER_AGENT}" "https://ipv64.net/ipcheck.php?ipv4")
UPDIP=$(cat $PFAD/updip.txt)
sleep 1

function SHOUTRRR_NOTIFY() {
echo "$DATUM  SHOUTRRR    - SHOUTRRR NACHRICHT wird gesendet"
NOTIFY="
DOCKER DDNS UPDATER IPV64.NET - IP UPDATE !!!
\n
`for DOMAIN in $(echo "${DOMAIN_IPV64}" | sed -e "s/,/ /g"); do echo "$DATUM  UPDATE !!! \nUpdate IP=$IP - Alte-IP=$UPDIP  \nDOMAIN mit PRAEFIX: ${DOMAIN_PRAEFIX}.${DOMAIN} \n"; done`"

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
    # curl -4sSL "https://ipv64.net/update.php?key=${DOMAIN_KEY}&domain=${DOMAIN_IPV64}&praefix=${DOMAIN_PRAEFIX}&ip=${IP}&output=min"
    UPDATE_IP=$(curl -4sSL --user-agent "${CURL_USER_AGENT}" "https://ipv64.net/update.php?key=${DOMAIN_KEY}&domain=${DOMAIN_IPV64}&praefix=${DOMAIN_PRAEFIX}&ip=${IP}&output=min")
    # if [ "$UPDATE_IP" = "ok" ] ; then
    if [[ "$UPDATE_IP" =~ (nochg|good|ok) ]] ; then
        echo "$DATUM  UPDATE !!!  - UPDATE IP=$IP WURDE AN IPV64.NET GESENDET"
        if [ -z "${SHOUTRRR_URL:-}" ] ; then
            echo > /dev/null
        else
            SHOUTRRR_NOTIFY
        fi
        echo "$IP" > $PFAD/updip.txt
    else
        echo "$DATUM  FEHLER !!!  - UPDATE IP=$IP WURDE NICHT AN IPV64.NET GESENTET"
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
            if ! /usr/local/bin/shoutrrr send --url "${SHOUTRRR_URL}" --message "`echo -e "$DATUM    INFO !!! \n\nUPDATE IP=$IP WURDE NICHT AN IPV64.NET GESENTET \n${DOMAIN_NOTIFY}"`" 2> /dev/null; then
                echo "$DATUM  FEHLER !!!  - SHOUTRRR NACHRICHT konnte nicht gesendet werden"
            else
                echo "$DATUM  SHOUTRRR    - SHOUTRRR NACHRICHT wurde gesendet"
            fi
        fi
    fi
    # curl -4sSL https://ipv64.net/update.php?key=${DOMAIN_KEY}&domain=${DOMAIN_IPV64}praefix=${DOMAIN_PRAEFIX}&ip=<ipaddr>&ip6=<ip6addr>&output=min
fi
echo "=============================================================================================="
sleep 5
# Nachpruefung ob der DOMAIN Eintrag richtig gesetzt ist
function CHECK_A_DOMAIN() {
DATUM=$(date +%Y-%m-%d\ %H:%M:%S)
UPDIP=$(cat $PFAD/updip.txt)
# IP=$(curl -4s https://ipv64.net/wieistmeineip.php | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | tail -n 1)
# IP=$(curl -4sSL --user-agent "${CURL_USER_AGENT}" "https://ipv64.net/update.php?howismyip" | jq -r 'to_entries[] | "\(.value)"')
IP=$(curl -4sSL --user-agent "${CURL_USER_AGENT}" "https://ipv64.net/ipcheck.php?ipv4")
# DOMAIN_CHECK=$(dig +short ${DOMAIN_IPV64} A @ns1.ipv64.net)
DOMAIN_CHECK=$(for DOMAIN in $(echo "${DOMAIN_IPV64}" | sed -e "s/,/ /g"); do dig +short ${DOMAIN_PRAEFIX}.${DOMAIN} A @ns1.ipv64.net; done | tail -n 1)
sleep 1
if [ "$IP" == "$DOMAIN_CHECK" ]; then
    # echo "$DATUM  CHECK       - DOMAIN mit PRAEFIX HAT DEN A-RECORD=`dig +noall +answer ${DOMAIN_PRAEFIX}.${DOMAIN_IPV64} A @ns1.ipv64.net`"
    for DOMAIN in $(echo "${DOMAIN_IPV64}" | sed -e "s/,/ /g"); do echo "$DATUM  CHECK       - DOMAIN mit PRAEFIX HAT DEN A-RECORD=`dig +noall +answer ${DOMAIN_PRAEFIX}.${DOMAIN} A @ns1.ipv64.net`"; done
else
    echo "$DATUM  UPDATE !!! ..."
    echo "$DATUM  UPDATE !!!  - NACHEINTRAG DIE IP WIRD NOCH EINMAL GESETZT"
    echo "$DATUM  UPDATE !!!  - Update IP=$IP - Alte-IP=$UPDIP"
    sleep 5
    # curl -4sSL "https://ipv64.net/update.php?key=${DOMAIN_KEY}&domain=${DOMAIN_IPV64}&praefix=${DOMAIN_PRAEFIX}&ip=${IP}&output=min"
    UPDATE_IP=$(curl -4sSL --user-agent "${CURL_USER_AGENT}" "https://ipv64.net/update.php?key=${DOMAIN_KEY}&domain=${DOMAIN_IPV64}&praefix=${DOMAIN_PRAEFIX}&ip=${IP}&output=min")
    # if [ "$UPDATE_IP" = "ok" ] ; then
    if [[ "$UPDATE_IP" =~ (nochg|good|ok) ]] ; then
        echo "$DATUM  UPDATE !!!  - UPDATE IP=$IP WURDE AN IPV64.NET GESENDET"
        if [ -z "${SHOUTRRR_URL:-}" ] ; then
            echo > /dev/null
        else
            SHOUTRRR_NOTIFY
        fi
        echo "$IP" > $PFAD/updip.txt
        # curl -4sSL https://ipv64.net/update.php?key=${DOMAIN_KEY}&domain=${DOMAIN_IPV64}&praefix=${DOMAIN_PRAEFIX}&ip=<ipaddr>&ip6=<ip6addr>&output=min
        sleep 15
        # echo "$DATUM  NACHEINTRAG - DOMAIN mit PRAEFIX HAT DEN A-RECORD=`dig +noall +answer ${DOMAIN_PRAEFIX}.${DOMAIN_IPV64} A @ns1.ipv64.net`"
        for DOMAIN in $(echo "${DOMAIN_IPV64}" | sed -e "s/,/ /g"); do echo "$DATUM  NACHEINTRAG - DOMAIN mit PRAEFIX HAT DEN A-RECORD=`dig +noall +answer ${DOMAIN_PRAEFIX}.${DOMAIN} A @ns1.ipv64.net`"; done
    else
        echo "$DATUM  FEHLER !!!  - UPDATE IP=$IP WURDE NICHT AN IPV64.NET GESENTET"
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
            if ! /usr/local/bin/shoutrrr send --url "${SHOUTRRR_URL}" --message "`echo -e "$DATUM    INFO !!! \n\nUPDATE IP=$IP WURDE NICHT AN IPV64.NET GESENTET \n${DOMAIN_NOTIFY}"`" 2> /dev/null; then
                echo "$DATUM  FEHLER !!!  - SHOUTRRR NACHRICHT konnte nicht gesendet werden"
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

echo "=============================================================================================="
