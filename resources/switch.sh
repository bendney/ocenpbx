#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#install source
switch/source-release.sh
#copy the switch conf files to /etc/freeswitch
switch/conf-copy.sh

