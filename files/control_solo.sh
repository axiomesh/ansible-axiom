#! /bin/bash
set -e

shell_dir=$(cd $(dirname ${BASH_SOURCE[0]}); pwd)
#base_dir=$(dirname ${shell_dir})
app_name=axiom-ledger
bin_path=${shell_dir}/${app_name}
cp -f /home/hyperchain/go/bin/${app_name} "${bin_path}"
pid_file=${shell_dir}/running.pid
wait_process_exit_check_time=10
wait_process_exit_check_interval=0.2

function wait_process_exit(){
  for ((i = 1; i <= ${wait_process_exit_check_time}; i = i + 1)); do
    process_cnt=$(ps -p${1} -o pid,comm | awk 'END{print NR}')
    if [ "${process_cnt}" == "2" ]; then
      sleep ${wait_process_exit_check_interval}
    else
      echo "${app_name} quit"
      return
    fi
  done
  echo "stop ${app_name} failed, wait process quit timeout, use kill -9 forced stop"
  kill -9 ${1}
}

# get_running_pid
function get_running_pid(){
  if [ -s "${pid_file}" ]; then
    pid=$(cat ${pid_file})
  else pid=$(ps aux|grep ${app_name} |grep -v "grep" | awk '{print $2}')
  fi
  echo "$pid"
}

function start(){
  pid=$(get_running_pid)
  if [[ ! -n "${pid}" ]]; then
    rm -rf ~/.axiom-ledger/*
    rm -rf ${shell_dir}/build_solo/*
    ${bin_path} config generate --solo
    cp -f ~/.axiom-ledger/* ${shell_dir}/build_solo/
    nohup "${bin_path}" --repo ${shell_dir}/build_solo start >/dev/null 2>&1 &
      if [[ $? -eq 0 ]]; then
        echo $! > ${pid_file}
        echo "start ${app_name}, pid: $!"
      else exit 1
      fi
  else 
    echo "${app_name} is running, pid: ${pid}"
    exit 1
  fi
}

function stop(){
  pid=$(get_running_pid)
  if [[ ! -n "${pid}" ]]; then
    echo "${app_name} is not running"
  else
    kill "${pid}"
    echo "stop ${app_name}, pid: ${pid}"
    wait_process_exit "${pid}"
    rm -f "${pid_file}"
  fi
}

function restart(){
  stop
  nohup "${bin_path}" --repo ${shell_dir}/build_solo start >/dev/null 2>&1 &
  if [[ $? -eq 0 ]]; then
    echo $! > ${pid_file}
    echo "start ${app_name}, pid: $!"
  else exit 1
  fi
}

function status(){
  pid=$(get_running_pid)
  if [[ ! "${pid}" == "" ]]; then
    echo "${app_name} is running, pid: ${pid}"
  else
    echo "${app_name} is stopped"
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