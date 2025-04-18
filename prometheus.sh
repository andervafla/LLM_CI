
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
  --web.listen-address=:9090 \
  --web.enable-remote-write-receiver


Restart=always

[Install]
WantedBy=multi-user.target


sudo systemctl daemon-reload
sudo systemctl enable prometheus
sudo systemctl start prometheus



// Sample config for Grafana Agent Flow.
//
// For a full configuration reference, see https://grafana.com/docs/agent/latest/flow/
logging {
  level = "warn"
}

prometheus.exporter.unix "default" {
  include_exporter_metrics = true
  disable_collectors       = ["mdadm"]
}

prometheus.scrape "default" {
  targets = concat(
   prometheus.exporter.unix.default.targets,
   [{
    // Self-collect metrics
    job         = "agent",
    __address__ = "127.0.0.1:12345",
   }],
  )

  forward_to = [prometheus.remote_write.default.receiver]
}


prometheus.remote_write "default" {
  endpoint {
    url = "http://3.81.60.209:9090/api/v1/write"
  }
}

prometheus.remote_write "default" {
  endpoint {
    url = "http://0.0.0.0:12345/api/v1/write"
  }
}

 2 вар 


logging {
  level = "info"
}

prometheus.exporter.unix "default" {
  include_exporter_metrics = true
}

prometheus.scrape "default" {
  targets = prometheus.exporter.unix.default.targets
  forward_to = [prometheus.remote_write.default.receiver]
}

prometheus.remote_write "default" {
  endpoint {
    url = "http://3.81.60.209:9090/api/v1/write"
  }
}


// Sample config for Grafana Agent Flow.
//
// For a full configuration reference, see https://grafana.com/docs/agent/latest/flow/
logging {
  level = "warn"
}

prometheus.exporter.unix "default" {
  include_exporter_metrics = true
  disable_collectors       = ["mdadm"]
}

prometheus.scrape "default" {
  targets = concat(
   prometheus.exporter.unix.default.targets,
   [{
    // Self-collect metrics
    job         = "agent",
    __address__ = "127.0.0.1:12345",
   }],
  )

  forward_to = [
  // TODO: components to forward metrics to (like prometheus.remote_write or
  // prometheus.relabel).
  ]
}

працює 

logging {
  level = "info"
}

prometheus.exporter.unix "default" {
  include_exporter_metrics = true
  enable_collectors = ["systemd"]
}

prometheus.scrape "default" {
  targets = prometheus.exporter.unix.default.targets
  forward_to = [prometheus.remote_write.default.receiver]
}

prometheus.remote_write "default" {
  endpoint {
    url = "http://18.206.215.29:9090/api/v1/write"
  }
}

[Unit]
Description=A high performance web server and a reverse proxy server
Documentation=man:nginx(8)
After=network-online.target remote-fs.target nss-lookup.target
Wants=network-online.target

[Service]
Type=forking
PIDFile=/run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t -q -g 'daemon on; master_process on;'
ExecStart=/usr/sbin/nginx -g 'daemon on; master_process on;'
ExecReload=/usr/sbin/nginx -g 'daemon on; master_process on;' -s reload
ExecStop=-/sbin/start-stop-daemon --quiet --stop --retry QUIT/5 --pidfile /run/nginx.pid
TimeoutStopSec=5
KillMode=mixed


[Install]
WantedBy=multi-user.target


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
    url = "http://18.234.29.54:9090/api/v1/write"
  }
}
#