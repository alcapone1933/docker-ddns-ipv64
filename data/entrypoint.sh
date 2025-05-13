#!/usr/bin/env bash
# set -x
# set -e
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
sleep 1
DATUM=$(date +%Y-%m-%d\ %H:%M:%S)
# cleanup
cleanup() {
    echo "=============================================================================================="
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

sleep 5
echo "=============================================================================================="
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

# echo -n "" > /data/log/cron.log
sleep 5
################################
# Set user and group ID
if [ "$PUID" != "0" ] || [ "$PGID" != "0" ]; then
    chown -R "$PUID":"$PGID" /data
    if [ ! -d "/data/log" ]; then
        install -d -o $PUID -g $PGID -m 755 /data/log
    fi
    if [ ! -f "/data/log/cron.log" ]; then
        install -o $PUID -g $PGID -m 644 /dev/null /data/log/cron.log
    fi
    if [ ! -f "/data/updip.txt" ]; then
        install -o $PUID -g $PGID -m 644 /dev/null /data/updip.txt
    fi
    echo "$DATUM  RECHTE      - Ornder /data UID: $PUID and GID: $PGID"
fi
if [ ! -d "/data/log" ]; then
    install -d -o $PUID -g $PGID -m 755 /data/log
fi
if [ ! -f "/data/log/cron.log" ]; then
    install -o $PUID -g $PGID -m 644 /dev/null /data/log/cron.log
fi
################################
MAX_LINES=1 /usr/local/bin/log-rotate.sh
################################
if [[ "${DOMAIN_PRAEFIX_YES}" =~ (YES|yes|Yes) ]] ; then
    if [ -z "${DOMAIN_PRAEFIX:-}" ] ; then
        echo "$DATUM  PRAEFIX     - Sie haben kein DOMAIN PRAEFIX gesetzt, schaue unter https://ipv64.net/dyndns nach bei Domain"
        sleep infinity
    else
        echo "$DATUM  PRAEFIX     - Sie haben ein DOMAIN PRAEFIX gesetzt"
    fi
    if [ -z "${DOMAIN_IPV64:-}" ] ; then
        echo "$DATUM  DOMAIN      - Sie haben keine DOMAIN gesetzt, schaue unter https://ipv64.net/dyndns nach bei Domain"
        sleep infinity
    else
        echo "$DATUM  DOMAIN      - Sie haben eine DOMAIN gesetzt"
        for DOMAIN in $(echo "${DOMAIN_IPV64}" | sed -e "s/,/ /g"); do echo "$DATUM  DOMAIN      - Deine DOMAIN mit PRAEFIX ${DOMAIN_PRAEFIX}.${DOMAIN}"; done
    fi
else
    if [ -z "${DOMAIN_IPV64:-}" ] ; then
        echo "$DATUM  DOMAIN      - Sie haben keine DOMAIN gesetzt, schaue unter https://ipv64.net/dyndns nach bei Domain"
        sleep infinity
    else
        echo "$DATUM  DOMAIN      - Sie haben eine DOMAIN gesetzt"
        # echo "$DATUM  DOMAIN      - Deine DOMAIN $DOMAIN_IPV64"
        for DOMAIN in $(echo "${DOMAIN_IPV64}" | sed -e "s/,/ /g"); do echo "$DATUM  DOMAIN      - Deine DOMAIN ${DOMAIN}"; done
    fi
fi

if [ -z "${DOMAIN_KEY:-}" ] ; then
    echo "$DATUM  DOMAIN KEY  - Sie haben keinen DOMAIN Key gesetzt, schaue unter https://ipv64.net/dyndns nach bei DynDNS Updatehash"
    sleep infinity
else
    echo "$DATUM  DOMAIN KEY  - Sie haben einen DOMAIN Key gesetzt"
fi

if [ -z "${CRON_TIME:-}" ] ; then
    echo "$DATUM  FEHLER !!!  - Sie haben die Environment CRON_TIME nicht gesetzt"
    sleep infinity
fi

if [ -z "${CRON_TIME_DIG:-}" ] ; then
    echo "$DATUM  FEHLER !!!  - Sie haben die Environment CRON_TIME_DIG nicht gesetzt"
    sleep infinity
fi

if [[ "$NETWORK_CHECK" =~ (YES|yes|Yes) ]] ; then
    while true; do
        # if ! curl -4sf --user-agent "${CURL_USER_AGENT}" "https://ipv64.net" 2>&1 > /dev/null; then
        if ! curl -4sf --user-agent "${CURL_USER_AGENT}" "https://ipv64.net/ipcheck.php" 2>&1 > /dev/null; then
            echo "$DATUM  FEHLER !!!  - 404 Sie haben kein Netzwerk oder Internetzugang oder die Webseite ipv64.net ist nicht erreichbar"
            sleep 900
            echo "=============================================================================================="
        else
            break
        fi
    done
    while true; do
        STATUS="OK"
        NAMESERVER_CHECK=$(dig +timeout=1 @${NAME_SERVER} 2>/dev/null)
        echo "$NAMESERVER_CHECK" | grep -s -q "timed out" && { NAMESERVER_CHECK="Timeout" ; STATUS="FAIL" ; }
        if [ "${STATUS}" = "FAIL" ] ; then
            echo "$DATUM  FEHLER !!!  - 404 NAMESERVER ${NAME_SERVER} ist nicht ist nicht erreichbar. Sie haben kein Netzwerk oder Internetzugang"
            sleep 900
            echo "=============================================================================================="
        else
            break
        fi
    done
else
    echo > /dev/null
fi

if [ -z "${SHOUTRRR_URL:-}" ] ; then
    echo "$DATUM  SHOUTRRR    - Sie haben keine SHOUTRRR URL gesetzt"
else
    echo "$DATUM  SHOUTRRR    - Sie haben eine  SHOUTRRR URL gesetzt"
    if [[ "${SHOUTRRR_SKIP_TEST}" =~ (NO|no|No) ]] ; then
        if ! /usr/local/bin/shoutrrr send --url "${SHOUTRRR_URL}" --message "`echo -e "$DATUM  TEST !!! \nDDNS Updater in Docker fuer Free DynDNS IPv64.net"`" 2>/dev/null; then
            echo "$DATUM  FEHLER !!!  - Die Angaben sind falsch  gesetzt: SHOUTRRR URL"
            echo "$DATUM    INFO !!!  - Schaue unter https://containrrr.dev/shoutrrr/ nach dem richtigen URL Format"
            echo "$DATUM    INFO !!!  - Stoppen sie den Container und Starten sie den Container mit den richtigen Angaben erneut"
            sleep infinity
        else
            echo "$DATUM  CHECK       - Die Angaben sind richtig gesetzt: SHOUTRRR URL"
        fi
    else
        echo "$DATUM  SHOUTRRR    - Sie haben die Shoutrrr Testnachricht übersprungen."
    fi

fi

# IP=$(curl -4s https://ipv64.net/wieistmeineip.php | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | tail -n 1)
# CHECK=$(curl -4sSL "https://ipv64.net/update.php?key=${DOMAIN_KEY}&domain=${DOMAIN_IPV64}&ip=$IP" | grep -o "success")
# IP=$(curl -4sSL --user-agent "${CURL_USER_AGENT}" "https://ipv64.net/update.php?howismyip" | jq -r 'to_entries[] | "\(.value)"')
# IP=$(curl -4sSL --user-agent "${CURL_USER_AGENT}" "https://ipv64.net/ipcheck.php?ipv4" 2>/dev/null)
PRIMARY_IP_SOURCES=(
    "https://ipinfo.io/ip"
    "https://ifconfig.me"
    "https://icanhazip.com"
    "https://api.ipify.org"
    "https://ipecho.net/plain"
    "https://ident.me"
    "https://ipv64.net/ipcheck.php?ipv4"
)

for url_ip in "${PRIMARY_IP_SOURCES[@]}"; do
    response=$(curl -4sSL --user-agent "${CURL_USER_AGENT}" "$url_ip" 2>/dev/null)
    if [[ "$response" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        export IP_SOURCE="$url_ip"
        break
    fi
done

IP=$(curl -4sSL --user-agent "${CURL_USER_AGENT}" "$IP_SOURCE" 2>/dev/null)

function Domain_default() {
if [ -f /etc/.firstrun ]; then
    CHECK=$(curl -4sSL --user-agent "${CURL_USER_AGENT}" "https://ipv64.net/update.php?key=${DOMAIN_KEY}&domain=${DOMAIN_IPV64}&ip=${IP}&output=min" 2>/dev/null)
    # if [ "$CHECK" = "ok" ] ; then
    if [[ "$CHECK" =~ (nochg|good|ok) ]] ; then
        echo "$DATUM  CHECK       - Die Angaben sind richtig gesetzt: DOMAIN und DOMAIN KEY"
        sleep 5
        if [[ "$IP_CHECK" =~ (YES|yes|Yes) ]] ; then
            for DOMAIN in $(echo "${DOMAIN_IPV64}" | sed -e "s/,/ /g"); do echo "$DATUM  IP CHECK    - Deine DOMAIN ${DOMAIN} HAT DIE IP=`dig +short ${DOMAIN} A @${NAME_SERVER}`"; done
        else
            echo > /dev/null
        fi
        echo "${IP}" > /data/updip.txt
        sleep 2
        rm /etc/.firstrun
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
else
    echo "$DATUM  CHECK       - Die Angaben sind richtig gesetzt: DOMAIN und DOMAIN KEY"
fi

echo "${CRON_TIME} /bin/bash /usr/local/bin/ddns-update.sh >> /data/log/cron.log 2>&1" > /etc/cron.d/container_cronjob
if [[ "$IP_CHECK" =~ (YES|yes|Yes) ]] ; then
    echo "${CRON_TIME_DIG} sleep 20 && /bin/bash /usr/local/bin/domain-ip-scheck.sh >> /data/log/cron.log 2>&1" >> /etc/cron.d/container_cronjob
else
    echo > /dev/null
fi
# echo "$CRON_TIME_DIG" 'sleep 20 && echo "`date +%Y-%m-%d\ %H:%M:%S`  IP CHECK    - Deine DOMAIN ${DOMAIN_IPV64} HAT DIE IP=`dig +short ${DOMAIN_IPV64} A @${NAME_SERVER}`" >> /data/log/cron.log 2>&1' >> /etc/cron.d/container_cronjob
# echo "$CRON_TIME_DIG" 'sleep 20 && for DOMAIN in $(echo "${DOMAIN_IPV64}" | sed -e "s/,/ /g"); do echo "`date +%Y-%m-%d\ %H:%M:%S`  IP CHECK    - Deine DOMAIN ${DOMAIN} HAT DIE IP=`dig +short ${DOMAIN} A @${NAME_SERVER}`" >> /data/log/cron.log 2>&1; done' >> /etc/cron.d/container_cronjob
}

function Domain_add_praefix() {
if [ -f /etc/.firstrun ]; then
    CHECK=$(curl -4sSL --user-agent "${CURL_USER_AGENT}" "https://ipv64.net/update.php?key=${DOMAIN_KEY}&domain=${DOMAIN_IPV64}&praefix=${DOMAIN_PRAEFIX}&ip=${IP}&output=min" 2>/dev/null)
    if [[ "$CHECK" =~ (nochg|good|ok) ]] ; then
        echo "$DATUM  CHECK       - Die Angaben sind richtig gesetzt: DOMAIN mit PRAEFIX und DOMAIN KEY"
        sleep 5
        if [[ "$IP_CHECK" =~ (YES|yes|Yes) ]] ; then
            for DOMAIN in $(echo "${DOMAIN_IPV64}" | sed -e "s/,/ /g"); do echo "$DATUM  IP CHECK    - Deine DOMAIN mit PRAEFIX ${DOMAIN_PRAEFIX}.${DOMAIN} HAT DIE IP=`dig +short ${DOMAIN_PRAEFIX}.${DOMAIN} A @${NAME_SERVER}`"; done
        else
            echo > /dev/null
        fi
        echo "${IP}" > /data/updip.txt
        sleep 2
        rm /etc/.firstrun
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
else
    echo "$DATUM  CHECK       - Die Angaben sind richtig gesetzt: DOMAIN mit PRAEFIX und DOMAIN KEY"
fi

echo "${CRON_TIME} /bin/bash /usr/local/bin/ddns-update-praefix.sh >> /data/log/cron.log 2>&1" > /etc/cron.d/container_cronjob
if [[ "$IP_CHECK" =~ (YES|yes|Yes) ]] ; then
    echo "${CRON_TIME_DIG} sleep 20 && /bin/bash /usr/local/bin/domain-ip-scheck.sh >> /data/log/cron.log 2>&1" >> /etc/cron.d/container_cronjob
else
    echo > /dev/null
fi
# echo "$CRON_TIME_DIG" 'sleep 20 && for DOMAIN in $(echo "${DOMAIN_IPV64}" | sed -e "s/,/ /g"); do echo "`date +%Y-%m-%d\ %H:%M:%S`  IP CHECK    - Deine DOMAIN mit PRAEFIX ${DOMAIN_PRAEFIX}.${DOMAIN} HAT DIE IP=`dig +short ${DOMAIN_PRAEFIX}.${DOMAIN} A @${NAME_SERVER}`" >> /data/log/cron.log 2>&1; done' >> /etc/cron.d/container_cronjob
}

if [[ "$DOMAIN_PRAEFIX_YES" =~ (YES|yes|Yes) ]] ; then
    Domain_add_praefix
else
    Domain_default
fi

echo "*/30 * * * * /usr/local/bin/log-rotate.sh" >> /etc/cron.d/container_cronjob

/usr/bin/crontab /etc/cron.d/container_cronjob
/usr/sbin/crond
echo "=============================================================================================="
set tail -f /data/log/cron.log "$@"
exec "$@" &

wait $!
