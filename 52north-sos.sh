#!/bin/bash
# ---------------------------------------------------------------------------
# 52north-sos.sh - Install and manage 52North SOS

# Copyright 2016, Natanael Simões, <natanael.simoes@ifro.edu.br>

#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#The above copyright notice and this permission notice shall be included in all
#copies or substantial portions of the Software.
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#SOFTWARE.

# Usage: 52north-sos.sh [-h|--help] [-i|--install] [-h|--host host] [-u|--update] [-s|--self-update]

# Revision history:
# 2016-02-24 Created by new_script ver. 3.3
# ---------------------------------------------------------------------------

PROGNAME=${0##*/}
VERSION="0.1"

clean_up() { # Perform pre-exit housekeeping
  return
}

error_exit() {
  printf "${PROGNAME}: ${1:-"Unknown Error"}" >&2
  printf "\n"
  clean_up
  exit 1
}

graceful_exit() {
  clean_up
  exit
}

signal_exit() { # Handle trapped signals
  case $1 in
    INT)
      error_exit "Program interrupted by user" ;;
    TERM)
      echo -e "\n$PROGNAME: Program terminated" >&2
      graceful_exit ;;
    *)
      error_exit "$PROGNAME: Terminating on unknown signal" ;;
  esac
}

usage() {
  printf "Usage: $PROGNAME [-h|--help] [-i|--install] [-h|--host host] [-u|--update] [-s|--self-update]"
}

help_message() {
  cat <<- _EOF_
  $PROGNAME ver. $VERSION
  Install and manage 52North SOS

  $(usage)

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

_EOF_
  return
}

# Trap signals
trap "signal_exit TERM" TERM HUP
trap "signal_exit INT"  INT

# Check for root UID
checkRoot() {
  if [[ $(id -u) != 0 ]]; then
    error_exit "You must be the superuser to run this script."
  fi
}

checkApacheInstalled() {
  apachectl=$(locate apachectl)
  if [[ ${apachectl// } != "" ]]; then
    error_exit "Previous instalation detected.\n\nPlease uninstall everything before running this parameter (Apache, Tomcat, Postgres...), or simple sun $PROGNAME -u to update.\n"
  fi
}

addRepositories() {
  REPOADDED=$(grep 'apt.postgresql' /etc/apt/sources.list)
  if [[ $REPOADDED == "" ]; then
    printf "Adding needed repositories..."
    OSCODENAME=$(cat /etc/*-release | grep "DISTRIB_CODENAME=") #Get distribution codename
    OSCODENAME=$(echo $OSCODENAME| cut -d '=' -f 2)  
    apt-get -qq -y install python-software-properties
    add-apt-repository ppa:webupd8team/java -y  
    if [[ $OSCODENAME != 'vivid' ]]; then
      echo "deb http://apt.postgresql.org/pub/repos/apt $OSCODENAME-pgdg main" >> /etc/apt/sources.list
    fi
    wget --quiet -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | sudo apt-key add -
    apt-get update
  fi
}

installJava() {
  if [[ $JAVA_HOME == "" ]]; then
    printf "Installing Java 7...\n";    
    apt-get -qq -y install oracle-java7-installer
  fi
}

installApache() {
  printf "Installing Apache 2...\n";
  apt-get -y install apache2 maven
}

installTomcat() {
  printf "installing Tomcat 7...\n";
  apt-get -y install tomcat7 tomcat7-admin
}

installPostgres() {
  printf "Installing PostgreSQL 9.4 + PostGIS...\n";
  apt-get -m -y install postgresql-9.4-postgis-2.1 postgresql-contrib-9.4
  apt-get -m -y install postgresql-9.4-postgis pgadmin3 postgresql-contrib #older OS
}

installSOS() {
  checkRoot
  addRepositories
  checkApacheInstalled
  installJava
  installApache
  installTomcat
  installPostgres
  printf "\n\nInstalation complete. Visit xxx to start using 52North SOS.\n\n"
}

# Parse command-line
while [[ -n $1 ]]; do
  case $1 in
    -h | --help)
      help_message; graceful_exit ;;
    -i | --install)
      install=yes ;;    
    -t | --host)
      shift; host="$1" ;;
    -u | --update)
      update=yes ;;
    -s | --self-update)
      self_update=yes ;;
    -* | --*)
      usage
      error_exit "Unknown option $1" ;;
    *)
      printf "Argument $1 to process..." ;;
  esac
  shift
done

# Main logic
if [[ $install ]]; then
  installSOS
elif [[ $update ]]; then
  updateSOS
elif [[ $self_update ]]; then
  selfUpdate
fi

graceful_exit

