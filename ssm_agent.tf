resource "aws_ssm_document" "grafana_setup" {
  name          = "grafana-setup-script"
  document_type = "Command"

  content = <<EOF
{
  "schemaVersion": "2.2",
  "description": "Install Grafana Agent and configure remote write",
  "mainSteps": [
    {
      "action": "aws:runShellScript",
      "name": "runShellScript",
      "inputs": {
        "runCommand": [
          "#!/bin/bash",
          "sudo mkdir -p /etc/apt/keyrings/",
          "wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null",
          "echo \"deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main\" | sudo tee /etc/apt/sources.list.d/grafana.list",
          "sudo apt-get update",
          "sudo apt-get install -y grafana-agent-flow",
          "sudo tee /etc/grafana-agent-flow.river > /dev/null <<EOF",

          "logging {",
          "  level = \"info\"",
          "}",
          "prometheus.exporter.unix \"default\" {",
          "  include_exporter_metrics = true",
          "  enable_collectors = [\"systemd\"]",
          "}",
          "prometheus.scrape \"default\" {",
          "  scrape_interval = \"15s\"",
          "  scrape_timeout  = \"10s\"",
          "  targets = prometheus.exporter.unix.default.targets",
          "  forward_to = [prometheus.remote_write.default.receiver]",
          "}",
          "prometheus.remote_write \"default\" {",
          "  endpoint {",
          "    url = \"http://:9090/api/v1/write\"",
          "  }",
          "}",
          "EOF",
          "sudo systemctl restart grafana-agent"
        ]
      }
    }
  ]
}
EOF
}

resource "aws_ssm_association" "llm_association" {
  name           = aws_ssm_document.grafana_setup.name

  targets {
    key    = "tag:aws:autoscaling:groupName"
    values = [aws_autoscaling_group.asg.name]
  }
}




