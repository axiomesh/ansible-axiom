#!/usr/bin/env bash
set -e
#set -x

# shellcheck source=/dev/null
source x.sh

function startTest() {
  for ((i = 1; i <= "$count"; i = i + 1)); do
    print_blue "Executing the test for the $i time"
    cd "$CHAOSBLADE_PATH"
    taskInfo=$(echo "$PASSWORD" | sudo -S ./blade create network loss --percent "$percent" --interface ens3 --local-port "$port" --timeout 45 --force)
    taskId=$(echo "$taskInfo" |grep success | awk -F '\"' {'print $8'})
    if [ -z "$taskId" ]; then
	  print_red "taskId is empty, please check you scripts!!!"
	  exit 2
    fi
    recordTime=$(date +"%Y-%m-%d-%s")
    print_green "recordTime is : $recordTime"
    print_green "Successful networkLoss tests on target machine, task id is: $taskId"
    sleep 15
  done
  print_blue "End the test"
}

while getopts ":n:p:c:" opt; do
  case $opt in
    n) count="$OPTARG";;
    p) port="$OPTARG";;
    c) percent="$OPTARG";;
    \?) echo "Invalid options: -$OPTARG" >&2;;
  esac
done

startTest

