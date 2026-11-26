#!/usr/bin/env bash
# Hangar — push deploy/ to the VPS and run install.sh there. Runs ON THE MAC.
# Doesn't pull images or start Plane. Override the SSH alias with HANGAR_HOST.
set -euo pipefail
HOST=${HANGAR_HOST:-hangar}
cd "$(dirname "$0")/.."
ssh "$HOST" 'rm -rf ~/hangar/deploy && mkdir -p ~/hangar/deploy'
COPYFILE_DISABLE=1 tar --no-xattrs --no-mac-metadata -C deploy -cf - . | ssh "$HOST" 'tar -C ~/hangar/deploy -xf -'
ssh "$HOST" 'bash ~/hangar/deploy/scripts/install.sh'
