# openresty for kwdog

### debug

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

yum install libyaml
yum install postgresql-libs
## /etc/hosts
curl http://end-iam-kin-svc.dev-fmes.svc/authx
curl http://end-iam-kin-svc.dev-fmes.svc.logs-pxy.default.svc/authx

## authz测试
curl http://127.0.0.1:81/api/kas/v1?access_token=kst..account.p7_17bf2c6d678b
curl http://127.0.0.1:81/api/iam/v1/a/odic/authx?access_token=kst..account.p7_17bf2c6d678b\
curl http://end-iam-cas-svc.dev-fmes.svc.cluster.local/authx?access_token=kst..account.p7_17bf2c6d678b


## proxy测试
https://so.com/api/iam/v1/authx
curl http://127.0.0.1:82/https-443.so.com/api/iam/v1/authx

curl http://https-443.so.com.logs-spy:82/api/iam/v1/authx
curl http://127.0.0.1:82/https-443.so.com/api/iam/v1/authx
curl http://http.end-iam-kin-svc.dev-fmes.svc.logs-spy:82/api/iam/v1/authx
curl http://127.0.0.1:82/internal.end-iam-kin-svc.dev-fmes.svc/api/iam/v1/authx


kratos watchdog => kwdog 看门狗


###

curl http://10.103.93.57/api/ssl/v1/ca/txt?key=tst > /etc/ssl/certs/ca-fake-tst.crt

curl http://10.103.93.57/api/ssl/v1/ca/txt?key=tst > ca-fake-tst.crt