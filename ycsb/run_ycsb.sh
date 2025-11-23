#!/bin/bash
database=$1
if [ -z "$database" ]; then
    echo "No database specified. Usage: $0 <database> <ip_address> <workload>"
    exit 1
fi
ip_address=$2
if [ -z "$ip_address" ]; then
    echo "No IP address specified. Usage: $0 <database> <ip_address> <workload>"
    exit 1
fi
workload=$3
if [ -z "$workload" ]; then
    echo "No workload specified. Usage: $0 <database> <ip_address> <workload>"
    exit 1
fi

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

    ./ycsb-0.17.0/bin/ycsb.sh load postgrenosql -P ./ycsb-0.17.0/workloads/$workload -P ./postgrenosql.properties

    ./ycsb-0.17.0/bin/ycsb.sh run postgrenosql -P ./ycsb-0.17.0/workloads/$workload -P ./postgrenosql.properties

elif [ "$database" = "scylla" ]; then
    ./ycsb-0.17.0/bin/ycsb.sh load cassandra-cql -P ./ycsb-0.17.0/workloads/$workload -p hosts=$ip_address -p port=9042

    ./ycsb-0.17.0/bin/ycsb.sh run cassandra-cql -P ./ycsb-0.17.0/workloads/$workload -p hosts=$ip_address -p port=9042
else
    echo "Invalid database specified. Usage: $0 <database> <workload>"
    exit 1
fi
