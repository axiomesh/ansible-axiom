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

starId=$1
endId=$2
if [ -z "$starId" ] || [ -z "$endId" ]; then
  echo "Usage: need <starId> and <endId>"
  exit 1
fi

function generateNewNodesConfig() {
  echo "===> Generating $starId-$endId new nodes configuration on ${BUILD_PATH}"
  for ((i = starId; i < endId + 1; i = i + 1)); do
    root=${BUILD_PATH}/node${i}
    echo ""
    echo "generate node${i} config"
    mkdir -p "${root}"
    rm -rf "${root:?}"/*
    rm -f "${root}"/.env.sh
    cp -rf "${CONFIG_SAMPLE_PATH}"/*.sh "${root}"/
    cp -rf "${CONFIG_SAMPLE_PATH}"/axiom-ledger "${root}"/
    cp -rf "${CONFIG_SAMPLE_PATH}"/tools "${root}"/
    cp -f "${AXIOM_LEDGER_BINARY_PATH}" "${root}"/tools/bin/
    # shellcheck disable=SC2219
    let JSONRPC_PORT=$START_JSONRPC_PORT+i,WEBSOCKET_PORT=$START_WEBSOCKET_PORT+i,P2P_PORT=$START_P2P_PORT+i,PPROF_PORT=$START_PPROF_PORT+i,MONITOR_PORT=$START_MONITOR_PORT+i

    {
    echo "export AXIOM_LEDGER_PORT_JSONRPC=${JSONRPC_PORT}"
    echo "export AXIOM_LEDGER_PORT_WEBSOCKET=${WEBSOCKET_PORT}"
    echo "export AXIOM_LEDGER_PORT_P2P=${P2P_PORT}"
    echo "export AXIOM_LEDGER_PORT_PPROF=${PPROF_PORT}"
    echo "export AXIOM_LEDGER_PORT_MONITOR=${MONITOR_PORT}"
    } >>"${root}"/.env.sh
  
    bash ${root}/init.sh
    cp -rf ${CONFIG_SAMPLE_PATH}/*.toml ${root}/

  done
}


function recordNewnodesConfig() {
  
  echo "===> record $starId-$endId new nodes configuration on nodes.info"
  recordTime=$(date +"%Y-%m-%d-%s")
  echo "===> record time is : $recordTime"
  for ((i = starId; i < endId + 1; i = i + 1)); do
    nodeInfo=$("${BUILD_PATH}"/node${i}/axiom-ledger config node-info)
    accountAddr=$(echo "$nodeInfo" |grep account-addr | awk {'print $2'})
    p2pId=$(echo "$nodeInfo" |grep p2p-id | awk {'print $2'})
    echo "######## $i #####record#####$accountAddr"
    nodeName=$(echo "node$i" | base64)
cat << EOF >> "${CURRENT_PATH}"/new-nodes-"$starId"-"$endId"-"$recordTime".info
export const node$i = {
    NodeId: '$p2pId',
    Address: '$accountAddr',
    Name = '$nodeName'
}

EOF
  done
}

generateNewNodesConfig
recordNewnodesConfig