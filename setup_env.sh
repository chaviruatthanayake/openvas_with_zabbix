#!/bin/bash

# Docker Compose Setup Script for OpenVAS, Zabbix, and Portainer
# This script creates necessary directories and sets proper permissions

set -e

# This isColor codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# This is Function to print colored output
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

print_header "Docker Compose Multi-Service Setup"
print_status "Starting setup process..."

BASE_DIR="/home/docker"
CURRENT_DIR=$(pwd)

print_status "Creating base directory structure..."

sudo mkdir -p $BASE_DIR
sudo chown $USER:$USER $BASE_DIR

print_status "Creating OpenVAS directories..."
mkdir -p $BASE_DIR/ovas001/{vt_data,notus_data,scap_data,cert_data,data_objects,gpg_data,redis_socket,psql_data,psql_socket,gvmd_data,gvmd_socket,ospd_openvas_socket,openvas_data,openvas_log_data}

print_status "Creating Zabbix directories..."
mkdir -p $BASE_DIR/zabbix_server/{alertscripts,externalscripts,dbscripts,export,modules,enc,ssh_keys,mibs,web,postgres-data}
mkdir -p $BASE_DIR/zabbix_proxy/{data,enc,keys,mibs,externalscripts,sqlite}

print_status "Creating Portainer directories..."
mkdir -p $BASE_DIR/portainer/data

print_status "Setting proper permissions..."

chmod 755 $BASE_DIR/ovas001
chmod 755 $BASE_DIR/ovas001/*
chmod 777 $BASE_DIR/ovas001/redis_socket
chmod 777 $BASE_DIR/ovas001/psql_socket
chmod 777 $BASE_DIR/ovas001/gvmd_socket
chmod 777 $BASE_DIR/ovas001/ospd_openvas_socket
chmod 777 $BASE_DIR/ovas001/openvas_log_data

chmod 755 $BASE_DIR/zabbix_server
chmod 755 $BASE_DIR/zabbix_server/*
chmod 777 $BASE_DIR/zabbix_server/postgres-data
chmod 755 $BASE_DIR/zabbix_proxy
chmod 755 $BASE_DIR/zabbix_proxy/*

chmod 755 $BASE_DIR/portainer
chmod 755 $BASE_DIR/portainer/data

print_status "Setting PostgreSQL directory ownership..."
sudo chown -R 999:999 $BASE_DIR/ovas001/psql_data 2>/dev/null || true
sudo chown -R 999:999 $BASE_DIR/zabbix_server/postgres-data 2>/dev/null || true

print_status "Setting Redis directory ownership..."
sudo chown -R 999:999 $BASE_DIR/ovas001/redis_socket 2>/dev/null || true

print_status "Directory structure created successfully!"

print_header "Directory Structure"
tree $BASE_DIR 2>/dev/null || find $BASE_DIR -type d | sort

print_header "System Requirements Check"

AVAILABLE_SPACE=$(df -h $BASE_DIR | awk 'NR==2 {print $4}')
print_status "Available disk space: $AVAILABLE_SPACE"

TOTAL_MEM=$(free -h | awk 'NR==2 {print $2}')
print_status "Total memory: $TOTAL_MEM"

print_warning "Minimum system requirements:"
echo "  - CPU: 4 cores"
echo "  - RAM: 8GB"
echo "  - Storage: 50GB free space"
echo "  - Network: Internet connection for downloading images"

print_header "Docker Compose Commands"
print_status "To start all services:"
echo "  docker-compose up -d"
echo ""
print_status "To stop all services:"
echo "  docker-compose down"
echo ""
print_status "To view logs:"
echo "  docker-compose logs -f [service_name]"
echo ""
print_status "To restart a specific service:"
echo "  docker-compose restart [service_name]"

print_header "Service Access Information"
print_status "Once started, services will be available at:"
echo "  - OpenVAS Web Interface: http://localhost:8080"
echo "  - Zabbix Web Interface: http://localhost:8081"
echo "  - Portainer Web Interface: http://localhost:9000"
echo "  - Zabbix Server: localhost:10051"
echo "  - Zabbix Proxy: localhost:8082"

print_header "Important Notes"
print_warning "Before starting the containers:"
echo "  1. Ensure Docker daemon is running"
echo "  2. Ensure sufficient disk space and memory"
echo "  3. Allow time for initial setup (can take 10-30 minutes)"
echo "  4. OpenVAS initial setup may take longer on first run"

print_header "Troubleshooting"
print_status "Common issues and solutions:"
echo "  - Permission denied: Check directory permissions"
echo "  - Port conflicts: Ensure ports 8080, 8081, 9000, 10051, 8082 are available"
echo "  - Container restart loops: Check logs with 'docker logs [container_name]'"
echo "  - Slow startup: Allow more time for data synchronization"

print_status "Setup completed successfully!"
print_status "You can now run 'docker-compose up -d' to start all services."

read -p "Do you want to start the services now? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "Starting Docker Compose services..."
    docker compose up -d
    print_status "Services started! Check status with 'docker-compose ps'"
else
    print_status "Services not started. Run 'docker compose up -d' when ready."
fi