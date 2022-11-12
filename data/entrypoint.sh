#!/usr/bin/env bash
# set -x
set -e
DATUM=$(date +%Y-%m-%d\ %H:%M:%S)
# cleanup
cleanup() {
    echo "================================  STOP DDNS UPDATER IPV64.NET ================================"
}

# Trap SIGTERM
trap 'cleanup' SIGTERM

echo -n "" > /var/log/cron.log
sleep 10

echo "================================ START DDNS UPDATER IPV64.NET ================================"

if [ -z "${DOMAIN_KEY:-}" ] ; then
    echo "$DATUM  DOMAIN KEY  - Sie haben keinen DOMAIN Key gesetzt, schauen die unter https://ipv64.net/dyndns.php nach bei  DynDNS Updatehash"
    exit 1
else
    echo "$DATUM  DOMAIN KEY  - Sie haben einen DOMAIN Key gesetzt"
fi

if [ -z "${DOMAIN_IPV64:-}" ] ; then
    echo "$DATUM  DOMAIN      - Sie haben keine DOMAIN gesetzt, schauen die unter https://ipv64.net/dyndns.php nach bei Domain"
    exit 1
else
    echo "$DATUM  DOMAIN      - Sie haben eine DOMAIN gesetzt"
    # echo "$DATUM  DOMAIN      - Deine DOMAIN $DOMAIN_IPV64"
    for DOMAIN in $(echo "${DOMAIN_IPV64}" | sed -e "s/,/ /g"); do echo "$DATUM  DOMAIN      - Deine DOMAIN $DOMAIN"; done
fi
if ! curl -sSL --user-agent "${CURL_USER_AGENT}" --fail https://ipv64.net/ > /dev/null; then
    echo "$DATUM  FEHLER !!!  - 404 Sie haben kein Netzwerk oder Internetzugang"
	exit 0
fi
# IP=$(curl -4s https://ipv64.net/wieistmeineip.php | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | tail -n 1)
# CHECK=$(curl -4sSL "https://ipv64.net/update.php?key=${DOMAIN_KEY}&domain=${DOMAIN_IPV64}&ip=$IP" | grep -o "success")
IP=$(curl -4ssL --user-agent "${CURL_USER_AGENT}" "https://ipv64.net/update.php?howismyip" | jq -r 'to_entries[] | "\(.value)"')
CHECK=$(curl -4sSL --user-agent "${CURL_USER_AGENT}" "https://ipv64.net/update.php?key=${DOMAIN_KEY}&domain=${DOMAIN_IPV64}&ip=${IP}&output=min")
# if [ "$CHECK" = "ok" ] ; then
if [[ "$CHECK" =~ (nochg|good|ok) ]] ; then
    echo "$DATUM  CHECK       - Die Angaben sind richtig gesetzt: DOMAIN und DOMAIN KEY"
    sleep 5 && for DOMAIN in $(echo "${DOMAIN_IPV64}" | sed -e "s/,/ /g"); do echo "$DATUM  IP CHECK    - Deine DOMAIN ${DOMAIN} HAT DIE IP=`dig +short ${DOMAIN} A @ns1.ipv64.net`"; done
else
    echo "$DATUM  FEHLER !!!  - Die Angaben sind falsch  gesetzt: DOMAIN oder DOMAIN KEY"
    exit 1
fi
echo "${IP}" > /data/updip.txt
echo "${CRON_TIME} /bin/bash /data/ddns-update.sh >> /var/log/cron.log 2>&1" > /etc/cron.d/container_cronjob
# echo "$CRON_TIME_DIG" 'sleep 20 && echo "`date +%Y-%m-%d\ %H:%M:%S`  IP CHECK    - Deine DOMAIN ${DOMAIN_IPV64} HAT DIE IP=`dig +short ${DOMAIN_IPV64} A @ns1.ipv64.net`" >> /var/log/cron.log 2>&1' >> /etc/cron.d/container_cronjob
echo "$CRON_TIME_DIG" 'sleep 20 && for DOMAIN in $(echo "${DOMAIN_IPV64}" | sed -e "s/,/ /g"); do echo "`date +%Y-%m-%d\ %H:%M:%S`  IP CHECK    - Deine DOMAIN ${DOMAIN} HAT DIE IP=`dig +short ${DOMAIN} A @ns1.ipv64.net`" >> /var/log/cron.log 2>&1; done' >> /etc/cron.d/container_cronjob

sleep 2

/usr/bin/crontab /etc/cron.d/container_cronjob
/usr/sbin/crond

set tail -f /var/log/cron.log "$@"
exec "$@" &

wait $!
