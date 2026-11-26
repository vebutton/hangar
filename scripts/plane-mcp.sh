#!/usr/bin/env bash
# Hangar — start the Plane MCP server (stdio) for Claude Code. Runs ON THE MAC.
# The API token comes from the macOS keychain, so it never sits in a config file:
#   security add-generic-password -a "$USER" -s hangar-plane-api-key -w   (prompts)
# PLANE_WORKSPACE_SLUG is set in the Claude Code MCP config (`claude mcp add -e`).
# Needs the SSH tunnel up: `ssh -f hangar-tunnel` (→ http://localhost:8090).
set -euo pipefail

PLANE_API_KEY=$(security find-generic-password -s hangar-plane-api-key -w 2>/dev/null) || {
  echo "plane-mcp: no keychain item 'hangar-plane-api-key'" >&2; exit 1; }
export PLANE_API_KEY
export PLANE_BASE_URL=${PLANE_BASE_URL:-http://localhost:8090}
: "${PLANE_WORKSPACE_SLUG:?plane-mcp: PLANE_WORKSPACE_SLUG not set}"

exec uvx plane-mcp-server@0.3.7 stdio
