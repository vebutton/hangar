#!/usr/bin/env bash
# Hangar — install/refresh the Plane Quadlets. Runs ON THE VPS as the hangar user.
# Idempotent. Doesn't pull images or start anything; see plane.sh for that.
#   1. Creates ~/hangar/plane.env from the example on first run (random secrets).
#   2. Renders per-service env files into ~/hangar/env/ (0600).
#   3. Copies Quadlets + plane.target into place, removing stale plane* Quadlets.
#   4. Validates with the Quadlet generator, reloads systemd, enables plane.target.
set -euo pipefail

[ "$(id -un)" = hangar ] || { echo "error: run as the hangar user" >&2; exit 1; }
SRC=$(cd "$(dirname "$0")/.." && pwd)        # ~/hangar/deploy
BASE=$HOME/hangar
QDIR=$HOME/.config/containers/systemd
UDIR=$HOME/.config/systemd/user
QUADLET=/usr/libexec/podman/quadlet
umask 077

# 1. Operator settings + secrets
if [ ! -f "$BASE/plane.env" ]; then
  while IFS= read -r line || [ -n "$line" ]; do
    if [[ $line == *=__GENERATE__ ]]; then
      echo "${line%__GENERATE__}$(openssl rand -hex 24)"
    else
      echo "$line"
    fi
  done < "$SRC/env/plane.env.example" > "$BASE/plane.env"
  echo "created $BASE/plane.env with generated secrets"
fi
chmod 600 "$BASE/plane.env"
if grep -q '=__GENERATE__$' "$BASE/plane.env"; then
  echo "error: $BASE/plane.env still has __GENERATE__ placeholders" >&2; exit 1
fi
for k in $(grep -oE '^[A-Z0-9_]+=' "$SRC/env/plane.env.example" | tr -d '='); do
  grep -q "^$k=" "$BASE/plane.env" || { echo "error: $k missing from plane.env (new in the example?)" >&2; exit 1; }
done

# 2. Per-service env files
set -a; . "$BASE/plane.env"; set +a
vars=$(grep -oE '^[A-Z0-9_]+=' "$BASE/plane.env" | sed 's/=$//; s/^/$/' | tr '\n' ' ')
mkdir -p "$BASE/env"
for t in "$SRC"/env/templates/*.env.tmpl; do
  out="$BASE/env/$(basename "$t" .tmpl)"
  grep -v '^#' "$t" | envsubst "$vars" > "$out.tmp"
  if grep -q '\${' "$out.tmp"; then
    echo "error: unresolved variable in $(basename "$t"):" >&2; grep '\${' "$out.tmp" >&2; rm "$out.tmp"; exit 1
  fi
  mv "$out.tmp" "$out"
done
echo "rendered env files into $BASE/env/"

# 3. Quadlets + target
mkdir -p "$QDIR" "$UDIR"
for f in "$QDIR"/plane*.container "$QDIR"/plane*.network "$QDIR"/plane*.volume; do
  [ -e "$f" ] || continue
  [ -e "$SRC/quadlets/$(basename "$f")" ] || { rm "$f"; echo "removed stale $(basename "$f")"; }
done
cp "$SRC"/quadlets/* "$QDIR/"
cp "$SRC"/systemd/plane.target "$UDIR/"

# 4. Validate, reload, enable
if ! "$QUADLET" -dryrun -user > /dev/null 2> "$BASE/quadlet-dryrun.err"; then
  echo "error: Quadlet validation failed:" >&2; cat "$BASE/quadlet-dryrun.err" >&2; exit 1
fi
grep -viE 'Loading source unit file|resolving path "/etc/containers/systemd/users' "$BASE/quadlet-dryrun.err" >&2 || true   # surface real warnings
systemctl --user daemon-reload
systemctl --user enable plane.target >/dev/null
echo "installed. Next: ~/hangar/deploy/scripts/plane.sh pull, then plane.sh start"
