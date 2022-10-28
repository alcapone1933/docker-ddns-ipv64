#!/usr/bin/env bash
DATUM=$(date +%Y-%m-%d\ %H:%M:%S)
PFAD="/data"
IP=$(curl -4s https://ipv64.net/wieistmeineip.php | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | tail -n 1)
UPDIP=$(cat $PFAD/updip.txt)

sleep 2

if [ "$IP" == "$UPDIP" ]; then
    echo
    echo "$DATUM  KEIN UPDATE - Aktuelle IP=$UPDIP"
    echo
else
    echo
    echo "$DATUM  Update ..."
    sleep 1
    echo "$DATUM  UPDATE!!! - Update IP= $IP - Alte-IP: $UPDIP"
    sleep 1
    echo "$IP" > $PFAD/updip.txt
    echo
    # curl -4sSL "https://ipv64.net/update.php?key=${DOMAIN_KEY}&domain=${DOMAIN_IPV64}&ip=${IP}"
    curl -4sSL https://ipv64.net/update.php?key=${DOMAIN_KEY}=${DOMAIN_IPV64}&ip=<ipaddr>&ip6=<ip6addr>
    echo
fi
