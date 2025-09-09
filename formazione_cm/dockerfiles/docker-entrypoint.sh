#!/bin/sh
set -e # Exit immediately if a command exits with a non-zero status (FAILURE)
# idk if it's needed but better safe than sorry

# Regenerate ssh key
ssh-keygen -A

if [ ! -d "/var/run/sshd" ]; then
    mkdir -p /var/run/sshd
fi

# launch SSHD in background
/usr/sbin/sshd -D &

# Start the Docker service
# Config insecure registry
mkdir -p /etc/docker && sudo tee /etc/docker/daemon.json <<EOF
{
  "insecure-registries": ["172.18.0.2:5000"]
}
EOF

# Start Docker (the original command of the container)
exec "$@"