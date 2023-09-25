#!/usr/bin/env bash

echo '检查服务器上有没有axiom的进程, 如果有的话将其杀掉'
name="axiom"
PID=$(ps aux|grep ${name} |grep -v "grep" | awk '{print $2}')
#echo $PID
#此处注意都需要空格，不然会有语法错误
if [ -n "$PID" ]; then
    kill -9 "$PID"
fi