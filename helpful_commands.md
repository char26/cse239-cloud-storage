View the logs of a GCP VM startup script

```sh
sudo journalctl -u google-startup-scripts.service
```

Run script again

```sh
sudo google_metadata_script_runner startup
```
