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

## Additional Expectations

Each project must include:

- Functional implementation of a distributed service or system prototype.
- Non-functional performance evaluation: efficiency, scalability, reliability, and cost-performance
  trade-offs.
- Benchmarking using K6, ApacheBench, JMeter, or equivalent.
  - Load, stress, spike, and soak testing to evaluate system stability and bottlenecks.
- System profiling and visualization (CPU, memory, storage, network, scaling behavior, request
  throughput, average and tail latencies, etc.).
  - Monitoring and dashboards using tools like Grafana, Prometheus, or GCP Cloud Monitoring.
- Load balancing and auto-scaling (horizontal and/or vertical).
- Dramatization of the system: a clear narrative or visualization of how the system behaves
  under load, scales, and reacts to failures.

## Cross-team Deployment

By the project presentation week, each team must exchange deployment materials (i.e., the Git
repository with detailed instructions) with another group. Each group will attempt to deploy the
other’s project using Minikube, Kind, or the free Nautilus testbed.
This exercise assesses the reproducibility and deployment simplicity of your system. Each peer
group should provide a testimonial describing how easy or difficult the deployment process was.
This testimonial will be included in the Discussion section of your report (see guidelines below).
