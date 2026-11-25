# Hangar

Self-hosted [Plane](https://plane.so) (Community Edition) on a personal VPS, run under
Podman, as the requirements and work-tracking backbone for software projects built with
coding agents.

Each software project gets its own Plane project. Claude Code reads and writes work
items through the [Plane MCP server](https://github.com/makeplane/plane-mcp-server),
replacing ad-hoc `todos.md` files.

## Shape

- **Runtime:** Podman on Linux (no Docker). Orchestration via systemd Quadlets or
  podman-compose; still being decided.
- **Access:** private only. Every port binds to localhost on the VPS; the web UI and
  the MCP server reach it through an SSH tunnel. No public domain, no TLS.
- **Agents:** `uvx plane-mcp-server stdio` runs locally on each Mac, pointed at the
  tunnelled instance with an API token.

## Status

Planning. Nothing is deployed yet. See [docs/requirements.md](docs/requirements.md)
for the spec and [TODO.md](TODO.md) for the task register.

## Layout

| Path | Role |
| --- | --- |
| `CLAUDE.md` | Project context for Claude Code sessions |
| `TODO.md` | Task register: work items, open questions, standing operations |
| `docs/requirements.md` | Requirements and deployment notes |
| `docs/session-state.md` | Session history and decisions |

Deployment config (Quadlet units or compose file, `plane.env.example`, scripts) lands
here as the work progresses. Real secrets never enter the repo.
