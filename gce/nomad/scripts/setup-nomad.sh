#!/bin/bash
set -e

SERVER=false
CLIENT=true
BOOTCOUNT=0
if [[ "$1" == "server" ]]; then
        SERVER=true
        CLIENT=false
        BOOTCOUNT=5
fi

## TODO: guard each step so this is idempotent

## Install Docker
apt-get update && apt-get install -y unzip

if [[ "$CLIENT" == "true" ]]; then

apt-get update && apt-get install -y \
     unzip \
     apt-transport-https \
     ca-certificates \
     curl \
     gnupg2 \
     software-properties-common
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"

## TODO: pin version of docker
apt-get update && apt-get install -y docker-ce
fi

## TODO: Possibly get from GCS bucket?
curl -sq -o /tmp/nomad.zip https://releases.hashicorp.com/nomad/0.8.5/nomad_0.8.5_linux_amd64.zip
cd /usr/local/bin && unzip -o /tmp/nomad.zip

useradd nomad || true
mkdir -p /etc/nomad
mkdir -p /opt/nomad && chown -R nomad.nomad /opt/nomad
REGION=`curl -sq -H "Metadata-Flavor: Google"  http://metadata.google.internal/computeMetadata/v1/instance/zone | cut -d '/' -f 4 | cut -d '-' -f 1-2`

## TODO: encryption of gossip
## TODO: encryption of RPC (TLS CA?)

cat >/etc/nomad/nomad.json << EOF
{
        "data_dir": "/opt/nomad",
        "datacenter": "$REGION",
        "bind_addr": "0.0.0.0",
        "server": {
                "enabled": $SERVER,
                "bootstrap_expect": $BOOTCOUNT
        },
        "client": {
                "enabled": $CLIENT
        }
        "consul": {
                "address": "127.0.0.1:8500"
        }
        "ui": true
}
EOF

cat >/etc/systemd/system/nomad.service << EOF
[Unit]
Description=Consul Service
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/nomad agent -config=/etc/nomad/nomad.json
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl enable nomad
systemctl start nomad