# config.py

# YCSB Workload and Trial settings
WORKLOAD = "workloads/workloada" # Path to the YCSB workload file
NUM_TRIALS = 3

# Output directory for logs
OUTDIR = "logs"

# PostgreSQL connection details
PG_USER = "cse239_db_tester"
PG_PASSWORD = "1234grep" # Eventually make this an environment variable that the user has defined
PG_DB = "database"
POSTGRES_PORT = 5432 # Default PostgreSQL port

# ScyllaDB connection details
SCYLLA_PORT = 9042 # Default ScyllaDB port

# Default hostnames for local Docker Compose environment
# These are the service names defined in compose.yaml
DEFAULT_POSTGRES_HOST = "postgres"
DEFAULT_SCYLLA_HOST = "scylla"

# Environment setting (e.g., "local", "gcs", "nautilus")
# This will be used to determine how to get actual IP addresses
ENV = "local" # Default to local

# Terraform path (if ENV is "gcs" or similar and requires terraform output)
TERRAFORM_DB_PATH = "databases-tf"
