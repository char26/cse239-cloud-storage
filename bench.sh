# Config stuff
WORKLOAD="" # need to look into YCSB more

# DB order
ORDER=("postgres" "scylla")

# Logs
OUTDIR="logs"
PYTHON="python3"

# User info for Postgres
PG_USER="user"
PG_PASSWORD="password"
PG_DB="database"

# Compose project name
COMPOSE_PROJECT="bench"

export COMPOSE_PROJECT_NAME="$COMPOSE_PROJECT"
mkdir -p "$OUTDIR"

# We'll need functions to clean things up, get the host port, wait for the host port to accept connections, etc

# We also need to bring up and stop the services
bring_up_service() {
    local service="$1"
    echo "Bringing up service: $service"
    docker-compose up -d "$service"
}

stop_service() {
    local service="$1"
    echo "Stopping service: $service"
    docker-compose down
}

# A basic postgres trial
run_postgres_trial() {
    local trial="$1"

    bring_up_service "postgres"

    # get the postgres port and wait for it to accept the connection

    local DSN="postgresql://${PG_USER}:${PG_PASSWORD}@${IP}:${PORT}/$PG_DB"

    # Make the log file for the trial
    local TSTAMP
    TSTAMP=$(date +"%Y%m%d-%H%M%S")
    local LOGFILE="${OUTDIR}/postgres/t${trial}-${TSTAMP}"
    mkdir -p "$(dirname "$LOGFILE")"

    echo "Running Postgres trial $trial, logging to $LOGFILE"

    # Run the benchmark script
    $PYTHON benchmark.py \
        --db postgres \
        --dsn "$DSN" \
        --workload "$WORKLOAD" \
        &> "$LOGFILE"

    stop_service "postgres"
}

# A basic scylla trial
run_scylla_trial() {
    local trial="$1"

    bring_up_service "scylla"

    # get the scylla port and wait for it to accept the connection

    # I don't think a DSN is required

    local TSTAMP
    TSTAMP=$(date +"%Y%m%d-%H%M%S")
    local LOGFILE="${OUTDIR}/scylla/t${trial}-${TSTAMP}"
    mkdir -p "$(dirname "$LOGFILE")"

    echo "Running Scylla trial $trial, logging to $LOGFILE"
    $PYTHON benchmark.py \
        --db scylla \
        --workload "$WORKLOAD" \
        &> "$LOGFILE"

    stop_service "scylla"
}

# Finally the logic to actually run the trials