#!/bin/bash
set -e

echo "RPC_URL_DEVNET: $RPC_URL_DEVNET"

if [ -z "$RPC_URL_DEVNET" ]; then
    echo "Error: RPC_URL_DEVNET is not set"
    exit 1
fi

while ! curl -s $RPC_URL_DEVNET > /dev/null; do
    echo "Waiting for devnet $RPC_URL_DEVNET to be ready..."
    sleep 2
done

cd /app
echo "Current directory: $(pwd)"
echo "Listing directory contents:"
ls -la

yarn install --immutable

# Check if snfoundry directory exists
if [ -d "snfoundry" ]; then
    echo "Deploying contracts..."
    yarn deploy
elif [ -d "./packages/snfoundry" ]; then
    echo "Deploying contracts..."
    yarn deploy
else
    echo "Warning: snfoundry directory not found, skipping deployment"
fi

# Check if nextjs directory exists
# if [ -d "nextjs" ]; then
#     echo "Starting Next.js server..."
#     exec yarn start
# elif [ -d "./packages/nextjs" ]; then
#     echo "Starting Next.js server..."
#     exec yarn start
# else
#     echo "Error: nextjs directory not found"
#     exit 1
# fi 

exec yarn start

echo "Done"