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

# Replace URL line in postgrenosql.properties with provided IP address
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "1s|^postgrenosql\.url =.*$|postgrenosql.url = jdbc:postgresql://$ip_address:5433/test|" ./postgrenosql.properties
else
    # Linux
    sed -i "1s|^postgrenosql\.url =.*$|postgrenosql.url = jdbc:postgresql://$ip_address:5433/test|" ./postgrenosql.properties
fi

./ycsb-0.17.0/bin/ycsb.sh load postgrenosql -P ./ycsb-0.17.0/workloads/$workload -P ./postgrenosql.properties -threads $threads -p recordcount=$recordcount -s \
2>&1 | tee -a "$RESULTS_DIR/insert_postgres.txt"



