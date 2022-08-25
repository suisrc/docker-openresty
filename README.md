# openresty for kwdog

kratos watchdog => kwdog 看门狗

## 环境变量
``` .env
NGX_MASTER_PROC; 默认, on, off: 单线程模式 
NGX_WORKER_CONNS; 默认, 4096， # 单实例服务进程，无需太多线程 2x4096即可
NGX_WORKER_COUNT; 默认, 2， # 可以适当缩小，用户保护业务应用的并发清空
KS_WATCHDOG; 默认, 关闭 看门狗模式， KS_WATCHDOG=inlog,authz
KS_PROXYDOG; 默认，关闭 看门狗代理， KS_PROXYDOG=pxy_p,pxy_h,pxy_a,pxy_i
NGX_SVC_ADDR; 默认, 127.0.0.1 业务服务地址
NGX_RESOLVRE; 默认, 127.0.0.1 DNS服务地址
NGX_INLOG_PORT; 默认, 12001  登录鉴权端口
NGX_AUTHZ_PORT; 默认, 12006  接口鉴权端口
NGX_PXY_P_PORT; 默认, 12011 系统代理端口, path
NGX_PXY_H_PORT; 默认, 12012 系统代理端口, http, 支持https，但是无法记录日志
NGX_PXY_I_PORT; 默认, 12013 系统代理端口, iptables， 需要虚假证书支持
NGX_PXY_A_PORT; 默认，12014 系统代理端口, all_proxy, http and https， 需要虚假证书支持
NGX_AUTHZ_EXTRA; 默认, 空 二次鉴权服务器额外参数，一般指向CAS，有时候也指向KIN
NGX_IAM_AUTHZ; 默认，http://end-iam-cas-svc/authz?$args
LOG_PROXY_HANDLER; 默认，/etc/nginx/az/log_by_sock_def.lua
LOG_AUTHZ_HANDLER; 默认，/etc/nginx/az/log_by_sock_usr.lua
LUA_NGX_SSL_CACHE; 默认,没有, 如果强制开启pxy_i or pxy_a, 自动配置为10m，如果使用pxy_i, pxy_a, 需要指定
NGX_HTTP_CONF;   http,   自定义配置
NGX_STREAM_CONF; stream, 自定义配置
LUA_SYSLOG_HOST; 默认, 127.0.0.1 日志地址
LUA_SYSLOG_PORT; 默认, 5144      日志端口
LUA_SYSLOG_TYPE; 默认, disable   日志类型, 开启： udp or tcp 
LUA_FAKESSL_URI; http://10.103.93.57/api/ssl/v1/cert?token=Ckt1YmVybmV0ZXM&key=tst&profile=&kind=1&cn=dev01&domain=%s
LUA_PROXY_LAN_M; 默认, .default.svc.cluster.local
LUA_NGX_ENV_DEF; 默认, env ...
LUA_PXY_FIX_HOSTS; 默认, /etc/nginx/az/proxy_k8s_hosts.lua, 修复局域网代理host

```

PS: 默认系统禁用日志, LUA_SYSLOG_TYPE=udp， 进出流量监控
    LUA_FAKESSL_URI,参数中有且仅有一个“%s”的参数用于接受域名参数

NGX_AUTHZ_EXTRA: >-
\n  location = /api/iam/v1/a/odic/authc {
\n    proxy_pass  http://end-iam-cas-svc/authc?$args;
\n  }
\n  location = /api/iam/v1/a/odic/authx {
\n    proxy_pass  http://end-iam-cas-svc/authx?$args;
\n  }
\n  location = /api/iam/v1/a/odic/authz {
\n    proxy_pass  http://end-iam-cas-svc/authz?$args;
\n  }
\n  location ^~ /api/iam/v1/a/ {
\n    proxy_pass  http://end-iam-kin-svc;
\n  }

### test

## authz测试
curl http://127.0.0.1:81/api/kas/v1?access_token=kst..account.p7_17bf2c6d678b

## proxy测试

pxy_p测试  
curl http://127.0.0.1:83/https-443.so.com/api/iam/v1/authx
通过路径第二级指定访问的真实地址，该访问不需要虚假证书也可以代理https协议。
主要是client-1️⃣->proxy-2️⃣->server, 1:使用http, 2:使用https

pxy_h,pxy_a测试
curl https://so.com/api/iam/v1/authx -x 127.0.0.1:83
通过http_proxy, https_proxy, all_proxy环境变量配置指定系统访问代理
client-1️⃣->proxy-2️⃣->server
pxy_h, http: 可以记录日志，https: 不可记录日志
pxy_a, 都可以记录日志，需要配合fake-ssl服务，1：使用的虚假证书， 因此需要pod信任需要的ca证书

pxy_i测试
修改host: so.com -> 127.0.0.1
curl https://so.com/api/iam/v1/authx
适合结合iptable进行全局流量转发，但是需要注意该访问也需要配合fake-ssl服务使用，让pod完全信任虚假的ca证书

### 使用自签名ca证书测试访问
curl https://so.com/api/iam/v1/authx -x 127.0.0.1:83 -cacert  /etc/ssl/certs/ca-fake-tst.crt
curl http://10.103.93.57/api/ssl/v1/ca/txt?key=tst > /etc/ssl/certs/ca-fake-tst.crt

### debug

mkdir /usr/local/openresty/lualib/resty/socket && \

#### socket.logger
https://github.com/cloudflare/lua-resty-logger-socket  

wget https://github.com/suisrc/lua-resty-logger-socket/archive/refs/tags/v0.0.1.tar.gz \
    -O lua_logger.tar.gz && tar -xzf lua_logger.tar.gz && \
    cp lua-resty-logger-socket-0.0.1/lib/resty/logger/socket.lua /usr/local/openresty/lualib/resty/socket/logger.lua &&\

#### socket.http
https://github.com/ledgetech/lua-resty-http  

wget https://github.com/suisrc/lua-resty-http/archive/refs/tags/v0.17.0.tar.gz \
    -O lua_http_req.tar.gz && tar -xzf lua_http_req.tar.gz && \
    cp lua-resty-http-0.17.0/lib/resty/* /usr/local/openresty/lualib/resty/socket/ &&\
    sed -i -e 's/"resty./"resty.socket./g'  /usr/local/openresty/lualib/resty/socket/http.lua &&\

#### fluent-bit
cat << EOF > /etc/yum.repos.d/fluent-bit.repo
[fluent-bit]
name = Fluent Bit
baseurl=https://packages.fluentbit.io/centos/7/x86_64/
gpgcheck=1
gpgkey=https://packages.fluentbit.io/fluentbit.key
repo_gpgcheck=1
enabled=1
EOF
cat /etc/yum.repos.d/fluent-bit.repo
yum -y install fluent-bit
yum -y install td-agent-bit

cp ./bin/fluent-bit /opt/fluent-bit/bin/

yum install libyaml
yum install postgresql-libs

#### openresty
cat << EOF > /etc/yum.repos.d/openresty.repo
[openresty]
name=Official OpenResty Open Source Repository for CentOS
baseurl=https://openresty.org/package/centos/7/x86_64
skip_if_unavailable=False
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://openresty.org/package/pubkey.gpg
enabled=1
enabled_metadata=1
EOF
cat /etc/yum.repos.d/openresty.repo
yum -y install openresty

