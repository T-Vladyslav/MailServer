#!/bin/sh

# Replace vars
envsubst < /etc/cluebringer.conf.template > /etc/cluebringer.conf

# Installing policyd
mkdir /usr/local/lib/policyd-2.0
cp -r cluebringer-v2.0.14/cbp /usr/local/lib/policyd-2.0/

cp cluebringer-v2.0.14/cbpadmin /usr/local/bin/
cp cluebringer-v2.0.14/cbpolicyd /usr/local/sbin/

# Installing perl modules
cpanm < perl_modules.txt

# Starting policyd
touch /var/log/cbpolicyd.log
cbpolicyd fg --config=/etc/cluebringer.conf
tail -n 20 -f /var/log/cbpolicyd.log