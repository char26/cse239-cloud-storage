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

echo "Postgres properties file: $(cat ./postgrenosql.properties)"

echo "Inserting $recordcount records into Postgres..."
./ycsb-0.17.0/bin/ycsb.sh load postgrenosql -P ./ycsb-0.17.0/workloads/$workload -P ./postgrenosql.properties -threads $threads -p recordcount=$recordcount -s \
2>&1 | tee -a "$RESULTS_DIR/insert_postgres.txt"



