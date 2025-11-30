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
  postgresql://postgres:changeme@10.128.0.30:5433/test \
  -c "TRUNCATE TABLE usertable;"
```
