#!/bin/sh
set -e

echo "Starting Capstone Documentation Automation..."

if [ -z "$EC2_SSH_PRIVATE_KEY" ]; then
  echo "ERROR: EC2_SSH_PRIVATE_KEY is not set."
  exit 1
fi

if [ -z "$TARGET_HOST" ]; then
  echo "ERROR: TARGET_HOST is not set."
  exit 1
fi

echo "Target host: $TARGET_HOST"

mkdir -p /root/.ssh

echo "Creating temporary SSH key..."
printf '%b\n' "$EC2_SSH_PRIVATE_KEY" > /tmp/capstone-ec2-key.pem
chmod 400 /tmp/capstone-ec2-key.pem

echo "Validating SSH private key..."

if ! ssh-keygen -y -f /tmp/capstone-ec2-key.pem >/dev/null 2>&1; then
  echo "ERROR: SSH private key is malformed or unreadable."
  exit 1
fi

echo "SSH private key is valid."

echo "Testing SSH reachability and collecting host key..."

if ! ssh-keyscan -T 10 -H "$TARGET_HOST" > /root/.ssh/known_hosts; then
  echo "ERROR: Could not reach $TARGET_HOST on SSH port 22."
  exit 1
fi

echo "Host key collected successfully."
echo "Starting Ansible..."

exec "$@"
