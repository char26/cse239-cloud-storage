#!/bin/bash
workload=$1
if [ -z "$workload" ]; then
    echo "No workload specified. Usage: $0 <workload>"
    exit 1
fi
./ycsb-0.17.0/bin/ycsb.sh load postgrenosql -P ./ycsb-0.17.0/workloads/$workload -P ./postgrenosql.properties

./ycsb-0.17.0/bin/ycsb.sh run postgrenosql -P ./ycsb-0.17.0/workloads/$workload -P ./postgrenosql.properties
