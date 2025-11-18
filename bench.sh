#!/bin/bash

# Config stuff
WORKLOAD="workloads/workloada" # Example YCSB workload file
NUM_TRIALS=3

# Logs
OUTDIR="logs"
PYTHON="python3"

# User info for Postgres
PG_USER="user"
PG_PASSWORD="password"
PG_DB="database"

mkdir -p "$OUTDIR"

# Function to wait for a port to be open
wait_for_port() {
    local host="$1"
    local port="$2"
    echo "Waiting for $host:$port to be open..."
    while ! nc -z "$host" "$port"; do
        sleep 1
    done
    echo "$host:$port is open."
}

# A basic postgres trial
run_postgres_trial() {
    local trial="$1"
    local ip="$2"

    wait_for_port "$ip" 5432

    local DSN="postgresql://${PG_USER}:${PG_PASSWORD}@${ip}:5432/${PG_DB}"

    # Make the log file for the trial
    local TSTAMP
    TSTAMP=$(date +"%Y%m%d-%H%M%S")
    local LOGFILE="${OUTDIR}/postgres/t${trial}-${TSTAMP}.log"
    mkdir -p "$(dirname "$LOGFILE")"

    echo "Running Postgres trial $trial, logging to $LOGFILE"

    # Run the benchmark script
    $PYTHON benchmark.py \
        --db postgres \
        --dsn "$DSN" \
        --workload "$WORKLOAD" \
        &> "$LOGFILE"
}

# A basic scylla trial
run_scylla_trial() {
    local trial="$1"
    local ip="$2"

    wait_for_port "$ip" 9042

    local TSTAMP
    TSTAMP=$(date +"%Y%m%d-%H%M%S")
    local LOGFILE="${OUTDIR}/scylla/t${trial}-${TSTAMP}.log"
    mkdir -p "$(dirname "$LOGFILE")"

    echo "Running Scylla trial $trial, logging to $LOGFILE"
    $PYTHON benchmark.py \
        --db scylla \
        --host "$ip" \
        --workload "$WORKLOAD" \
        &> "$LOGFILE"
}

# --- Main Logic ---

# Get IP addresses from terraform output
echo "Getting IP addresses from Terraform..."
POSTGRES_IP=$(terraform -chdir=databases-tf output -raw postgres_public_ip)
SCYLLA_IP=$(terraform -chdir=databases-tf output -raw scylla_public_ip)

echo "Postgres IP: $POSTGRES_IP"
echo "Scylla IP: $SCYLLA_IP"

# Run Postgres trials
for i in $(seq 1 $NUM_TRIALS); do
    run_postgres_trial "$i" "$POSTGRES_IP"
done

# Run Scylla trials
for i in $(seq 1 $NUM_TRIALS); do
    run_scylla_trial "$i" "$SCYLLA_IP"
done

echo "Benchmarking complete. Logs are in the '$OUTDIR' directory."