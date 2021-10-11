#!/bin/sh
/usr/bin/openresty -g "daemon off;" &
inotifywait -e modify,move,create,delete -mr --timefmt '%d/%m/%y %H:%M' --format '%T' ${NGINX_CONF} | while read date time; do
    echo "At ${time} on ${date}, config file update detected."
    nginx -s reload
done