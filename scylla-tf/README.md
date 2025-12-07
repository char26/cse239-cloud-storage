# Scylla Horizontal Scaling Test

Note: this is a last minute addition to this project and has not yet been made easily reproducible.

After creating the nodes, after ssh:

Node 1:

```sh
cat /etc/scylla/scylla.yaml
```

All other nodes:

```sh
sudo nano /etc/scylla/scylla.yaml
```

Replace `cluster_name` with the cluster name of Node 1

Replace `seeds` with the seed from Node 1.

Then run

```sh
sudo systemctl restart scylla-server
```
