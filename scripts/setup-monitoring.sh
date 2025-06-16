#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print status messages
print_status() {
    echo -e "${GREEN}==>${NC} $1"
}

print_error() {
    echo -e "${RED}Error:${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}Warning:${NC} $1"
}

# Check if running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    print_error "This script is designed for macOS only"
    exit 1
fi

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    print_error "This script should not be run as root"
    exit 1
fi

# Function to set up Prometheus
setup_prometheus() {
    print_status "Setting up Prometheus..."

    # Create Prometheus configuration
    mkdir -p ~/monitoring/prometheus
    cat > ~/monitoring/prometheus/prometheus.yml << 'EOL'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node'
    static_configs:
      - targets: ['localhost:9100']

  - job_name: 'cadvisor'
    static_configs:
      - targets: ['localhost:8080']
EOL

    # Start Prometheus
    prometheus --config.file=~/monitoring/prometheus/prometheus.yml &
}

# Function to set up Grafana
setup_grafana() {
    print_status "Setting up Grafana..."

    # Create Grafana configuration
    mkdir -p ~/monitoring/grafana
    cat > ~/monitoring/grafana/grafana.ini << 'EOL'
[server]
http_port = 3000
domain = localhost

[security]
admin_user = admin
admin_password = admin

[auth.anonymous]
enabled = true
org_role = Viewer
EOL

    # Start Grafana
    grafana-server --config ~/monitoring/grafana/grafana.ini &
}

# Function to set up Loki
setup_loki() {
    print_status "Setting up Loki..."

    # Create Loki configuration
    mkdir -p ~/monitoring/loki
    cat > ~/monitoring/loki/loki-config.yml << 'EOL'
auth_enabled: false

server:
  http_listen_port: 3100

ingester:
  lifecycler:
    address: 127.0.0.1
    ring:
      kvstore:
        store: inmemory
      replication_factor: 1
    final_sleep: 0s
  chunk_idle_period: 5m
  chunk_retain_period: 30s

schema_config:
  configs:
    - from: 2020-05-15
      store: boltdb
      object_store: filesystem
      schema: v11
      index:
        prefix: index_
        period: 168h

storage_config:
  boltdb:
    directory: /tmp/loki/index

  filesystem:
    directory: /tmp/loki/chunks

limits_config:
  enforce_metric_name: false
  reject_old_samples: true
  reject_old_samples_max_age: 168h
EOL

    # Start Loki
    loki -config.file=~/monitoring/loki/loki-config.yml &
}

# Function to set up Promtail
setup_promtail() {
    print_status "Setting up Promtail..."

    # Create Promtail configuration
    mkdir -p ~/monitoring/promtail
    cat > ~/monitoring/promtail/promtail-config.yml << 'EOL'
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /tmp/positions.yaml

clients:
  - url: http://localhost:3100/loki/api/v1/push

scrape_configs:
  - job_name: system
    static_configs:
      - targets:
          - localhost
        labels:
          job: varlogs
          __path__: /var/log/*log

  - job_name: journal
    journal:
      max_age: 12h
      labels:
        job: systemd-journal
    relabel_configs:
      - source_labels: ['__journal__systemd_unit']
        target_label: 'unit'
EOL

    # Start Promtail
    promtail -config.file=~/monitoring/promtail/promtail-config.yml &
}

# Function to set up Elasticsearch
setup_elasticsearch() {
    print_status "Setting up Elasticsearch..."

    # Create Elasticsearch configuration
    mkdir -p ~/monitoring/elasticsearch
    cat > ~/monitoring/elasticsearch/elasticsearch.yml << 'EOL'
cluster.name: monitoring-cluster
network.host: localhost
http.port: 9200
discovery.type: single-node
xpack.security.enabled: false
EOL

    # Start Elasticsearch
    elasticsearch -Epath.conf=~/monitoring/elasticsearch &
}

# Function to set up Kibana
setup_kibana() {
    print_status "Setting up Kibana..."

    # Create Kibana configuration
    mkdir -p ~/monitoring/kibana
    cat > ~/monitoring/kibana/kibana.yml << 'EOL'
server.host: localhost
elasticsearch.hosts: ["http://localhost:9200"]
EOL

    # Start Kibana
    kibana --config ~/monitoring/kibana/kibana.yml &
}

# Function to set up InfluxDB
setup_influxdb() {
    print_status "Setting up InfluxDB..."

    # Create InfluxDB configuration
    mkdir -p ~/monitoring/influxdb
    cat > ~/monitoring/influxdb/influxdb.conf << 'EOL'
[meta]
  dir = "/tmp/influxdb/meta"

[data]
  dir = "/tmp/influxdb/data"
  wal-dir = "/tmp/influxdb/wal"

[http]
  enabled = true
  bind-address = ":8086"
  auth-enabled = false
EOL

    # Start InfluxDB
    influxd -config ~/monitoring/influxdb/influxdb.conf &
}

# Function to set up Chronograf
setup_chronograf() {
    print_status "Setting up Chronograf..."

    # Start Chronograf
    chronograf --host localhost --port 8888 &
}

# Function to set up Node Exporter
setup_node_exporter() {
    print_status "Setting up Node Exporter..."

    # Start Node Exporter
    node_exporter &
}

# Function to set up cAdvisor
setup_cadvisor() {
    print_status "Setting up cAdvisor..."

    # Start cAdvisor
    cadvisor -port 8080 &
}

# Function to set up Netdata
setup_netdata() {
    print_status "Setting up Netdata..."

    # Start Netdata
    netdata -D &
}

# Function to create monitoring dashboard
create_dashboard() {
    print_status "Creating monitoring dashboard..."

    # Create a simple HTML dashboard
    mkdir -p ~/monitoring/dashboard
    cat > ~/monitoring/dashboard/index.html << 'EOL'
<!DOCTYPE html>
<html>
<head>
    <title>Monitoring Dashboard</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .container { display: grid; grid-template-columns: repeat(2, 1fr); gap: 20px; }
        .panel { border: 1px solid #ccc; padding: 20px; border-radius: 5px; }
        iframe { width: 100%; height: 400px; border: none; }
    </style>
</head>
<body>
    <h1>Monitoring Dashboard</h1>
    <div class="container">
        <div class="panel">
            <h2>Grafana</h2>
            <iframe src="http://localhost:3000"></iframe>
        </div>
        <div class="panel">
            <h2>Kibana</h2>
            <iframe src="http://localhost:5601"></iframe>
        </div>
        <div class="panel">
            <h2>Chronograf</h2>
            <iframe src="http://localhost:8888"></iframe>
        </div>
        <div class="panel">
            <h2>Netdata</h2>
            <iframe src="http://localhost:19999"></iframe>
        </div>
    </div>
</body>
</html>
EOL
}

# Main function
main() {
    print_status "Starting monitoring setup..."

    # Set up monitoring tools
    setup_prometheus
    setup_grafana
    setup_loki
    setup_promtail
    setup_elasticsearch
    setup_kibana
    setup_influxdb
    setup_chronograf
    setup_node_exporter
    setup_cadvisor
    setup_netdata

    # Create dashboard
    create_dashboard

    print_status "Monitoring setup completed!"
    print_status "Access the monitoring dashboard at: ~/monitoring/dashboard/index.html"
    print_status "Grafana: http://localhost:3000"
    print_status "Kibana: http://localhost:5601"
    print_status "Chronograf: http://localhost:8888"
    print_status "Netdata: http://localhost:19999"
}

# Run the main function
main
