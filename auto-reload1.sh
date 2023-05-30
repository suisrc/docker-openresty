#!/bin/sh

# 启动nginx
nginx -g "daemon off;" &

# 监控nginx配置文件变化，自动reload
last_time=
inotifywait -e modify,move,create,delete -mr --timefmt '%d/%m/%y %H:%M:%S.%N' --format '%T' /etc/nginx/conf.d/ | while read date time; do
    # 如果最后修改的时间和当前时间相同，不执行
    if [[ "$last_time" == "$time" ]]; then
        continue
    fi
    last_time=$time
    # 执行更改处理
    echo "At ${time} on ${date}, config file update detected."
    nginx -s reload
done
