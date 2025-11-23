#!/bin/bash
database=$1
if [ -z "$database" ]; then
    echo "No database specified. Usage: $0 <database> <workload>"
    exit 1
fi
workload=$2
if [ -z "$workload" ]; then
    echo "No workload specified. Usage: $0 <database> <workload>"
    exit 1
fi
if [ "$database" = "postgres" ]; then
    ./run_ycsb_postgres.sh $workload
elif [ "$database" = "scylla" ]; then
    ./run_ycsb_scylla.sh $workload
else
    echo "Invalid database specified. Usage: $0 <database> <workload>"
    exit 1
fi
