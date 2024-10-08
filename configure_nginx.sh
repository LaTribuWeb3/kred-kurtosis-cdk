#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install Nginx if not already installed
if ! command_exists nginx; then
    echo "Nginx is not installed. Installing Nginx..."
    sudo apt-get update
    sudo apt-get install -y nginx
else
    echo "Nginx is already installed."
fi

# Ask user for DNS suffix
read -p "Enter the DNS for RPC (e.g., rpc.example.com): " rpc_dns
read -p "Enter the DNS for WS RPC (e.g., ws-rpc.example.com): " ws_rpc_dns

# Create Nginx configuration file
config_file="/etc/nginx/sites-available/rpc_redirect"

# Find the Docker container exposing port 8123
container_id=$(docker ps --format '{{.ID}}\t{{.Ports}}' | grep '8123' | awk '{print $1}')

if [ -z "$container_id" ]; then
    echo "No container found exposing port 8123. Please check your Docker containers."
    exit 1
else
    echo "Found container $container_id exposing port 8123"
fi

# Extract the external port bound to 8123 in the container
external_port=$(docker port $container_id 8123 | cut -d ':' -f 2)

if [ -z "$external_port" ]; then
    echo "Failed to extract external port for container $container_id. Using default port 8123."
    external_port=8123
else
    echo "External port $external_port is bound to internal port 8123 for container $container_id"
fi


cat << EOF | sudo tee "$config_file" > /dev/null
server {
        listen       80;
        server_name  $rpc_dns;

        location / {
                proxy_pass http://127.0.0.1:$external_port;
                proxy_set_header Host \$host;
                proxy_set_header X-Real-IP \$remote_addr;
                proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto \$scheme;
        }
}

server {
        listen       443 ssl;
        server_name  $ws_rpc_dns;
        ssl_certificate /etc/letsencrypt/live/$rpc_dns/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/$rpc_dns/privkey.pem;
        ssl_session_cache builtin:1000 shared:SSL:10m;
        ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
        ssl_ciphers HIGH:!aNULL:!eNULL:!EXPORT:!CAMELLIA:!DES:!MD5:!PSK:!RC4;
        ssl_prefer_server_ciphers on;

        location / {
                proxy_pass http://127.0.0.1:$external_port;
                proxy_set_header Host \$host;
                proxy_set_header X-Real-IP \$remote_addr;
                proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto \$scheme;
        }
}
EOF

# Create symlink to enable the site
sudo ln -sf "$config_file" /etc/nginx/sites-enabled/

# Test Nginx configuration
sudo nginx -t

# Install certbot
sudo apt-get update
sudo apt-get install -y certbot python3-certbot-nginx

sudo systemctl stop nginx

# Generate SSL certificates for both domains
sudo certbot --standalone -d $rpc_dns -d $ws_rpc_dns --non-interactive --agree-tos --email olden@la-tribu.xyz

sudo systemctl start nginx

# Ensure the certificates were generated successfully
if [ $? -eq 0 ]; then
    echo "SSL certificates have been successfully generated for $rpc_dns and $ws_rpc_dns"
else
    echo "Failed to generate SSL certificates. Please check the certbot logs and try again manually."
    exit 1
fi

if [ $? -eq 0 ]; then
    echo "Nginx configuration test passed."
    # Reload Nginx to apply changes
    sudo systemctl reload nginx
    echo "Nginx has been configured to redirect traffic from $rpc_dns to localhost:8123"
else
    echo "Nginx configuration test failed. Please check the configuration manually."
fi