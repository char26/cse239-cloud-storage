#!/bin/bash

if [ -f .env ]; then
    # shellcheck source=.env
    source .env
fi

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
    local max_retries=5
    local backoff=10
    echo "Waiting for $host:$port to be open..."
    for ((i=1; i<=max_retries; i++)); do
        if nc -z "$host" "$port"; then
            echo "$host:$port is open."
            return 0
        fi
        echo "Attempt $i/$max_retries failed. Retrying in $backoff seconds..."
        sleep "$backoff"
        backoff=$((backoff * 2))
    done
    echo "Error: Could not connect to $host:$port after $max_retries attempts."
    exit 1
}

# A basic postgres trial
run_postgres_trial() {
    local trial="$1"
    local full_address="$2"
    local ip
    local port

    # Check if a port is specified in the address
    if [[ "$full_address" == *":"* ]]; then
        ip=$(echo "$full_address" | cut -d: -f1)
        port=$(echo "$full_address" | cut -d: -f2)
    else
        ip="$full_address"
        port=5432
    fi

    wait_for_port "$ip" "$port"

    local DSN="${ip}"

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

# Get IP addresses based on the environment
if [ "$ENV" = "gcs" ]; then
    echo "GCS environment detected. Getting IP addresses from Terraform..."
    # Use existing variables if they are set, otherwise get from terraform
    if [ -z "$POSTG" ]; then
        POSTGRES_IP=$(terraform -chdir=databases-tf output -raw postgres_public_ip)
    fi
    if [ -z "$SCYLLA_IP" ]; then
        SCYLLA_IP=$(terraform -chdir=databases-tf output -raw scylla_public_ip)
    fi
elif [ "$ENV" = "nautilus" ]; then
    echo "Nautilus environment detected. Using environment variables for IP addresses..."
    if [ -z "$POSTGRES_IP" ] || [ -z "$SCYLLA_IP" ]; then
        echo "Error: POSTGRES_IP and SCYLLA_IP must be set in the Nautilus environment."
        exit 1
    fi
else
    echo "No ENV specified. Using environment variables for IP addresses..."
    if [ -z "$POSTGRES_IP" ] || [ -z "$SCYLLA_IP" ]; then
        echo "Error: POSTGRES_IP and SCYLLA_IP must be set for the local environment."
        exit 1
    fi
fi

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