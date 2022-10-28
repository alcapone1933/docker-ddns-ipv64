#!/usr/bin/env bash
# set -x
set -e
sleep 15
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

curl -sSL --fail https://ipv64.net/ > /dev/null || exit 1
echo "${CRON_TIME} /bin/bash /data/ddns-update.sh >> /var/log/cron.log 2>&1" > /etc/cron.d/container_cronjob
echo "$CRON_TIME_DIG" 'echo "`date +%Y-%m-%d\ %H:%M:%S`  Deine DOMAIN ${DOMAIN_IPV64} HAT DIE IP=`dig +short ${DOMAIN_IPV64} A`" >> /var/log/cron.log 2>&1' >> /etc/cron.d/container_cronjob

sleep 2

/usr/bin/crontab /etc/cron.d/container_cronjob
/usr/sbin/crond

set tail -f /var/log/cron.log "$@"
exec "$@"