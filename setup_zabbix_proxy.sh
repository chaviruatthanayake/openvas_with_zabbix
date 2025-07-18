#!/bin/bash

# Zabbix Proxy Setup Script
# This script creates necessary directories and sets proper permissions for Zabbix Proxy

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root"
   exit 1
fi

command -v docker >/dev/null 2>&1 || { print_error "Docker is not installed. Please install Docker first."; exit 1; }
command -v docker compose >/dev/null 2>&1 || { print_error "Docker Compose is not installed. Please install Docker Compose first."; exit 1; }

if ! groups $USER | grep -q '\bdocker\b'; then
    print_error "User $USER is not in the docker group. Please add user to docker group:"
    echo "sudo usermod -aG docker $USER"
    echo "Then logout and login again."
    exit 1
fi

print_header "Zabbix Proxy Setup"
print_status "Starting Zabbix Proxy setup process..."

BASE_DIR="/home/docker"
CURRENT_DIR=$(pwd)

print_status "Creating base directory structure..."
sudo mkdir -p $BASE_DIR
sudo chown $USER:$USER $BASE_DIR

print_status "Creating Zabbix Proxy directories..."
mkdir -p $BASE_DIR/zabbix_proxy/{data,enc,keys,mibs,externalscripts,sqlite}

print_status "Setting proper permissions for Zabbix Proxy..."
chmod 755 $BASE_DIR/zabbix_proxy
chmod 755 $BASE_DIR/zabbix_proxy/*

print_status "Zabbix Proxy directory structure created successfully!"

print_header "Zabbix Proxy Directory Structure"
tree $BASE_DIR/zabbix_proxy 2>/dev/null || find $BASE_DIR/zabbix_proxy -type d | sort

print_header "Zabbix Proxy Service Information"
print_status "Zabbix Proxy will be available at:"
echo "  - Zabbix Proxy: localhost:8082"

print_header "Zabbix Proxy Important Notes"
print_warning "Before starting Zabbix Proxy:"
echo "  1. Ensure Docker daemon is running"
echo "  2. Ensure sufficient disk space (at least 5GB for Zabbix Proxy)"
echo "  3. Configure proxy settings in Zabbix Server web interface"
echo "  4. SQLite database will be used for local storage"
echo "  5. Proxy must be registered with Zabbix Server"

print_header "Zabbix Proxy Configuration"
print_status "Key configuration steps:"
echo "  1. Add proxy in Zabbix Server web interface (Administration > Proxies)"
echo "  2. Configure proxy name and mode (active/passive)"
echo "  3. Set appropriate hosts to be monitored by proxy"
echo "  4. Ensure network connectivity between proxy and server"

print_header "Zabbix Proxy Troubleshooting"
print_status "Common Zabbix Proxy issues and solutions:"
echo "  - Permission denied: Check directory permissions"
echo "  - Port 8082 conflict: Ensure port is available"
echo "  - Connection to server failed: Check network connectivity"
echo "  - Container restart loops: Check logs with 'docker logs [container_name]'"
echo "  - Proxy not appearing in server: Check proxy registration"

print_status "Zabbix Proxy setup completed successfully!"
print_status "You can now start Zabbix Proxy with your docker-compose configuration."