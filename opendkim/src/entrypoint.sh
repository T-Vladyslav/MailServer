#!/bin/sh

# Replace vars
envsubst < /etc/opendkim.conf.template > /etc/opendkim.conf

/usr/bin/supervisord -c /etc/supervisor.conf
sleep 5
echo "The opendkim has been started"

tail -n 20 -f /var/log/syslog
