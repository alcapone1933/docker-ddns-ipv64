#!/usr/bin/env bash
DATUM=$(date +%Y-%m-%d\ %H:%M:%S)
PFAD="/data"
IP=$(curl -4s https://ipv64.net/wieistmeineip.php | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | tail -n 1)
UPDIP=$(cat $PFAD/updip.txt)

sleep 1

if [ "$IP" == "$UPDIP" ]; then
    echo
    echo "$DATUM  KEIN UPDATE - Aktuelle IP= $UPDIP"
    echo
else
    echo
    echo "$DATUM  UPDATE !!! ..."
    echo "$DATUM  UPDATE !!!  - Update IP= $IP - Alte-IP= $UPDIP"
    sleep 1
    echo "$IP" > $PFAD/updip.txt
    echo
    curl -4sSL "https://ipv64.net/update.php?key=${DOMAIN_KEY}&domain=${DOMAIN_IPV64}&ip=${IP}"
    # curl -4sSL https://ipv64.net/update.php?key=${DOMAIN_KEY}=${DOMAIN_IPV64}&ip=<ipaddr>&ip6=<ip6addr>
    echo
fi
sleep 5
# Nachpruefung ob der DOMAIN Eintrag richtig gesetzt ist
function CHECK_A_DOMAIN() {
DATUM=$(date +%Y-%m-%d\ %H:%M:%S)
UPDIP=$(cat $PFAD/updip.txt)
IP=$(curl -4s https://ipv64.net/wieistmeineip.php | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | tail -n 1)
DOMAIN_CHECK=$(dig +short ${DOMAIN_IPV64} A @ns1.ipv64.net)
sleep 1
if [ "$IP" == "$DOMAIN_CHECK" ]; then
    echo
    echo "$DATUM  CHECK       - DOMAIN HAT DEN A-RECORD= `dig +noall +answer ${DOMAIN_IPV64} A @ns1.ipv64.net`"
    echo
else
    echo
    echo "$DATUM  UPDATE !!! ..."
    echo "$DATUM  UPDATE !!!  - NACHEINTRAG DIE IP WIRD NOCH EINMAL GESETZT"
    echo "$DATUM  UPDATE !!!  - Update IP= $IP - Alte-IP= $UPDIP"
    sleep 5
    echo
    curl -4sSL "https://ipv64.net/update.php?key=${DOMAIN_KEY}&domain=${DOMAIN_IPV64}&ip=${IP}"
    # curl -4sSL https://ipv64.net/update.php?key=${DOMAIN_KEY}=${DOMAIN_IPV64}&ip=<ipaddr>&ip6=<ip6addr>
    sleep 15
    echo
    echo "$DATUM  NACHEINTRAG - DOMAIN HAT DEN IP EINTRAG= `dig +noall +answer ${DOMAIN_IPV64} A @ns1.ipv64.net`"
    echo
fi
}
CHECK_A_DOMAIN
