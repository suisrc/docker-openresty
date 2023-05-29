# https://hub.docker.com/_/nginx
# FROM nginx:1.25.0-bullseye
FROM nginx:1.25.0-alpine-slim

# RUN apt update && apt install --no-install-recommends -y inotify-tools &&\
#     rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*

RUN apk add --no-cache inotify-tools

# Copy nginx configuration files
COPY nginx.conf /etc/nginx/nginx.conf
ADD ["base.conf", "default.conf", "/etc/nginx/conf.d/"]
RUN ln -sf /usr/share/nginx/html /www

# 部署启动文件
ADD  ["*.sh", "/cmd/"]
CMD  ["/cmd/auto-reload1.sh"]

# Use SIGQUIT instead of default SIGTERM to cleanly drain requests
# See https://github.com/openresty/docker-openresty/blob/master/README.md#tips--pitfalls
STOPSIGNAL SIGQUIT