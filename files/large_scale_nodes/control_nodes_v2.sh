#! /bin/bash
set -e
#set -x

CURRENT_PATH=$(cd $(dirname ${BASH_SOURCE[0]}); pwd)

function start(){
  for node in $CURRENT_PATH/*; do
    if [[ $node == *"node"[0-9]* ]] && [[ -f "$node/start.sh" ]];then
      echo "find dir: $node, execute start.sh, result is : "
      bash $node/start.sh
    fi
  done
}

function stop(){
  for node in $CURRENT_PATH/*; do
    if [[ $node == *"node"[0-9]* ]] && [[ -f "$node/stop.sh" ]];then
      echo "find dir: $node, execute stop.sh, result is : " 
      bash $node/stop.sh
    fi
  done
}

function restart(){
  for node in $CURRENT_PATH/*; do
    if [[ $node == *"node"[0-9]* ]] && [[ -f "$node/restart.sh" ]];then
      echo "find dir: $node, execute restart.sh, result is : "
      bash $node/restart.sh
    fi
  done
}

function status(){
  for node in $CURRENT_PATH/*; do
    if [[ $node == *"node"[0-9]* ]] && [[ -f "$node/status.sh" ]];then
      echo "find dir: $node, execute status.sh, result is : " 
      bash $node/status.sh
    fi
  done
}

function clean(){
  for node in $CURRENT_PATH/*; do
    if [[ $node == *"node"[0-9]* ]];then
      echo "find dir: $node, execute rm -rf storage and logs"
      rm -rf  $node/logs
      rm -rf  $node/storage
    fi 
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
  clean)
    clean
    ;;
  *)
    echo "Usage: ./control.sh {start|stop|restart|status}"
    exit 1
esac

exit $?