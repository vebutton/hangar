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
