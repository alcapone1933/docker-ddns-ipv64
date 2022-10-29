# docker-ddns-ipv64

[![Build Status](https://shields.cosanostra-cloud.de/drone/build/alcapone1933/docker-ddns-ipv64?logo=drone&server=https%3A%2F%2Fdrone.docker-for-life.de)](https://drone.docker-for-life.de/alcapone1933/docker-ddns-ipv64)
[![Build Status Branch Master](https://shields.cosanostra-cloud.de/drone/build/alcapone1933/docker-ddns-ipv64/master?logo=drone&label=build%20%5Bbranch%20master%5D&server=https%3A%2F%2Fdrone.docker-for-life.de)](https://drone.docker-for-life.de/alcapone1933/docker-ddns-ipv64/branches)
[![Docker Pulls](https://shields.cosanostra-cloud.de/docker/pulls/alcapone1933/ddns-ipv64?logo=docker&logoColor=blue)](https://hub.docker.com/r/alcapone1933/ddns-ipv64/tags)
![Docker Image Version (latest semver)](https://shields.cosanostra-cloud.de/docker/v/alcapone1933/ddns-ipv64?sort=semver&logo=docker&logoColor=blue&label=dockerhub%20version)

&nbsp;

### DDNS Updater in Docker für die Webseite https://ipv64.net/ erst einmal nur für ipv4

&nbsp;
* * *
&nbsp;

## Docker CLI

```bash
docker run -d \
    --restart always \
    --name ddns-ipv64 \
    -e "CRON_TIME=*/15 * * * *" \
    -e "CRON_TIME_DIG=*/30 * * * *" \
    -e "DOMAIN_IPV64=DEINE DOMAIN https://ipv64.net/dyndns.php" \
    -e "DOMAIN_KEY=DEIN DOMAIN KEY bzw. DynDNS Updatehash" \
    alcapone1933/ddns-ipv64:latest

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
      # Standert Abfrage Alle 15 Minuten
      - "CRON_TIME=*/15 * * * *"
      # Standert Alle 30 Minuten Abfrage ob der Domain eintrag richtig ist
      - "CRON_TIME_DIG=*/30 * * * *"
      - "DOMAIN_IPV64=DEINE DOMAIN https://ipv64.net/dyndns.php"
      - "DOMAIN_KEY=DEIN DOMAIN KEY bzw. DynDNS Updatehash"

```


&nbsp;

&nbsp;

## Volume Parameter

| Name (Beschreibung) #Optional | Wert    | Standert                                     |
| ----------------------------- | ------- | -------------------------------------------- |
| Speichertort logs und Script  | volume  | ddns-ipv64_data:/data oder /dein Pfad:/data  |

* * *

&nbsp;

## Env Parameter

| Name (Beschreibung)                                             | Wert            | Standert           |
| --------------------------------------------------------------- | --------------- | ------------------ |
| Zeitzone                                                        | TZ              | Europe/Berlin      |
| Zeitliche abfrage für die Aktuelle IP                           | CRON_TIME       | */15 * * * *       |
| Zeitliche abfrage auf die Domain (dig DOMAIN_IPV64 A}           | CRON_TIME_DIG   | */30 * * * *       |
| DOMAIN KEY: DEIN DOMAIN KEY bzw. DynDNS Updatehash              | DOMAIN_KEY      | ------------------ |
| DEINE DOMAIN: z.b. demo.ipv64.net https://ipv64.net/dyndns.php" | DOMAIN_IPV64    | ------------------ |

* * *

&nbsp;

## DEMO

<img src="demo/demo.gif" width="700" height="400">

