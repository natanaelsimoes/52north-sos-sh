# 52north-sos.sh
This is a bash script to install and manage 52°North SOS in a debian-based linux server: a working in progress for my master degree in Applied Computing at [UEFS][12] about local climate sensing of [Feira de Santana][13] based on [Internet of Things][14].

Main project can be viewed in [52° North GitHub repository][1].

## Installation
```
wget https://raw.githubusercontent.com/natanaelsimoes/52north-sos-sh/master/52north-sos.sh
chmod +x 52north-sos.sh
mv 52north-sos.sh /usr/local/bin/52north-sos
```

## Usage
```
# 52north-sos -i
```
These are the default usernames and passwords to manage services installed:
 * tomcat7 : username `uefs` / password `uefs`
 * postgresql-9.4 : username `postgres` / password `postgres`
 * 52n-sos-webapp : username `admin` / password `password`

### Other options
```
$ 52north-sos -h

  52north-sos ver. 1.0
  Install and manage 52North SOS

  Usage: 52north-sos [-h|--help] [-i|--install] [-h|--host host] [-u|--update] [-s|--self-update]

  Options:
  -h, --help         Display this help message and exit.
  -i, --install      Install 52North SOS for the first time.
  -t, --host host    Set the specified argument as the host
                     (to configure jsClient API provider).
                     Will use eth0 address as default if not set.
                     Where 'host' is the IP address or network name.
  -u, --update       Update 52North SOS if a new version is available
  -s, --self-update  Self-update this script is a new version is available

  NOTE: You must be the superuser to run this script.
```

## What is 52°North SOS?

"The 52°North SOS is a reference implementation of the [OGC Sensor Observation Service specification (version 2.0)][2]. It was
implemented during the [OGC Web Services Testbed,  Phase 9 (OWS-9)][3] and tested  to be compliant to this specification within the [OGC CITE testing][4] in December of 2012."

## Script procedure

[Installation procedure of 52°North SOS][5] can be very harmful. There are lot of requirements needed to build/deploy the service. This script just automate the hard work making it simple as running a single command to add repositories to custom packages, install requirements, configure database, download and build 52°North SOS from source.

### Important packages installed

 * [git][6] : used to control 52°North SOS versioning
 * [xml-twig-tools][7] : used to get information in XML configuration files
 * [maven][8] : it configures application, runs tests and builds WAR file
 * [oracle-java7-installer][9] : installs official Oracle Java JDK 7
 * [tomcat7][10] : the Java Application Server
 * [postgresql-9.4-postgis-2.1][11] : the database with geographical capabilities

### Determining SOS version

As tested, not every 52°North SOS commit works well. Because of that, [VERSION file](VERSION) will always hold the latest working version commit id to ensure installation success.

--
[1]: https://github.com/52north/SOS
[2]: https://portal.opengeospatial.org/files/?artifact_id=47599
[3]: http://www.ogcnetwork.net/ows-9
[4]: http://cite.opengeospatial.org/test_engine
[5]: https://wiki.52north.org/bin/view/SensorWeb/SensorObservationServiceIVDocumentation#Installation
[6]: https://github.com/git/git
[7]: https://packages.debian.org/jessie/xml-twig-tools
[8]: https://github.com/apache/maven
[9]: https://launchpad.net/~webupd8team/+archive/ubuntu/java
[10]: https://launchpad.net/tomcat7
[11]: https://packages.debian.org/jessie/postgresql-9.4-postgis-2.1
[12]: http://pgca.uefs.br
[13]: https://en.wikipedia.org/wiki/Feira_de_Santana
[14]: https://en.wikipedia.org/wiki/Internet_of_Things