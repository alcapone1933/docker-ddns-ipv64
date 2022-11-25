#!/usr/bin/env bash
DATUM=$(date +%Y-%m-%d\ %H:%M:%S)
if ! curl -sSL --user-agent "${CURL_USER_AGENT}" --fail "https://ipv64.net" > /dev/null; then
    echo "$DATUM  FEHLER !!!  - 404 Sie haben kein Netzwerk oder Internetzugang oder die Webseite ipv64.net ist nicht erreichbar"
	exit 0
fi
PFAD="/data"
IP=$(curl -4ssL --user-agent "${CURL_USER_AGENT}" "https://ipv64.net/update.php?howismyip" | jq -r 'to_entries[] | "\(.value)"')
UPDIP=$(cat $PFAD/updip.txt)

sleep 1

if [ "$IP" == "$UPDIP" ]; then
    echo "$DATUM  KEIN UPDATE - Aktuelle IP=$UPDIP"
else
    echo "$DATUM  UPDATE !!! ..."
    echo "$DATUM  UPDATE !!!  - Update IP=$IP - Alte-IP=$UPDIP"
    sleep 1
    echo "$IP" > $PFAD/updip.txt
    # curl -4sSL "https://ipv64.net/update.php?key=${DOMAIN_KEY}&domain=${DOMAIN_IPV64}&praefix=${DOMAIN_PRAEFIX}&ip=${IP}&output=min"
    UPDATE_IP=$(curl -4sSL --user-agent "${CURL_USER_AGENT}" "https://ipv64.net/update.php?key=${DOMAIN_KEY}&domain=${DOMAIN_IPV64}&praefix=${DOMAIN_PRAEFIX}&ip=${IP}&output=min")
    # if [ "$UPDATE_IP" = "ok" ] ; then
    if [[ "$UPDATE_IP" =~ (nochg|good|ok) ]] ; then
        echo "$DATUM  UPDATE !!!  - UPDATE IP=$IP AN IPV64.NET GESENDET"
    else
        echo "$DATUM  UPDATE !!!  - UPDATE IP=$IP NICHT GESENTET"
    fi
    # curl -4sSL https://ipv64.net/update.php?key=${DOMAIN_KEY}=${DOMAIN_IPV64}&praefix=${DOMAIN_PRAEFIX}&praefix=${DOMAIN_PRAEFIX}&ip=<ipaddr>&ip6=<ip6addr>&output=min
fi
sleep 5
# Nachpruefung ob der DOMAIN Eintrag richtig gesetzt ist
function CHECK_A_DOMAIN() {
DATUM=$(date +%Y-%m-%d\ %H:%M:%S)
UPDIP=$(cat $PFAD/updip.txt)
# IP=$(curl -4s https://ipv64.net/wieistmeineip.php | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | tail -n 1)
IP=$(curl -4ssL --user-agent "${CURL_USER_AGENT}" "https://ipv64.net/update.php?howismyip" | jq -r 'to_entries[] | "\(.value)"')
# DOMAIN_CHECK=$(dig +short ${DOMAIN_IPV64} A @ns1.ipv64.net)
DOMAIN_CHECK=$(for DOMAIN in $(echo "${DOMAIN_IPV64}" | sed -e "s/,/ /g"); do dig +short ${DOMAIN_PRAEFIX}.${DOMAIN} A @ns1.ipv64.net; done | tail -n 1)
sleep 1
if [ "$IP" == "$DOMAIN_CHECK" ]; then
    # echo "$DATUM  CHECK       - DOMAIN mit PRAEFIX HAT DEN A-RECORD= `dig +noall +answer ${DOMAIN_PRAEFIX}.${DOMAIN_IPV64} A @ns1.ipv64.net`"
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
        echo "$DATUM  UPDATE !!!  - UPDATE IP=$IP AN IPV64.NET GESENDET"
    else
        echo "$DATUM  UPDATE !!!  - UPDATE IP=$IP NICHT GESENTET"
    fi
    # curl -4sSL https://ipv64.net/update.php?key=${DOMAIN_KEY}=${DOMAIN_IPV64}&praefix=${DOMAIN_PRAEFIX}&ip=<ipaddr>&ip6=<ip6addr>&output=min
    sleep 15
    # echo "$DATUM  NACHEINTRAG - DOMAIN mit PRAEFIX HAT DEN A-RECORD= `dig +noall +answer ${DOMAIN_PRAEFIX}.${DOMAIN_IPV64} A @ns1.ipv64.net`"
    for DOMAIN in $(echo "${DOMAIN_IPV64}" | sed -e "s/,/ /g"); do echo "$DATUM  NACHEINTRAG - DOMAIN mit PRAEFIX HAT DEN A-RECORD=`dig +noall +answer ${DOMAIN_PRAEFIX}.${DOMAIN} A @ns1.ipv64.net`"; done
fi
}
CHECK_A_DOMAIN