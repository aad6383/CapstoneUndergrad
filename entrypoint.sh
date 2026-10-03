#!/bin/sh
set -e

echo "Starting Capstone Documentation Automation..."

mkdir -p /root/.ssh

# -----------------------------
# Linux target setup
# -----------------------------
if [ -n "$LINUX_TARGET_HOST" ]; then
  echo "Linux target detected: $LINUX_TARGET_HOST"

  if [ -z "$EC2_SSH_PRIVATE_KEY" ]; then
    echo "ERROR: EC2_SSH_PRIVATE_KEY is not set."
    exit 1
  fi

  echo "Creating temporary Linux SSH key..."
  printf '%b\n' "$EC2_SSH_PRIVATE_KEY" > /tmp/capstone-ec2-key.pem
  chmod 400 /tmp/capstone-ec2-key.pem

  echo "Validating Linux SSH private key..."

  if ! ssh-keygen -y -f /tmp/capstone-ec2-key.pem >/dev/null 2>&1; then
    echo "ERROR: Linux SSH private key is malformed or unreadable."
    exit 1
  fi

  echo "Collecting Linux host key..."

  if ! ssh-keyscan -T 10 -H "$LINUX_TARGET_HOST" >> /root/.ssh/known_hosts; then
    echo "ERROR: Could not reach Linux target $LINUX_TARGET_HOST on SSH port 22."
    exit 1
  fi

  echo "Linux SSH configuration ready."
fi


# -----------------------------
# macOS target setup
# -----------------------------
if [ -n "$MAC_TARGET_HOST" ]; then
  echo "macOS target detected: $MAC_TARGET_HOST"

  if [ -z "$MAC_SSH_PRIVATE_KEY" ]; then
    echo "ERROR: MAC_SSH_PRIVATE_KEY is not set."
    exit 1
  fi

  echo "Creating temporary macOS SSH key..."
  printf '%b\n' "$MAC_SSH_PRIVATE_KEY" > /tmp/capstone-mac-key
  chmod 400 /tmp/capstone-mac-key

  echo "Validating macOS SSH private key..."

  if ! ssh-keygen -y -f /tmp/capstone-mac-key >/dev/null 2>&1; then
    echo "ERROR: macOS SSH private key is malformed or unreadable."
    exit 1
  fi

  echo "Collecting macOS host key..."

  if ! ssh-keyscan -T 10 -H "$MAC_TARGET_HOST" >> /root/.ssh/known_hosts; then
    echo "ERROR: Could not reach macOS target $MAC_TARGET_HOST on SSH port 22."
    exit 1
  fi

  echo "macOS SSH configuration ready."
fi


# -----------------------------
# Windows target setup
# -----------------------------
if [ -n "$WINDOWS_TARGET_HOST" ]; then
  echo "Windows target detected: $WINDOWS_TARGET_HOST"
  echo "Windows target will use WinRM."
fi


# -----------------------------
# Validation
# -----------------------------
if [ -z "$LINUX_TARGET_HOST" ] && \
   [ -z "$MAC_TARGET_HOST" ] && \
   [ -z "$WINDOWS_TARGET_HOST" ]; then

  echo "WARNING: No target host environment variables are set."
  echo "Expected at least one of:"
  echo "  LINUX_TARGET_HOST"
  echo "  MAC_TARGET_HOST"
  echo "  WINDOWS_TARGET_HOST"
fi


echo "Starting Ansible..."

exec "$@"