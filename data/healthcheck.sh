#!/usr/bin/env bash
set -e
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
    echo "Sie haben einen DOMAIN gesetzt"
    echo
fi
curl -sSL --fail https://ipv64.net/ > /dev/null || exit 1
