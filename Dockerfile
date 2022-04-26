# https://hub.docker.com/r/openresty/openresty/tags
FROM openresty/openresty:1.19.9.1-12-alpine

RUN sed -i "s|v3.15|edge|g" /etc/apk/repositories &&\
    apk update && apk --no-cache inotify-tools graphicsmagick-dev &&\
    rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*

COPY gmwand/*   /usr/local/openresty/lualib/gmwand/
COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
ADD  ["*.sh", "/cmd/"]
CMD  ["/cmd/auto-reload-1.sh"]