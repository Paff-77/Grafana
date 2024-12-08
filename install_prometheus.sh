#!/bin/bash

# Get the latest version number
VER=$(wget -qO- https://api.github.com/repos/prometheus/prometheus/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')

# Determine the system architecture
ARCH=$(uname -m)
TYPE=""

if [ "$ARCH" == "x86_64" ]; then
  TYPE="amd64"
elif [ "$ARCH" == "arm5l" ]; then
  TYPE="armv5"
elif [ "$ARCH" == "armv6l" ]; then
  TYPE="armv6"
elif [ "$ARCH" == "armv7l" ]; then
  TYPE="armv7"
elif [ "$ARCH" == "aarch64" ]; then
  TYPE="arm64"
fi

# Stop prometheus service
systemctl stop prometheus

# Download the corresponding architecture's Prometheus to the /tmp directory
wget -P /tmp https://github.com/prometheus/prometheus/releases/download/v${VER}/prometheus-${VER}.linux-${TYPE}.tar.gz

# Unpack the file
tar -zxvf /tmp/prometheus-${VER}.linux-${TYPE}.tar.gz -C /tmp

# Create user and configuration directories
useradd -rs /bin/false prometheus
mkdir /etc/prometheus
mkdir /var/lib/prometheus
chown prometheus:prometheus /etc/prometheus
chown prometheus:prometheus /var/lib/prometheus

# Check if the prometheus.yml configuration file already exists
if [ ! -f /etc/prometheus/prometheus.yml ]; then
    # Copy the new prometheus configuration file to the /etc/prometheus directory
    cp /tmp/prometheus-${VER}.linux-${TYPE}/prometheus.yml /etc/prometheus/prometheus.yml
else
    echo "The configuration file /etc/prometheus/prometheus.yml already exists and will not be overwritten."
fi

chown prometheus:prometheus /etc/prometheus/prometheus.yml

# Copy binaries and configuration files
cp /tmp/prometheus-${VER}.linux-${TYPE}/prometheus /usr/local/bin/
cp /tmp/prometheus-${VER}.linux-${TYPE}/promtool /usr/local/bin/
chown prometheus:prometheus /usr/local/bin/prometheus
chown prometheus:prometheus /usr/local/bin/promtool

cp -r /tmp/prometheus-${VER}.linux-${TYPE}/consoles /etc/prometheus
cp -r /tmp/prometheus-${VER}.linux-${TYPE}/console_libraries /etc/prometheus
chown -R prometheus:prometheus /etc/prometheus/consoles
chown -R prometheus:prometheus /etc/prometheus/console_libraries

# Remove old files and directories
rm /tmp/prometheus-${VER}.linux-${TYPE}.tar.gz && rm -rf /tmp/prometheus-${VER}.linux-${TYPE}

# Create systemd service file
cat > /etc/systemd/system/prometheus.service << EOF 
[Unit]
Description=Prometheus Service
Documentation=https://github.com/prometheus/prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
Restart=on-failure
ExecStart=/usr/local/bin/prometheus \\
    --config.file /etc/prometheus/prometheus.yml \\
    --storage.tsdb.path /var/lib/prometheus/ \\
    --web.console.templates=/etc/prometheus/consoles \\
    --web.console.libraries=/etc/prometheus/console_libraries \\
    --web.enable-lifecycle \\
    --web.enable-admin-api \\
    --web.external-url=https://**************************************************/prometheus/ \\  
    --web.listen-address=localhost:9090 \\
    --web.route-prefix=/

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd manager configuration
systemctl daemon-reload

# Enable Prometheus service to start on boot
systemctl enable prometheus

# Start Prometheus service
systemctl start prometheus
