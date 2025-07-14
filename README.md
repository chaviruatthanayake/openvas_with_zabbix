# 🛡️ Greenbone/OpenVAS + Zabbix + Portainer Docker Stack

This project deploys a complete **Greenbone Community Edition (OpenVAS)** vulnerability scanner stack along with **Zabbix Monitoring** and **Portainer** for container management — all via Docker Compose.

---

## 🧰 Stack Components

- **Greenbone/OpenVAS**
  - `ospd-openvas`, `gvmd`, `gsa`, `openvas`, `redis-server`, `pg-gvm`, etc.
- **Zabbix Monitoring**
  - `zabbix-server`, `zabbix-web`, `zabbix-db`, `zabbix-proxy`
- **Portainer CE**

---

## 🚀 How to Deploy

### 1. Prepare Directories & Permissions

```bash
chmod +x setup_env.sh
./setup_env.sh
