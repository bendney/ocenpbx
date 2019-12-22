#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./config.sh
. ./colors.sh

#send a message
verbose "Installing Prosody"

#included in the distribution
yum -y update
yum -y install prosody


#Reserve prosody configuration 

#systemd 
systemctl restart prosody

#send a message
verbose "Prosoy installed"
