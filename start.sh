#!/bin/bash

# Mermaid Live Editor Docker Launcher
# This script builds and runs the Mermaid Live Editor in Docker
# Press Ctrl+C to stop the container

set -e

CONTAINER_NAME="mermaid-live-editor"
IMAGE_NAME="mermaid-js/mermaid-live-editor"
PORT=8080

# Cleanup function to stop and remove container
cleanup() {
    echo ""
    echo "Stopping container..."
    docker stop "$CONTAINER_NAME" 2>/dev/null || true
    docker rm "$CONTAINER_NAME" 2>/dev/null || true
    echo "Container stopped and removed."
    exit 0
}

# Set trap to catch Ctrl+C (SIGINT) and SIGTERM
trap cleanup SIGINT SIGTERM

# Stop and remove existing container if running
echo "Checking for existing container..."
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "Removing existing container..."
    docker stop "$CONTAINER_NAME" 2>/dev/null || true
    docker rm "$CONTAINER_NAME" 2>/dev/null || true
fi

# Build the Docker image only if it doesn't exist
if ! docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
    echo "Building Docker image..."
    docker build -t "$IMAGE_NAME" .
else
    echo "Docker image already exists, skipping build..."
    echo "(To rebuild, run: docker rmi $IMAGE_NAME)"
fi

# Run the container
echo "Starting container..."
docker run --detach --name "$CONTAINER_NAME" --publish "$PORT:$PORT" "$IMAGE_NAME"

echo ""
echo "✓ Mermaid Live Editor is running!"
echo "  Access it at: http://localhost:$PORT"
echo ""
echo "Press Ctrl+C to stop the container..."
echo ""

# Follow container logs and wait
docker logs -f "$CONTAINER_NAME" &
LOGS_PID=$!

# Wait for the logs process (which will be interrupted by Ctrl+C)
wait $LOGS_PID 2>/dev/null || cleanup
