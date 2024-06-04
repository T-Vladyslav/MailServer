#!/bin/sh

# Replace vars
envsubst < /etc/opendkim.conf.template > /etc/opendkim.conf

# MySQL Server status 
echo 'Waiting for the MySQL to start'
./wait-for OPENDKIM_DB_SERVER:3306 -- echo "MySQL is up and running"

/usr/bin/supervisord -c /etc/supervisor.conf
sleep 5
echo "The opendkim has been started"

tail -n 20 -f /var/log/syslog
