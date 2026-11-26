# Session State — Archaeology

> Backward-looking detail: thread-by-thread work, decisions and reasoning, ruled-out
> paths, commits, memories banked. The forward-looking brief lives in CLAUDE.md ->
> Session State. Consult this file on demand when depth is needed.

## 2026-11-25 / 26 — VPS access brief (T-PLANE-01)
- Wrote the reusable prompt `docs/prompts/vps-access-brief.md` (commit 6b422ce) and ran
  it in the co-tenant project. Brief returned (repo + live box) and kept in `collateral/`.
- Recorded the scrubbed pattern in `docs/vps.md` and the specifics in `CLAUDE.local.md`.
  Closed T-PLANE-01.
- Decisions: Hangar runs under its own `hangar` user with a new passphrase-protected key.
  Add swap before deploying (4 GB recommended; the operator said 2 or 4). The operator
  applies the pending OS updates and reboot first and confirms the co-tenant gateway
  comes back.
- Raised: put the VPS on the operator's tailnet (open question in `TODO.md`).
- Noted for the box owner: root key login, NOPASSWD sudo, unencrypted key (Unscheduled).

## 2026-11-26 — Box prepared; Quadlets decided (T-PLANE-02/03/09)
- Operator applied OS updates + reboot and added a 4 GB swapfile; co-tenant gateway
  confirmed back. Operator created a passphrase-protected key on the Mac.
- Via the existing login user: created `hangar` (uid 1001, subuid range, lingering,
  key-only), installed Podman 4.9.3 + netavark/aardvark-dns/passt/uidmap. No reboot
  needed. Verified a `hangar` login and rootless `podman info` (netavark, overlay,
  cgroup v2, Quadlet user generator present).
- Plane's Podman Quadlets page turned out to be Commercial Edition only. Options weighed:
  Commercial free plan + Plane's installer (A), CE + our own Quadlets (B), CE +
  podman-compose (C). Chose B: native boot and restart, per-service memory caps,
  localhost binding we control, and the repo fully reproduces the deploy. Cost: we
  translate the compose file and re-check it on upgrades.
- Read CE v1.5.1 (released 2026-11-25) `docker-compose.yml` + `variables.env`; findings
  in `TODO.md` → T-PLANE-04 detail.

## 2026-11-26 (cont.) — Quadlets drafted (T-PLANE-04)
- Read the CE v1.5.1 image internals: the proxy's Caddyfile routes by service name
  (web/space/admin/live :3000, api :8000, plane-minio :9000). The api, worker and beat
  entrypoints wait for the db and for migrations themselves.
- Box checks: memory controller delegated to `hangar` (systemd 255); `envsubst` present.
- Drafted `deploy/` (Quadlets, `plane.target`, env example + templates, `install.sh`,
  `plane.sh`), `scripts/deploy.sh` and `docs/deploy.md`. Decisions: per-container
  `--memory` caps instead of systemd `MemoryMax=` (RabbitMQ sizes itself from the
  visible limit); per-service env files rendered with envsubst; Postgres
  max_connections 200; proxy on 127.0.0.1:8090 only.
- Gotcha: the Bash tool runs zsh, where unquoted `$var` doesn't word-split. It broke a
  multi-volume loop; fixed by hand.
- Not yet validated on the box and not committed; waiting on the operator's OK to run
  `scripts/deploy.sh`.
- Ran `scripts/deploy.sh` with the operator's OK. Three fixes along the way: the
  placeholder check matched the example's comment line; the env-var regex skipped names
  with digits (`AWS_S3_*`); macOS tar xattr warnings (now `--no-xattrs
  --no-mac-metadata`). Quadlet 4.9 accepted the migrator's `Type=oneshot`. The proxy
  publishes `127.0.0.1:8090:80`. All env files are 0600 with nothing unresolved.
  The only generator warning is the harmless missing `/etc/containers/systemd/users/1001`.
  Closed T-PLANE-04. Added the memory-cap tuning to T-PLANE-05's done criteria.
- First start (T-PLANE-05), with the operator's OK: pulled 10 images in 46 s (four
  services share plane-backend) and started `plane.target` in ~2 min. API and space
  answered ~35 s after the units went active (the api entrypoint runs
  register/configure/collectstatic first). All routes 200, `/uploads/` 403 (bucket
  present). Cold-start memory ~0.8 GB in total, no restarts; gateway untouched.
- The operator OK'd restarting the co-tenant gateway for that occasion only; a gateway
  restart or reboot still needs an OK each time (`docs/vps.md`).
- T-PLANE-06: the operator created the admin account (company "Hangar") and the
  workspace, and disabled public sign-up. Workspace slug in `CLAUDE.local.md`. In
  v1.5.1, API tokens live at Settings → Profile → API tokens
  (`/settings/profile/api-tokens/`).
- T-PLANE-07: token in the macOS keychain (`hangar-plane-api-key`). `scripts/plane-mcp.sh`
  wraps `uvx plane-mcp-server@0.3.7 stdio`. Registered at user scope (operator's choice:
  the pilot runs from another repo). The first connect timed out (30 s) while uvx
  downloaded; after warming, connected with 33 tools. REST check: `/api/v1/users/me/` 200.
