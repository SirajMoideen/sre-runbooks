# Nginx Reverse Proxy Runbook (HTTPS + Application Proxy)

This runbook explains how to configure **Nginx as a reverse proxy** for internal applications running on custom ports.

It covers:

- Reverse proxy configuration
- HTTP → HTTPS redirection
- TLS configuration
- Enabling sites
- Troubleshooting
- Multi-application setup
- Windows deployment

Sensitive information such as internal domains, IP addresses, and certificates has been replaced with generic examples.

---

## Architecture Overview

Client
   │
   │ HTTPS :443
   ▼
Nginx Reverse Proxy
   │
   │ HTTP :PORT
   ▼
Application Service

Example:

https://app.example.com → Nginx → http://127.0.0.1:8090

---

## 1. Install Nginx (Linux)

```bash
sudo apt update
sudo apt install nginx -y
```

Verify installation

```bash
nginx -v
```

---

## 2. Create Reverse Proxy Configuration

Create a new site configuration.

```bash
sudo vi /etc/nginx/sites-available/app-proxy.conf
```

Example configuration:

```nginx
server {
    listen 443 ssl http2;
    server_name app.example.com;

    ssl_certificate     /etc/nginx/ssl/tls.crt;
    ssl_certificate_key /etc/nginx/ssl/tls.key;

    location / {
        proxy_pass http://127.0.0.1:8090;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";

        client_max_body_size 250M;
    }
}
```

---

## 3. Enable HTTP → HTTPS Redirect

Add a second server block.

```nginx
server {
    listen 80;
    server_name app.example.com;

    return 301 https://$host$request_uri;
}
```

---

## 4. Enable the Configuration

Create a symbolic link.

```bash
sudo ln -s /etc/nginx/sites-available/app-proxy.conf /etc/nginx/sites-enabled/
```

Test configuration.

```bash
sudo nginx -t
```

Reload Nginx.

```bash
sudo systemctl reload nginx
```

Enable on boot.

```bash
sudo systemctl enable nginx
```

---

## 5. Root Path Redirection (Optional)

If an application requires redirecting the root path.

```nginx
location = / {
    return 301 https://$host/source;
}
```

---

## 6. Troubleshooting

Check configuration.

```bash
sudo nginx -t
```

View logs.

```bash
sudo tail -f /var/log/nginx/error.log
```

Check service.

```bash
sudo systemctl status nginx
```

Restart service.

```bash
sudo systemctl restart nginx
```

---

## 7. Firewall Configuration

Allow HTTP and HTTPS traffic.

```bash
sudo ufw allow 'Nginx Full'
```

Verify firewall rules.

```bash
sudo ufw status
```

---

## 8. Adding Multiple Applications

Create a new configuration file per service.

```bash
sudo vi /etc/nginx/sites-available/service2.conf
```

Example configuration:

```nginx
server {
    listen 443 ssl http2;
    server_name service2.example.com;

    ssl_certificate     /etc/nginx/ssl/tls.crt;
    ssl_certificate_key /etc/nginx/ssl/tls.key;

    location / {
        proxy_pass http://127.0.0.1:8080;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

Enable the configuration.

```bash
sudo ln -s /etc/nginx/sites-available/service2.conf /etc/nginx/sites-enabled/
```

Reload Nginx.

```bash
sudo nginx -t
sudo systemctl reload nginx
```

---

## 9. Reverse Proxy With Extended Timeouts

Useful for long-running workloads.

```nginx
location / {
    proxy_pass http://localhost:8000;

    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";

    proxy_connect_timeout 300s;
    proxy_send_timeout 300s;
    proxy_read_timeout 300s;
}
```

---

## 10. Nginx on Windows

Download Nginx.

http://nginx.org/en/download.html

Extract to:

```
C:\nginx
```

Directory structure:

```
C:\nginx
 ├── conf
 ├── html
 ├── logs
```

Start Nginx.

```cmd
cd C:\nginx
start nginx
```

Verify installation by opening:

http://localhost

Stop Nginx.

```cmd
nginx -s stop
```

---

## 11. Windows Reverse Proxy Configuration

Edit configuration.

```cmd
code C:\nginx\conf\nginx.conf
```

Example configuration.

```nginx
server {
    listen 80;
    server_name app.example.com;

    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    server_name app.example.com;

    ssl_certificate      C:/nginx/conf/ssl/tls.crt;
    ssl_certificate_key  C:/nginx/conf/ssl/tls.key;

    ssl_session_cache shared:SSL:1m;
    ssl_session_timeout 5m;

    ssl_protocols TLSv1.2 TLSv1.3;

    location / {
        proxy_pass http://localhost:3000;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

Reload Nginx.

```cmd
nginx -s reload
```

---

## Summary

This runbook demonstrates:

- Reverse proxy configuration
- HTTPS enforcement
- TLS setup
- WebSocket support
- Multi-service routing
- Linux and Windows deployment
- Operational troubleshooting

These patterns are commonly used in production environments to securely expose internal services behind a reverse proxy layer.