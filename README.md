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
    -e "SHOUTRRR_URL=" \
    -e "SHOUTRRR_SKIP_TEST=no" \
    -e "NAME_SERVER=ns1.ddnss.de" \

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
      - "CRON_TIME=*/15 * * * *"
      - "CRON_TIME_DIG=*/30 * * * *"
      - "DOMAIN_DDNSS=deine-domain.ddnss.de"
      #  Wenn Du mehrere DOMAINS (vHostname) eintragen willst, bitte mit Komma trennen:
      # - "DOMAIN_DDNSS=deine-domain.ddnss.de,deine-domain.ddnss.org"
      - "DOMAIN_KEY=1234567890abcdefghijklmnopqrstuv"
      # - "SHOUTRRR_URL="
      # - "SHOUTRRR_SKIP_TEST=no"
      # - "NAME_SERVER=ns1.ddnss.de"
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

| Name (Beschreibung)                                                                               | Wert               | Standard           | Beispiel                                     |
| ------------------------------------------------------------------------------------------------- | ------------------ | ------------------ | -------------------------------------------- |
| Zeitzone                                                                                          | TZ                 | Europe/Berlin      | Europe/Berlin                                |
| Zeitliche Abfrage für die aktuelle IP                                                             | CRON_TIME          | */15 * * * *       | */15 * * * *                                 |
| Zeitliche Abfrage auf die Domain (dig DOMAIN_DDNSS A)                                             | CRON_TIME_DIG      | */30 * * * *       | */30 * * * *                                 |
| DOMAIN KEY: DEIN KEY bzw. DynDNS Update Key zu finden unter     https://ddnss.de/ua/index.php     | DOMAIN_KEY         | ------------------ | 1234567890abcdefghijklmnopqrstuv             |
| DEINE DOMAIN:  z.b. deine-domain.ddnss.de zu finden unter https://ddnss.de/ua/vhosts_list.php     | DOMAIN_DDNSS       | ------------------ | deine-domain.ddnss.de                        |
| DEINE DOMAINS: z.b. deine-domain.ddnss.de,deine-domain.ddnss.org                                  | DOMAIN_DDNSS       | ------------------ | deine-domain.ddnss.de,deine-domain.ddnss.org |
| IP CHECK: Die IP Adresse der Domain wird überprüft                                                | IP_CHECK           | Yes                | Yes                                          |
| SHOUTRRR URL: Deine Shoutrrr URL als Benachrichtigungsdienst z.b ( gotify,discord,telegram,email) | SHOUTRRR_URL       | ------------------ | [Shoutrrr-Beispiele](#shoutrrr-beispiele)    |
| SHOUTRRR_SKIP_TEST: Beim Start des Containers wird keine Testnachricht gesendet                   | SHOUTRRR_SKIP_TEST | no                 | no     (yes oder no)                         |
| NAME_SERVER: : Der Nameserver, um die IP-Adresse Ihrer Domain zu überprüfen                       | NAME_SERVER        | ns1.ddnss.de       | ns1.ddnss.de (ns3.ddnss.de)                  |

* * *

&nbsp;

## Shoutrrr Beispiele

Die Nachricht wird fest vom Script erstellt. \
Sie können den Betreff (titel) frei wählen wie im Beispiel genannt. \
So könnte die Nachricht ausehen.

```txt
Betreff:   DDNS DDNSS.DE IP UPDATE
# Die Nachricht wird fest vom Script erstellt.
Nachricht: DOCKER DDNS UPDATER DDNSS.DE - IP UPDATE !!!
           DATUM  UPDATE !!! 
           Update IP=IP - Alte-IP=IP
           DOMAIN: DOMAIN

----------------------------------------------------------
Nachricht: DOCKER DDNS UPDATER DDNSS.DE - IP UPDATE !!!
           2023-01-01 08:01:00  UPDATE !!!
           Update IP=1.0.0.1 - Alte-IP=1.1.1.1
           DOMAIN: deine-domain.ddnss.de

```

Das sind Beispiele für Shoutrrr als Benachrichtigungsdienst, für weitere Services infos fidetest du hier [Shoutrrr](https://containrrr.dev/shoutrrr/latest/services/overview/)

| Service Name | URL Beispiel                                                                                      |
| ------------ | ------------------------------------------------------------------------------------------------- |
| gotify       | `gotify://<url domain.de>/<token>/?title=<title>&priority=<priority>`                             |
| discord      | `discord://<token>@<webhook id>?title=<title>`                                                    |
| telegram     | `telegram://<token>@telegram/?chats=<chad_id>&title=<title>`                                      |
| smtp (email) | `smtp://<username>:<password>@<host>:<port>/?from=<sender_email>&to=<to_email>&subject=<subject>` |

| Service Name | URL Beispiel (Beispiel text)                                                                                                     |
| ------------ | -------------------------------------------------------------------------------------------------------------------------------- |
| gotify       | `gotify://domain.de/123456abc/?title=DDNS+DDNSS.DE+IP+UPDATE&priority=5`                                                         |
| discord      | `discord://123456abc@555555555555555?title=DDNS+DDNSS.DE+IP+UPDATE`                                                              |
| telegram     | `telegram://1111111111:123456abc@telegram/?chats=5555555555&title=DDNS+DDNSS.DE+IP+UPDATE`                                       |
| smtp (email) | `smtp://noreply@domain.de:password@mail.domain.de:587/?from=noreply@domain.de&to=user@domain.de&subject=DDNS+DDNSS.DE+IP+UPDATE` |

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

docker run --rm -it alcapone1933/shoutrrr send --verbose --url "< Shoutrrr URL >" --message "DOCKER DDNS UPDATER DDNSS.DE"
```

* * *