#!/bin/bash

# Zabbix Server Setup Script
# This script creates necessary directories and sets proper permissions for Zabbix Server

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

print_header "Zabbix Server 7.4 Setup"
print_status "Starting Zabbix Server 7.4 setup process..."

BASE_DIR="/home/docker"
CURRENT_DIR=$(pwd)

print_status "Creating base directory structure..."
sudo mkdir -p $BASE_DIR
sudo chown $USER:$USER $BASE_DIR

print_status "Creating Zabbix Server 7.4 directories..."
mkdir -p $BASE_DIR/zabbix_server/{alertscripts,externalscripts,dbscripts,export,modules,enc,ssh_keys,mibs,web,postgres-data}

print_status "Setting proper permissions for Zabbix Server 7.4..."
chmod 755 $BASE_DIR/zabbix_server
chmod 755 $BASE_DIR/zabbix_server/*
chmod 777 $BASE_DIR/zabbix_server/postgres-data

print_status "Setting PostgreSQL directory ownership for Zabbix Server 7.4..."
sudo chown -R 999:999 $BASE_DIR/zabbix_server/postgres-data 2>/dev/null || true

print_status "Zabbix Server 7.4 directory structure created successfully!"

print_header "Zabbix Server 7.4 Directory Structure"
tree $BASE_DIR/zabbix_server 2>/dev/null || find $BASE_DIR/zabbix_server -type d | sort

print_header "Zabbix Server 7.4 Service Information"
print_status "Zabbix Server 7.4 will be available at:"
echo "  - Zabbix Web Interface: http://localhost:8081"
echo "  - Zabbix Server: localhost:10051"

print_header "Zabbix Server 7.4 Important Notes"
print_warning "Before starting Zabbix Server 7.4:"
echo "  1. Ensure Docker daemon is running"
echo "  2. Ensure sufficient disk space (at least 10GB for Zabbix Server)"
echo "  3. Allow time for initial database setup (5-10 minutes)"
echo "  4. Default login: Admin/zabbix"
echo "  5. PostgreSQL database will be initialized on first run"

print_header "Zabbix Server 7.4 Troubleshooting"
print_status "Common Zabbix Server 7.4 issues and solutions:"
echo "  - Permission denied: Check directory permissions"
echo "  - Port 8081 or 10051 conflict: Ensure ports are available"
echo "  - Database connection issues: Check PostgreSQL container logs"
echo "  - Container restart loops: Check logs with 'docker logs [container_name]'"
echo "  - Web interface not accessible: Check if web container is running"

print_status "Zabbix Server 7.4 setup completed successfully!"
print_status "You can now start Zabbix Server 7.4 with your docker-compose configuration."