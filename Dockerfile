# https://hub.docker.com/r/openresty/openresty/tags
# 1.19.9.1-2-buster buster-fat alpine 
FROM openresty/openresty:1.19.9.1-10-buster-fat

RUN apt update && apt install --no-install-recommends -y inotify-tools &&\
    rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*

ADD ["*.sh", "/"]
ADD nginx.conf  /usr/local/openresty/nginx/conf/nginx.conf
CMD ["/auto-reload-1.sh"]