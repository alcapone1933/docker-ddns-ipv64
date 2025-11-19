# docker-ddns-ipv64

[![Build Status](https://shields.cosanostra-cloud.de/drone/build/alcapone1933/docker-ddns-ipv64?logo=drone&server=https%3A%2F%2Fdrone.docker-for-life.de)](https://drone.docker-for-life.de/alcapone1933/docker-ddns-ipv64)
[![Build Status Branch Master](https://shields.cosanostra-cloud.de/drone/build/alcapone1933/docker-ddns-ipv64/master?logo=drone&label=build%20%5Bbranch%20master%5D&server=https%3A%2F%2Fdrone.docker-for-life.de)](https://drone.docker-for-life.de/alcapone1933/docker-ddns-ipv64/branches)
[![Docker Pulls](https://shields.cosanostra-cloud.de/docker/pulls/alcapone1933/ddns-ipv64?logo=docker&logoColor=blue)](https://hub.docker.com/r/alcapone1933/ddns-ipv64/tags)
![Docker Image Version (latest semver)](https://shields.cosanostra-cloud.de/docker/v/alcapone1933/ddns-ipv64?sort=semver&logo=docker&logoColor=blue&label=dockerhub%20version)
[![Website](https://shields.cosanostra-cloud.de/website?down_color=red&down_message=DOWN&label=Webseite%20IPV64.NET&up_color=green&up_message=UP&url=https%3A%2F%2Fipv64.net%2F)](https://ipv64.net/)

&nbsp;

# DDNS Updater in Docker für DynDNS [IPv64.net](https://ipv64.net/)

Dieser Docker-Container ist ein DDNS-Updater für den DynDNS-Dienst von ipv64.net.\
Bei einer Änderung der IPv4- oder IPv6-Adresse am Standort wird die neue Adresse automatisch als A- bzw. AAAA-Record an ipv64.net übermittelt.

Wenn Du dieses Docker-Projekt nutzen möchtest, passe bitte vor dem Start des Containers die Environment-Variablen entsprechend an.
&nbsp;

Nutzer von DS-Lite-Anschlüssen sollten beachten, dass in solchen Umgebungen oft keine echte öffentliche IPv4-Adresse verfügbar ist;\
in diesem Fall kann es erforderlich sein, die IPv4-Aktualisierung zu deaktivieren, indem die Variable  `IPV4_ENABLED=no ` gesetzt wird.

&nbsp;

***

Danke geht an :pray: @[lodzen](https://github.com/lodzen) für die Unterstützung bei dem code für ipv6.

## Erklärung

### Domain

  * Hier bitte deine DOMAIN eintragen (ersetzen), die unter https://ipv64.net/dyndns erstellt wurde, z.B "deine-domain.ipv64.net"

    `-e "DOMAIN_IPV64=deine-domain.ipv64.net"`

  * Wenn Du mehrere DOMAINS eintragen willst, bitte mit Komma trennen:

    `-e "DOMAIN_IPV64=deine-domain.ipv64.net,deine-domain.ipv64.de"`

    💹 Hinweis: Wenn mehrere Domains verwendet werden, dann den [Account Update Token](#domain-Key) bei `DOMAIN_KEY=` eintragen.

&nbsp;

### Domain Praefix

  * Wenn Du einen DOMAIN PRAEFIX verwenden willst, dann benutze die Variablen ***DOMAIN_PRAEFIX_YES=yes*** und ***DOMAIN_PRAEFIX***

    `-e "DOMAIN_PRAEFIX_YES=yes"`
  
  * Hier bitte nur ein DOMAIN PRAEFIX (subdomain) eintragen (ersetzen), das unter https://ipv64.net/dyndns erstellt wurde:

    `-e "DOMAIN_PRAEFIX=ddns"`

⚠️ ***Solltest Du mehrere DOMAINS verwenden, dann bitte nur ein PRAEFIX eintragen (ersetzen)*** ⚠️

***Bei mehreren Domains wird immer derselbe PRAEFIX verwendet.***

***Beispiel: ddns.deine-domain.ipv64.net und ddns.deine-domain.ipv64.de***

&nbsp;

### Domain Key

  * Hier bitte dein DOMAIN KEY bzw. DynDNS Updatehash eintragen (ersetzen). \
    Zu finden ist dieser unter https://ipv64.net/dyndns z.B "1234567890abcdefghijklmnopqrstuvwxyz"
    
    `-e "DOMAIN_KEY=1234567890abcdefghijklmnopqrstuvwxyz"`
    
    &nbsp;

    Account Update Token oder Domain Key
    
    <img src="demo/account_key.png" alt="Account Update Token" width="600">

    <img src="demo/domain_key.png" alt="Account Update Token oder Domain Key" width="600" height="600">

&nbsp;

***

## Docker CLI

```bash
docker run -d \
    --restart always \
    --name ddns-ipv64 \
    -e "TZ=Europe/Berlin" \
    -e "CRON_TIME=*/15 * * * *" \
    -e "CRON_TIME_DIG=*/30 * * * *" \
    -e "DOMAIN_KEY=1234567890abcdefghijklmnopqrstuvwxyz" \
    -e "DOMAIN_IPV64=deine-domain.ipv64.net" \
    alcapone1933/ddns-ipv64:latest

# Erweiterte Optionen (optional):
#    -e "DOMAIN_IPV64=deine-domain.ipv64.net,deine-domain.ipv64.de" \
#    -e "DOMAIN_PRAEFIX_YES=yes" \
#    -e "DOMAIN_PRAEFIX=ddns" \
#    -e "IPV4_ENABLED=yes" \
#    -e "IPV6_ENABLED=no" \
#    -e "IP_CHECK=yes" \
#    -e "SHOUTRRR_URL=" \
#    -e "SHOUTRRR_SKIP_TEST=no" \
#    -e "NAME_SERVER=ns1.ipv64.net" \
#    -e "NETWORK_CHECK=yes" \
#    -e "CURL_USER_AGENT=DDNS-Updater-IPv64_github.com/alcapone1933/docker-ddns-ipv64_version_v0.1.9" \
#    -e "MAX_FILES=10" \
#    -e "MAX_LINES=1000" \
#    -e "PUID=1000" \
#    -e "PGID=1000" \
```

## Docker Compose

```yaml
services:
  ddns-ipv64:
    image: alcapone1933/ddns-ipv64:latest
    container_name: ddns-ipv64
    restart: unless-stopped
    environment:
      - "TZ=Europe/Berlin"
      - "CRON_TIME=*/15 * * * *"
      - "CRON_TIME_DIG=*/30 * * * *"
      - "DOMAIN_KEY=1234567890abcdefghijklmnopqrstuvwxyz"
      - "DOMAIN_IPV64=deine-domain.ipv64.net"
      # Erweiterte Optionen (optional):
      # - "DOMAIN_IPV64=deine-domain.ipv64.net,deine-domain.ipv64.de"
      # - "DOMAIN_PRAEFIX_YES=yes"
      # ⚠️ Hier bitte nur ein DOMAIN PRAEFIX (subdomain) eintragen (ersetzen) ⚠️
      # - "DOMAIN_PRAEFIX=ddns"
      # IPv4/IPv6 Kontrolle:
      # - "IPV4_ENABLED=yes"
      # - "IPV6_ENABLED=no"
      # Weitere Optionen:
      # - "IP_CHECK=yes"
      # - "SHOUTRRR_URL="
      # - "SHOUTRRR_SKIP_TEST=no"
      # - "NAME_SERVER=ns1.ipv64.net"
      # - "NETWORK_CHECK=yes"
      # - "CURL_USER_AGENT=DDNS-Updater-IPv64_github.com/alcapone1933/docker-ddns-ipv64_version_v0.1.9"
      # Log-Rotation:
      # - "MAX_FILES=10"
      # - "MAX_LINES=1000"
      # Benutzer-/Gruppen-IDs:
      # - "PUID=1000"
      # - "PGID=1000"
```

&nbsp;

***

## IPv6 Netzwerk in Docker einrichten

Für die vollständige Unterstützung von IPv6 in Docker müssen zusätzliche Konfigurationsschritte durchgeführt werden:

### 1. Docker Daemon für IPv6 konfigurieren

Erstelle oder bearbeite die Datei `/etc/docker/daemon.json`:

```json
{
  "ipv6": true,
  "fixed-cidr-v6": "2001:db8:1::/64",
  "experimental": true,
  "ip6tables": true
}
```

### 2. Docker Service neustarten

Nach der Konfiguration muss der Docker-Dienst neugestartet werden:

```bash
sudo systemctl restart docker
```

### 3. Container mit IPv6-Netzwerk starten

Verwende das erstellte Netzwerk beim Starten des Containers:

```bash
docker run -d \
    --restart always \
    --name ddns-ipv64 \
    --network_mode bridge \
    -e "CRON_TIME=*/15 * * * *" \
    -e "CRON_TIME_DIG=*/30 * * * *" \
    -e "DOMAIN_KEY=1234567890abcdefghijklmnopqrstuvwxyz" \
    -e "DOMAIN_IPV64=deine-domain.ipv64.net" \
    -e "IPV4_ENABLED=yes" \
    -e "IPV6_ENABLED=yes" \
    alcapone1933/ddns-ipv64:latest
```

### 4. Docker Compose mit IPv6

Für Docker Compose füge die Netzwerk-Konfiguration hinzu:

```yaml
services:
  ddns-ipv64:
    image: alcapone1933/ddns-ipv64:latest
    container_name: ddns-ipv64
    restart: unless-stopped
    network_mode: bridge
    volumes:
      - data:/data
    environment:
      - "TZ=Europe/Berlin"
      - "CRON_TIME=*/15 * * * *"
      - "CRON_TIME_DIG=*/30 * * * *"
      - "DOMAIN_KEY=1234567890abcdefghijklmnopqrstuvwxyz"
      - "DOMAIN_IPV64=deine-domain.ipv64.net"
      # Erweiterte Optionen (optional):
      # - "DOMAIN_IPV64=deine-domain.ipv64.net,deine-domain.ipv64.de"
      # - "DOMAIN_PRAEFIX_YES=yes"
      # ⚠️ Hier bitte nur ein DOMAIN PRAEFIX (subdomain) eintragen (ersetzen) ⚠️
      # - "DOMAIN_PRAEFIX=ddns"
      # IPv4/IPv6 Kontrolle:
      - "IPV4_ENABLED=yes"
      - "IPV6_ENABLED=yes"
      # Weitere Optionen:
      # - "IP_CHECK=yes"
      # - "SHOUTRRR_URL="
      # - "SHOUTRRR_SKIP_TEST=no"
      # - "NAME_SERVER=ns1.ipv64.net"
      # - "NETWORK_CHECK=yes"
      # - "CURL_USER_AGENT=DDNS-Updater-IPv64_github.com/alcapone1933/docker-ddns-ipv64_version_v0.1.9"
      # Log-Rotation:
      # - "MAX_FILES=10"
      # - "MAX_LINES=1000"
      # Benutzer-/Gruppen-IDs:
      # - "PUID=1000"
      # - "PGID=1000"
volumes:
  data:
    name: ddns-ipv64_data
```

⚠️ **Wichtige Hinweise:**
- Nach Änderungen an der `daemon.json` muss Docker immer neugestartet werden.
- Stelle sicher, dass dein Host-System IPv6-Konnektivität hat.

&nbsp;

***

## Volume Parameter

| Name (Beschreibung) #Optional | Wert    | Standard              |
| ----------------------------- | ------- | --------------------- |
| Speicherort logs              | volume  | ddns-ipv64_data:/data |
|                               |         | /dein Pfad:/data      |

&nbsp;

## Env Parameter

| Name (Beschreibung)                                                                               | Wert               | Standard           | Beispiel                                     |
| ------------------------------------------------------------------------------------------------- | ------------------ | ------------------ | -------------------------------------------- |
| Zeitzone                                                                                          | TZ                 | Europe/Berlin      | Europe/Berlin                                |
| Zeitliche Abfrage für die aktuelle IP                                                             | CRON_TIME          | */15 * * * *       | */15 * * * *                                 |
| Zeitliche Abfrage auf die Domain (dig DOMAIN_IPV64 A)                                             | CRON_TIME_DIG      | */30 * * * *       | */30 * * * *                                 |
| DOMAIN KEY: DEIN DOMAIN KEY bzw. DynDNS Updatehash zu finden unter https://ipv64.net/dyndns       | DOMAIN_KEY         | ------------------ | 1234567890abcdefghijklmnopqrstuvwxyz         |
| DEINE DOMAIN:  z.b. deine-domain.ipv64.net zu finden unter         https://ipv64.net/dyndns       | DOMAIN_IPV64       | ------------------ | deine-domain.ipv64.net                       |
| DEINE DOMAINS: z.b. deine-domain.ipv64.net, deine-domain.ipv64.de                                 | DOMAIN_IPV64       | ------------------ | deine-domain.ipv64.net,deine-domain.ipv64.de |
| DOMAIN PRAEFIX YES: Damit wird das Domain PRAEFIX aktiv genutzt                                   | DOMAIN_PRAEFIX_YES | no                 | yes    (yes oder no)                         |
| DEIN DOMAIN PRAEFIX (subdomain): ⚠️ Nur ein Praefix verwenden ⚠️ z.b. ddns                       | DOMAIN_PRAEFIX     | ------------------ | ddns                                         |
| IP CHECK: Die IP-Adresse der Domain wird überprüft                                                | IP_CHECK           | yes                | yes    (yes oder no)                         |
| SHOUTRRR URL: Deine Shoutrrr URL als Benachrichtigungsdienst z.b ( gotify,discord,telegram,email) | SHOUTRRR_URL       | ------------------ | [Shoutrrr-Beispiele](#shoutrrr-beispiele)    |
| SHOUTRRR SKIP TEST: Beim Start des Containers wird keine Testnachricht gesendet                   | SHOUTRRR_SKIP_TEST | no                 | no     (yes oder no)                         |
| NAME SERVER: Der Nameserver, um die IP-Adresse Ihrer Domain zu überprüfen                         | NAME_SERVER        | ns1.ipv64.net      | ns1.ipv64.net (ns2.ipv64.net  zb. 1.1.1.1)   |
| NETWORK CHECK: Es wird die Verbidung zu ipv64.net getestet                                        | NETWORK_CHECK      | yes                | yes    (yes oder no)                         |
| PUID: Rechte für Benutzer-ID des Ornder /data im Container                                        | PUID               | 0                  | 1000                                         |
| PGID: Rechte für Gruppen-ID des Ornder /data im Container                                         | PGID               | 0                  | 1000                                         |
| IPV4_ENABLED: Wenn aktiviert, wird die öffentliche IPv4-Adresse an ipv64.net gesendet             | IPV4_ENABLED       | yes                | yes    (yes oder no)                         |
| IPV6_ENABLED: Wenn aktiviert, wird die öffentliche IPv6-Adresse an ipv64.net gesendet             | IPV6_ENABLED       | no                 | no    (yes oder no)                          |

* * *

&nbsp;

## Shoutrrr Beispiele

Die Nachricht wird fest vom Script erstellt. \
Sie können den Betreff (titel) frei wählen wie im Beispiel genannt. \
So könnte die Nachricht ausehen.

```txt
Betreff:   DDNS IPV64 IP UPDATE
# Die Nachricht wird fest vom Script erstellt.
Nachricht: DOCKER DDNS UPDATER IPV64.NET - IP UPDATE !!!
           DATUM  UPDATE !!! 
           Update IP=IP - Alte-IP=IP
           DOMAIN: DOMAIN

----------------------------------------------------------
Nachricht: DOCKER DDNS UPDATER IPV64.NET - IP UPDATE !!!
           2022-12-27 14:40:59  UPDATE !!!
           Update IP=1.0.0.1 - Alte-IP=1.1.1.1
           DOMAIN: deine-domain.ipv64.net

Nachricht: DOCKER DDNS UPDATER IPV64.NET - IP UPDATE !!!
           2022-12-27 14:40:59  UPDATE !!!
           Update IP=1.0.0.1 - Alte-IP=1.1.1.1
           DOMAIN mit PRAEFIX: ddnd.deine-domain.ipv64.net
```

Das sind Beispiele für Shoutrrr als Benachrichtigungsdienst, für weitere Services infos fidetest du hier [Shoutrrr](https://containrrr.dev/shoutrrr/latest/services/overview/)

| Service Name | URL Beispiel                                                                                      |
| ------------ | ------------------------------------------------------------------------------------------------- |
| gotify       | `gotify://<url domain.de>/<token>/?title=<title>&priority=<priority>`                             |
| discord      | `discord://<token>@<webhook id>?title=<title>`                                                    |
| telegram     | `telegram://<token>@telegram/?chats=<chad_id>&title=<title>`                                      |
| smtp (email) | `smtp://<username>:<password>@<host>:<port>/?from=<sender_email>&to=<to_email>&subject=<subject>` |


| Service Name | URL Beispiel (Beispiel text)                                                                                                  |
| ------------ | ----------------------------------------------------------------------------------------------------------------------------- |
| gotify       | `gotify://domain.de/123456abc/?title=DDNS+IPV64+IP+UPDATE&priority=5`                                                         |
| discord      | `discord://123456abc@555555555555555?title=DDNS+IPV64+IP+UPDATE`                                                              |
| telegram     | `telegram://1111111111:123456abc@telegram/?chats=5555555555&title=DDNS+IPV64+IP+UPDATE`                                       |
| smtp (email) | `smtp://noreply@domain.de:password@mail.domain.de:587/?from=noreply@domain.de&to=user@domain.de&subject=DDNS+IPV64+IP+UPDATE` |

&nbsp;

### Du kannst die Shoutrrr URL auch generieren lassen

```bash
# $ docker run --rm -it alcapone1933/shoutrrr generate
#Error: no service specified
#Usage:
#  shoutrrr generate [flags]
#
#Flags:
#  -g, --generator string       The generator to use (default "basic")
#  -h, --help                   help for generate
#  -p, --property stringArray   Configuration property in key=value format
#  -s, --service string         The notification service to generate a URL for
#
#Available services:
#  opsgenie, slack, teams, generic, googlechat, join, bark, logger, matrix, discord, mattermost, rocketchat, pushbullet, pushover, smtp, telegram, zulip, gotify, hangouts, ifttt

# docker run --rm -it alcapone1933/shoutrrr generate gotify

docker run --rm -it alcapone1933/shoutrrr generate

# TEST
# $ docker run --rm -it alcapone1933/shoutrrr send --verbose --url "< Shoutrrr URL >" --message "DOCKER DDNS UPDATER IPV64.NET"

docker run --rm -it alcapone1933/shoutrrr send --verbose --url "< Shoutrrr URL >" --message "DOCKER DDNS UPDATER IPV64.NET"
```

<details>
<summary markdown="span">DEMO Shoutrrr URL generieren</summary>

<img src="demo/shoutrrr-demo.gif" width="1050" height="400">

</details>

&nbsp;

## DEMO

<img src="demo/demo.gif" width="700" height="400">

