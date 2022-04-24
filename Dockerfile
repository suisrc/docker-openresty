# https://hub.docker.com/r/openresty/openresty/tags
FROM openresty/openresty:1.19.9.1-11-buster-fat

RUN apt update && apt install --no-install-recommends -y \
    inotify-tools graphicsmagick libgraphicsmagick1-dev &&\
    apt autoremove -y && rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*

COPY gmwand.lua /usr/local/openresty/lualib/gmwand.lua
COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
ADD  ["*.sh", "/cmd/"]
CMD  ["/cmd/auto-reload-1.sh"]