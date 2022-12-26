# docker-ddns-ddnss

[![Build Status](https://shields.cosanostra-cloud.de/drone/build/alcapone1933/docker-ddns-ddnss?logo=drone&server=https%3A%2F%2Fdrone.docker-for-life.de)](https://drone.docker-for-life.de/alcapone1933/docker-ddns-ddnss)
[![Build Status Branch Master](https://shields.cosanostra-cloud.de/drone/build/alcapone1933/docker-ddns-ddnss/master?logo=drone&label=build%20%5Bbranch%20master%5D&server=https%3A%2F%2Fdrone.docker-for-life.de)](https://drone.docker-for-life.de/alcapone1933/docker-ddns-ddnss/branches)
[![Docker Pulls](https://shields.cosanostra-cloud.de/docker/pulls/alcapone1933/ddns-ddnss?logo=docker&logoColor=blue)](https://hub.docker.com/r/alcapone1933/ddns-ddnss/tags)
![Docker Image Version (latest semver)](https://shields.cosanostra-cloud.de/docker/v/alcapone1933/ddns-ddnss?sort=semver&logo=docker&logoColor=blue&label=dockerhub%20version)

&nbsp;

# DDNS Updater in Docker für DynDNS [ddnss.de](https://ddnss.de/) - NUR FÜR IPV4 -

Dieser Docker Container ist ein DDNS Updater für DynDNS - ddnss.de.

Bei einer Änderung der ipv4 Adresse am Standort wird die neue ipv4 Adresse an ddnss.de geschickt.

Wenn Du dieses Docker Projekt nutzen möchtest, ändere bitte die Environments vor dem Starten des Docker Containers.

&nbsp;

***

## Erklärung

### Domain

  * Hier bitte deine DOMAIN (vHostname) eintragen (ersetzen), die unter https://ddnss.de/ua/vhosts_list.php erstellt wurde, z.B "deine-domain.ddnss.de"

    `-e "DOMAIN_DDNSS=deine-domain.ddnss.de"`

  * Wenn Du mehrere DOMAINS (vHostname) eintragen willst, bitte mit Komma trennen:

    `-e "DOMAIN_DDNSS=deine-domain.ddnss.de,deine-domain.ddnss.org"`

&nbsp;

### Domain Key

  * Hier bitte dein KEY bzw. DynDNS Update Key eintragen (ersetzen). \
    Zu finden ist dieser unter https://ddnss.de/ua/index.php z.B "1234567890abcdefghijklmnopqrstuv"

    `-e "DOMAIN_KEY=1234567890abcdefghijklmnopqrstuv"`

&nbsp;

***

## Docker CLI

```bash
docker run -d \
    --restart always \
    --name ddns-ddnss \
    -e "CRON_TIME=*/15 * * * *" \
    -e "CRON_TIME_DIG=*/30 * * * *" \
    -e "DOMAIN_DDNSS=deine-domain.ddnss.de" \
    -e "DOMAIN_KEY=1234567890abcdefghijklmnopqrstuv" \
    alcapone1933/ddns-ddnss:latest

    -e "DOMAIN_DDNSS=deine-domain.ddnss.de,deine-domain.ddnss.org" \
```

## Docker Compose

```yaml
version: "3.9"
services:
  ddns-ddnss:
    image: alcapone1933/ddns-ddnss:latest
    container_name: ddns-ddnss
    restart: always
    environment:
      - "TZ=Europe/Berlin"
      # Standard Abfrage alle 15 Minuten nach der aktuellen ip
      - "CRON_TIME=*/15 * * * *"
      # Standard Abfrage alle 30 Minuten für die Domain Adresse
      - "CRON_TIME_DIG=*/30 * * * *"
      #  Hier bitte deine DOMAIN (vHostname) eintragen (ersetzen), die unter https://ddnss.de/ua/vhosts_list.php erstellt wurde, z.B "deine-domain.ddnss.de"
      - "DOMAIN_DDNSS=deine-domain.ddnss.de"
      #  Wenn Du mehrere DOMAINS (vHostname) eintragen willst, bitte mit Komma trennen:
      # - "DOMAIN_DDNSS=deine-domain.ddnss.de,deine-domain.ddnss.org"
      # Hier bitte dein KEY bzw. DynDNS Update Key eintragen (ersetzen). Zu finden ist dieser unter https://ddnss.de/ua/index.php z.B "1234567890abcdefghijklmnopqrstuv"
      - "DOMAIN_KEY=1234567890abcdefghijklmnopqrstuv"
```

&nbsp;

***

## Volume Parameter

| Name (Beschreibung) #Optional | Wert    | Standard              |
| ----------------------------- | ------- | --------------------- |
| Speicherort logs und script   | volume  | ddns-ddnss_data:/data |
|                               |         | /dein Pfad:/data      |

&nbsp;

## Env Parameter

| Name (Beschreibung)                                                                           | Wert          | Standard           | Beispiel                                     |
| --------------------------------------------------------------------------------------------- | ------------- | ------------------ | -------------------------------------------- |
| Zeitzone                                                                                      | TZ            | Europe/Berlin      | Europe/Berlin                                |
| Zeitliche Abfrage für die aktuelle IP                                                         | CRON_TIME     | */15 * * * *       | */15 * * * *                                 |
| Zeitliche Abfrage auf die Domain (dig DOMAIN_DDNSS A)                                         | CRON_TIME_DIG | */30 * * * *       | */30 * * * *                                 |
| DOMAIN KEY: DEIN KEY bzw. DynDNS Update Key zu finden unter     https://ddnss.de/ua/index.php | DOMAIN_KEY    | ------------------ | 1234567890abcdefghijklmnopqrstuv             |
| DEINE DOMAIN:  z.b. deine-domain.ddnss.de zu finden unter https://ddnss.de/ua/vhosts_list.php | DOMAIN_DDNSS  | ------------------ | deine-domain.ddnss.de                        |
| DEINE DOMAINS: z.b. deine-domain.ddnss.de,deine-domain.ddnss.org                              | DOMAIN_DDNSS  | ------------------ | deine-domain.ddnss.de,deine-domain.ddnss.org |

* * *

