#! /bin/bash
set -e

CURRENT_PATH=$(cd $(dirname ${BASH_SOURCE[0]}); pwd)
PROJECT_PATH=$(dirname "${CURRENT_PATH}")
BUILD_PATH=${CURRENT_PATH}/build
BIN_PATH=${CURRENT_PATH}/axiom-ledger
AXIOM_PROJECT_PATH=/home/hyperchain/code/axiomesh/axiom-ledger
N=4


function start(){
    prepare
    start_by_nohup
}

function stop(){
  for ((i = 1; i < N + 1; i = i + 1)); do
    lsof_output=$(lsof -i:888${i})
    pid=$(echo "$lsof_output" | awk 'NR==2 {print $2}')
    kill "${pid}"
    echo "kill node-${i}"
  done
}

function restart(){
  stop
  start_by_nohup
}

function status(){
  for ((i = 1; i < N + 1; i = i + 1)); do
    lsof_output=$(lsof -i:888${i})
    pid=$(echo "$lsof_output" | awk 'NR==2 {print $2}')
    if [[ ! "${pid}" == "" ]]; then
      echo "${app_name} is running,node:${i}, pid: ${pid}"
    else
      echo "${app_name} is stopped"
    fi
  done
}

function start_by_nohup() {
  echo "===> Staring cluster"
  for ((i = 0; i < N; i = i + 1)); do
    ${BUILD_PATH}/node$(($i + 1))/start.sh
  done
}

function prepare() {
  echo "===> Generating $N nodes configuration"
  rm -rf "${BUILD_PATH}"
  mkdir "${BUILD_PATH}"
  for ((i = 1; i < N + 1; i = i + 1)); do
    rm -rf ~/.axiom-ledger/*
    root=${BUILD_PATH}/node${i}
    mkdir ${root}
    cp -rf ${AXIOM_PROJECT_PATH}/scripts/package/* ${root}/
    cp -f /home/hyperchain/go/bin/axiom-ledger ${root}/tools/bin/
    echo "export AXIOM_LEDGER_PORT_JSONRPC=888${i}" >> ${root}/.env.sh
    echo "export AXIOM_LEDGER_PORT_WEBSOCKET=999${i}" >> ${root}/.env.sh
    echo "export AXIOM_LEDGER_PORT_P2P=400${i}" >> ${root}/.env.sh
    echo "export AXIOM_LEDGER_PORT_PPROF=5312${i}" >> ${root}/.env.sh
    echo "export AXIOM_LEDGER_PORT_MONITOR=4001${i}" >> ${root}/.env.sh
    ${root}/axiom-ledger config generate --default-node-index ${i}
  done
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