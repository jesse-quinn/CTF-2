#!/bin/bash

set -e

# Start the outer Docker daemon and the outer host ssh daemon.
dockerd > /dev/null 2>&1 &
/usr/sbin/sshd -D > /dev/null 2>&1 &

# Wait for the outer Docker engine to accept commands before deploying the stack.
until docker info >/dev/null 2>&1; do sleep 1; done

# Run CMD: docker compose builds the inner stack and pulls its base images.
exec "$@"
