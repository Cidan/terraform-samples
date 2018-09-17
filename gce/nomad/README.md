# Nomad on GCE
A set of terraform configuration files and scripts to bootstrap a Nomad cluster from scratch on GCE.

## Usage

    terraform init
    terraform apply -var project=... \ 
      -var nomad-client-type=n1-standard-8 \
      -var nomad-client-count=8

The above command will bootstrap an 8 node Nomad cluster, with 5 dedicated Consul master servers, and 5 dedicated Nomad master servers, 18 servers total.

## Implementation

The terraform scripts setup 5 Consul and Nomad servers of n1-standard-1 size, and N number of Nomad client servers (defaut: 4) of n1-standard-8 size. The entire cluster launches on us-central1 with multi-zonal placement for both servers and clients.

Consul uses the new cloud auto-join method of detecting peer servers, thus all servers are configured with minimal IAM service account scopes to allow read-only access to GCE. The "datacenter" configuration paramenter for both Consul and Nomad are configured to use us-central1.