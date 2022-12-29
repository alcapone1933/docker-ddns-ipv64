#!/usr/bin/env bash
if [[ "${DOMAIN_PRAEFIX_YES}" =~ (YES|yes|Yes) ]] ; then
    for DOMAIN in $(echo "${DOMAIN_IPV64//,/ }"); do
        echo "`date +%Y-%m-%d\ %H:%M:%S`  IP CHECK    - Deine DOMAIN ${DOMAIN} HAT DIE IP=`dig +short ${DOMAIN} A @ns1.ipv64.net`" >> /var/log/cron.log 2>&1
    done
else
    for DOMAIN in $(echo "${DOMAIN_IPV64//,/ }"); do
        echo "`date +%Y-%m-%d\ %H:%M:%S`  IP CHECK    - Deine DOMAIN mit PRAEFIX ${DOMAIN_PRAEFIX}.${DOMAIN} HAT DIE IP=`dig +short ${DOMAIN_PRAEFIX}.${DOMAIN} A @ns1.ipv64.net`" >> /var/log/cron.log 2>&1
    done
fi
