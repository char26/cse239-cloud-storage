#!/bin/bash

workload="workloada"
TARGETS=(200 500 1000 2500 5000 10000 20000)

threads=8

database=$1
ip_address=$2

# Validate required positional arguments
if [ -z "$database" ]; then
    echo "No database specified."
    echo "Usage: $0 <database> <ip_address>"
    exit 1
fi

if [ -z "$ip_address" ]; then
    echo "No IP address specified."
    echo "Usage: $0 <database> <ip_address>"
    exit 1
fi

shift 2

while [[ $# -gt 0 ]]; do
    case $1 in
        -t)
            threads=$2
            shift 2
            ;;
    esac
done

# Create results directory
RESULTS_DIR="ycsb_results"
mkdir -p "$RESULTS_DIR"

echo "Running load test..."
echo "Results will be saved to: $RESULTS_DIR"
echo ""

echo "Running YCSB with:"
echo "  Database: $database"
echo "  Workload: $workload"
echo "  IP address: $ip_address"
echo "  Operation count: $operationcount"
echo "  Threads: $threads"
echo ""

# THIS FILE EXPECTS THE DATABASE TO BE LOADED BEFOREHAND
# RUN insert_postgres.sh OR insert_scylla.sh BEFORE RUNNING THIS FILE

if [ "$database" = "postgres" ]; then
    # Ensure postgrenosql.properties exists
    if [ ! -f ./postgrenosql.properties ]; then
        echo "postgrenosql.properties not found. Please create it before running the script."
        exit 1
    fi

    # Replace URL line in postgrenosql.properties with provided IP address
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "1s|^postgrenosql\.url =.*$|postgrenosql.url = jdbc:postgresql://$ip_address:5433/test|" ./postgrenosql.properties
    else
        # Linux
        sed -i "1s|^postgrenosql\.url =.*$|postgrenosql.url = jdbc:postgresql://$ip_address:5433/test|" ./postgrenosql.properties
    fi
fi

# RUNNING THE BENCHMARK
for target in "${TARGETS[@]}"; do
    # Scale operation count with target: 50 ops per target unit
    operationcount=$((target * 50))
    if [ "$database" = "postgres" ]; then
        ./ycsb-0.17.0/bin/ycsb.sh run postgrenosql -P ./ycsb-0.17.0/workloads/$workload -P ./postgrenosql.properties -target $target -threads $threads -p operationcount=$operationcount -s \
        2>&1 | tee -a "$RESULTS_DIR/postgres_load.txt"

    elif [ "$database" = "scylla" ]; then
        ./ycsb-0.17.0/bin/ycsb.sh run cassandra-cql -P ./ycsb-0.17.0/workloads/$workload -p hosts=$ip_address -p port=9042 -target $target -threads $threads -p operationcount=$operationcount -s \
        2>&1 | tee -a "$RESULTS_DIR/scylla_load.txt"
    else
        echo "Invalid database specified. Supported: postgres, scylla"
        echo "Usage: $0 <database> <workload> -i <ip_address> [-r <recordcount>] [-o <operationcount>] [-t <threads>]"
        exit 1
    fi
done



