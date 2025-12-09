import argparse
import subprocess
import os
import psycopg2

def clear_postgres_table(postgres_host, user, password, dbname):
    try:
        conn = psycopg2.connect(
            host=postgres_host,
            database=dbname,
            user=user,
            password=password,
            port=5432
        )
        cur = conn.cursor()
        cur.execute("TRUNCATE TABLE usertable;")
        conn.commit()
        cur.close()
        conn.close()
        print(f"Successfully truncated usertable in PostgreSQL at {postgres_host}")
    except Exception as e:
        print(f"Error clearing PostgreSQL usertable: {e}")
        exit(1)

def main():
    parser = argparse.ArgumentParser(description="Run YCSB benchmarks.")
    parser.add_argument("--db", required=True, help="The database to benchmark (postgres or scylla).")
    parser.add_argument("--dsn", help="The host for PostgreSQL.")
    parser.add_argument("--host", help="The host for ScyllaDB.")
    parser.add_argument("--workload", required=True, help="Path to the YCSB workload file.")
    args = parser.parse_args()

    ycsb_dir = os.path.join(os.path.dirname(__file__), "ycsb")
    ycsb_bin = os.path.join(ycsb_dir, "bin", "ycsb")

    if not os.path.exists(ycsb_bin):
        print(f"Error: YCSB executable not found at {ycsb_bin}")
        print("Please download and extract YCSB to a 'ycsb' directory in your project root.")
        exit(1)

    if args.db == "postgres":
        if not args.dsn:
            print("Error: --dsn is required for PostgreSQL benchmarks.")
            exit(1)
        
        clear_postgres_table(args.dsn, "user", "password", "database") # Clear table before loading

        db_binding = "jdbc"
        db_driver = "org.postgresql.Driver"
        load_command = [
            ycsb_bin, "load", db_binding,
            "-P", args.workload,
            "-p", f"db.driver={db_driver}",
            "-p", f"db.url=jdbc:postgresql://{args.dsn}:5432/database",
            "-p", "db.user=user",
            "-p", "db.passwd=password"
        ]
        run_command = [
            ycsb_bin, "run", db_binding,
            "-P", args.workload,
            "-p", f"db.driver={db_driver}",
            "-p", f"db.url=jdbc:postgresql://{args.dsn}:5432/database",
            "-p", "db.user=user",
            "-p", "db.passwd=password"
        ]
    elif args.db == "scylla":
        db_binding = "cassandra-cql"
        load_command = [
            ycsb_bin, "load", db_binding,
            "-P", args.workload,
            "-p", f"hosts={args.host}",
            "-p", "port=9042"
        ]
        run_command = [
            ycsb_bin, "run", db_binding,
            "-P", args.workload,
            "-p", f"hosts={args.host}",
            "-p", "port=9042"
        ]
    else:
        print(f"Error: Unsupported database: {args.db}")
        exit(1)

    print("--- YCSB Load Phase ---")
    print(" ".join(load_command))
    subprocess.run(load_command, check=True)

    print("\n--- YCSB Run Phase ---")
    print(" ".join(run_command))
    subprocess.run(run_command, check=True)

if __name__ == "__main__":
    main()
