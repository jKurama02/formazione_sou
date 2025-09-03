#!/bin/sh
set -e # Exit immediately if a command exits with a non-zero status (FAILURE)
# idk if it's needed but better safe than sorry

# launch SSHD in background
/usr/sbin/sshd -D &

# Start Docker (the original command of the container)
exec "$@"