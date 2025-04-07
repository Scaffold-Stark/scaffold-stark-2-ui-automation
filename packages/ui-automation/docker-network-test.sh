#!/bin/bash

# Test network connectivity between containers
echo "Testing network connectivity between containers..."

echo "Testing nextjs -> starknet-devnet..."
docker compose exec nextjs curl -s http://starknet-devnet:5050 > /dev/null
if [ $? -eq 0 ]; then
    echo "✅ nextjs can connect to starknet-devnet"
else
    echo "❌ nextjs cannot connect to starknet-devnet"
fi

echo "Testing playwright -> nextjs..."
docker compose exec playwright curl -s http://nextjs:3000 > /dev/null
if [ $? -eq 0 ]; then
    echo "✅ playwright can connect to nextjs"
else
    echo "❌ playwright cannot connect to nextjs"
    echo "This is the main issue that needs to be fixed!"
fi

echo "Testing playwright -> starknet-devnet..."
docker compose exec playwright curl -s http://starknet-devnet:5050 > /dev/null
if [ $? -eq 0 ]; then
    echo "✅ playwright can connect to starknet-devnet"
else
    echo "❌ playwright cannot connect to starknet-devnet"
fi

echo "Network test complete." 