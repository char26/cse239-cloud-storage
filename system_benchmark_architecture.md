# System Architecture

We define three VMs in a Terraform configuration file. One VM for Postgres, Scylla, and an additional VM to run the benchmarks from. All of which are hosted at the same location. Postgres and Scylla both get dedicated 375GB local NVME SSDs.

We also include a Docker Compose file, made to make local testing and peer deployment easier. This may also double as a quick way to test on a Nautilus VM, or any other compute cluster.

# Benchmarking Methods

## VM Setup

For simplicity and "fairness" (though this test is not necessarily fair), we will start with just a single Scylla node on the same size VM as a Postgres instance.

The comparisons that do not consider additional VM sizes will be run on `n2d-standard-2` VMs, which have 2 vCPUs and 8GB of memory. All VMs are given a 375GB NVME SSD that is mounted to the corresponding database instance.

## YCSB

**Note: Postgres has issues with how YCSBs multithreading sends queries, so we are stuck with only 1 thread for all Postgres YCSB tests: https://github.com/brianfrankcooper/YCSB/issues/1379**

All tests should be run against a database loaded with 10,000,000 records.
`recordcount`: 10,000,000

We are defaulting to `workloada`, which is a 50/50 split of reads and updates.

Operation count effectively controls how long the test runs for.

### Load (and Simulated Growth)

View latency patterns across normal loads.

Targeted throughput can simulate any number of operations per second.

`target`: 100, 200, 500, 1000, 2500, 5,000, 10,000
`operationcount`: 1,000,000

### Soak

Long test under reasonable load.

`target`: 3,000
`operationcount`: 50,000,000

### Stress

No target throughput (as fast as the database can process queries).

`operationcount:` 10,000,000

Unfortunate limitation: Postgres deadlocks will multiple YCSB threads, so we are restricted to just 1 YCSB thread.

For Scylla, use 25 threads.

### Spike

Simulate small to large load sizes.

Postgres: custom pgbench script with 8 -> 75 -> 8 -> 100 client connections, each sending 1000 transactions.

Scylla: cassandra-stress 4 -> 104 -> 204 -> 304 -> 404 threads

### Vertical Scaling

For both Postgres and Scylla: run against `n2d-standard-2`, `n2d-standard-4`, and `n2d-standard-8`. These VMs have (2 vCPUs, 8GB RAM), (4 vCPUs, 16GB RAM), and (8 vCPUs, 32GB RAM) respectively.

Postgres: pgbench with 8 client connections, 5000 transactions per client

Scylla: cassandra-stress with 1,000,000 writes, followed by 1,000,000 reads

### Horizontal Scaling

Create a cluster of Scylla nodes and observe read and write performance for 1, 2, and 3 total nodes.

### ScyllaDB Cloud

To supplement our lacking dashboards, provision a trial Scylla cluster of 3 nodes, all with 2 vCPUs and 16GB RAM.

Run default cassandra-stress benchmark with the increasing thread count (4 -> 104 -> 204 -> 304 -> 404) and specifically observe caching behavior from the integrated Grafana dashboard.
