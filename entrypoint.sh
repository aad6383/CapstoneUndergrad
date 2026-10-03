#!/bin/sh
set -e

echo "Starting Capstone Documentation Automation..."

mkdir -p /root/.ssh

# Detect Ansible --limit
LIMIT_VALUE=""
PREVIOUS_ARG=""

for ARG in "$@"; do
  if [ "$PREVIOUS_ARG" = "--limit" ]; then
    LIMIT_VALUE="$ARG"
    break
  fi

  case "$ARG" in
    --limit=*)
      LIMIT_VALUE="${ARG#--limit=}"
      break
      ;;
  esac

  PREVIOUS_ARG="$ARG"
done

if [ -n "$LIMIT_VALUE" ]; then
  echo "Ansible host limit detected: $LIMIT_VALUE"
fi

PREPARE_LINUX=false
PREPARE_MAC=false
PREPARE_WINDOWS=false

case "$LIMIT_VALUE" in
  linux_hosts)
    PREPARE_LINUX=true
    ;;
  mac_hosts)
    PREPARE_MAC=true
    ;;
  windows_hosts)
    PREPARE_WINDOWS=true
    ;;
  "")
    [ -n "$LINUX_TARGET_HOST" ] && PREPARE_LINUX=true
    [ -n "$MAC_TARGET_HOST" ] && PREPARE_MAC=true
    [ -n "$WINDOWS_TARGET_HOST" ] && PREPARE_WINDOWS=true
    ;;
  *)
    [ -n "$LINUX_TARGET_HOST" ] && PREPARE_LINUX=true
    [ -n "$MAC_TARGET_HOST" ] && PREPARE_MAC=true
    [ -n "$WINDOWS_TARGET_HOST" ] && PREPARE_WINDOWS=true
    ;;
esac

# Linux
if [ "$PREPARE_LINUX" = true ]; then
  if [ -z "$LINUX_TARGET_HOST" ]; then
    echo "ERROR: linux_hosts selected but LINUX_TARGET_HOST is not set."
    exit 1
  fi

  if [ -z "$EC2_SSH_PRIVATE_KEY" ]; then
    echo "ERROR: EC2_SSH_PRIVATE_KEY is not set."
    exit 1
  fi

  echo "Linux target detected: $LINUX_TARGET_HOST"

  printf '%b\n' "$EC2_SSH_PRIVATE_KEY" > /tmp/capstone-ec2-key.pem
  chmod 400 /tmp/capstone-ec2-key.pem

  if ! ssh-keygen -y -f /tmp/capstone-ec2-key.pem >/dev/null 2>&1; then
    echo "ERROR: Linux SSH private key is malformed."
    exit 1
  fi

  if ! ssh-keyscan -T 10 -H "$LINUX_TARGET_HOST" >> /root/.ssh/known_hosts; then
    echo "ERROR: Could not reach Linux target on port 22."
    exit 1
  fi

  echo "Linux SSH configuration ready."
fi

# macOS
if [ "$PREPARE_MAC" = true ]; then
  if [ -z "$MAC_TARGET_HOST" ]; then
    echo "ERROR: mac_hosts selected but MAC_TARGET_HOST is not set."
    exit 1
  fi

  if [ -z "$MAC_SSH_PRIVATE_KEY" ]; then
    echo "ERROR: MAC_SSH_PRIVATE_KEY is not set."
    exit 1
  fi

  echo "macOS target detected: $MAC_TARGET_HOST"

  printf '%b\n' "$MAC_SSH_PRIVATE_KEY" > /tmp/capstone-mac-key
  chmod 400 /tmp/capstone-mac-key

  if ! ssh-keygen -y -f /tmp/capstone-mac-key >/dev/null 2>&1; then
    echo "ERROR: macOS SSH private key is malformed."
    exit 1
  fi

  if ! ssh-keyscan -T 10 -H "$MAC_TARGET_HOST" >> /root/.ssh/known_hosts; then
    echo "ERROR: Could not reach macOS target on port 22."
    exit 1
  fi

  echo "macOS SSH configuration ready."
fi

# Windows
if [ "$PREPARE_WINDOWS" = true ]; then
  if [ -z "$WINDOWS_TARGET_HOST" ]; then
    echo "ERROR: windows_hosts selected but WINDOWS_TARGET_HOST is not set."
    exit 1
  fi

  if [ -z "$WINDOWS_USERNAME" ]; then
    echo "ERROR: WINDOWS_USERNAME is not set."
    exit 1
  fi

  if [ -z "$WINDOWS_PASSWORD" ]; then
    echo "ERROR: WINDOWS_PASSWORD is not set."
    exit 1
  fi

  echo "Windows target detected: $WINDOWS_TARGET_HOST"
  echo "Windows will use WinRM."
fi

echo "Starting Ansible..."

exec "$@"