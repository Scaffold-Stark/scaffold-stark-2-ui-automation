#!/bin/bash

echo "Checking Playwright container environment..."

# Check network configuration
echo "Network configuration:"
docker compose exec playwright ip addr

# Check connectivity to containers
echo "Testing connectivity to nextjs:"
docker compose exec playwright curl -v http://nextjs:3000

echo "Testing connectivity to localhost:"
docker compose exec playwright curl -v http://localhost:3000

echo "Testing connectivity to host.docker.internal:"
docker compose exec playwright curl -v http://host.docker.internal:3000

# Check DNS resolution
echo "DNS resolution test:"
docker compose exec playwright nslookup nextjs
docker compose exec playwright cat /etc/hosts

# Check environment variables
echo "Environment variables:"
docker compose exec playwright env | grep -i base_url

echo "Check complete." 