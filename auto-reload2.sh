#!/bin/bash

## 看门狗模式
if [ $KS_WATCHDOG ]; then 
    vars="" ## 变量列表
    while read line; do  vars=$vars"\${${line%%;*}} "; done < /etc/nginx/kg/env.conf
    ## 证书内存缓存
    if [ $LUA_NGX_SSL_CACHE ]; then 
        export LUA_NGX_SSL_CACHE="lua_shared_dict ssl_cache      ${LUA_NGX_SSL_CACHE};"
    fi
    ## DNS服务器
    if [[ ! $NGX_RESOLVRE ]]; then
        export NGX_RESOLVRE=`cat /etc/resolv.conf | grep "nameserver" | awk '{print $2}' | tr '\n' ' '`
    fi
    ## 局域网域名
    if [[ ! $LUA_PROXY_LAN_M ]]; then
        export LUA_PROXY_LAN_M=`cat /etc/resolv.conf | grep "search" | awk '{print $2}'`
    fi
    ## LUA需要的系统环境变量
    if [[ ! $LUA_NGX_ENV_DEF ]]; then
        export LUA_NGX_ENV_DEF="env LUA_SYSLOG_HOST;env LUA_SYSLOG_TYPE;env LUA_FAKESSL_URI;env LUA_PROXY_LAN_M;"
    fi
    if [[ !$NGX_INLOG_EXTRA ]]; then
        evalue=""
        ## 提出环境变量
        extras=`env | grep "NGX_INLOG_EXTRA_" | awk -F= '{print $1}'`
        ## 合并变量的值
        for extra in $extras; do evalue="$evalue\n###env.$extra\n$(eval echo \"\$$extra\")"; done
        evalue=`echo -e "$evalue"` # 处理拼接时候的换行符
        ## 赋值环境变量
        export NGX_INLOG_EXTRA="$evalue"
    fi
    if [[ !$NGX_AUTHZ_EXTRA ]]; then
        evalue=""
        extras=`env | grep "NGX_AUTHZ_EXTRA_" | awk -F= '{print $1}'`
        for extra in $extras; do evalue="$evalue\n###env.$extra\n$(eval echo \"\$$extra\")"; done
        evalue=`echo -e "$evalue"`
        export NGX_AUTHZ_EXTRA="$evalue"
    fi
    ##################################################################################
    if [[ $KS_WATCHDOG =~ 'inlog' ]]; then ## 登录鉴权
        envsubst  "$vars" < /etc/nginx/kg/inlog.conf > /etc/nginx/conf.d/inlog.conf
        echo "envsubst /etc/nginx/kg/inlog.conf"
    fi
    if [[ $KS_WATCHDOG =~ 'autho' ]]; then ## 接口鉴权, 与authz只能二选一， 优先authz
        envsubst  "$vars" < /etc/nginx/kg/autho.conf > /etc/nginx/conf.d/authz.conf
        echo "envsubst /etc/nginx/kg/autho.conf"
    fi
    if [[ $KS_WATCHDOG =~ 'authz' ]]; then ## 接口鉴权
        envsubst  "$vars" < /etc/nginx/kg/authz.conf > /etc/nginx/conf.d/authz.conf
        echo "envsubst /etc/nginx/kg/authz.conf"
    fi
    ##################################################################################
    if [[ $KS_PROXYDOG =~ 'pxy_p' ]]; then ## path_proxy代理
        envsubst  "$vars" < /etc/nginx/kg/pxy_p.conf > /etc/nginx/conf.d/pxy_p.conf
        echo "envsubst /etc/nginx/kg/pxy_p.conf"
    fi
    if [[ $KS_PROXYDOG =~ 'pxy_h' ]]; then ## http_proxy代理
        envsubst  "$vars" < /etc/nginx/kg/pxy_h.conf > /etc/nginx/conf.d/pxy_h.conf
        echo "envsubst /etc/nginx/kg/pxy_h.conf"
    fi
    if [[ $KS_PROXYDOG =~ 'pxy_a' ]]; then ## all_proxy代理
        envsubst  "$vars" < /etc/nginx/kg/pxy_a.conf > /etc/nginx/conf.d/pxy_a.conf
        echo "envsubst /etc/nginx/kg/pxy_a.conf"
        if [[ ! $LUA_NGX_SSL_CACHE ]]; then ## 虚假证书需要共享缓存
            export LUA_NGX_SSL_CACHE='lua_shared_dict ssl_cache      10m;'
        fi
    fi
    if [[ $KS_PROXYDOG =~ 'pxy_i' ]]; then ## iptables_proxy代理
        envsubst  "$vars" < /etc/nginx/kg/pxy_i.conf   > /etc/nginx/conf.d/pxy_i.conf
        envsubst  "$vars" < /etc/nginx/kg/pxy_i.stream > /etc/nginx/conf.d/pxy_i.stream
        echo "envsubst /etc/nginx/kg/pxy_i.conf"
        if [[ ! $LUA_NGX_SSL_CACHE ]]; then ## 虚假证书需要共享缓存
            export LUA_NGX_SSL_CACHE='lua_shared_dict ssl_cache      10m;'
        fi
    fi
    ##################################################################################
    ## 最后处理nginx配置
    envsubst  "$vars" < /etc/nginx/kg/nginx.conf   > /usr/local/openresty/nginx/conf/nginx.conf
fi

## 启动nginx
nginx -g "daemon off;" &
inotifywait -e modify,move,create,delete -mr --timefmt '%d/%m/%y %H:%M' --format '%T' /etc/nginx/conf.d/ | while read date time; do
    echo "At ${time} on ${date}, config file update detected."
    nginx -s reload
done
