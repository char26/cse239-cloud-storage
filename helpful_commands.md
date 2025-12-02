View the logs of a GCP VM startup script

```sh
sudo journalctl -u google-startup-scripts.service
```

Run script again

```sh
sudo google_metadata_script_runner startup
```

Build and push YCSB Dockerfile

```sh
docker build --platform linux/amd64 -t ycsb .
docker tag ycsb:latest char26/ycsb:latest
docker push char26/ycsb:latest
```

Truncate Postgres YCSB table

```sh
docker run --rm postgres:9.6 psql \
  postgresql://postgres:changeme@<ip_address>:5433/test \
  -c "TRUNCATE TABLE usertable;"
```

pgbench run command

```sh
docker run -e PGPASSWORD=changeme --rm postgres:9.6 pgbench -h <ip_address> -p 5433 -U postgres -d test --client 30 --jobs 8 --transactions 5000
```
