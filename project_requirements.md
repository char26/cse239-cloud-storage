# 3.3 Project 3: Cloud Storage Performance Evaluation

## Goal

Evaluate database performance trade-offs across SQL and NoSQL systems.

## Description

Students will design an application requiring persistent data storage and compare
relational (MySQL) and non-relational (MongoDB, HBase) performance under realistic query work-
loads, comparing a SQL (MySQL) against a NoSQL (MongoDB, HBase) database performance and
evaluating the read/write latency, throughput, scaling cost, and storage behavior.

## Requirements

- Implement CRUD-heavy and analytics-heavy workloads.
- Measure query throughput, read/write latency, storage cost, and scaling efficiency subject to
  the YCSB workload (https://github.com/brianfrankcooper/YCSB)
- Simulate load growth and analyze cost vs. performance scaling behavior.
- Use monitoring tools to observe I/O and caching patterns.

## Deliverables

A Git repository containing:

- Application design and workload description.
- Dockerfiles and deployment manifests.
- Query benchmarking results (load, stress, soak).
- Performance-cost trade-off analysis.
- Dashboard screenshots with observed patterns.
