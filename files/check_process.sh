#!/usr/bin/env bash
set -e

app_name="axiom-ledger"
PID=$(ps aux|grep ${app_name} |grep -v "grep" | awk '{print $2}')
#echo $PID
if [ -n "$PID" ]; then
    kill -9 "$PID"
fi