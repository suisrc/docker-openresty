# 说明

## 安装resty.socket.logger and resty.socket.http


### socket.logger
https://github.com/cloudflare/lua-resty-logger-socket

### socket.http
https://github.com/ledgetech/lua-resty-http



### 安装
```

mkdir /usr/local/openresty/lualib/resty/socket && \
wget https://github.com/suisrc/lua-resty-logger-socket/archive/refs/tags/v0.0.1.tar.gz \
    -O lua_logger.tar.gz && tar -xzf lua_logger.tar.gz && \
    cp lua-resty-logger-socket-0.0.1/lib/resty/logger/socket.lua /usr/local/openresty/lualib/resty/socket/logger.lua &&\
wget https://github.com/suisrc/lua-resty-http/archive/refs/tags/v0.17.0.tar.gz \
    -O lua_http_req.tar.gz && tar -xzf lua_http_req.tar.gz && \
    cp lua-resty-http-0.17.0/lib/resty/* /usr/local/openresty/lualib/resty/socket/ &&\
    sed -i -e 's/"resty./"resty.socket./g'  /usr/local/openresty/lualib/resty/socket/http.lua &&\

```

