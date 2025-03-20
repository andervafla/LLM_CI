#!/bin/bash

# Приймаємо IP адресу як параметр
MONITORING_IP=$1

# Перевірка, чи передана IP адреса
if [ -z "$MONITORING_IP" ]; then
  echo "Error: Monitoring IP address is missing!"
  exit 1
fi

# Встановлення Grafana Agent
sudo mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee /etc/apt/sources.list.d/grafana.list

sudo apt-get update
sudo apt-get install grafana-agent-flow

# Створення конфігураційного файлу для Grafana Agent
sudo tee /etc/grafana-agent-flow.river > /dev/null <<EOF
node_systemd_unit_state{name="nginx.service"}

logging {
  level = "info"
}

prometheus.exporter.unix "default" {
  include_exporter_metrics = true
  enable_collectors = ["systemd"]
}

prometheus.scrape "default" {
  scrape_interval = "15s"
  scrape_timeout  = "10s"
  targets = prometheus.exporter.unix.default.targets
  forward_to = [prometheus.remote_write.default.receiver]
}

prometheus.remote_write "default" {
  endpoint {
    url = "http://${MONITORING_IP}:9090/api/v1/write"
  }
}
EOF

# Перезапуск Grafana Agent
sudo systemctl restart grafana-agent
