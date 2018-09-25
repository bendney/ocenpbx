#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./config.sh
. ./colors.sh

#send a message
verbose "Installing PostgreSQL"

#generate a random password
password=$(dd if=/dev/urandom bs=1 count=20 2>/dev/null | base64)

#included in the distribution
yum -y update
yum -y install postgresql-server postgresql-contrib postgresql

#send a message
verbose "Initalize PostgreSQL database"

#initialize the database
/usr/bin/postgresql-setup initdb

#allow loopback
sed -i "/listen_addresses/i listen_addresses = '*' " /var/lib/pgsql/data/postgresql.conf
sed -i 's/\(host  *all  *all  *0.0.0.0\/0  *\)ident/\1md5/' /var/lib/pgsql/data/pg_hba.conf
sed -i 's/\(host  *all  *all  *::1\/128  *\)ident/\1md5/' /var/lib/pgsql/data/pg_hba.conf

#systemd
systemctl daemon-reload
systemctl restart postgresql

#move to /tmp to prevent a red herring error when running sudo with psql
cwd=$(pwd)
cd /tmp

#add the databases, users and grant permissions to them
sudo -u postgres /usr/bin/psql -c "DROP SCHEMA public cascade;";
sudo -u postgres /usr/bin/psql -c "CREATE SCHEMA public;";
sudo -u postgres /usr/bin/psql -c "CREATE DATABASE ocenpbx";
sudo -u postgres /usr/bin/psql -c "CREATE DATABASE freeswitch";
sudo -u postgres /usr/bin/psql -c "CREATE ROLE ocenpbx WITH SUPERUSER LOGIN PASSWORD '$password';"
sudo -u postgres /usr/bin/psql -c "CREATE ROLE freeswitch WITH SUPERUSER LOGIN PASSWORD '$password';"
sudo -u postgres /usr/bin/psql -c "GRANT ALL PRIVILEGES ON DATABASE ocenpbx to ocenpbx;"
sudo -u postgres /usr/bin/psql -c "GRANT ALL PRIVILEGES ON DATABASE freeswitch to ocenpbx;"
sudo -u postgres /usr/bin/psql -c "GRANT ALL PRIVILEGES ON DATABASE freeswitch to freeswitch;"
sudo -u postgres /usr/bin/psql -d freeswitch -c "CREATE TABLE IF NOT EXISTS userinfo(username varchar(16) NOT NULL, password varchar(16) NOT NULL, dtmf varchar(16), qualify varchar(16), grade varchar(16));"
sudo -u postgres /usr/bin/psql -d freeswitch -c "CREATE TABLE conference(confnum varchar(16) NOT NULL, confname varchar(16) NOT NULL, confuserpin varchar(16), confadminpin varchar(16), mode varchar(16));"
#ALTER USER fusionpbx WITH PASSWORD 'newpassword';
cd $cwd

#send a message
verbose "PostgreSQL installed"
