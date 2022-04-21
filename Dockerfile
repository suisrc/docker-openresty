# https://hub.docker.com/r/openresty/openresty/tags
# 1.19.9.1-2-buster buster-fat alpine 
FROM openresty/openresty:1.19.9.1-10-buster-fat

RUN apt update && apt install --no-install-recommends -y inotify-tools graphicsmagick libgraphicsmagick1-dev git &&\
    mkdir /usr/local/openresty/lualib/graphicsmagick/ &&\
    git clone https://github.com/clementfarabet/graphicsmagick.git /usr/local/openresty/lualib/graphicsmagick/ &&\
    rm -rf /usr/local/openresty/lualib/graphicsmagick/.git /usr/local/openresty/lualib/graphicsmagick/test &&\
    rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*

ADD ["*.sh", "/"]
ADD nginx.conf  /usr/local/openresty/nginx/conf/nginx.conf
CMD ["/auto-reload-1.sh"]