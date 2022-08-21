# docker-openresty
auto reload nginx by inotifywait

## 增加的内容

### https流代理模块

https://github.com/chobits/ngx_http_proxy_connect_module  

用于解决https正向代理

### lua_resty_socket_logger模块

https://github.com/suisrc/lua-resty-logger-socket (✔)  
https://github.com/cloudflare/lua-resty-logger-socket  

用于解决日志输出问题，PS: 原版使用 "resty.logger.socket", 在openresty中更改为 "resty.socket.logger"

### lua_resty_socket_http模块

 https://github.com/suisrc/lua-resty-http (✔)  
 https://github.com/ledgetech/lua-resty-http  

 用户解决远程访问，虽然ngx.location.capture提供子调用，但是这只限于内部接口调用，  
 PS： "resty.http", 更改为 "resty.socket.http"