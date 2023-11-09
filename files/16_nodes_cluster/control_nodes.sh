#! /bin/bash
set -e
#set -x

# shellcheck source=/dev/null
source x.sh

CURRENT_PATH=$(cd $(dirname ${BASH_SOURCE[0]}); pwd)
cp -f "$AXIOM_LEDGER_BINARY_PATH" "$CURRENT_PATH"/
pid_file=${CURRENT_PATH}/running.pid
wait_process_exit_check_time=10
wait_process_exit_check_interval=0.2

function wait_process_exit(){
  for ((i = 1; i <= ${wait_process_exit_check_time}; i = i + 1)); do
    process_cnt=$(ps -p${1} -o pid,comm | awk 'END{print NR}')
    if [ "${process_cnt}" == "2" ]; then
      sleep ${wait_process_exit_check_interval}
    else
      echo "axiom-ledger quit"
      return
    fi
  done
  echo "stop axiom-ledger failed, wait process quit timeout, use kill -9 forced stop"
  kill -9 ${1}
}

# get_running_pid
function get_running_pid(){
  if [ -s "${pid_file}" ]; then
    pid=$(cat ${pid_file})
  else pid=$(ps aux|grep axiom-ledger |grep -v "grep" | awk '{print $2}')
  fi
  echo "$pid"
}

function start(){
  pid=$(get_running_pid)
  if [[ ! -n "${pid}" ]]; then

    if [ -d "${CURRENT_PATH}/build_solo/" ];then
      rm -rf ${CURRENT_PATH}/build_solo/*
    else 
      mkdir ${CURRENT_PATH}/build_solo/
    fi
    
    if [ -d "$HOME/.axiom-ledger/" ];then
      rm -rf "$HOME"/.axiom-ledger
    fi
    ${CURRENT_PATH}/axiom-ledger config generate --solo
    cp -f $HOME/.axiom-ledger/* ${CURRENT_PATH}/build_solo/
    nohup ${CURRENT_PATH}/axiom-ledger --repo ${CURRENT_PATH}/build_solo start >/dev/null 2>&1 &
      if [[ $? -eq 0 ]]; then
        echo $! > ${pid_file}
        echo "start axiom-ledger, pid: $!"
      else exit 1
      fi
  else 
    echo "axiom-ledger is running, pid: ${pid}"
    exit 1
  fi
}

function stop(){
  pid=$(get_running_pid)
  if [[ ! -n "${pid}" ]]; then
    echo "axiom-ledger is not running"
  else
    kill "${pid}"
    echo "stop axiom-ledger, pid: ${pid}"
    wait_process_exit "${pid}"
    rm -f "${pid_file}"
  fi
}

function restart(){
  stop
  nohup ${CURRENT_PATH}/axiom-ledger --repo ${CURRENT_PATH}/build_solo start >/dev/null 2>&1 &
  if [[ $? -eq 0 ]]; then
    echo $! > ${pid_file}
    echo "start axiom-ledger, pid: $!"
  else exit 1
  fi
}

function status(){
  pid=$(get_running_pid)
  if [[ ! "${pid}" == "" ]]; then
    echo "axiom-ledger is running, pid: ${pid}"
  else
    echo "axiom-ledger is stopped"
  fi
}

case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart)
    restart
    ;;
  status)
    status
    ;;
  *)
    echo "Usage: ./control.sh {start|stop|restart|status}"
    exit 1
esac

exit $?