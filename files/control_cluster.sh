#! /bin/bash
set -e
#set -x

# shellcheck source=/dev/null
source x.sh

CURRENT_PATH=$(cd $(dirname ${BASH_SOURCE[0]}); pwd)
BUILD_PATH=${CURRENT_PATH}/build
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
    echo "kill node${i}"
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
      echo "axiom-ledger is running,node:${i}, pid: ${pid}"
    else
      echo "axiom-ledger is stopped"
    fi
  done
}

function start_by_nohup() {
  echo "===> Staring cluster"
  for ((i = 1; i < N + 1; i = i + 1)); do
    ${BUILD_PATH}/node${i}/start.sh
  done
}

function prepare() {
  echo "===> Generating $N nodes configuration"
  if [ -d "${BUILD_PATH}" ];then
    rm -rf "${BUILD_PATH}"
  else 
    mkdir -p "${BUILD_PATH}"
  fi
  for ((i = 1; i < N + 1; i = i + 1)); do
    root=${BUILD_PATH}/node${i}
    mkdir -p "$root"
    cp -rf "$AXIOM_LEDGER_PROJECT_PATH"/scripts/package/* "$root"/
    cp -f "$AXIOM_LEDGER_BINARY_PATH" "$root"/
    cp -f "$root"/axiom-ledger "$root"/tools/bin/
    "$root"/axiom-ledger --repo "$root" config generate --default-node-index ${i}
    echo "export AXIOM_LEDGER_PORT_JSONRPC=888${i}" >> "$root"/.env.sh
    echo "export AXIOM_LEDGER_PORT_WEBSOCKET=999${i}" >> "$root"/.env.sh
    echo "export AXIOM_LEDGER_PORT_P2P=400${i}" >> "$root"/.env.sh
    echo "export AXIOM_LEDGER_PORT_PPROF=5312${i}" >> "$root"/.env.sh
    echo "export AXIOM_LEDGER_PORT_MONITOR=4001${i}" >> "$root"/.env.sh
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