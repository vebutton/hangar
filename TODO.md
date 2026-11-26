# Hangar — ToDo

> The single durable task register. Committed, so every line stays generic: people's
> names, hosts, internal product names, credentials and customer-tied dates live in
> `CLAUDE.local.md` and are referenced, never copied here. Build and resolution dates
> are fine.

## Rules
- **ID:** `T-<SLUG>-<nn>`. Permanent, never reused, never renumbered. Numbered per track.
- **Slugs** come from CLAUDE.md → Tracks, plus `PROJ` for project/repo plumbing that
  belongs to no track. A new track is added to CLAUDE.md first, by agreement, never
  invented here.
- **An item is work that finishes.** Anything that recurs, or would never close, is a
  Standing operation (section 4): no ID, no checkbox.
- **Track and deliverable are fixed at creation.** If the deliverable changes, close the
  item with a pointer and open a new one that references the old ID. Don't retitle.
- **New items** append at the end of their track. Propose each one with a proposed ID
  and wait for agreement.
- **Closed items** stay in place, ticked: `(resolved YYYY-MM-DD: outcome)`. Move them to
  Archive only when the resolution no longer informs current work.
- **Item detail is current state only:** what's left, what it waits on, priority,
  dependencies, pointers. What happened and when goes in `docs/session-state.md`.
- **Open questions live only here** (section 3). Requirements and design docs point to
  this section instead of keeping their own lists.
- **This is the only durable task list.** The in-session todo tool is scratch. At end of
  session, reconcile it into this file, and give every open or next-step line written to
  `docs/session-state.md` an ID or an Unscheduled line, or drop it deliberately.
- **Refer to items by ID everywhere** (CLAUDE.md, docs, commit messages), never by
  position ("pickup item 3"). A commit that does an item's work names its ID.

## 1. Items

### PROJ — Project and repo plumbing
- [x] T-PROJ-01 Create the remote GitHub repo and push the first commit (resolved 2026-11-25: public repo, first commit pushed)

### PLANE — Track 1: Plane deployment
- [x] T-PLANE-01 Gather the VPS access pattern (SSH user, keys, firewall, existing services/ports) from the operator's other VPS projects (resolved 2026-11-26: pattern in `docs/vps.md`, specifics in `CLAUDE.local.md`)
- [ ] T-PLANE-02 Decide Quadlets vs podman-compose for running Plane's stack
- [ ] T-PLANE-03 Check VPS capacity (≥2 CPU, ≥4 GB RAM free, 8 GB recommended) and Podman version
- [ ] T-PLANE-04 Commit the deployment config (units or compose, `plane.env.example`, start/stop/upgrade scripts)
- [ ] T-PLANE-05 Deploy Plane on the VPS, bound to localhost only
- [ ] T-PLANE-06 Reach the web UI through an SSH tunnel; create the admin account and workspace
- [ ] T-PLANE-07 Create an API token and configure the Plane MCP server (stdio) in Claude Code on a Mac
- [ ] T-PLANE-08 Smoke test: Claude Code creates, updates and closes a work item via MCP
- [ ] T-PLANE-09 Prepare the box: OS updates + reboot (gateway confirmed back), 4 GB swapfile, `hangar` user with lingering and a passphrase-protected key, Podman installed

## 2. Item detail

### PLANE
- **T-PLANE-03:** capacity mostly known from the access brief (`docs/vps.md`): 2 vCPU,
  7.6 GiB RAM with ~6.1 GiB available, no swap, 51 GB disk free. Left: the Podman
  version, which only exists once Podman is installed (expected 4.9.x).
- **T-PLANE-02:** start from Plane's "Podman Quadlets" self-hosting page
  (developers.plane.so → Self-hosting → Methods). Lean: Quadlets (systemd-native
  restarts, documented by Plane). Resolve after T-PLANE-03 confirms the Podman version.
- **T-PLANE-09:** blocks T-PLANE-05. The operator applies the pending updates and
  reboot first, since a reboot restarts the co-tenant gateway. Then: swapfile,
  `useradd hangar` + `loginctl enable-linger hangar`, new ed25519 key with a passphrase
  on the Mac, `apt install podman`. Recording `podman --version` closes T-PLANE-03.
- **T-PLANE-05:** the proxy listens on `LISTEN_HTTP_PORT`. Bind it to `127.0.0.1` so
  nothing is exposed publicly. Set `WEB_URL` / `CORS_ALLOWED_ORIGINS` to the tunnel origin.
- **T-PLANE-07:** `uvx plane-mcp-server stdio` with `PLANE_API_KEY`,
  `PLANE_WORKSPACE_SLUG`, `PLANE_BASE_URL=http://localhost:<tunnel-port>`. Token never
  committed.

## 3. Open questions
- **Pilot project:** which existing repo with real ongoing feature work pilots Plane?
  Already ruled out: see `CLAUDE.local.md`. Resolves after T-PLANE-08; promote into a
  pilot track then.
- **Repo-to-project link:** how each repo points at its Plane project (a line in its
  CLAUDE.md vs a small config file with the project ID). Decide during the pilot.
- **Podman approach:** Quadlets vs podman-compose. Resolved by T-PLANE-02.
- **Tailscale on the VPS:** join the VPS to the operator's tailnet (this Mac plus 3
  devices) so it can reach local resources, and possibly replace the SSH tunnel. The VPS
  was kept off the tailnet to isolate the co-tenant's agents from local devices, so
  joining needs ACLs/tags that limit what the VPS can reach. Affects how the tunnel stays
  up (next question). Owner's call; decide before T-PLANE-06.
- **Keeping the tunnel up:** how the SSH tunnel stays available for the MCP server from
  the Macs (manual `ssh -L`, autossh, launchd agent). Decide after T-PLANE-08; manual is
  acceptable for the first test.

## 4. Standing operations
Recurring work: no IDs, no checkboxes, tracked by last-run date.

| Operation | Cadence / trigger | Last run | Notes |
|---|---|---|---|
| Upgrade Plane | On new release, operator's call | — | Back up first once backups exist |

## 5. Unscheduled
Ideas that came up but aren't committed work. No ID until promoted into a track.
- Scheduled Postgres dumps plus uploads/MinIO data copied to offsite S3 storage. Not a
  launch requirement.
- Create the Plane project automatically when a new repo is started. Only after the pilot.
- Hand Plane's Podman deployment over to the operator's Podman tooling project once it
  has a Linux mode.
- Webhooks from Plane to other services.
- VPS hardening for the box owner (outside Hangar's scope): root key login is enabled,
  the co-tenant user has NOPASSWD sudo, and its Mac key has no passphrase.
- Compare against GitHub Issues/Projects after the pilot.

## 6. Archive
Closed items whose resolution no longer informs current work.
