# https://hub.docker.com/r/openresty/openresty/tags
FROM openresty/openresty:1.21.4.1-3-alpine-amd64

RUN sed -i "s|v3.15|edge|g" /etc/apk/repositories &&\
    apk update && apk add --no-cache inotify-tools graphicsmagick-dev &&\
    rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*

#COPY process/*  /etc/nginx/conf.d/
COPY gmwand/*   /usr/local/openresty/lualib/gmwand/
COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
ADD  ["*.sh", "/cmd/"]
CMD  ["/cmd/auto-reload-1.sh"]