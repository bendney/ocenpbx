#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ../config.sh
. ../colors.sh

#send a message
verbose "Installing FreeSWITCH"

#install dependencies
yum -y install memcached curl gdb

#install freeswitch packages
yum install -y http://files.freeswitch.org/freeswitch-release-1-6.noarch.rpm
yum install -y git alsa-lib-devel autoconf automake bison broadvoice-devel bzip2 curl-devel db-devel e2fsprogs-devel flite-devel g722_1-devel gcc-c++ gdbm-devel gnutls-devel ilbc2-devel ldns-devel libcodec2-devel libcurl-devel libedit-devel libidn-devel libjpeg-devel libmemcached-devel libogg-devel libsilk-devel libsndfile-devel libtheora-devel libtiff-devel libtool libuuid-devel libvorbis-devel libxml2-devel lua-devel lzo-devel mongo-c-driver-devel ncurses-devel net-snmp-devel openssl-devel opus-devel pcre-devel perl perl-ExtUtils-Embed pkgconfig portaudio-devel postgresql-devel python26-devel python-devel soundtouch-devel speex-devel sqlite-devel unbound-devel unixODBC-devel wget which yasm zlib-devel

cwd=$(pwd)
cd freeswitch

./bootstrap.sh -j
./configure -C --enable-portable-binary --with-gnu-ld --with-python --with-openssl --enable-core-odbc-support --enable-zrtp --enable-core-pgsql-support
make  -j 
make -j install 

cd $cwd

#remove the music package to protect music on hold from package updates
mkdir -p /usr/share/freeswitch/sounds/temp
mv /usr/share/freeswitch/sounds/music/*000 /usr/share/freeswitch/sounds/temp
yum -y remove freeswitch-sounds-music
mkdir -p /usr/share/freeswitch/sounds/music/default
mv /usr/share/freeswitch/sounds/temp/* /usr/share/freeswitch/sounds/music/default
rm -R /usr/share/freeswitch/sounds/temp

#send a message
verbose "FreeSWITCH installed"
