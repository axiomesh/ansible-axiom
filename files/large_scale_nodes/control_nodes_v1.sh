#! /bin/bash
set -e
#set -x

begin_index=$2
end_index=$3
CURRENT_PATH=$(cd $(dirname ${BASH_SOURCE[0]}); pwd)

function start(){
  for ((i = begin_index; i <= end_index ; i = i + 1)); do
    #cd $CURRENT_PATH/nodes/node$i
    bash $CURRENT_PATH/node$i/start.sh
  done
}

function stop(){
  for ((i = begin_index; i <= end_index; i = i + 1)); do
    #cd $CURRENT_PATH/nodes/node$i
    bash $CURRENT_PATH/node$i/stop.sh
  done
}

function restart(){
  for ((i = begin_index; i <= end_index; i = i + 1)); do
    #cd $CURRENT_PATH/nodes/node$i
    bash $CURRENT_PATH/node$i/restart.sh
  done
}

function status(){
  for ((i = begin_index; i <= end_index; i = i + 1)); do
    #cd $CURRENT_PATH/nodes/node$i
    bash $CURRENT_PATH/node$i/status.sh
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