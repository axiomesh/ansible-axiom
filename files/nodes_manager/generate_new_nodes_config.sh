#!/usr/bin/env bash

set -e

CURRENT_PATH=$(
  cd $(dirname ${BASH_SOURCE[0]})
  pwd
)
source ${CURRENT_PATH}/.env.sh
BUILD_PATH=${CURRENT_PATH}/new-nodes
CONFIG_SAMPLE_PATH=${CURRENT_PATH}/config-sample

if [ ! -d "$BUILD_PATH" ]; then
  mkdir -p "$BUILD_PATH"
fi

N=$1
function generateNewNodesConfig() {
  echo "===> Generating $N new nodes configuration on ${BUILD_PATH}"
  for ((i = 1; i <= N; i = i + 1)); do
    root=${BUILD_PATH}/node${i}
    echo ""
    echo "generate node${i} config"
    mkdir -p ${root}
    rm -rf ${root}/*
    rm -f ${root}/.env.sh
    cp -rf ${CONFIG_SAMPLE_PATH}/*.sh ${root}/
    cp -rf ${CONFIG_SAMPLE_PATH}/axiom-ledger ${root}/
    cp -rf ${CONFIG_SAMPLE_PATH}/tools ${root}/
    cp -f ${AXIOM_LEDGER_BINARY_PATH} ${root}/tools/bin/
    let JSONRPC_PORT=3880+i,WEBSOCKET_PORT=3990+i,P2P_PORT=3000+i,PPROF_PORT=33120+i,MONITOR_PORT=30010+i

    echo "export AXIOM_LEDGER_PORT_JSONRPC=${JSONRPC_PORT}" >>${root}/.env.sh
    echo "export AXIOM_LEDGER_PORT_WEBSOCKET=${WEBSOCKET_PORT}" >>${root}/.env.sh
    echo "export AXIOM_LEDGER_PORT_P2P=${P2P_PORT}" >>${root}/.env.sh
    echo "export AXIOM_LEDGER_PORT_PPROF=${PPROF_PORT}" >>${root}/.env.sh
    echo "export AXIOM_LEDGER_PORT_MONITOR=${MONITOR_PORT}" >>${root}/.env.sh
  
    bash ${root}/init.sh
    cp -rf ${CONFIG_SAMPLE_PATH}/*.toml ${root}/

  done
}


function recordNewnodesConfig() {
  
  echo "===> record $N new nodes configuration on nodes.info "
  recordTime=$(date +"%Y-%m-%d-%s")
  echo "===> record time is : $recordTime"
  for ((i = 1; i < N + 1; i = i + 1)); do
    nodeInfo=$(${BUILD_PATH}/node${i}/axiom-ledger config node-info)
    accountAddr=$(echo "$nodeInfo" |grep account-addr | awk {'print $2'})
    p2pId=$(echo "$nodeInfo" |grep p2p-id | awk {'print $2'})
    #echo "######## $i ##########$accountAddr"
    nodeName=$(echo "new-node$i" | base64)
cat << EOF >> ${CURRENT_PATH}/new-nodes-$recordTime.info
[[new-nodes]]
  id = $i
  account_address = '$accountAddr'
  p2p_node_id = '$p2pId'
  name = '$nodeName'

EOF
  done
}

#generateNewNodesConfig
recordNewnodesConfig