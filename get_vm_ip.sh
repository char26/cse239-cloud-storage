#!/bin/bash
vm_name=$1
if [ -z "$vm_name" ]; then
    echo "Usage: $0 <vm_name>"
    exit 1
fi
jq -r '.resources[] | select(.type=="google_compute_instance") | .instances[] | select(.attributes.name=="'$vm_name'") | .attributes.network_interface[0].access_config[0].nat_ip' databases-tf/terraform.tfstate.backup
