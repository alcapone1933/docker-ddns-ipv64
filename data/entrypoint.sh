#!/usr/bin/env bash
# set -x
set -e
sleep 10
echo "================================ START DDNS UPDATER IPV64.NET ================================"

if [ -z "${DOMAIN_KEY:-}" ] ; then
    echo
    echo "Sie haben keinen DOMAIN Key gesetzt, schauen die unter https://ipv64.net/dyndns.php nach bei  DynDNS Updatehash"
    echo
    exit 1
else
    echo
    echo "Sie haben einen DOMAIN Key gesetzt"
    echo
fi

if [ -z "${DOMAIN_IPV64:-}" ] ; then
    echo
    echo "Sie haben keine DOMAIN gesetzt, schauen die unter https://ipv64.net/dyndns.php nach bei Domain"
    echo
    exit 1
else
    echo
    echo "Sie haben eine DOMAIN gesetzt"
    echo
    echo "Deine DOMAIN $DOMAIN_IPV64"
fi

IP=$(curl -4s https://ipv64.net/wieistmeineip.php | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | tail -n 1)
# CHECK=$(curl -4sSL "https://ipv64.net/update.php?key=${DOMAIN_KEY}&domain=${DOMAIN_IPV64}&ip=$IP" | grep -o "success")

if [ "`curl -4sSL "https://ipv64.net/update.php?key=${DOMAIN_KEY}&domain=${DOMAIN_IPV64}&ip=${IP}" | grep -o "success"`" = "success" ] ; then
    echo
    echo "Die Angaben sind richtig gesetzt: DOMAIN und DOMAIN KEY"
    echo
else
    echo
    echo "Die Angaben sind falsch  gesetzt: DOMAIN oder DOMAIN KEY"
    echo
    exit 1
fi
echo "${IP}" > /data/updip.txt
curl -sSL --fail https://ipv64.net/ > /dev/null || exit 1
echo "${CRON_TIME} /bin/bash /data/ddns-update.sh >> /var/log/cron.log 2>&1" > /etc/cron.d/container_cronjob
echo "$CRON_TIME_DIG" 'sleep 20 && echo "`date +%Y-%m-%d\ %H:%M:%S`  Deine DOMAIN ${DOMAIN_IPV64} HAT DIE IP=`dig +short ${DOMAIN_IPV64} A @ns1.ipv64.net`" >> /var/log/cron.log 2>&1' >> /etc/cron.d/container_cronjob

sleep 2

/usr/bin/crontab /etc/cron.d/container_cronjob
/usr/sbin/crond

set tail -f /var/log/cron.log "$@"
exec "$@"
