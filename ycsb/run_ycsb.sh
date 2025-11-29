#!/bin/bash

# Default values
threads=1
recordcount=1000
operationcount=10000
ip_address=""

# Parse positional arguments
database=$1
workload=$2

# Shift past the positional arguments
shift 2

# Parse optional flags
while [[ $# -gt 0 ]]; do
    case $1 in
        -i)
            ip_address=$2
            shift 2
            ;;
        -r)
            recordcount=$2
            shift 2
            ;;
        -o)
            operationcount=$2
            shift 2
            ;;
        -t)
            threads=$2
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 <database> <workload> -i <ip_address> [-r <recordcount>] [-o <operationcount>] [-t <threads>]"
            exit 1
            ;;
    esac
done

# Validate required positional arguments
if [ -z "$database" ]; then
    echo "No database specified."
    echo "Usage: $0 <database> <workload> -i <ip_address> [-r <recordcount>] [-o <operationcount>] [-t <threads>]"
    exit 1
fi

if [ -z "$workload" ]; then
    echo "No workload specified."
    echo "Usage: $0 <database> <workload> -i <ip_address> [-r <recordcount>] [-o <operationcount>] [-t <threads>]"
    exit 1
fi

# Validate ip_address
if [ -z "$ip_address" ]; then
    echo "No IP address specified."
    echo "Usage: $0 <database> <workload> -i <ip_address> [-r <recordcount>] [-o <operationcount>] [-t <threads>]"
    exit 1
fi

echo "Running YCSB with:"
echo "  Database: $database"
echo "  Workload: $workload"
echo "  IP address: $ip_address"
echo "  Record count: $recordcount"
echo "  Operation count: $operationcount"
echo "  Threads: $threads"
echo ""

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

    ./ycsb-0.17.0/bin/ycsb.sh load postgrenosql -P ./ycsb-0.17.0/workloads/$workload -P ./postgrenosql.properties -threads $threads -p recordcount=$recordcount

    ./ycsb-0.17.0/bin/ycsb.sh run postgrenosql -P ./ycsb-0.17.0/workloads/$workload -P ./postgrenosql.properties -threads $threads -p operationcount=$operationcount

elif [ "$database" = "scylla" ]; then
    ./ycsb-0.17.0/bin/ycsb.sh load cassandra-cql -P ./ycsb-0.17.0/workloads/$workload -p hosts=$ip_address -p port=9042 -threads $threads -p recordcount=$recordcount

    ./ycsb-0.17.0/bin/ycsb.sh run cassandra-cql -P ./ycsb-0.17.0/workloads/$workload -p hosts=$ip_address -p port=9042 -threads $threads -p operationcount=$operationcount
else
    echo "Invalid database specified. Supported: postgres, scylla"
    echo "Usage: $0 <database> <workload> -i <ip_address> [-r <recordcount>] [-o <operationcount>] [-t <threads>]"
    exit 1
fi
