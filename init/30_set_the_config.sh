#!/bin/bash
mkdir -p /config/configs

[[ ! -f /config/znc.pem ]] && /usr/local/bin/znc -d /config -p

while [ ! -f "/config/znc.pem" ]; do
echo "waiting for pem file to be generated"
sleep 1s
done

[[ ! -f /config/configs/znc.conf ]] && cp /defaults/znc.conf /config/configs/znc.conf

chown -R abc:abc /config

