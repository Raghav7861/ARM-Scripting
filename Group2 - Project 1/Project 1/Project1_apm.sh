#!/bin/bash
#Bhaskar, Charan, Luke

ip=$(ifconfig ens33 | grep "inet" | head -1 | awk '{ print $2 }')

run() {
  #spawn processes
  ./APM1 "$1" &
  pid1=$!
  echo "proc1: ${pid1}"
  ./APM2 "$1" &
  pid2=$!
  echo "proc2: ${pid2}"
  ./APM3 "$1" &
  pid3=$!
  echo "proc3: ${pid3}"
  ./APM4 "$1" &
  pid4=$!
  echo "proc4: ${pid4}"
  ./APM5 "$1" &
  pid5=$!
  echo "proc5: ${pid5}"
  ./APM6 "$1" &
  pid6=$!
  echo "proc6: ${pid6}"

  ifstat -a -d 1
}

proc_metrics() {
  echo "$time ,$(ps -aux | awk -v r=$pid1 '$2 == r' | awk '{print $3}'), $(ps -aux | awk -v r=$pid1 '$2 == r' | awk '{print $4}')" >>APM1_metrics.csv
  echo "$time ,$(ps -aux | awk -v r=$pid2 '$2 == r' | awk '{print $3}'), $(ps -aux | awk -v r=$pid2 '$2 == r' | awk '{print $4}')" >>APM2_metrics.csv
  echo "$time ,$(ps -aux | awk -v r=$pid3 '$2 == r' | awk '{print $3}'), $(ps -aux | awk -v r=$pid3 '$2 == r' | awk '{print $4}')" >>APM3_metrics.csv
  echo "$time ,$(ps -aux | awk -v r=$pid4 '$2 == r' | awk '{print $3}'), $(ps -aux | awk -v r=$pid4 '$2 == r' | awk '{print $4}')" >>APM4_metrics.csv
  echo "$time ,$(ps -aux | awk -v r=$pid5 '$2 == r' | awk '{print $3}'), $(ps -aux | awk -v r=$pid5 '$2 == r' | awk '{print $4}')" >>APM5_metrics.csv
  echo "$time ,$(ps -aux | awk -v r=$pid6 '$2 == r' | awk '{print $3}'), $(ps -aux | awk -v r=$pid6 '$2 == r' | awk '{print $4}')" >>APM6_metrics.csv
}

sys_metrics() {
  RX=$(ifstat | grep ens33 | awk '{print $6}' | sed 's/K//g')
  TX=$(ifstat | grep ens33 | awk '{print $9}' | sed 's/K//g')
  DiskWite=$(iostat | grep sda | awk '{print $4}')
  DiskSpace=$(df -h -m /dev/mapper/cl-root | awk '{print $4}' | tail -1)

  echo "$time ,$RX,$TX,$DiskWite,$DiskSpace" >>SysMetrics.csv
}

cleanup() {
  kill -9 $pid1
  kill -9 $pid2
  kill -9 $pid3
  kill -9 $pid4
  kill -9 $pid5
  kill -9 $pid6
  pkill -f -9 "ifstat"
  exit $?
}

trap cleanup SIGINT

run "$ip"
SECONDS=0
while true; do
  sleep 5
  if [[ $duration -ge 905 ]]; then
    cleanup
  fi
  echo "sleeping 5 seconds"
  time=$SECONDS
  proc_metrics
  sys_metrics
done
