#!/usr/bin/env bash
# Hangar — day-to-day control of the Plane stack. Runs ON THE VPS as hangar.
#   plane.sh pull          pull every image the Quadlets reference
#   plane.sh start|stop|restart
#   plane.sh status        unit states + container memory
#   plane.sh logs <svc>    follow one service's journal (e.g. api, proxy, db)
set -euo pipefail
QDIR=$HOME/.config/containers/systemd

case "${1:-}" in
  pull)
    grep -h '^Image=' "$QDIR"/plane-*.container | cut -d= -f2- | sort -u |
      while read -r img; do podman pull -q "$img" >/dev/null && echo "pulled $img"; done ;;
  start)   systemctl --user start plane.target ;;
  stop)    systemctl --user stop plane.target ;;
  restart) systemctl --user stop plane.target; systemctl --user start plane.target ;;
  status)
    systemctl --user list-units 'plane*' --all --no-pager --no-legend
    echo; podman stats --no-stream --format 'table {{.Name}}\t{{.MemUsage}}\t{{.CPUPerc}}' ;;
  logs)
    [ -n "${2:-}" ] || { echo "usage: plane.sh logs <svc>" >&2; exit 1; }
    journalctl --user -u "plane-${2#plane-}" -f ;;
  *) sed -n '2,7p' "$0"; exit 1 ;;
esac
