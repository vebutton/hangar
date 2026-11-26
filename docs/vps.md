# The VPS — access pattern and constraints

> Generic, committable pattern for the shared VPS Hangar deploys onto. Real hosts,
> users, key names and provider details live in `CLAUDE.local.md`. Source: an access
> brief from the co-tenant project (2026-11-25, repo + live box), produced with
> [prompts/vps-access-brief.md](prompts/vps-access-brief.md).

## Host
- Cloud VPS, dedicated-vCPU class. Ubuntu 24.04 LTS.
- 2 vCPU, 7.6 GiB RAM, 75 GB disk. **No swap.**
- Headroom at check time: ~6.1 GiB RAM available, 51 GB disk free, load ~0.1–0.35.

## Co-tenant
The box already runs an **agent gateway** (a Node service, ~1 GB RSS, with Chromium
spikes on demand) as a systemd user service under the existing login user, plus a
daily backup timer at 03:00 UTC. It's another project's production workload:
- Never restart it, reboot the box, or re-run its provisioning without the owner's OK.
- Don't run `terraform apply` or the co-tenant's full Ansible install against this box;
  both have drifted from it or overwrite live config.
- Keep Hangar's scheduled jobs away from 03:00 UTC and off the top of the hour.

## SSH
- Direct key auth on port 22. Password and keyboard-interactive auth are off.
- Existing login user = service user for the co-tenant, with NOPASSWD sudo. Root key
  login is enabled.
- Hangar gets its **own user** (`hangar`) with its own passphrase-protected key, so it
  stays out of the co-tenant's home directory, backups and sudo account.
- Recommended client config: `IdentitiesOnly yes`, `ServerAliveInterval 30`,
  `ServerAliveCountMax 10` (long sessions drop otherwise).
- Non-interactive SSH: no per-user PATH additions; `systemctl --user` needs
  `XDG_RUNTIME_DIR=/run/user/$(id -u)` and lingering enabled.

## Network
- ufw: default deny incoming; only 22/tcp open. Provider-level firewall: unknown.
- No reverse proxy, nothing on 80/443, no Tailscale on the box today.
- Ports in use: 22 (sshd, public), 18789 (gateway, loopback), 53 (resolved,
  loopback). Also avoid 18780–18799 and 11434.
- Hangar: Plane's proxy on `127.0.0.1:8090` (free), reached by `ssh -L 8090:127.0.0.1:8090`.
  No ufw change needed.

## Containers
- No container runtime installed. Ubuntu 24.04's `podman` package is 4.9.x, which
  supports Quadlets (to be confirmed once installed). Installing it needs no reboot.
- Rootless Podman under `hangar`, with lingering. Quadlets in
  `~/.config/containers/systemd/`; data under `~/hangar/` or named volumes.
- Don't use Docker: published ports bypass ufw.

## Memory budget
- Cap Plane's containers at ≤4 GB in total (`MemoryMax=` per Quadlet or a user slice),
  leaving room for the gateway and Chromium spikes.
- Add a 4 GB swapfile before deploying, so an OOM doesn't kill the gateway.

## Backups
- The co-tenant's backup covers only its own data. Hangar needs its own `pg_dump` and
  uploads backup (Unscheduled in `TODO.md`). Provider snapshots: unknown.
