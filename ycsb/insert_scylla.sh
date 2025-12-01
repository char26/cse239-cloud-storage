#!/bin/bash

workload="workloada"
threads=8
recordcount=10000000


ip_address=$1


if [ -z "$ip_address" ]; then
    echo "No IP address specified."
    echo "Usage: $0 <ip_address>"
    exit 1
fi

shift 1

while [[ $# -gt 0 ]]; do
    case $1 in
        -t)
            threads=$2
            shift 2
            ;;
        -r)
            recordcount=$2
            shift 2
            ;;
    esac
done

echo "past flags"

# Create results directory

RESULTS_DIR="ycsb_results"
mkdir -p "$RESULTS_DIR"

# INSERT DATA
echo "Inserting $recordcount records into Scylla..."
./ycsb-0.17.0/bin/ycsb.sh load cassandra-cql -P ./ycsb-0.17.0/workloads/$workload -p hosts=$ip_address -p port=9042 -threads $threads -p recordcount=$recordcount -s \
2>&1 | tee -a "$RESULTS_DIR/insert_scylla.txt"



