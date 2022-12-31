#!/usr/bin/env bash
# set -x
# set -e
DATUM=$(date +%Y-%m-%d\ %H:%M:%S)
# cleanup
cleanup() {
    echo "================================  STOP DDNS UPDATER IPV64.NET ================================"
    echo "=============================================================================================="
    echo "=========================  ######     #######    #######    #######  ========================="
    echo "=========================  #     #       #       #     #    #     #  ========================="
    echo "=========================  #             #       #     #    #     #  ========================="
    echo "=========================   #####        #       #     #    ######   ========================="
    echo "=========================        #       #       #     #    #        ========================="
    echo "=========================  #     #       #       #     #    #        ========================="
    echo "=========================   #####        #       #######    #        ========================="
    echo "=============================================================================================="
}

# Trap SIGTERM
trap 'cleanup' SIGTERM

echo -n "" > /var/log/cron.log
sleep 10
echo "================================ START DDNS UPDATER IPV64.NET ================================"
echo "=============================================================================================="
echo "================  ######    ########     ##     ##     #######     ##    ##   ================"
echo "================    ##      ##     ##    ##     ##    ##     ##    ##    ##   ================"
echo "================    ##      ##     ##    ##     ##    ##           ##    ##   ================"
echo "================    ##      ########     ##     ##    ########     ##    ##   ================"
echo "================    ##      ##            ##   ##     ##     ##    #########  ================"
echo "================    ##      ##             ## ##      ##     ##          ##   ================"
echo "================  ######    ##              ###        #######           ##   ================"
echo "=============================================================================================="

if [[ "${DOMAIN_PRAEFIX_YES}" =~ (YES|yes|Yes) ]] ; then
    if [ -z "${DOMAIN_PRAEFIX:-}" ] ; then
        echo "$DATUM  PRAEFIX     - Sie haben kein DOMAIN PRAEFIX gesetzt, schaue unter https://ipv64.net/dyndns.php nach bei Domain"
        exit 1
    else
        echo "$DATUM  PRAEFIX     - Sie haben ein DOMAIN PRAEFIX gesetzt"
    fi
    if [ -z "${DOMAIN_IPV64:-}" ] ; then
        echo "$DATUM  DOMAIN      - Sie haben keine DOMAIN gesetzt, schaue unter https://ipv64.net/dyndns.php nach bei Domain"
        exit 1
    else
        echo "$DATUM  DOMAIN      - Sie haben eine DOMAIN gesetzt"
        for DOMAIN in $(echo "${DOMAIN_IPV64}" | sed -e "s/,/ /g"); do echo "$DATUM  DOMAIN      - Deine DOMAIN mit PRAEFIX ${DOMAIN_PRAEFIX}.${DOMAIN}"; done
    fi
else
    if [ -z "${DOMAIN_IPV64:-}" ] ; then
        echo "$DATUM  DOMAIN      - Sie haben keine DOMAIN gesetzt, schaue unter https://ipv64.net/dyndns.php nach bei Domain"
        exit 1
    else
        echo "$DATUM  DOMAIN      - Sie haben eine DOMAIN gesetzt"
        # echo "$DATUM  DOMAIN      - Deine DOMAIN $DOMAIN_IPV64"
        for DOMAIN in $(echo "${DOMAIN_IPV64}" | sed -e "s/,/ /g"); do echo "$DATUM  DOMAIN      - Deine DOMAIN ${DOMAIN}"; done
    fi
fi

if [ -z "${DOMAIN_KEY:-}" ] ; then
    echo "$DATUM  DOMAIN KEY  - Sie haben keinen DOMAIN Key gesetzt, schaue unter https://ipv64.net/dyndns.php nach bei DynDNS Updatehash"
    exit 1
else
    echo "$DATUM  DOMAIN KEY  - Sie haben einen DOMAIN Key gesetzt"
fi

if [ -z "${CRON_TIME:-}" ] ; then
    echo "$DATUM  FEHLER !!!  - Sie haben die Environment CRON_TIME nicht gesetzt"
    exit 1
fi

if [ -z "${CRON_TIME_DIG:-}" ] ; then
    echo "$DATUM  FEHLER !!!  - Sie haben die Environment CRON_TIME_DIG nicht gesetzt"
    exit 1
fi

if ! curl -4sf --user-agent "${CURL_USER_AGENT}" "https://ipv64.net" 2>&1 > /dev/null; then
    echo "$DATUM  FEHLER !!!  - 404 Sie haben kein Netzwerk oder Internetzugang oder die Webseite ipv64.net ist nicht erreichbar"
    exit 1
fi

STATUS="OK"
NAMESERVER_CHECK=$(dig +timeout=1 @ns1.ipv64.net 2> /dev/null)
echo "$NAMESERVER_CHECK" | grep -s -q "timed out" && { NAMESERVER_CHECK="Timeout" ; STATUS="FAIL" ; }
if [ "${STATUS}" = "FAIL" ] ; then
    echo "$DATUM  FEHLER !!!  - 404 NAMESERVER ist nicht ist nicht erreichbar. Sie haben kein Netzwerk oder Internetzugang"
    exit 1
fi

if [ -z "${SHOUTRRR_URL:-}" ] ; then
    echo "$DATUM  SHOUTRRR    - Sie haben keine SHOUTRRR URL gesetzt"
else
    echo "$DATUM  SHOUTRRR    - Sie haben eine  SHOUTRRR URL gesetzt"
    if ! /usr/local/bin/shoutrrr send --url "${SHOUTRRR_URL}" --message "`echo -e "$DATUM  TEST !!! \nDDNS Updater in Docker fuer Free DynDNS IPv64.net"`" 2> /dev/null; then
        echo "$DATUM  FEHLER !!!  - Die Angaben sind falsch  gesetzt: SHOUTRRR URL"
        echo "$DATUM    INFO !!!  - Schaue unter https://containrrr.dev/shoutrrr/ nach dem richtigen URL Format"
        exit 1
    else
        echo "$DATUM  CHECK       - Die Angaben sind richtig gesetzt: SHOUTRRR URL"
    fi
fi

# IP=$(curl -4s https://ipv64.net/wieistmeineip.php | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | tail -n 1)
# CHECK=$(curl -4sSL "https://ipv64.net/update.php?key=${DOMAIN_KEY}&domain=${DOMAIN_IPV64}&ip=$IP" | grep -o "success")
IP=$(curl -4sSL --user-agent "${CURL_USER_AGENT}" "https://ipv64.net/update.php?howismyip" | jq -r 'to_entries[] | "\(.value)"')

function Domain_default() {
CHECK=$(curl -4sSL --user-agent "${CURL_USER_AGENT}" "https://ipv64.net/update.php?key=${DOMAIN_KEY}&domain=${DOMAIN_IPV64}&ip=${IP}&output=min")
# if [ "$CHECK" = "ok" ] ; then
if [[ "$CHECK" =~ (nochg|good|ok) ]] ; then
    echo "$DATUM  CHECK       - Die Angaben sind richtig gesetzt: DOMAIN und DOMAIN KEY"
    sleep 5
    for DOMAIN in $(echo "${DOMAIN_IPV64}" | sed -e "s/,/ /g"); do echo "$DATUM  IP CHECK    - Deine DOMAIN ${DOMAIN} HAT DIE IP=`dig +short ${DOMAIN} A @ns1.ipv64.net`"; done
    echo "${IP}" > /data/updip.txt
    sleep 2
else
    CHECK_INTERVALL=$(curl -4sSL --user-agent "${CURL_USER_AGENT}" "https://ipv64.net/update.php?key=${DOMAIN_KEY}&domain=${DOMAIN_IPV64}&ip=${IP}" | grep -o "Updateintervall")
    if [ "$CHECK_INTERVALL" == "Updateintervall" ]; then
        echo "$DATUM  CHECK       - Die Angaben sind richtig gesetzt: DOMAIN und DOMAIN KEY"
        echo "$DATUM  FEHLER !!!  - Dein DynDNS Update Limit ist wohl erreicht"
        echo "$DATUM    INFO !!!  - Es kann erst wieder ein Update gesedet werden wenn dein DynDNS Update Limit im grünen Bereich ist"
    else
        echo "$DATUM  FEHLER !!!  - Die Angaben sind falsch  gesetzt: DOMAIN oder DOMAIN KEY"
        echo "$DATUM    INFO !!!  - Stoppen sie den Container und Starten sie den Container mit den richtigen Angaben erneut"
        return
    fi
fi

echo "${CRON_TIME} /bin/bash /data/ddns-update.sh >> /var/log/cron.log 2>&1" > /etc/cron.d/container_cronjob
echo "${CRON_TIME_DIG} sleep 20 && /bin/bash /data/domain-ip-scheck.sh >> /var/log/cron.log 2>&1" >> /etc/cron.d/container_cronjob
# echo "$CRON_TIME_DIG" 'sleep 20 && echo "`date +%Y-%m-%d\ %H:%M:%S`  IP CHECK    - Deine DOMAIN ${DOMAIN_IPV64} HAT DIE IP=`dig +short ${DOMAIN_IPV64} A @ns1.ipv64.net`" >> /var/log/cron.log 2>&1' >> /etc/cron.d/container_cronjob
# echo "$CRON_TIME_DIG" 'sleep 20 && for DOMAIN in $(echo "${DOMAIN_IPV64}" | sed -e "s/,/ /g"); do echo "`date +%Y-%m-%d\ %H:%M:%S`  IP CHECK    - Deine DOMAIN ${DOMAIN} HAT DIE IP=`dig +short ${DOMAIN} A @ns1.ipv64.net`" >> /var/log/cron.log 2>&1; done' >> /etc/cron.d/container_cronjob
}

function Domain_mit_praefix() {
CHECK=$(curl -4sSL --user-agent "${CURL_USER_AGENT}" "https://ipv64.net/update.php?key=${DOMAIN_KEY}&domain=${DOMAIN_IPV64}&praefix=${DOMAIN_PRAEFIX}&ip=${IP}&output=min")
if [[ "$CHECK" =~ (nochg|good|ok) ]] ; then
    echo "$DATUM  CHECK       - Die Angaben sind richtig gesetzt: DOMAIN mit PRAEFIX und DOMAIN KEY"
    sleep 5
    for DOMAIN in $(echo "${DOMAIN_IPV64}" | sed -e "s/,/ /g"); do echo "$DATUM  IP CHECK    - Deine DOMAIN mit PRAEFIX ${DOMAIN_PRAEFIX}.${DOMAIN} HAT DIE IP=`dig +short ${DOMAIN_PRAEFIX}.${DOMAIN} A @ns1.ipv64.net`"; done
    echo "${IP}" > /data/updip.txt
    sleep 2
else
    CHECK_INTERVALL=$(curl -4sSL --user-agent "${CURL_USER_AGENT}" "https://ipv64.net/update.php?key=${DOMAIN_KEY}&domain=${DOMAIN_IPV64}&praefix=${DOMAIN_PRAEFIX}&ip=${IP}" | grep -o "Updateintervall")
    if [ "$CHECK_INTERVALL" == "Updateintervall" ]; then
        echo "$DATUM  CHECK       - Die Angaben sind richtig gesetzt: DOMAIN mit PRAEFIX und DOMAIN KEY"
        echo "$DATUM  FEHLER !!!  - Dein DynDNS Update Limit ist wohl erreicht"
        echo "$DATUM    INFO !!!  - Es kann erst wieder ein Update gesedet werden wenn dein DynDNS Update Limit im grünen Bereich ist"
    else
        echo "$DATUM  FEHLER !!!  - Die Angaben sind falsch  gesetzt: DOMAIN mit PRAEFIX oder DOMAIN KEY"
        echo "$DATUM    INFO !!!  - Stoppen sie den Container und Starten sie den Container mit den richtigen Angaben erneut"
        return
    fi
fi

echo "${CRON_TIME} /bin/bash /data/ddns-update-praefix.sh >> /var/log/cron.log 2>&1" > /etc/cron.d/container_cronjob
echo "${CRON_TIME_DIG} sleep 20 && /bin/bash /data/domain-ip-scheck.sh >> /var/log/cron.log 2>&1" >> /etc/cron.d/container_cronjob
# echo "$CRON_TIME_DIG" 'sleep 20 && for DOMAIN in $(echo "${DOMAIN_IPV64}" | sed -e "s/,/ /g"); do echo "`date +%Y-%m-%d\ %H:%M:%S`  IP CHECK    - Deine DOMAIN mit PRAEFIX ${DOMAIN_PRAEFIX}.${DOMAIN} HAT DIE IP=`dig +short ${DOMAIN_PRAEFIX}.${DOMAIN} A @ns1.ipv64.net`" >> /var/log/cron.log 2>&1; done' >> /etc/cron.d/container_cronjob
}

if [[ "$DOMAIN_PRAEFIX_YES" =~ (YES|yes|Yes) ]] ; then
    Domain_mit_praefix
else
    Domain_default
fi

/usr/bin/crontab /etc/cron.d/container_cronjob
/usr/sbin/crond
echo "=============================================================================================="
set tail -f /var/log/cron.log "$@"
exec "$@" &

wait $!
