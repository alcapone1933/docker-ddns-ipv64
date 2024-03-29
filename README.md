# docker-ddns-ipv64

[![Build Status](https://shields.cosanostra-cloud.de/drone/build/alcapone1933/docker-ddns-ipv64?logo=drone&server=https%3A%2F%2Fdrone.docker-for-life.de)](https://drone.docker-for-life.de/alcapone1933/docker-ddns-ipv64)
[![Build Status Branch Master](https://shields.cosanostra-cloud.de/drone/build/alcapone1933/docker-ddns-ipv64/master?logo=drone&label=build%20%5Bbranch%20master%5D&server=https%3A%2F%2Fdrone.docker-for-life.de)](https://drone.docker-for-life.de/alcapone1933/docker-ddns-ipv64/branches)
[![Docker Pulls](https://shields.cosanostra-cloud.de/docker/pulls/alcapone1933/ddns-ipv64?logo=docker&logoColor=blue)](https://hub.docker.com/r/alcapone1933/ddns-ipv64/tags)
![Docker Image Version (latest semver)](https://shields.cosanostra-cloud.de/docker/v/alcapone1933/ddns-ipv64?sort=semver&logo=docker&logoColor=blue&label=dockerhub%20version)
[![Website](https://shields.cosanostra-cloud.de/website?down_color=red&down_message=DOWN&label=Webseite%20IPV64.NET&up_color=green&up_message=UP&url=https%3A%2F%2Fipv64.net%2F)](https://ipv64.net/)

&nbsp;

# DDNS Updater in Docker für Free DynDNS [IPv64.net](https://ipv64.net/) - NUR FÜR IPV4 -

Dieser Docker Container ist ein DDNS Updater für Free DynDNS - ipv64.net.

Bei einer Änderung der ipv4 Adresse am Standort wird die neue ipv4 Adresse als A-Record an ipv64.net geschickt.

Wenn Du dieses Docker Projekt nutzen möchtest, ändere bitte die Environments vor dem Starten des Docker Containers.

&nbsp;

***

## Erklärung

### Domain

  * Hier bitte deine DOMAIN eintragen (ersetzen), die unter https://ipv64.net/dyndns.php erstellt wurde, z.B "deine-domain.ipv64.net"

    `-e "DOMAIN_IPV64=deine-domain.ipv64.net"`

  * Wenn Du mehrere DOMAINS eintragen willst, bitte mit Komma trennen:

    `-e "DOMAIN_IPV64=deine-domain.ipv64.net,deine-domain.ipv64.de"`

&nbsp;

### Domain Praefix

  * Wenn Du einen DOMAIN PRAEFIX verwenden willst, dann benutze die Variablen ***DOMAIN_PRAEFIX_YES=yes*** und ***DOMAIN_PRAEFIX***

    `-e "DOMAIN_PRAEFIX_YES=yes"`
  
  * Hier bitte nur ein DOMAIN PRAEFIX (subdomain) eintragen (ersetzen), das unter https://ipv64.net/dyndns.php erstellt wurde:

    `-e "DOMAIN_PRAEFIX=ddns"`

⚠️ ***Solltest Du mehrere DOMAINS verwenden, dann bitte nur ein PRAEFIX eintragen (ersetzen)*** ⚠️

***Bei mehreren Domains wird immer derselbe PRAEFIX verwendet.***

***Beispiel: ddns.deine-domain.ipv64.net und ddns.deine-domain.ipv64.de***

&nbsp;

### Domain Key

  * Hier bitte dein DOMAIN KEY bzw. DynDNS Updatehash eintragen (ersetzen). \
    Zu finden ist dieser unter https://ipv64.net/dyndns.php z.B "1234567890abcdefghijklmn"

    `-e "DOMAIN_KEY=1234567890abcdefghijklmn"`

&nbsp;

***

## Docker CLI

```bash
docker run -d \
    --restart always \
    --name ddns-ipv64 \
    -e "CRON_TIME=*/15 * * * *" \
    -e "CRON_TIME_DIG=*/30 * * * *" \
    -e "DOMAIN_IPV64=deine-domain.ipv64.net" \
    -e "DOMAIN_KEY=1234567890abcdefghijklmn" \
    alcapone1933/ddns-ipv64:latest


    -e "DOMAIN_IPV64=deine-domain.ipv64.net,deine-domain.ipv64.de" \
    -e "DOMAIN_PRAEFIX_YES=yes" \
    "⚠️ Hier bitte nur ein DOMAIN PRAEFIX (subdomain) eintragen (ersetzen) ⚠️"
    -e "DOMAIN_PRAEFIX=ddns" \
    -e "SHOUTRRR_URL=" \
    -e "SHOUTRRR_SKIP_TEST=no" \
    -e "NAME_SERVER=ns1.ipv64.net" \

```

## Docker Compose

```yaml
version: "3.9"
services:
  ddns-ipv64:
    image: alcapone1933/ddns-ipv64:latest
    container_name: ddns-ipv64
    restart: always
    environment:
      - "TZ=Europe/Berlin"
      - "CRON_TIME=*/15 * * * *"
      - "CRON_TIME_DIG=*/30 * * * *"
      - "DOMAIN_IPV64=deine-domain.ipv64.net"
      # - "DOMAIN_IPV64=deine-domain.ipv64.net,deine-domain.ipv64.de"
      # - "DOMAIN_PRAEFIX_YES=yes"
      # ⚠️ Hier bitte nur ein DOMAIN PRAEFIX (subdomain) eintragen (ersetzen) ⚠️
      # - "DOMAIN_PRAEFIX=ddns"
      - "DOMAIN_KEY=1234567890abcdefghijklmn"
      # - "SHOUTRRR_URL="
      # - "SHOUTRRR_SKIP_TEST=no"
      # - "NAME_SERVER=ns1.ipv64.net"
```

&nbsp;

***

## Volume Parameter

| Name (Beschreibung) #Optional | Wert    | Standard              |
| ----------------------------- | ------- | --------------------- |
| Speicherort logs und script   | volume  | ddns-ipv64_data:/data |
|                               |         | /dein Pfad:/data      |

&nbsp;

## Env Parameter

| Name (Beschreibung)                                                                               | Wert               | Standard           | Beispiel                                     |
| ------------------------------------------------------------------------------------------------- | ------------------ | ------------------ | -------------------------------------------- |
| Zeitzone                                                                                          | TZ                 | Europe/Berlin      | Europe/Berlin                                |
| Zeitliche Abfrage für die aktuelle IP                                                             | CRON_TIME          | */15 * * * *       | */15 * * * *                                 |
| Zeitliche Abfrage auf die Domain (dig DOMAIN_IPV64 A)                                             | CRON_TIME_DIG      | */30 * * * *       | */30 * * * *                                 |
| DOMAIN KEY: DEIN DOMAIN KEY bzw. DynDNS Updatehash zu finden unter https://ipv64.net/dyndns.php   | DOMAIN_KEY         | ------------------ | 1234567890abcdefghijklmn                     |
| DEINE DOMAIN:  z.b. deine-domain.ipv64.net zu finden unter         https://ipv64.net/dyndns.php   | DOMAIN_IPV64       | ------------------ | deine-domain.ipv64.net                       |
| DEINE DOMAINS: z.b. deine-domain.ipv64.net, deine-domain.ipv64.de                                 | DOMAIN_IPV64       | ------------------ | deine-domain.ipv64.net,deine-domain.ipv64.de |
| DOMAIN PRAEFIX YES: Damit wird das Domain PRAEFIX aktiv genutzt                                   | DOMAIN_PRAEFIX_YES | no                 | yes    (yes oder no)                         |
| DEIN DOMAIN PRAEFIX (subdomain) : ⚠️ Nur ein Praefix verwenden ⚠️ z.b. ddns                      | DOMAIN_PRAEFIX     | ------------------ | ddns                                         |
| IP CHECK: Die IP-Adresse der Domain wird überprüft                                                | IP_CHECK           | yes                | yes    (yes oder no)                         |
| SHOUTRRR URL: Deine Shoutrrr URL als Benachrichtigungsdienst z.b ( gotify,discord,telegram,email) | SHOUTRRR_URL       | ------------------ | [Shoutrrr-Beispiele](#shoutrrr-beispiele)    |
| SHOUTRRR_SKIP_TEST: Beim Start des Containers wird keine Testnachricht gesendet                   | SHOUTRRR_SKIP_TEST | no                 | no     (yes oder no)                         |
| NAME_SERVER: : Der Nameserver, um die IP-Adresse Ihrer Domain zu überprüfen                       | NAME_SERVER        | ns1.ipv64.net      | ns1.ipv64.net                                |

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
