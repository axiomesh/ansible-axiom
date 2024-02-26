#!/usr/bin/env bash

set -e

CURRENT_PATH=$(
  cd $(dirname ${BASH_SOURCE[0]})
  pwd
)

source "${CURRENT_PATH}"/.env.sh
BUILD_PATH=${CURRENT_PATH}/nodes

N=$1
function generateNodesConfig() {
  echo "===> Generating $N nodes configuration on ${BUILD_PATH}"
  for ((i = 1; i <= N; i = i + 1)); do
    root=${BUILD_PATH}/node${i}
    echo ""
    echo "generate node${i} config"
    mkdir -p "${root}"
    rm -rf "${root:?}"/*
    rm -f "${root}"/.env.sh
    cp -rf "${AXIOM_LEDGER_PROJECT_PATH}"/scripts/package/* "${root}"/
    cp -f "${AXIOM_LEDGER_BINARY_PATH}" "${root}"/tools/bin/
    # shellcheck disable=SC2219
    let JSONRPC_PORT=$START_JSONRPC_PORT+i,WEBSOCKET_PORT=$START_WEBSOCKET_PORT+i,P2P_PORT=$START_P2P_PORT+i,PPROF_PORT=$START_PPROF_PORT+i,MONITOR_PORT=$START_MONITOR_PORT+i

    {
    echo "export AXIOM_LEDGER_PORT_JSONRPC=${JSONRPC_PORT}"
    echo "export AXIOM_LEDGER_PORT_WEBSOCKET=${WEBSOCKET_PORT}"
    echo "export AXIOM_LEDGER_PORT_P2P=${P2P_PORT}"
    echo "export AXIOM_LEDGER_PORT_PPROF=${PPROF_PORT}"
    echo "export AXIOM_LEDGER_PORT_MONITOR=${MONITOR_PORT}"
    echo "export AXIOM_LEDGER_GENESIS_EPOCH_INFO_CONSENSUS_PARAMS_MAX_VALIDATOR_NUM=${N}"
    echo "export AXIOM_LEDGER_GENESIS_BALANCE=${AXIOM_LEDGER_GENESIS_BALANCE}"
    echo "export AXIOM_LEDGER_GENESIS_TOKEN_TOTAL_SUPPLY=${AXIOM_LEDGER_GENESIS_TOKEN_TOTAL_SUPPLY}"
    } >>"${root}"/.env.sh
  
    "${root}"/axiom-ledger config generate --default-node-index ${i} --epoch-enable
  done
}

function generateClusterConfig() {
  echo "===> Generating cluster configuration on ${BUILD_PATH}"
  echo "===> Calculate the number of validator and candidate"
  validator_num=$N
  #candidate_num=$(echo "$N - $validator_num" | bc)
  echo "validator number is : $validator_num"
 
  rm -rf "${CURRENT_PATH}"/genesis.toml
  cp "${BUILD_PATH}"/node1/genesis.toml "${CURRENT_PATH}"/

  for ((i = 9; i <= validator_num; i = i + 1)); do
    nodeInfo=$("${BUILD_PATH}"/node${i}/axiom-ledger config node-info)
    accountAddr=$(echo "$nodeInfo" |grep node-key-addr | awk {'print $2'})
    p2pId=$(echo "$nodeInfo" |grep p2p-id | awk {'print $2'})
    #echo "######## $i #####validator#####$accountAddr"
    nodeName=$(echo "node$i" | base64)
cat << EOF >> ${CURRENT_PATH}/genesis.toml

[[node_names]]
id = $i
name = '$nodeName'

[[epoch_info.validator_set]]
  id = $i
  account_address = '$accountAddr'
  p2p_node_id = '$p2pId'
  consensus_voting_power = 1000
EOF
  done

  for ((i = 1; i <= $validator_num; i = i + 1)); do
    cp -r "${CURRENT_PATH}"/genesis.toml "${BUILD_PATH}"/node$i/
    echo 'export AXIOM_LEDGER_GENESIS_EPOCH_INFO_P2P_BOOTSTRAP_NODE_ADDRESSES="\
/ip4/172.16.30.81/tcp/4001/p2p/16Uiu2HAmJ38LwfY6pfgDWNvk3ypjcpEMSePNTE6Ma2NCLqjbZJSF;\
/ip4/172.16.30.81/tcp/4002/p2p/16Uiu2HAmRypzJbdbUNYsCV2VVgv9UryYS5d7wejTJXT73mNLJ8AK;\
/ip4/172.16.30.81/tcp/4003/p2p/16Uiu2HAmTwEET536QC9MZmYFp1NUshjRuaq5YSH1sLjW65WasvRk;\
/ip4/172.16.30.81/tcp/4004/p2p/16Uiu2HAmQBFTnRr84M3xNhi3EcWmgZnnBsDgewk4sNtpA3smBsHJ;\
/ip4/172.16.30.82/tcp/4005/p2p/16Uiu2HAm2HeK145KTfLaURhcoxBUMZ1PfhVnLRfnmE8qncvXWoZj;\
/ip4/172.16.30.82/tcp/4006/p2p/16Uiu2HAm2CVtLveAtroaN7pcR8U2saBKjwYqRAikMSwxqdoYMxtv;\
/ip4/172.16.30.82/tcp/4007/p2p/16Uiu2HAmQv3m5SSyYAoafKmYbTbGmXBaS4DXHXR9wxWKQ9xLzC3n;\
/ip4/172.16.30.82/tcp/4008/p2p/16Uiu2HAkx1o5fzWLdAobanvE6vqbf1XSbDSgCnid3AoqDGQYFVxo;\
"' >>"${BUILD_PATH}"/node$i/.env.sh
    echo 'export AXIOM_LEDGER_LOG_MODULE_CONSENSUS='debug'' >>"${BUILD_PATH}"/node$i/.env.sh
  done
}

function recordNodesConfig() {

  echo "===> record $N nodes configuration on nodes.info "
  recordTime=$(date +"%Y-%m-%d-%s")
  echo "===> record time is : $recordTime"

  for ((i = 1; i < N + 1; i = i + 1)); do
    nodeInfo=$("${BUILD_PATH}"/node${i}/axiom-ledger config node-info)
    accountAddr=$(echo "$nodeInfo" |grep node-key-addr | awk {'print $2'})
    p2pId=$(echo "$nodeInfo" |grep p2p-id | awk {'print $2'})
    echo "######## $i #####record#####$accountAddr"
    nodeName=$(echo "node$i" | base64)
cat << EOF >> "${CURRENT_PATH}"/nodes-"$recordTime".info
export const node$i = {
    NodeId: '$p2pId',
    Address: '$accountAddr',
    Name = '$nodeName'
}

EOF
  done
}

generateNodesConfig
generateClusterConfig
recordNodesConfig