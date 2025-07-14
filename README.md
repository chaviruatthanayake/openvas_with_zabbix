# OpenVAS and Zabbix Stacks Repository

Welcome to the repository containing Docker Compose configurations for deploying OpenVAS and Zabbix stacks. This repository includes four individual stack configurations to be managed via Portainer, as per your requirements. The stacks are designed to run independently on a Docker-enabled environment.

## Overview

This repository provides the following stack configurations:

- **OpenVAS**: A vulnerability management solution based on the Greenbone Community Edition (documentation: [Greenbone Container Docs](https://greenbone.github.io/docs/latest/22.4/container/index.html)).
- **Zabbix Server 7.4**: A monitoring solution with server, web interface, and PostgreSQL database (image: [zabbix/zabbix-server-pgsql](https://hub.docker.com/r/zabbix/zabbix-server-pgsql)).
- **Zabbix Server 7.0**: A monitoring solution with server, web interface, and PostgreSQL database (image: [zabbix/zabbix-server-pgsql](https://hub.docker.com/r/zabbix/zabbix-server-pgsql)).
- **Zabbix Proxy 7.0**: A proxy for Zabbix monitoring (image: [zabbix/zabbix-proxy-sqlite3](https://hub.docker.com/r/zabbix/zabbix-proxy-sqlite3)).

Each stack is provided as a separate Docker Compose file to allow independent deployment and management.

## Prerequisites

Before deploying the stacks, ensure the following are in place:

- A server with Docker and Docker Compose installed.
- Portainer installed and accessible (e.g., at `http://<VM_PUBLIC_IP>:9000`).
- Sufficient disk space and memory (recommended: at least 4GB RAM).
- The following directories created on the host with appropriate permissions:
  - `/home/docker/ovas001/` for OpenVAS volumes.
  - `/home/docker/zabbix_server/` for Zabbix 7.4 volumes.
  - `/home/docker/zabbix_server_7.0/` for Zabbix 7.0 volumes.
  - `/home/docker/zabbix_proxy/` for Zabbix Proxy 7.0 volumes.
- Network ports 8080 (OpenVAS), 8081 (Zabbix 7.4), 8082 (Zabbix 7.0), and 8083 (Zabbix Proxy 7.0) available and allowed through any firewall or cloud security rules.

## Files

- `docker-compose-openvas.yml`: Configuration for the OpenVAS stack.
- `docker-compose-zabbix-server-7.4.yml`: Configuration for the Zabbix Server 7.4 stack.
- `docker-compose-zabbix-server-7.0.yml`: Configuration for the Zabbix Server 7.0 stack.
- `docker-compose-zabbix-proxy-7.0.yml`: Configuration for the Zabbix Proxy 7.0 stack.

## Deployment Instructions

### Step 1: Prepare the Environment
1. Run the setup script in the Host VM<br/>
     ` chmod +x setup_env.sh `<br/>
     ` ./setup_env.sh `

### Step 2: Create a redis.conf file (Sample is below)
` mkdir -p /home/docker/ovas001/redis_conf `<br/>
` echo -e "port 6379\nunixsocket /run/redis/redis.sock\nunixsocketperm 777" > /home/docker/ovas001/redis_conf/redis.conf `<br/>
` chown 1001:1001 /home/docker/ovas001/redis_conf/redis.conf `<br/>
` chmod 644 /home/docker/ovas001/redis_conf/redis.conf `<br/>

### Step 3: Deploy Stacks in Portainer
1. Navigate to Stacks in the left sidebar in Portainer and click Add stack.
2. For each stack create a new stack, select "Web Editor", paste the contents of each compose yml file for respective stack and click Deploy.
3. Verify the status of each stack under Stacks to ensure all containers are running.

## Configuration Notes
OpenVAS Redis Fix: The OpenVAS stack uses a Redis socket (/run/redis/redis.sock). To avoid connection issues, configure Redis with a custom redis.conf file as described in Step 1. Update docker-compose-openvas.yml to mount this file and adjust the redis-server command if not already done.



