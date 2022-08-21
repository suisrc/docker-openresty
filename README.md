# openresty for kwdog

kratos watchdog => kwdog 看门狗

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

