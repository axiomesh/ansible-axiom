set -e

index="$2"
network1="$3"
network2="$4"
network3="$5"
network4="$6"
CURRENT_PATH=$(cd $(dirname ${BASH_SOURCE[0]}); pwd)
PROJECT_PATH=$(dirname "${CURRENT_PATH}")
BUILD_PATH=${CURRENT_PATH}/build
BIN_PATH=${CURRENT_PATH}/axiom-ledger
AXIOM_PROJECT_PATH=/home/hyperchain/code/axiomesh/axiom-ledger

function start(){
    prepare
    start_by_nohup
}

function stop(){
    lsof_output=$(lsof -i:888${index})
    pid=$(echo "$lsof_output" | awk 'NR==2 {print $2}')
    kill "${pid}"
    echo "kill node-${index}"
}

function restart(){
    stop
    start_by_nohup
}

function prepare() {
  echo "===> Generating node configuration"
  if [ ! -d "$BUILD_PATH" ]; then
  # 目录不存在，创建它
    mkdir -p "${BUILD_PATH}"
  fi
  rm -rf ~/.axiom-ledger/*
  root=${BUILD_PATH}/node${index}
  rm -rf ${root}
  mkdir ${root}
  cp -rf ${AXIOM_PROJECT_PATH}/scripts/package/* ${root}/
  cp -f /home/hyperchain/go/bin/axiom-ledger ${root}/tools/bin/
  echo "export AXIOM_LEDGER_PORT_JSONRPC=888${index}" >> ${root}/.env.sh
  echo "export AXIOM_LEDGER_PORT_WEBSOCKET=999${index}" >> ${root}/.env.sh
  echo "export AXIOM_LEDGER_PORT_P2P=400${index}" >> ${root}/.env.sh
  echo "export AXIOM_LEDGER_PORT_PPROF=5312${index}" >> ${root}/.env.sh
  echo "export AXIOM_LEDGER_PORT_MONITOR=4001${index}" >> ${root}/.env.sh
  ${root}/axiom-ledger config generate --default-node-index ${index}
  
  sed -i "s|/ip4/127.0.0.1/tcp/4001/p2p/16Uiu2HAmJ38LwfY6pfgDWNvk3ypjcpEMSePNTE6Ma2NCLqjbZJSF|/ip4/$network1/tcp/4001/p2p/16Uiu2HAmJ38LwfY6pfgDWNvk3ypjcpEMSePNTE6Ma2NCLqjbZJSF|g" ${root}/config.toml
  sed -i "s|/ip4/127.0.0.1/tcp/4002/p2p/16Uiu2HAmRypzJbdbUNYsCV2VVgv9UryYS5d7wejTJXT73mNLJ8AK|/ip4/$network2/tcp/4002/p2p/16Uiu2HAmRypzJbdbUNYsCV2VVgv9UryYS5d7wejTJXT73mNLJ8AK|g" ${root}/config.toml
  sed -i "s|/ip4/127.0.0.1/tcp/4003/p2p/16Uiu2HAmTwEET536QC9MZmYFp1NUshjRuaq5YSH1sLjW65WasvRk|/ip4/$network3/tcp/4003/p2p/16Uiu2HAmTwEET536QC9MZmYFp1NUshjRuaq5YSH1sLjW65WasvRk|g" ${root}/config.toml
  sed -i "s|/ip4/127.0.0.1/tcp/4004/p2p/16Uiu2HAmQBFTnRr84M3xNhi3EcWmgZnnBsDgewk4sNtpA3smBsHJ|/ip4/$network4/tcp/4004/p2p/16Uiu2HAmQBFTnRr84M3xNhi3EcWmgZnnBsDgewk4sNtpA3smBsHJ|g" ${root}/config.toml
}


function status(){
    lsof_output=$(lsof -i:888${index})
    pid=$(echo "$lsof_output" | awk 'NR==2 {print $2}')
    if [[ ! "${pid}" == "" ]]; then
      echo "${app_name} is running,node:${i}, pid: ${pid}"
    else
      echo "${app_name} is stopped"
    fi
}

function start_by_nohup() {
  echo "===> Staring cluster"
  ${BUILD_PATH}/node$(($index))/start.sh
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