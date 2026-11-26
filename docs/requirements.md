# Hangar — Requirements

Open questions and work items live in [TODO.md](../TODO.md), not here. Hosts,
providers and credentials live in `CLAUDE.local.md`.

## Track 1 — Plane deployment

### Goal
Self-host Plane Community Edition on the operator's VPS as the requirements and
work-tracking system for software projects. Coding agents (Claude Code) use it.

### Priority
First objective (confirmed): Plane running on the VPS, reachable over the SSH tunnel,
with Claude Code reading and writing work items via MCP. Everything else is
explicitly secondary to that: backups, choosing a pilot project, the repo-to-project
linking convention, and keeping the tunnel up permanently.

### Hard constraints
- **Podman only.** No Docker, no native install. Podman runs natively on the Linux VPS,
  with no podman machine.
- **Standalone.** No dependency on the operator's separate Podman tooling project.
- **Private only.** No public domain, no public TLS. Bind every published port to
  localhost and use an SSH tunnel for all access (browser and MCP).
- **Single user** (the operator) for now. One Plane project per software project.
- **Secrets never committed.** `plane.env` with real values, API tokens and SSH keys stay
  out of the repo. Commit only a `plane.env.example`.
- **No cost / licences:** Community Edition only. No Commercial-only features
  (prime-cli, OAuth MCP).
- **Pilot before automation:** no cross-repo automation until a pilot project validates
  the workflow.

### Deployment shape (from Plane docs, 2026-11-25)
- **Services (CE v1.5.1 compose, 13):** `web`, `space`, `admin`, `live`, `api`,
  `worker`, `beat-worker`, `proxy`, plus a one-shot `migrator`. Backing services:
  Postgres 15.7 (`plane-db`), Valkey 7.2 (`plane-redis`), RabbitMQ 3.13 (`plane-mq`),
  MinIO-compatible object storage (`plane-minio`, image `pgsty/silo`).
- **Install assets:** the GitHub release ships `docker-compose.yml`, `variables.env`
  and `setup.sh`; they assume Docker. Plane's own Podman Quadlets method installs
  **Commercial Edition** only, so Hangar writes its own Quadlets from the CE compose
  file (T-PLANE-02).
- **Ports:** the `proxy` serves `LISTEN_HTTP_PORT` (default 80) / `LISTEN_HTTPS_PORT`.
  Only HTTP is needed behind the tunnel.
- **Key env:** `WEB_URL` and `CORS_ALLOWED_ORIGINS` must equal the browser's origin
  through the tunnel: `http://localhost:8090`.
- **Persistent data:** volumes for Postgres (`pgdata`), Redis (`redisdata`), uploads
  and MinIO. Backup scope = Postgres + object storage.
- **Minimum host:** 2 CPU, 4 GB RAM (8 GB recommended), x64 or ARM64.

### Agent integration
- **Primary route:** the Plane MCP server (`makeplane/plane-mcp-server`, Python/FastMCP),
  run locally on each Mac via `uvx plane-mcp-server stdio`.
  - Env: `PLANE_API_KEY`, `PLANE_WORKSPACE_SLUG`, `PLANE_BASE_URL` (the tunnel URL).
  - On Community Edition only stdio + token works. The hosted server and OAuth HTTP
    transport can't reach a private instance.
  - Needs Python 3.11+ (sources disagree: 3.10+ / 3.11+; 3.11 is safe) and `uv`.
  - Tools are one per resource with an `action` parameter: `workitem`, `project`,
    `state`, `label`, `cycle`, `module`, `workitem_comment`, etc.
- **Secondary:** REST API (`x-api-key: <token>`, `/api/v1/...`); webhooks unverified.
  Only if a need appears.
- **Dependency:** the MCP server only works while the SSH tunnel is up (see TODO.md →
  Open questions).

### Done when (Track 1)
1. Plane runs under Podman on the VPS and survives a reboot.
2. Nothing listens on a public interface.
3. The web UI loads on a Mac through the SSH tunnel; the workspace exists.
4. Claude Code on a Mac creates, updates and closes a work item via the MCP server.
5. The deployment is reproducible from this repo's config plus the operator's secrets.

### Later (not launch requirements)
- Backups: scheduled Postgres dump + object-storage copy to offsite S3-compatible storage.
- Repo-to-Plane-project linking convention, settled during the pilot.

### Reference observations
- Plane self-hosting docs: developers.plane.so/self-hosting (methods overview, Docker
  Compose, Podman Quadlets, database & storage). The Docker Compose page leads with
  Commercial Edition; the Community Edition steps sit in a collapsed section.
- MCP docs: developers.plane.so/dev-tools/mcp-server and `mcp-server-self-host`; repo
  github.com/makeplane/plane-mcp-server. Tool counts and token locations differ between
  the docs and the README, so check against the installed version.
- Podman Quadlets page (read 2026-11-26): Commercial Edition only (`prime.plane.so`
  tarball v2.6.3, Podman ≥ 4.4); doesn't cover stop, upgrade, backup or localhost binding.
- Not yet read: the backup page, the REST API reference and
  the webhooks docs.
