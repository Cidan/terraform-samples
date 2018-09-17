#!/bin/bash
set -e

SERVER=false
BOOTCOUNT=0
if [[ "$1" == "server" ]]; then
        SERVER=true
        BOOTCOUNT=5
fi

## TODO: guard each step so this is idempotent
apt-get update && apt-get install -y unzip

## TODO: Possibly get from GCS bucket?
curl -sq -o /tmp/consul.zip https://releases.hashicorp.com/consul/1.2.3/consul_1.2.3_linux_amd64.zip
cd /usr/local/bin && unzip -o /tmp/consul.zip

useradd consul || true
mkdir -p /etc/consul
mkdir -p /opt/consul && chown -R consul.consul /opt/consul
REGION=`curl -sq -H "Metadata-Flavor: Google"  http://metadata.google.internal/computeMetadata/v1/instance/zone | cut -d '/' -f 4 | cut -d '-' -f 1-2`

## TODO: encryption of gossip
## TODO: encryption of RPC (TLS CA?)

cat >/etc/consul/consul.json << EOF
{
        "datacenter": "$REGION",
        "data_dir": "/opt/consul",
        "bootstrap_expect": $BOOTCOUNT,
        "server": $SERVER,
        "ui": true,
        "retry_join": ["provider=gce tag_value=consul-nomad zone_pattern=$REGION.*"],
        "retry_interval_wan": "5s"
}
EOF

cat >/etc/systemd/system/consul.service << EOF
[Unit]
Description=Consul Service
After=network.target

[Service]
Type=simple
User=consul
ExecStart=/usr/local/bin/consul agent -config-file=/etc/consul/consul.json
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl enable consul
systemctl start consul