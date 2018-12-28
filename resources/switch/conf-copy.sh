#!/bin/sh

#copy the conf directory
mv /usr/local/freeswitch/conf /usr/local/freeswitch/conf.orig
mkdir /usr/local/freeswitch/conf
cp -R switch/config/* /usr/local/freeswitch/conf
\cp -rf switch/lua/* /usr/local/freeswitch/scripts/
