# Demo

Ideally have the infrastructure running before we present

```sh
cd terraform
echo "yes" | terraform apply
```

SSH into benchmark-vm

```sh
gcloud compute instances describe scylla-vm --zone us-central1-a --format='get(networkInterfaces[0].networkIP)'

gcloud compute ssh benchmark-vm --zone us-central1-a
```

Run workloada with 8 threads and 50,000 operations (50/50 read/updates) on a database with 10,000 records

```sh
docker run -it char26/ycsb ./run_ycsb.sh scylla workloada -i <SCYLLA_IP> -r 10000 -o 50000 -t 8
```
