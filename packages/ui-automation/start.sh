#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "$SCRIPT_DIR"

# docker compose build --no-cache nextjs

docker compose up -d

echo "Waiting for starknet-devnet to start..."
MAX_RETRIES=30
COUNT=0
while ! curl -s http://localhost:5050 > /dev/null && [ $COUNT -lt $MAX_RETRIES ]; do
    echo "Attempt $((COUNT+1))/$MAX_RETRIES: Waiting for starknet-devnet..."
    sleep 2
    ((COUNT++))
done

if [ $COUNT -eq $MAX_RETRIES ]; then
    echo "❌ Error: starknet-devnet did not start within the timeout period"
    exit 1
fi

echo "✅ starknet-devnet is running"

echo "Waiting for nextjs to start..."
COUNT=0
while ! curl -s http://localhost:3000 > /dev/null && [ $COUNT -lt $MAX_RETRIES ]; do
    echo "Attempt $((COUNT+1))/$MAX_RETRIES: Waiting for nextjs..."
    sleep 2
    ((COUNT++))
done

if [ $COUNT -eq $MAX_RETRIES ]; then
    echo "❌ Error: nextjs did not start within the timeout period"
    exit 1
fi

echo "✅ nextjs is running"

echo "Setup complete! You can now access:"
echo "- Starknet Devnet: http://localhost:5050"
echo "- NextJS App: http://localhost:3000"

echo "Testing network connectivity between containers..."
./docker-network-test.sh

echo "Installing browser dependencies in playwright container..."
docker compose exec playwright npx playwright install chromium --with-deps

echo "Starting sequential tests..."

TEST_FILES=$(docker compose exec playwright find /app/tests -name "*.spec.ts" | sort)

for test_file in $TEST_FILES; do
    test_name=$(basename "$test_file")
    echo "Running test: $test_name"
    
    docker compose exec -e DEBUG=pw:api -e BASE_URL="http://nextjs:3000" playwright npx playwright test "$test_file" --reporter=list
    
    if [ $? -eq 0 ]; then
        echo "✅ Test $test_name completed successfully"
    else
        echo "❌ Test $test_name failed"
        echo "Collecting debug information..."
        docker compose logs nextjs > nextjs-logs.txt
        docker compose logs starknet-devnet > starknet-logs.txt
    fi
    
    echo "Moving to next test in 3 seconds... (Press Ctrl+C to stop)"
    sleep 3
done

echo "All tests completed!"