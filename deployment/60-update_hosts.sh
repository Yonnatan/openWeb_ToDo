#!/bin/bash

# Get the LoadBalancer hostname
LB_HOSTNAME=$(kubectl get service nginx-proxy-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

# Check if we got a hostname
if [ -z "$LB_HOSTNAME" ]; then
    echo "Failed to get LoadBalancer hostname. Is the service running?"
    exit 1
fi

# Resolve the IP address from the hostname
LB_IP=$(dig +short $LB_HOSTNAME | tail -n 1)

# Check if we got an IP address
if [ -z "$LB_IP" ]; then
    echo "Failed to resolve IP address for $LB_HOSTNAME."
    exit 1
fi

# Check if the entry already exists in /etc/hosts
if grep -q "tools.devops-openweb.com" /etc/hosts; then
    echo "Entry for tools.devops-openweb.com already exists in /etc/hosts. Updating..."
    sudo sed -i "s/.*tools.devops-openweb.com/$LB_IP tools.devops-openweb.com/" /etc/hosts
else
    echo "Adding new entry to /etc/hosts..."
    echo "$LB_IP tools.devops-openweb.com" | sudo tee -a /etc/hosts > /dev/null
fi

echo "Updated /etc/hosts. You can now access the app at http://tools.devops-openweb.com/todo"