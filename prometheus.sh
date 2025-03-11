
wget https://github.com/prometheus/prometheus/releases/download/v2.53.3/prometheus-2.53.3.linux-amd64.tar.gz

tar -xvzf prometheus-2.53.3.linux-amd64.tar.gz
sudo mv prometheus-2.53.3.linux-amd64 /usr/local/prometheus

sudo useradd --no-create-home --shell /bin/false prometheus

sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus

sudo cp /usr/local/prometheus/prometheus /usr/local/bin/
sudo cp /usr/local/prometheus/promtool /usr/local/bin/
sudo cp -r /usr/local/prometheus/consoles /etc/prometheus
sudo cp -r /usr/local/prometheus/console_libraries /etc/prometheus

sudo nano /etc/prometheus/prometheus.yml

global:
  scrape_interval: 15s  

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'grafana-agent'
    static_configs:
      - targets: ['asg-instance-1:9100', 'asg-instance-2:9100'] 


sudo chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus
sudo chmod -R 775 /etc/prometheus /var/lib/prometheus


sudo nano /etc/systemd/system/prometheus.service

[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus/ \
  --web.listen-address=0.0.0.0:9090 \
  --web.enable-lifecycle

Restart=always

[Install]
WantedBy=multi-user.target


sudo systemctl daemon-reload
sudo systemctl enable prometheus
sudo systemctl start prometheus
