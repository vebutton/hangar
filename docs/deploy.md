# Deploying Plane (Quadlets)

Plane Community Edition **v1.5.1**, translated from the release's `docker-compose.yml`
and `variables.env` into rootless Podman Quadlets. The box layout and its constraints are
in [vps.md](vps.md).

## Layout

| Repo path | Lands on the VPS at | What |
|---|---|---|
| `deploy/quadlets/` | `~/.config/containers/systemd/` | 13 `.container`, 10 `.volume`, 1 `.network` |
| `deploy/systemd/plane.target` | `~/.config/systemd/user/` | Groups the stack; enabled at boot (lingering) |
| `deploy/env/plane.env.example` | `~/hangar/plane.env` (0600) | Operator settings + generated secrets. Never committed |
| `deploy/env/templates/*.env.tmpl` | `~/hangar/env/*.env` (0600) | Per-service env, rendered from `plane.env` |
| `deploy/scripts/` | `~/hangar/deploy/scripts/` | `install.sh`, `plane.sh` (run on the VPS) |
| `scripts/deploy.sh` | — | Runs on the Mac: copies `deploy/` over, runs `install.sh` |

Naming: unit files are `plane-<svc>`, so the units are `plane-<svc>.service`.
`ContainerName=` keeps the compose service name (`api`, `web`, `plane-db`, …), because
the proxy and apps reach each other by those DNS names on the `plane-nw` network.

## Flow

```sh
scripts/deploy.sh                                # Mac: copy + install (no start)
ssh hangar '~/hangar/deploy/scripts/plane.sh pull'   # pre-pull images (~13)
ssh hangar '~/hangar/deploy/scripts/plane.sh start'
ssh -f hangar-tunnel                             # then http://localhost:8090
```

`install.sh` is idempotent. On first run it creates `plane.env` and fills every
`__GENERATE__` with `openssl rand -hex 24`. Later runs keep the existing secrets, re-render
the env files, replace the Quadlets, and remove stale `plane*` Quadlets. It fails if
`plane.env` is missing a key that's in the example.

Day to day: `plane.sh status | logs <svc> | restart | stop`.

## Why the env is split
Compose renames variables per service (`RABBITMQ_USER` → `RABBITMQ_DEFAULT_USER`,
`AWS_ACCESS_KEY_ID` → `MINIO_ROOT_USER`), and `podman --env-file` does no interpolation.
So `plane.env` is the single source, and each service gets its own rendered file. web,
space and admin get no env, as in compose.

## Memory caps (`--memory`, ≤4 GB steady)
Caps are per container (`PodmanArgs=--memory=`), not systemd `MemoryMax=`, so services
that size themselves from the visible cgroup limit (RabbitMQ, Postgres) see the real cap.

| Service | Cap | | Service | Cap |
|---|---|---|---|---|
| plane-db | 512m | | api | 768m |
| plane-redis | 128m | | worker | 640m |
| plane-mq | 384m | | beat-worker | 256m |
| plane-minio | 256m | | live | 256m |
| migrator (one-shot) | 512m | | space | 256m |
| web / admin / proxy | 64m each | | **Steady total** | **~3.6 GB** |

These are first guesses. Tune them from `plane.sh status` after the first run.

## Deviations from compose
- Proxy publishes `127.0.0.1:8090:80` only; no 443, no TLS.
- Postgres `max_connections=200` (compose: 1000) to save memory.
- `migrator` is `Type=oneshot` + `RemainAfterExit`; app services start after it, and
  they wait for migrations themselves anyway.
- Images are fully qualified (`docker.io/...`) and pinned to the release tag.

## Upgrading
1. Download the new release's `docker-compose.yml` + `variables.env`
   (`gh release download <tag> -R makeplane/plane`) and diff them against the current
   release: services, images, env anchors.
2. Bump the `makeplane/*` tags (and any backing-service images that changed) in
   `deploy/quadlets/`; mirror new env vars in the templates and the example.
3. Back up first (once backups exist), then `scripts/deploy.sh`, `plane.sh pull`,
   `plane.sh restart`.
