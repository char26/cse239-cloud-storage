# Benchmarking Methods

## VM Setup

For simplicity and "fairness" (though this test is not necessarily fair), we will start with just a single Scylla node on the same size VM as a Postgres instance. We should consider additional Scylla nodes after recording primary benchmarks.

## YCSB

All tests should be run against a database loaded with 10,000,000 records.
`recordcount`: 10,000,000

Operation count effectively controls how long the test runs for.

### Load (and Simulated Growth)

View latency patterns across normal loads.

Targeted throughput can simulate any number of operations per second.

`target`: 100, 200, 500, 1000, 2500, 5,000, 10,000
`operationcount`: 1,000,000

### Soak

Long test under reasonable load.

`target`: 3,000 (?)
`operationcount`: 50,000,000

### Stress

Many threads, medium operation count, no target throughput (unlimited)

### Compare VM Sizes (Cost comparison)

Run stress test against multiple VM sizes for Postgres and Scylla

Postgres has its own GCP service with built-in auto scaling, but that wouldn't be much of a comparison since Scylla doesn't.
