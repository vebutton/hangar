# Prompt: VPS access brief

> **What this is:** a reusable prompt. Paste it into a Claude Code session in any project
> that already runs on the operator's VPS. That session answers with a structured
> brief, which the requesting project uses to deploy onto the same box without
> clashing with what's there.
>
> **Before pasting:** fill in the two `<…>` placeholders in "About the requesting
> project". Leave the rest as is.

---

## Prompt (copy everything below this line)

You're being asked for a **VPS access brief**. Another of my projects needs to deploy
onto the same VPS that this project uses. Write down what this project already knows
about getting onto that VPS and running services there, so the other project can follow
the same pattern and stay clear of what's already running.

### About the requesting project
- **Name / purpose:** `<e.g. a self-hosted web app run as Podman containers>`
- **What it will need on the box:** `<e.g. ~4 GB RAM, one localhost HTTP port, persistent volumes; private access over an SSH tunnel, no public domain>`

### Rules
1. **Read-only.** Don't change anything in this repo or on the VPS.
2. **Sources:** this repo's CLAUDE.md, CLAUDE.local.md, docs, scripts, config, and
   anything else in the repo you need. Don't run commands on the VPS unless I approve
   it in this session. If I do, run only read-only commands (e.g. `ss -tlnp`,
   `podman ps`, `free -h`, `df -h`, `podman --version`, `systemctl --user list-units`)
   and say which answers came from the live box and which from the repo.
3. **No secrets in the output.** Never include private keys, passwords, API tokens or
   key contents. Say *where* a secret lives (e.g. "key in `~/.ssh/<name>` on the Mac",
   "token in the macOS keychain under `<item>`") and *how* it's used, not its value.
4. **Split the output into two parts** (format below):
   - **Part A, the pattern:** generic and safe to commit. No hostnames, IPs, usernames,
     personal names or provider account details. Use placeholders like `<vps-host>`
     and `<deploy-user>`.
   - **Part B, the specifics:** the real values (host alias, IP, usernames, key file
     names, provider). They'll go into a gitignored local file. Still no secret values.
5. **Unknown is a fine answer.** If the repo doesn't say, write `unknown` and don't guess.
   Mark anything inferred rather than documented as `(inferred)`.
6. **Add the lessons.** Include gotchas, failures and fixes this project hit on the VPS.
   They're often the most useful part.

### Output format
Reply with one markdown document using exactly this structure.

```markdown
# VPS access brief — from <this project's generic description>
Generated: YYYY-MM-DD · Sources: repo | repo + live box

## Part A — Pattern (safe to commit)

### 1. Host & OS
- Provider type / plan class (e.g. "cloud VPS, shared vCPU"):
- OS and version:
- CPU / RAM / disk (total):
- Current headroom if known (free RAM, free disk, load):

### 2. SSH access
- How the Mac connects (ssh config alias? jump host? port):
- Auth method (key type, agent, 1Password/keychain SSH agent, etc.):
- Login user vs. service user(s); is root login disabled?
- sudo policy for the service user:
- Example ssh config block with placeholders:

### 3. Network & firewall
- Provider-level firewall (yes/no, which ports open):
- Host firewall (ufw/nftables/firewalld; rules summary):
- Publicly exposed ports and what owns them:
- How private services are reached (SSH tunnel, Tailscale/WireGuard, reverse proxy):
- Reverse proxy / TLS on the box (if any; which tool, where config lives):

### 4. Container runtime
- Runtime and version (Podman/Docker):
- Rootless or rootful; which user owns the containers:
- Orchestration (Quadlets, podman-compose, systemd units, other):
- Where unit/compose files live on the box:
- Is lingering enabled for the service user (`loginctl enable-linger`)?
- How images are updated / services restarted:
- Volumes / persistent data location:

### 5. Existing services & ports (avoid clashes)
| Service | Port(s) | Bound to (0.0.0.0 / 127.0.0.1) | Run as | Managed by |
|---|---|---|---|---|

### 6. Deploy workflow
- How changes reach the box (git pull on box, scp/rsync, CI, manual):
- Scripts in this repo that do it (paths):
- How secrets/env files get onto the box and where they live there:

### 7. Backups & recovery
- Provider snapshots/backups enabled?
- App-level backups (what, where to, schedule):
- Restore ever tested?

### 8. Monitoring & logs
- How you check health / read logs (journalctl, podman logs, external monitor):

### 9. Lessons learned / gotchas
- 

### 10. Recommendations for the requesting project
- Suggested ports, user, directory layout, and anything to avoid, given what's already there:

## Part B — Specifics (local only, never commit)
- Provider:
- Host alias in `~/.ssh/config`:
- Hostname / IP:
- Login user / service user(s):
- SSH key file name(s) and where they're stored (no contents):
- Other credential locations (no values):
- Provider console / project name:
```

When you're done, also tell me in one line which sections were `unknown`, so I know
what to check on the box directly.
