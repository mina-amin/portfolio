#!/bin/bash
set -e

read -p "Project name: " project
read -p "Domain (e.g. test.local): " domain

DIR="/var/www/html/$project"
CONF="/etc/nginx/sites-available/$domain"
WAIT="sleep 2"

$WAIT

# Directory Setup
if [ -d "$DIR" ]; then
  echo "Directory already exists."
else
  mkdir -p "$DIR" || { echo "Failed to create directory!"; }
  echo "Directory created."
fi

$WAIT

# Web Application Deployment
if [ -f "$DIR/index.html" ]; then
  echo "index.html already exists."
else
  echo "<h1>Welcome to $domain</h1>" > "$DIR/index.html"
  echo "Web app deployed."
fi

chmod -R 755 "$DIR"

$WAIT

# Nginx Configuration
if [ -f "$CONF" ]; then
  echo "Config already exists."
else
  echo "server {
    listen 80;
    server_name $domain;
    root $DIR;
    index index.html;
}" > "$CONF"
  ln -s "$CONF" /etc/nginx/sites-enabled/ 2>/dev/null
  echo "Nginx config created."
fi

$WAIT

# Domain Resolution
read -p "Enter IP address for $domain: " IP
IP=${IP:-127.0.0.1}

if grep -q "$domain" /etc/hosts; then
  echo "Domain already in /etc/hosts."
else
  echo "$IP $domain" >> /etc/hosts
  echo "Domain added with IP $IP."
fi

$WAIT

# Nginx Service Management
nginx -t && systemctl restart nginx || { echo "Nginx error!"; }

$WAIT

# Smoke Testing
if curl -s --head "http://$domain" | grep "200 OK" > /dev/null; then
  echo "Website is working."
else
  echo "Website not reachable."
fi

$WAIT

# success Confirmation
echo "Deployment complete! Visit: http://$domain"