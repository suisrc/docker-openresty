# https://hub.docker.com/r/openresty/openresty/tags

FROM debian:bullseye-slim as builder

ARG REST_VERSION_M=1.21.4
ARG REST_VERSION=${REST_VERSION_M}.1

RUN DEBIAN_FRONTEND=noninteractive apt update \
    && apt install -y --no-install-recommends \
      build-essential \
      libreadline-dev \
      libssl-dev \
      libpcre3-dev \
      libperl-dev \
      zlib1g-dev \
      ca-certificates \
      openssl libpcre3 perl \
      make curl wget patch \
    && rm -rf /var/lib/apt/lists/*

# 构建openresty
RUN wget https://github.com/chobits/ngx_http_proxy_connect_module/archive/refs/tags/v0.0.3.tar.gz \
    -O ngx_hpc_module.tar.gz && tar -xzf ngx_hpc_module.tar.gz && \
    wget https://openresty.org/download/openresty-${REST_VERSION}.tar.gz && \
    tar -zxf openresty-${REST_VERSION}.tar.gz && cd openresty-${REST_VERSION} && \
    ./configure \
      --with-cc-opt="-I/usr/local/opt/openssl/include/ -I/usr/local/opt/pcre/include/" \
      --with-ld-opt="-L/usr/local/opt/openssl/lib/ -L/usr/local/opt/pcre/lib/" \
      --with-luajit \
      --with-threads \
      --with-pcre-jit \
      --with-http_v2_module \
      --without-mail_pop3_module \
      --without-mail_imap_module \
      --without-mail_smtp_module \
      --with-http_stub_status_module \
      --with-http_realip_module \
      --with-http_addition_module \
      --with-http_auth_request_module \
      --with-http_secure_link_module \
      --with-http_random_index_module \
      --with-http_gzip_static_module \
      --with-http_sub_module \
      --with-http_dav_module \
      --with-http_flv_module \
      --with-http_mp4_module \
      --with-http_gunzip_module \
      --add-module=../ngx_http_proxy_connect_module-0.0.3 && \
    patch -d build/nginx-${REST_VERSION_M}/ -p 1 < ../ngx_http_proxy_connect_module-0.0.3/patch/proxy_connect_rewrite_102101.patch && \
    make && make install

# 安装lua_resty_socket_logger,lua_resty_socket_http模块
RUN mkdir /usr/local/openresty/lualib/resty/socket && \
    wget https://github.com/suisrc/lua-resty-logger-socket/archive/refs/tags/v0.0.1.tar.gz \
        -O lua_logger.tar.gz && tar -xzf lua_logger.tar.gz && \
        cp lua-resty-logger-socket-0.0.1/lib/resty/logger/socket.lua /usr/local/openresty/lualib/resty/socket/logger.lua &&\
    wget https://github.com/suisrc/lua-resty-http/archive/refs/tags/v0.17.0.tar.gz \
        -O lua_http_req.tar.gz && tar -xzf lua_http_req.tar.gz && \
        cp lua-resty-http-0.17.0/lib/resty/* /usr/local/openresty/lualib/resty/socket/ &&\
        sed -i -e 's/"resty./"resty.socket./g'  /usr/local/openresty/lualib/resty/socket/http.lua

# build runner
FROM debian:bullseye-slim as runner

# copy openresty binary form builder to runner
COPY --from=builder /usr/local/openresty /usr/local/openresty

# add dependency for runner
RUN DEBIAN_FRONTEND=noninteractive apt update \
    && DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
        inotify-tools ca-certificates gettext-base curl \
    && DEBIAN_FRONTEND=noninteractive apt autoremove -y && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /var/run/openresty \
    && mkdir -p /etc/nginx/conf.d \
    && mkdir -p /www && cp -rf /usr/local/openresty/nginx/html/* /www \
    && ln -sf /dev/stdout /usr/local/openresty/nginx/logs/access.log \
    && ln -sf /dev/stderr /usr/local/openresty/nginx/logs/error.log

# Add additional binaries into PATH for convenience
ENV PATH="$PATH:/usr/local/openresty/luajit/bin:/usr/local/openresty/nginx/sbin:/usr/local/openresty/bin"

# Copy nginx configuration files
COPY nginx.conf /etc/nginx/nginx.conf
ADD ["base.conf", "default.conf", "/etc/nginx/conf.d/"]
RUN ln -sf /etc/nginx/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf

# 部署启动文件
ADD  ["*.sh", "/cmd/"]
CMD  ["/cmd/auto-reload1.sh"]

# Use SIGQUIT instead of default SIGTERM to cleanly drain requests
# See https://github.com/openresty/docker-openresty/blob/master/README.md#tips--pitfalls
STOPSIGNAL SIGQUIT
