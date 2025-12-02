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

### Compare VM Sizes (Cost comparison)

Run database specific benchmarking (`pgbench` and `cassandra-stress`) against multiple sizes of VMs to compare cost to performance.

#### Vertical Scaling

For both Postgres and Scylla: run against `n2d-standard-2`, `n2d-standard-4`, and `n2d-standard-8`. These VMs have (2 vCPUs, 8GB RAM), (4 vCPUs, 16GB RAM), and (8 vCPUs, 32GB RAM) respectively.

#### Horizontal Scaling

Create a cluster of Scylla nodes and observe read and write performance for 1, 2, and 3 total nodes.
