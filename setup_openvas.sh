#!/bin/bash

# OpenVAS Setup Script
# This script creates necessary directories and sets proper permissions for OpenVAS

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

print_header "OpenVAS Setup"
print_status "Starting OpenVAS setup process..."

BASE_DIR="/home/docker"
CURRENT_DIR=$(pwd)

print_status "Creating base directory structure..."
sudo mkdir -p $BASE_DIR
sudo chown $USER:$USER $BASE_DIR

print_status "Creating OpenVAS directories..."
mkdir -p $BASE_DIR/ovas001/{vt_data,notus_data,scap_data,cert_data,data_objects,gpg_data,redis_socket,psql_data,psql_socket,gvmd_data,gvmd_socket,ospd_openvas_socket,openvas_data,openvas_log_data}

print_status "Setting proper permissions for OpenVAS..."
chmod 755 $BASE_DIR/ovas001
chmod 755 $BASE_DIR/ovas001/*
chmod 777 $BASE_DIR/ovas001/redis_socket
chmod 777 $BASE_DIR/ovas001/psql_socket
chmod 777 $BASE_DIR/ovas001/gvmd_socket
chmod 777 $BASE_DIR/ovas001/ospd_openvas_socket
chmod 777 $BASE_DIR/ovas001/openvas_log_data

print_status "Setting PostgreSQL directory ownership..."
sudo chown -R 999:999 $BASE_DIR/ovas001/psql_data 2>/dev/null || true

print_status "Setting Redis directory ownership..."
sudo chown -R 999:999 $BASE_DIR/ovas001/redis_socket 2>/dev/null || true

print_status "OpenVAS directory structure created successfully!"

print_header "OpenVAS Directory Structure"
tree $BASE_DIR/ovas001 2>/dev/null || find $BASE_DIR/ovas001 -type d | sort

print_header "OpenVAS Service Information"
print_status "OpenVAS will be available at:"
echo "  - OpenVAS Web Interface: http://localhost:8080"

print_header "OpenVAS Important Notes"
print_warning "Before starting OpenVAS:"
echo "  1. Ensure Docker daemon is running"
echo "  2. Ensure sufficient disk space (at least 20GB for OpenVAS)"
echo "  3. Allow time for initial setup (can take 10-30 minutes)"
echo "  4. OpenVAS initial setup may take longer on first run"
echo "  5. Initial vulnerability data sync can take several hours"

print_header "OpenVAS Troubleshooting"
print_status "Common OpenVAS issues and solutions:"
echo "  - Permission denied: Check directory permissions"
echo "  - Port 8080 conflict: Ensure port is available"
echo "  - Container restart loops: Check logs with 'docker logs [container_name]'"
echo "  - Slow startup: Allow more time for data synchronization"
echo "  - Feed sync issues: Check internet connection"

print_status "OpenVAS setup completed successfully!"
print_status "You can now start OpenVAS with your docker-compose configuration."