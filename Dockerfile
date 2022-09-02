# https://hub.docker.com/r/openresty/openresty/tags
# FROM openresty/openresty:1.21.4.1-alpine-amd64
# FROM openresty/openresty:1.21.4.1-buster-fat-amd64
# FROM openresty/openresty:1.21.4.1-3-bullseye-fat-amd64
FROM suisrc/openresty:1.21.4.1-hp-2

LABEL maintainer="suisrc@outlook.com"

# gettext <- envsubst
# RUN apk update && apk add --no-cache inotify-tools gettext &&\
#     rm -rf /tmp/* /var/tmp/*
# gettext-base <- envsubst
# RUN apt update && apt install -y --no-install-recommends inotify-tools gettext-base &&\
#     apt autoremove -y && rm -rf /var/lib/apt/lists/*

# 看门狗模式环境变量
# 单实例服务进程，无需太多线程 2x4096即可
# 可以适当缩小，用户保护业务应用的并发清空
ENV LUA_SYSLOG_TYPE=disable \
    LOG_AUTHZ_HANDLER=/etc/nginx/az/log_by_sock_usr.lua \
    LOG_PROXY_HANDLER=/etc/nginx/az/log_by_sock_def.lua \
    LUA_PXY_FIX_HOSTS=/etc/nginx/az/proxy_k8s_hosts.lua \
    LOG_BODYZ_HANDLER=/etc/nginx/az/log_by_body.lua \
    LOG_BODYP_HANDLER=/etc/nginx/az/log_by_body.lua \
    NGX_IAM_AUTHZ=http://end-iam-cas-svc \
    NGX_SVC_ADDR=127.0.0.1 \
    NGX_INLOG_PORT=12001 \
    NGX_AUTHZ_PORT=12006 \
    NGX_PXY_P_PORT=12011 \
    NGX_PXY_H_PORT=12012 \
    NGX_PXY_I_PORT=12013 \
    NGX_PXY_A_PORT=12014 \
    NGX_WORKER_CONNS=4096 \
    NGX_WORKER_COUNT=2 \
    NGX_MASTER_PROC=on

# 部署lua，ngx配置
ADD  ["*.lua", "*.conf", "*.pem", "/etc/nginx/az/"]
ADD  ["kwdog/*", "/etc/nginx/kg/"]

# 部署启动文件
ADD  ["*.sh", "/cmd/"]
CMD  ["/cmd/auto-reload2.sh"]
