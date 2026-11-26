# Plane MCP server for Claude Code (Mac)

Coding agents reach Plane through the official `plane-mcp-server`, run locally in
stdio mode and pointed at the self-hosted instance through the SSH tunnel. Hosted MCP and
OAuth can't reach a private Community Edition instance, so this uses an API token.

## Prerequisites
- `uv` (provides `uvx`); the server needs Python 3.11+ (uvx fetches one if needed).
- SSH aliases `hangar-tunnel` (forwards `localhost:8090`); see [vps.md](vps.md).
- A Plane API token: **Settings → Profile → API tokens**
  (`http://localhost:8090/settings/profile/api-tokens/`).

## Setup (once per Mac)
```sh
# 1. Store the token in the macOS keychain (prompts; never in shell history)
security add-generic-password -a "$USER" -s hangar-plane-api-key -w

# 2. Register the server at user scope (available in every repo)
claude mcp add plane --scope user -e PLANE_WORKSPACE_SLUG=<workspace-slug> \
  -- <path-to-hangar>/scripts/plane-mcp.sh

# 3. Check
ssh -f hangar-tunnel
claude mcp get plane        # Status: ✔ Connected
```

[`scripts/plane-mcp.sh`](../scripts/plane-mcp.sh) reads the token from the keychain,
sets `PLANE_BASE_URL=http://localhost:8090`, and runs `uvx plane-mcp-server@0.3.7 stdio`
(pinned; bump deliberately). No secret is written to any config file.

## Notes
- **The tunnel must be up** whenever an agent uses Plane. Claude Code loads MCP servers
  at session start, so open the tunnel first or restart the session.
- **First run is slow** (~40 s): uvx downloads the package. This can exceed Claude
  Code's 30 s connect timeout once; run `claude mcp get plane` again after the cache warms.
- v0.3.7 advertises 33 tools for the workspace.
- Revoke or rotate: delete the token in Plane, then
  `security delete-generic-password -s hangar-plane-api-key` and re-add.
