# docker-ddns-ipv64

[![Build Status](https://shields.cosanostra-cloud.de/drone/build/alcapone1933/docker-ddns-ipv64?logo=drone&server=https%3A%2F%2Fdrone.docker-for-life.de)](https://drone.docker-for-life.de/alcapone1933/docker-ddns-ipv64)
[![Build Status Branch Master](https://shields.cosanostra-cloud.de/drone/build/alcapone1933/docker-ddns-ipv64/master?logo=drone&label=build%20%5Bbranch%20master%5D&server=https%3A%2F%2Fdrone.docker-for-life.de)](https://drone.docker-for-life.de/alcapone1933/docker-ddns-ipv64/branches)
[![Docker Pulls](https://shields.cosanostra-cloud.de/docker/pulls/alcapone1933/ddns-ipv64?logo=docker&logoColor=blue)](https://hub.docker.com/r/alcapone1933/ddns-ipv64/tags)
![Docker Image Version (latest semver)](https://shields.cosanostra-cloud.de/docker/v/alcapone1933/ddns-ipv64?sort=semver&logo=docker&logoColor=blue&label=dockerhub%20version)
[![Website](https://shields.cosanostra-cloud.de/website?down_color=red&down_message=down&label=Status%20Webseite%20IPV64.NET&style=plastic&up_color=green&up_message=ready&url=https%3A%2F%2Fipv64.net%2F)](https://ipv64.net/)
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
      # Standard Abfrage alle 15 Minuten nach der aktuellen ip
      - "CRON_TIME=*/15 * * * *"
      # Standard Abfrage alle 30 Minuten für die Domain Adresse 
      - "CRON_TIME_DIG=*/30 * * * *"
      #  Hier bitte deine DOMAIN eintragen (ersetzen), die unter https://ipv64.net/dyndns.php erstellt wurde, z.B "deine-domain.ipv64.net"
      - "DOMAIN_IPV64=deine-domain.ipv64.net"
      #  Wenn Du mehrere DOMAINS eintragen willst, bitte mit Komma trennen:
      # - "DOMAIN_IPV64=deine-domain.ipv64.net,deine-domain.ipv64.de"
      # Damit wird das Domain PRAEFIX aktiv genutzt
      # - "DOMAIN_PRAEFIX_YES=yes"
      # ⚠️ Hier bitte nur ein DOMAIN PRAEFIX (subdomain) eintragen (ersetzen), das unter https://ipv64.net/dyndns.php erstellt wurde. Gilt auch bei mehreren Domains ⚠️
      # - "DOMAIN_PRAEFIX=ddns"
      # Hier bitte dein DOMAIN KEY bzw. DynDNS Updatehash eintragen (ersetzen). Zu finden ist dieser unter https://ipv64.net/dyndns.php z.B "1234567890abcdefghijklmn"
      - "DOMAIN_KEY=1234567890abcdefghijklmn"

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

| Name (Beschreibung)                                                                             | Wert               | Standard           | Beispiel                                     |
| ----------------------------------------------------------------------------------------------- | ------------------ | ------------------ | -------------------------------------------- |
| Zeitzone                                                                                        | TZ                 | Europe/Berlin      | Europe/Berlin                                |
| Zeitliche Abfrage für die aktuelle IP                                                           | CRON_TIME          | */15 * * * *       | */15 * * * *                                 |
| Zeitliche Abfrage auf die Domain (dig DOMAIN_IPV64 A)                                           | CRON_TIME_DIG      | */30 * * * *       | */30 * * * *                                 |
| DOMAIN KEY: DEIN DOMAIN KEY bzw. DynDNS Updatehash zu finden unter https://ipv64.net/dyndns.php | DOMAIN_KEY         | ------------------ | 1234567890abcdefghijklmn                     |
| DEINE DOMAIN:  z.b. deine-domain.ipv64.net zu finden unter         https://ipv64.net/dyndns.php | DOMAIN_IPV64       | ------------------ | deine-domain.ipv64.net                       |
| DEINE DOMAINS: z.b. deine-domain.ipv64.net, deine-domain.ipv64.de                               | DOMAIN_IPV64       | ------------------ | deine-domain.ipv64.net,deine-domain.ipv64.de |
| DOMAIN PRAEFIX YES: Damit wird das Domain PRAEFIX aktiv genutzt                                 | DOMAIN_PRAEFIX_YES | no                 | yes                                          |
| DEIN DOMAIN PRAEFIX (subdomain) : ⚠️ Nur ein Praefix verwenden ⚠️ z.b. ddns                    | DOMAIN_PRAEFIX     | ------------------ | ddns                                         |

* * *

&nbsp;

## DEMO

<img src="demo/demo.gif" width="700" height="400">
