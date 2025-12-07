4 threads

```
Results:
Op rate : 15,064 op/s [READ: 15,064 op/s]
Partition rate : 15,064 pk/s [READ: 15,064 pk/s]
Row rate : 15,064 row/s [READ: 15,064 row/s]
Latency mean : 0.3 ms [READ: 0.3 ms]
Latency median : 0.2 ms [READ: 0.2 ms]
Latency 95th percentile : 0.3 ms [READ: 0.3 ms]
Latency 99th percentile : 0.5 ms [READ: 0.5 ms]
Latency 99.9th percentile : 2.1 ms [READ: 2.1 ms]
Latency max : 10.8 ms [READ: 10.8 ms]
Total partitions : 1,000,000 [READ: 1,000,000]
Total errors : 0 [READ: 0]
Total GC count : 0
Total GC memory : 0.000 KiB
Total GC time : 0.0 seconds
Avg GC time : NaN ms
StdDev GC time : 0.0 ms
Total operation time : 00:01:06
```

104 threads

```
Results:
Op rate : 53,470 op/s [READ: 53,470 op/s]
Partition rate : 53,470 pk/s [READ: 53,470 pk/s]
Row rate : 53,470 row/s [READ: 53,470 row/s]
Latency mean : 1.9 ms [READ: 1.9 ms]
Latency median : 1.6 ms [READ: 1.6 ms]
Latency 95th percentile : 3.6 ms [READ: 3.6 ms]
Latency 99th percentile : 5.8 ms [READ: 5.8 ms]
Latency 99.9th percentile : 16.0 ms [READ: 16.0 ms]
Latency max : 493.4 ms [READ: 493.4 ms]
Total partitions : 1,000,000 [READ: 1,000,000]
Total errors : 0 [READ: 0]
Total GC count : 0
Total GC memory : 0.000 KiB
Total GC time : 0.0 seconds
Avg GC time : NaN ms
StdDev GC time : 0.0 ms
Total operation time : 00:00:18

Improvement over 4 threadCount: 255%
```

204

```
Results:
Op rate : 54,712 op/s [READ: 54,712 op/s]
Partition rate : 54,712 pk/s [READ: 54,712 pk/s]
Row rate : 54,712 row/s [READ: 54,712 row/s]
Latency mean : 3.6 ms [READ: 3.6 ms]
Latency median : 2.9 ms [READ: 2.9 ms]
Latency 95th percentile : 7.0 ms [READ: 7.0 ms]
Latency 99th percentile : 10.9 ms [READ: 10.9 ms]
Latency 99.9th percentile : 23.1 ms [READ: 23.1 ms]
Latency max : 640.7 ms [READ: 640.7 ms]
Total partitions : 1,000,000 [READ: 1,000,000]
Total errors : 0 [READ: 0]
Total GC count : 0
Total GC memory : 0.000 KiB
Total GC time : 0.0 seconds
Avg GC time : NaN ms
StdDev GC time : 0.0 ms
Total operation time : 00:00:18

Improvement over 104 threadCount: 2%
```

304

```
Results:
Op rate                   :   61,507 op/s  [READ: 61,507 op/s]
Partition rate            :   61,507 pk/s  [READ: 61,507 pk/s]
Row rate                  :   61,507 row/s [READ: 61,507 row/s]
Latency mean              :    4.8 ms [READ: 4.8 ms]
Latency median            :    4.2 ms [READ: 4.2 ms]
Latency 95th percentile   :   10.3 ms [READ: 10.3 ms]
Latency 99th percentile   :   15.6 ms [READ: 15.6 ms]
Latency 99.9th percentile :   27.6 ms [READ: 27.6 ms]
Latency max               :   59.3 ms [READ: 59.3 ms]
Total partitions          :  1,000,000 [READ: 1,000,000]
Total errors              :          0 [READ: 0]
Total GC count            : 0
Total GC memory           : 0.000 KiB
Total GC time             :    0.0 seconds
Avg GC time               :    NaN ms
StdDev GC time            :    0.0 ms
Total operation time      : 00:00:16

Improvement over 204 threadCount: 12%
```

404

```
Results:
Op rate                   :   46,488 op/s  [READ: 46,488 op/s]
Partition rate            :   46,488 pk/s  [READ: 46,488 pk/s]
Row rate                  :   46,488 row/s [READ: 46,488 row/s]
Latency mean              :    8.3 ms [READ: 8.3 ms]
Latency median            :    5.8 ms [READ: 5.8 ms]
Latency 95th percentile   :   14.7 ms [READ: 14.7 ms]
Latency 99th percentile   :   22.7 ms [READ: 22.7 ms]
Latency 99.9th percentile :  704.6 ms [READ: 704.6 ms]
Latency max               : 2533.4 ms [READ: 2,533.4 ms]
Total partitions          :  1,000,000 [READ: 1,000,000]
Total errors              :          0 [READ: 0]
Total GC count            : 0
Total GC memory           : 0.000 KiB
Total GC time             :    0.0 seconds
Avg GC time               :    NaN ms
StdDev GC time            :    0.0 ms
Total operation time      : 00:00:21

Improvement over 304 threadCount: -24%
```
