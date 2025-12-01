#!/bin/bash

workload="workloada"
threads=8

ip_address=$1
recordcount=$2

if [ -z "$ip_address" ]; then
    echo "No IP address specified."
    echo "Usage: $0 <ip_address>"
    exit 1
fi

if [ -z "$recordcount" ]; then
    recordcount=10000000
    echo "No record count specified. Using default: $recordcount"
fi

# Create results directory

RESULTS_DIR="ycsb_results"
mkdir -p "$RESULTS_DIR"

# INSERT DATA

./ycsb-0.17.0/bin/ycsb.sh load cassandra-cql -P ./ycsb-0.17.0/workloads/$workload -p hosts=$ip_address -p port=9042 -threads $threads -p recordcount=$recordcount -s \
2>&1 | tee -a "$RESULTS_DIR/insert_scylla.txt"



