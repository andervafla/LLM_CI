
terraform {
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "~> 1.0"  # або актуальну версію
    }
  }
}

provider "grafana" {
  url  = "http://<grafana-host>:3000"
  auth = "Bearer <YOUR_GRAFANA_API_KEY>"
}

resource "grafana_contact_point" "slack" {
  name = "My Slack Contact"

  slack {
    url       = "https://hooks.slack.com/services/TXXXXXXXX/BXXXXXXXX/XXXXXXXXXXXXXXXXXXXXXXXX"
    recipient = "#alerts-channel"
  }
}


resource "grafana_rule_group" "nginx_alerts" {
  folder_uid = "prometheus" 
  name       = "nginx-alerts"
  rules      = jsonencode([
    {
      alert       = "NginxNotActive"
      expr        = "node_systemd_unit_state{name=\"nginx.service\", state=\"active\"} < 1"
      for         = "1m"
      labels = {
        severity = "critical"
      }
      annotations = {
        summary     = "Nginx неактивний",
        description = "Перевірте стан сервісу nginx на сервері."
      }
    }
  ])
}

resource "grafana_notification_policy" "default" {
  // Вказуємо, до яких контактних точок будуть відправлятись сповіщення
  contact_points = [grafana_contact_point.slack.name]
  // group_by — як групувати alert (наприклад, за alertname)
  group_by = ["alertname"]
  // receivers — це список контактних точок, куди будуть надсилатись сповіщення
  receivers = [grafana_contact_point.slack.name]
}
