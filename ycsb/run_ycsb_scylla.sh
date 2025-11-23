#!/bin/bash
workload=$1
if [ -z "$workload" ]; then
    echo "No workload specified. Usage: $0 <workload>"
    exit 1
fi
./ycsb-0.17.0/bin/ycsb.sh load cassandra-cql -P ./ycsb-0.17.0/workloads/$workload -p hosts=scylla -p port=9042

./ycsb-0.17.0/bin/ycsb.sh run cassandra-cql -P ./ycsb-0.17.0/workloads/$workload -p hosts=scylla -p port=9042
