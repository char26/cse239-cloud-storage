# YCSB Benchmark Script Commands

## Universal YCSB script

```sh
docker run -it char26/ycsb ./run_ycsb.sh [database] [workload] -i [ip_addr] -r [record_count] -o [operation_count] -t [threads]
```

## Insert scripts

### Postgres

```sh
docker run -it char26/ycsb ./insert_postgres.sh [ip_addr] -r [record_count] -t [threads]
```

### Scylla

```sh
docker run -it char26/ycsb ./insert_scylla.sh [ip_addr] -r [record_count] -t [threads]
```

## Load Test

```sh
docker run -it char26/ycsb ./run_load.sh [database] [ip_addr] -t [threads]
```

## Soak Test

```sh
docker run -it char26/ycsb ./run_soak.sh [database] [ip_addr] -t [threads] -o [operation_count]
```

## Stress Test

```sh
docker run -it char26/ycsb ./run_stress.sh [database] [ip_addr] -t [threads] -o [operation_count]
```
