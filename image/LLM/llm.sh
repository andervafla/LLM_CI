#!/bin/bash

set -e 

curl -fsSL https://ollama.com/install.sh | sh
ollama pull llama3.2:1b

sleep 15

sudo apt update && sudo apt install npm python3-pip python3-venv git -y

git clone https://github.com/open-webui/open-webui.git
cd open-webui

cp .env.example .env

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

nvm install 22
nvm use 22
npm install -g npm@latest

npm install
npm run build

cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt -U

sudo mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee /etc/apt/sources.list.d/grafana.list

sudo apt-get update

sudo apt-get install grafana-agent-flow

sudo tee /etc/grafana-agent-flow.river > /dev/null <<EOF
node_systemd_unit_state{name="nginx.service"}

logging {
  level = "info"
}

prometheus.exporter.unix "default" {
  include_exporter_metrics = true
  enable_collectors = ["systemd"]  // Включаємо колектор systemd для збору метрик сервісів
}

prometheus.scrape "default" {
  scrape_interval = "15s"
  scrape_timeout  = "10s"
  targets = prometheus.exporter.unix.default.targets
  forward_to = [prometheus.remote_write.default.receiver]
}

prometheus.remote_write "default" {
  endpoint {
    url = "http://:9090/api/v1/write"
  }
}
EOF
