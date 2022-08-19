#!/bin/bash

if [ $KS_WATCHDOG ]; then ## 看门狗模式
    vars=""
    while read line; do  vars=$vars"\${${line%%;*}} "; done < /etc/nginx/kg/env.conf
    envsubst  "$vars" < /etc/nginx/kg/nginx.conf   > /usr/local/openresty/nginx/conf/nginx.conf

    if [[ $KS_WATCHDOG =~ 'authx' ]]; then ## 登录鉴权
        envsubst  "$vars" < /etc/nginx/kg/authx.conf > /etc/nginx/conf.d/authx.conf
        echo "envsubst /etc/nginx/kg/authx.conf"
    fi
    if [[ $KS_WATCHDOG =~ 'authz' ]]; then ## 接口鉴权
        envsubst  "$vars" < /etc/nginx/kg/authz.conf > /etc/nginx/conf.d/authz.conf
        echo "envsubst /etc/nginx/kg/authz.conf"
    fi
    if [[ $KS_WATCHDOG =~ 'pxy_p' ]]; then ## path_proxy代理
        envsubst  "$vars" < /etc/nginx/kg/pxy_p.conf > /etc/nginx/conf.d/pxy_p.conf
        echo "envsubst /etc/nginx/kg/pxy_p.conf"
    fi
    if [[ $KS_WATCHDOG =~ 'pxy_h' ]]; then ## http_proxy代理
        envsubst  "$vars" < /etc/nginx/kg/pxy_h.conf > /etc/nginx/conf.d/pxy_h.conf
        echo "envsubst /etc/nginx/kg/pxy_h.conf"
    fi
    if [[ $KS_WATCHDOG =~ 'pxy_a' ]]; then ## all_proxy代理
        envsubst  "$vars" < /etc/nginx/kg/pxy_a.conf > /etc/nginx/conf.d/pxy_a.conf
        echo "envsubst /etc/nginx/kg/pxy_a.conf"
    fi
    if [[ $KS_WATCHDOG =~ 'pxy_i' ]]; then ## iptables_proxy代理
        envsubst  "$vars" < /etc/nginx/kg/pxy_i.conf   > /etc/nginx/conf.d/pxy_i.conf
        envsubst  "$vars" < /etc/nginx/kg/pxy_i.stream > /etc/nginx/conf.d/pxy_i.stream
        echo "envsubst /etc/nginx/kg/pxy_i.conf"
    fi
fi

nginx -g "daemon off;" &
inotifywait -e modify,move,create,delete -mr --timefmt '%d/%m/%y %H:%M' --format '%T' /etc/nginx/conf.d/ | while read date time; do
    echo "At ${time} on ${date}, config file update detected."
    nginx -s reload
done
