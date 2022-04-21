# https://hub.docker.com/r/openresty/openresty/tags
# 1.19.9.1-2-buster buster-fat alpine 
FROM openresty/openresty:1.19.9.1-10-buster-fat

RUN apt update && apt install --no-install-recommends -y \
    inotify-tools graphicsmagick libgraphicsmagick1-dev git &&\
    rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*

COPY graphicsmagick /usr/local/openresty/lualib/
COPY nginx.conf     /usr/local/openresty/nginx/conf/nginx.conf
ADD  ["*.sh", "/cmd/"]
CMD  ["/cmd/auto-reload-1.sh"]