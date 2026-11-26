# Hangar — Project Context for Claude Code

> **File roles:** CLAUDE.md (this file) = project context. `TODO.md` = the task register.
> `docs/requirements.md` = the spec. `CLAUDE.local.md` = internal specifics (gitignored).

## User
The operator: a solo developer who runs several software projects with coding agents
(Claude Code) and already hosts services on a personal VPS. They are comfortable with
Podman, SSH and self-hosting. Committed files never name the user or their employer:
both live in `CLAUDE.local.md`, so this file reads correctly in any teammate's session.

## This Project
Hangar self-hosts **Plane**, the open-source Jira/Linear alternative, on the operator's
VPS. It becomes the requirements and work-tracking backbone for real software projects.
Each software project gets its own Plane project. Coding agents read and write work
items through Plane's MCP server, replacing ad-hoc `todos.md` files. It's private and
single-user, and self-hosted to avoid licence costs.

- **Full requirements:** [docs/requirements.md](docs/requirements.md)
- **Task register:** [TODO.md](TODO.md) is the only durable task list. Read it before
  planning any work.
- **Internal details:** `CLAUDE.local.md`. It's gitignored; read it every session. It
  holds the user's name, the VPS provider and host, the backup provider, internal
  project names and credential workflows.

## Input / Output
- **Input:** Plane's official container images and install assets; operator-supplied
  config (`plane.env` values, secrets kept out of the repo).
- **Output:** a running Plane instance on the VPS; the deployment config that
  reproduces it (Quadlet units, env template, scripts) in this repo;
  a documented MCP client setup that coding agents use from the operator's Macs.

## Interface
- Plane web UI, reached privately through an SSH tunnel (no public domain, no TLS).
- Plane MCP server (`uvx plane-mcp-server stdio`, run locally on each Mac), pointed at
  the tunnelled instance via `PLANE_BASE_URL`.
- Plane REST API (`x-api-key` header) and webhooks, if needed later.

## Key Integrations
- Plane Community Edition (self-hosted), Plane MCP server, Plane REST API
- Podman on Linux (rootless where Plane allows; natively, with no podman machine VM)
- SSH (tunnel for UI and MCP access)
- Offsite S3-compatible storage for backups (later; provider in `CLAUDE.local.md`)

## Tech / Tooling
- **Runtime:** rootless Podman 4.9.3 on the VPS, under a dedicated `hangar` user. No Docker, no native install. **Standalone:** no
  dependency on the operator's separate Podman tooling project (see `CLAUDE.local.md`).
- **Orchestration:** systemd **Quadlets**, written in this repo by translating Plane
  Community Edition's release `docker-compose.yml` (decided in T-PLANE-02). Plane's own
  Quadlets installer is Commercial Edition only; don't use it. VPS layout and
  constraints: [docs/vps.md](docs/vps.md).
- **Repo content:** deployment config and shell scripts, plus docs. No application
  code or language toolchain yet. If a helper script grows beyond shell, Python uses
  pyenv + uv (never venv/Poetry/Conda/Pipenv).
- **MCP server prerequisite on the Macs:** `uv` (for `uvx`), Python 3.11+.

## How to Work With This User
- Be direct and concise; give a recommendation, not a survey.
- Ask rather than assume when something material is ambiguous.
- Confirm before anything that touches the VPS (deploys, restarts, deletes) or creates
  remote artifacts.
- Pilot first, automate later: don't build cross-project automation until the pilot
  proves the workflow.

## Environment
First started: CLI
Date: 2026-11-25

---

## Tracks

> A **track** is a distinct workstream with its own objective. Work items live in
> `TODO.md`, with IDs `T-<SLUG>-<nn>`. Slugs are permanent.

### Track 1 — Plane deployment (PLANE)
- **Objective:** Plane running under standalone Podman on the VPS. You can reach it
  privately over an SSH tunnel, and Claude Code on a Mac can read and write work items
  through the Plane MCP server.
- **Status:** In progress. Quadlets installed; next is the first start (T-PLANE-05).
- **Depends on:** Nothing; this is the first track.

**Further tracks:** None yet. Add each as `### Track N — [Name] ([SLUG])` with the same
three fields and a matching section in `TODO.md`. State whether it **may depend on an
existing track** or **must stand alone**.

---

## Session State

> Forward-looking operating context only. Backward-looking archaeology lives in
> `docs/session-state.md`. Task state lives in `TODO.md`.

**Last:** T-PLANE-01/02/03/09 closed. The box has 4 GB swap, a `hangar` user (SSH aliases
`hangar` for a shell, `hangar-tunnel` for the 8090 forward) and rootless Podman 4.9.3.
Decided: Community Edition with our own Quadlets. T-PLANE-04 done: Quadlets installed and validated
on the box (`plane.target` enabled, secrets generated in `~hangar/hangar/plane.env`).
No images pulled, no containers running.

**Next session — pick up here:**
1. Cold start: re-read CLAUDE.md and CLAUDE.local.md.
2. T-PLANE-05: with the operator's OK, `plane.sh pull` + `plane.sh start` on the box,
   then tune the memory caps (see the item detail).
3. Tailscale vs SSH tunnel (TODO.md open question) before T-PLANE-06.

**Continuity reminders:**
- Plane's official scripts (`setup.sh`, prime-cli) assume Docker, and Plane's Quadlets
  method is Commercial Edition. Translate the CE compose file; don't run either.
- `WEB_URL` and `CORS_ALLOWED_ORIGINS` in `plane.env` must match the exact origin the
  browser uses through the tunnel (`http://localhost:8090`), or the UI breaks.
- On Community Edition, the hosted MCP server and OAuth can't reach a private instance.
  Use local stdio with an API token.

**Session continuity:** Next session is a cold start. Re-read CLAUDE.md before doing
anything. Sessions are never re-entered. End-of-session updates cover three layers: this
brief, `docs/session-state.md`, and `TODO.md`.
