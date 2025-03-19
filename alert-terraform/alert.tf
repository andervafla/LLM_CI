terraform {
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = ">= 2.9.0"
    }
  }
}

provider "grafana" {
  url  = "http://:3000"
  auth = ""
}

data "grafana_data_source" "existing" {
  name = "prometheus"
}

resource "grafana_folder" "alert_folder" {
  title = "EC2 Alerts"
}

resource "grafana_contact_point" "slack" {
  name = "Slack Notifications"

  slack {
    url       = "https://"  
    recipient = "#alert-test"  
  }
}

resource "grafana_notification_policy" "slack_policy" {
  group_by      = ["alertname"]
  contact_point = grafana_contact_point.slack.name

  group_wait      = "30s"
  group_interval  = "5m"
  repeat_interval = "4h"

  policy {
    matcher {
      label = "alertname"
      match = "=~"
      value = ".*"
    }
  }
}



resource "grafana_rule_group" "ec2_alert_rules" {
  name             = "EC2 Alert Rules"
  folder_uid       = grafana_folder.alert_folder.uid
  interval_seconds = 60

  rule {
    name      = "[llm]-[test]-[ec2]-[low]-[cpu]"
    condition = "C"
    for       = "5m"

    data {
      ref_id = "A"
      relative_time_range {
        from = 600
        to   = 0
      }
      datasource_uid = data.grafana_data_source.existing.uid
      model = jsonencode({
        expr         = "(1 - avg by (instance) (rate(node_cpu_seconds_total{mode=\"idle\"}[5m]))) * 100",
        intervalMs    = 1000,
        maxDataPoints = 43200,
        refId         = "A"
      })
    }

    data {
      datasource_uid = "__expr__"
      ref_id         = "B"
      relative_time_range {
        from = 0
        to   = 0
      }
      model = jsonencode({
        type       = "reduce",
        expression = "A",
        reducer    = "mean",
        refId      = "B"
      })
    }

    data {
      datasource_uid = "__expr__"
      ref_id         = "C"
      relative_time_range {
        from = 0
        to   = 0
      }
      model = jsonencode({
        type       = "math",
        expression = "$B < 20",
        refId      = "C"
      })
    }
  }


  rule {
    name      = "[llm]-[test]-[ec2]-[high]-[cpu]"
    condition = "C"
    for       = "5m"

    data {
      ref_id = "A"
      relative_time_range {
        from = 600
        to   = 0
      }
      datasource_uid = data.grafana_data_source.existing.uid
      model = jsonencode({
        expr         = "(1 - avg by (instance) (rate(node_cpu_seconds_total{mode=\"idle\"}[5m]))) * 100",
        intervalMs    = 1000,
        maxDataPoints = 43200,
        refId         = "A"
      })
    }

    data {
      datasource_uid = "__expr__"
      ref_id         = "B"
      relative_time_range {
        from = 0
        to   = 0
      }
      model = jsonencode({
        type       = "reduce",
        expression = "A",
        reducer    = "mean",
        refId      = "B"
      })
    }

    data {
      datasource_uid = "__expr__"
      ref_id         = "C"
      relative_time_range {
        from = 0
        to   = 0
      }
      model = jsonencode({
        type       = "math",
        expression = "$B > 80",
        refId      = "C"
      })
    }
  }


  rule {
    name      = "[llm]-[test]-[ec2]-[low]-[memory]"
    condition = "C"
    for       = "5m"

    data {
      ref_id = "A"
      relative_time_range {
        from = 600
        to   = 0
      }
      datasource_uid = data.grafana_data_source.existing.uid
      model = jsonencode({
        expr         = "100 * (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes))",
        intervalMs    = 1000,
        maxDataPoints = 43200,
        refId         = "A"
      })
    }
  
    data {
      datasource_uid = "__expr__"
      ref_id         = "B"
      relative_time_range {
        from = 0
        to   = 0
      }
      model = jsonencode({
        type       = "reduce",
        expression = "A",
        reducer    = "mean",
        refId      = "B"
      })
    }
  
    data {
      datasource_uid = "__expr__"
      ref_id         = "C"
      relative_time_range {
        from = 0
        to   = 0
      }
      model = jsonencode({
        type       = "math",
        expression = "$B < 30",
        refId      = "C"
      })
    }
  }

  rule {
    name      = "[llm]-[test]-[ec2]-[high]-[memory]"
    condition = "C"
    for       = "5m"
  
    data {
      ref_id = "A"
      relative_time_range {
        from = 600
        to   = 0
      }
      datasource_uid = data.grafana_data_source.existing.uid
      model = jsonencode({
        expr         = "100 * (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes))",
        intervalMs    = 1000,
        maxDataPoints = 43200,
        refId         = "A"
      })
    }
  
    data {
      datasource_uid = "__expr__"
      ref_id         = "B"
      relative_time_range {
        from = 0
        to   = 0
      }
      model = jsonencode({
        type       = "reduce",
        expression = "A",
        reducer    = "mean",
        refId      = "B"
      })
    }
  
    data {
      datasource_uid = "__expr__"
      ref_id         = "C"
      relative_time_range {
        from = 0
        to   = 0
      }
      model = jsonencode({
        type       = "math",
        expression = "$B > 90",
        refId      = "C"
      })
    }
  }

rule {
  name      = "[llm]-[test]-[ec2]-[low]-[disk-space]"
  condition = "C"
  for       = "5m"

  data {
    ref_id = "A"
    relative_time_range {
      from = 600
      to   = 0
    }
    datasource_uid = data.grafana_data_source.existing.uid
    model = jsonencode({
      expr         = "100 * (1 - (node_filesystem_free_bytes{instance=\"ip-10-0-3-172\", job=\"integrations/unix\", device=\"/dev/root\"} / node_filesystem_size_bytes{instance=\"ip-10-0-3-172\", job=\"integrations/unix\", device=\"/dev/root\"}))",
      intervalMs    = 1000,
      maxDataPoints = 43200,
      refId         = "A"
    })
  }

  data {
    datasource_uid = "__expr__"
    ref_id         = "B"
    relative_time_range {
      from = 0
      to   = 0
    }
    model = jsonencode({
      type       = "reduce",
      expression = "A",
      reducer    = "mean",
      refId      = "B"
    })
  }

  data {
    datasource_uid = "__expr__"
    ref_id         = "C"
    relative_time_range {
      from = 0
      to   = 0
    }
    model = jsonencode({
      type       = "math",
      expression = "$B < 20",
      refId      = "C"
    })
  }
}

rule {
  name      = "[llm]-[test]-[ec2]-[high]-[disk-space]"
  condition = "C"
  for       = "5m"

  data {
    ref_id = "A"
    relative_time_range {
      from = 600
      to   = 0
    }
    datasource_uid = data.grafana_data_source.existing.uid
    model = jsonencode({
      expr         = "100 * (1 - (node_filesystem_free_bytes{instance=\"ip-10-0-3-172\", job=\"integrations/unix\", device=\"/dev/root\"} / node_filesystem_size_bytes{instance=\"ip-10-0-3-172\", job=\"integrations/unix\", device=\"/dev/root\"}))",
      intervalMs    = 1000,
      maxDataPoints = 43200,
      refId         = "A"
    })
  }

  data {
    datasource_uid = "__expr__"
    ref_id         = "B"
    relative_time_range {
      from = 0
      to   = 0
    }
    model = jsonencode({
      type       = "reduce",
      expression = "A",
      reducer    = "mean",
      refId      = "B"
    })
  }

  data {
    datasource_uid = "__expr__"
    ref_id         = "C"
    relative_time_range {
      from = 0
      to   = 0
    }
    model = jsonencode({
      type       = "math",
      expression = "$B > 90",
      refId      = "C"
    })
  }
}

}

