#!/usr/bin/env bash

set -e

CURRENT_PATH=$(
  cd $(dirname ${BASH_SOURCE[0]})
  pwd
)
source ${CURRENT_PATH}/.env.sh
BUILD_PATH=${CURRENT_PATH}/nodes

N=$1
function generateNodesConfig() {
  echo "===> Generating $N nodes configuration on ${BUILD_PATH}"
  for ((i = 1; i <= N; i = i + 1)); do
    root=${BUILD_PATH}/node${i}
    echo ""
    echo "generate node${i} config"
    mkdir -p ${root}
    rm -rf ${root}/*
    rm -f ${root}/.env.sh
    cp -rf ${AXIOM_LEDGER_PROJECT_PATH}/scripts/package/* ${root}/
    cp -f ${AXIOM_LEDGER_BINARY_PATH} ${root}/tools/bin/
    let JSONRPC_PORT=8880+i,WEBSOCKET_PORT=9990+i,P2P_PORT=4000+i,PPROF_PORT=53120+i,MONITOR_PORT=40010+i

    echo "export AXIOM_LEDGER_PORT_JSONRPC=${JSONRPC_PORT}" >>${root}/.env.sh
    echo "export AXIOM_LEDGER_PORT_WEBSOCKET=${WEBSOCKET_PORT}" >>${root}/.env.sh
    echo "export AXIOM_LEDGER_PORT_P2P=${P2P_PORT}" >>${root}/.env.sh
    echo "export AXIOM_LEDGER_PORT_PPROF=${PPROF_PORT}" >>${root}/.env.sh
    echo "export AXIOM_LEDGER_PORT_MONITOR=${MONITOR_PORT}" >>${root}/.env.sh
  
    ${root}/axiom-ledger config generate --default-node-index ${i} #--epoch-enable
  done
}

function generateClusterConfig() {
  echo "===> Generating cluster configuration on ${BUILD_PATH}"
  echo "===> Calculate the number of validator and candidate"
  validator_num=$N
  #candidate_num=$(echo "$N - $validator_num" | bc)
  echo "validator number is : $validator_num"
 
  rm -rf ${CURRENT_PATH}/config.toml
  cp ${BUILD_PATH}/node1/config.toml ${CURRENT_PATH}/
  sed -i '/candidate_set/d' ${CURRENT_PATH}/config.toml

  for ((i = 5; i <= validator_num; i = i + 1)); do
    nodeInfo=$(${BUILD_PATH}/node${i}/axiom-ledger config node-info)

    #echo "$nodeInfo"
    accountAddr=$(echo "$nodeInfo" |grep account-addr | awk {'print $2'})
    p2pId=$(echo "$nodeInfo" |grep p2p-id | awk {'print $2'})
    echo "######## $i #####validator#####$accountAddr"
cat << EOF >> ${CURRENT_PATH}/config.toml

[[genesis.epoch_info.validator_set]]
  id = $i
  account_address = '$accountAddr'
  p2p_node_id = '$p2pId'
  consensus_voting_power = 100
EOF
  done

  for ((i = 1; i <= $validator_num; i = i + 1)); do
    cp -r ${CURRENT_PATH}/config.toml ${BUILD_PATH}/node$i/
    echo 'export AXIOM_LEDGER_GENESIS_EPOCH_INFO_P2P_BOOTSTRAP_NODE_ADDRESSES="\
/ip4/172.16.30.81/tcp/4001/p2p/16Uiu2HAmJ38LwfY6pfgDWNvk3ypjcpEMSePNTE6Ma2NCLqjbZJSF;\
/ip4/172.16.30.81/tcp/4002/p2p/16Uiu2HAmRypzJbdbUNYsCV2VVgv9UryYS5d7wejTJXT73mNLJ8AK;\
/ip4/172.16.30.81/tcp/4003/p2p/16Uiu2HAmTwEET536QC9MZmYFp1NUshjRuaq5YSH1sLjW65WasvRk;\
/ip4/172.16.30.81/tcp/4004/p2p/16Uiu2HAmQBFTnRr84M3xNhi3EcWmgZnnBsDgewk4sNtpA3smBsHJ;\
"' >>${BUILD_PATH}/node$i/.env.sh
  done
  #rm -rf ${CURRENT_PATH}/config.toml
}

function recordNodesConfig() {
  rm -rf ${CURRENT_PATH}/nodes.info

  echo "===> record $N nodes configuration on nodes.info "
  for ((i = 1; i < N + 1; i = i + 1)); do
    nodeInfo=$(${BUILD_PATH}/node${i}/axiom-ledger config node-info)
    accountAddr=$(echo "$nodeInfo" |grep account-addr | awk {'print $2'})
    p2pId=$(echo "$nodeInfo" |grep p2p-id | awk {'print $2'})
    #echo "######## $i #####validator#####$accountAddr"
cat << EOF >> ${CURRENT_PATH}/nodes.info

[[nodes]]
  id = $i
  account_address = '$accountAddr'
  p2p_node_id = '$p2pId'
EOF
  done
}

generateNodesConfig
generateClusterConfig
recordNodesConfig