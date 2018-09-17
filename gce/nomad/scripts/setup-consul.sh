#!/bin/bash
set -e

## TODO: guard each step so this is idempotent

curl -s -o /tmp/consul.zip https://releases.hashicorp.com/consul/1.2.3/consul_1.2.3_linux_amd64.zip
useradd consul || true
mkdir -p /etc/consul
mkdir -p /opt/consul && chown -R consul.consul /opt/consul
REGION=`curl -sq -H "Metadata-Flavor: Google"  http://metadata.google.internal/computeMetadata/v1/instance/zone | cut -d '/' -f 4 | cut -d '-' -f 1-2`

cat >/etc/consul/consul.json << EOF
{
        "datacenter": "$REGION",
        "data_dir": "/opt/consul",
        "bootstrap_expect": 5,
        "server": true,
        "ui": true,
        "retry_join": ["provider=gce tag_value=consul-nomad zone_pattern=$REGION.*"]
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