The hardware configuration used as a baseline in our tests (n2d-standard-2) incurs a monthly cost of roughly $61.63. For every double in vCPUs and memory (e.g., n2d-standard-2 to n2d-standard-4), the monthly cost also doubles.

When vertically scaling Postgres, we see a throughput speedup of 1.14x when going from 2 to 4 vCPUs and 8 to 16GB of RAM, and a cost increase of 2x. From 2 to 8 vCPUs and 8 to 32GB of RAM, we see a speedup of 1.74x and a cost increase of 4x. Vertical scaling is common practice for Postgres instances, but the cost does not scale linearly with throughput from our testing.

When horizontally scaling Scylla nodes, we noticed that 1 to 2 nodes showed minimal improvement while incurring twice the monthly cost. On the other end, scaling Scylla from 2 to 3 nodes yielded 1.42x throughput speedup for 1.5x the monthly cost. This was the most cost effective upgrade from our tests.

In terms of raw throughput and latency, Scylla performed significantly better for less resources than Postgres in our testing.

Both databases showed resilence by never failing a single query in any of our tests. Scaling is only necessary once latency metrics begin to surge. Different applications may have different thresholds for when latency is too high. For example, a responsive application making a database call that the end user will notice requires very low latency (sub 10ms), where an application querying a database for some batch jobs may tolerate a much higher latency. The only real answer for "when should we scale?" is: it depends.

For our project, we were very diligent with the resources we used. Thanks to Terraform and careful planning, we consumed only $9.09 of our $50 budget.
