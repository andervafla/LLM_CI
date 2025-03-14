#!/bin/bash
set -e

sudo apt-get update -y
sudo apt-get install -y wget

wget https://github.com/prometheus/prometheus/releases/download/v2.53.3/prometheus-2.53.3.linux-amd64.tar.gz
tar -xvzf prometheus-2.53.3.linux-amd64.tar.gz
sudo mv prometheus-2.53.3.linux-amd64 /usr/local/prometheus

sudo useradd --no-create-home --shell /bin/false prometheus

sudo mkdir -p /etc/prometheus /var/lib/prometheus

sudo cp /usr/local/prometheus/prometheus /usr/local/bin/
sudo cp /usr/local/prometheus/promtool /usr/local/bin/
sudo cp -r /usr/local/prometheus/consoles /etc/prometheus
sudo cp -r /usr/local/prometheus/console_libraries /etc/prometheus

cat <<EOF | sudo tee /etc/prometheus/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
EOF

sudo chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus
sudo chmod -R 775 /etc/prometheus /var/lib/prometheus

cat <<EOF | sudo tee /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus --config.file=/etc/prometheus/prometheus.yml --storage.tsdb.path=/var/lib/prometheus/ --web.listen-address=:9090 --web.enable-remote-write-receiver
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable prometheus


sudo apt-get install -y apt-transport-https software-properties-common wget

sudo mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null

echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list

sudo apt-get update

sudo apt-get install grafana -y

sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable grafana-server

sudo /bin/systemctl start grafana-server


sudo snap install amazon-ssm-agent --classic

sudo snap list amazon-ssm-agent

sudo snap start amazon-ssm-agent

sudo snap services amazon-ssm-agent