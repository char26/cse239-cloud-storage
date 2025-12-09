# Postgres Insert

```sh
docker run -it char26/ycsb ./insert_postgres.sh <ip_address> -t 1
```

```
[OVERALL], RunTime(ms), 5,113,288
[OVERALL], Throughput(ops/sec), 1,955.69

[TOTAL_GCS_PS_Scavenge], Count, 22,989
[TOTAL_GC_TIME_PS_Scavenge], Time(ms), 17,802
[TOTAL_GC_TIME_%_PS_Scavenge], Time(%), 0.348
[TOTAL_GCS_PS_MarkSweep], Count, 1
[TOTAL_GC_TIME_PS_MarkSweep], Time(ms), 10
[TOTAL_GC_TIME_%_PS_MarkSweep], Time(%), 0.0002
[TOTAL_GCs], Count, 22,990
[TOTAL_GC_TIME], Time(ms), 17,812
[TOTAL_GC_TIME_%], Time(%), 0.35

[CLEANUP], Operations, 1
[CLEANUP], AverageLatency(us), 271
[CLEANUP], MinLatency(us), 271
[CLEANUP], MaxLatency(us), 271
[CLEANUP], 95thPercentileLatency(us), 271
[CLEANUP], 99thPercentileLatency(us), 271

[INSERT], Operations, 10,000,000
[INSERT], AverageLatency(us), 509.26
[INSERT], MinLatency(us), 290
[INSERT], MaxLatency(us), 358,911
[INSERT], 95thPercentileLatency(us), 599
[INSERT], 99thPercentileLatency(us), 1,803
[INSERT], Return=OK, 10,000,000
```

![](../screenshots/ycsb_insert_postgres.jpg)

Postgres appears stuck at only 25% CPU utilization. This is likely due to the concurrency issue we ran into with YCSB, where it does not open multiple connections.
