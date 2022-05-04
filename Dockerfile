# https://hub.docker.com/r/openresty/openresty/tags
FROM openresty/openresty:1.19.9.1-12-alpine

RUN apk update && apk add --no-cache inotify-tools &&\
    rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*

COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
ADD  ["*.sh", "/cmd/"]
CMD  ["/cmd/auto-reload-1.sh"]