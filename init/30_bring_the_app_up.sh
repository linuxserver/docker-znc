#!/bin/bash
exec /usr/bin/supervisord -c /defaults/supervisord.conf > /dev/null 2>&1
