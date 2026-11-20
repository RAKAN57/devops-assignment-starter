# DevOps Assignment — Notifications API

Node.js and Express API backed by PostgreSQL, packaged with Docker Compose and a GitHub Actions build workflow.

## What's included

A minimal Node.js + Express API backed by PostgreSQL:

| Method | Path | Description |
|--------|------|-------------|
| GET | `/health` | Health check (includes DB connectivity) |
| GET | `/users` | List all users |
| POST | `/users` | Create a user (`{ "name": "Alice" }`) |
| GET | `/notifications?user_id=<id>` | List notifications for a user |
| POST | `/notifications` | Create a notification |

## Run with Docker Compose

Prerequisites: Docker Engine with the Compose plugin.

Create a local environment file and set a strong database password:

```bash
cp .env.example .env
# Edit .env and replace DB_PASSWORD before starting.
docker compose up --build -d
docker compose ps
```

The API listens on `http://localhost:8080` by default. Compose waits for PostgreSQL to become healthy before starting the API, and reports API health through `/health`.

Example requests:

```bash
curl http://localhost:8080/health
curl -X POST http://localhost:8080/users -H "Content-Type: application/json" -d '{"name":"Alice"}'
curl http://localhost:8080/users
curl -X POST http://localhost:8080/notifications \
  -H "Content-Type: application/json" \
  -d '{"user_id":1,"title":"Hello","body":"Welcome!","channel":"in_app"}'
curl "http://localhost:8080/notifications?user_id=1"
```

Stop the services with `docker compose down`. Persistent database data is stored in the `postgres_data` volume; `docker compose down -v` removes it.

## Database operations

The scripts require Docker Compose and a POSIX shell. Run them from the repository root:

```bash
scripts/backup-db.sh
scripts/restore-db.sh backups/notifications-YYYYMMDDTHHMMSSZ.sql.gz
```

Backups are compressed SQL dumps under `backups/`. Restore prompts for confirmation because it changes database contents. Keep backups in a secure location; they contain application data.

## CI

GitHub Actions validates the Compose configuration, starts the API and database, and checks the health, user, and notification endpoints on pull requests and pushes to `main`. After verification succeeds on `main`, a separate job publishes the API image to GitHub Container Registry (`ghcr.io`) with both the commit SHA and `latest` tags. The workflow uses the repository's `GITHUB_TOKEN`; no personal registry token is needed.

## Environment variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PORT` | HTTP port | `8080` |
| `DB_HOST` | PostgreSQL host | `localhost` locally; `db` in Compose |
| `DB_PORT` | PostgreSQL port | `5432` |
| `DB_NAME` | Database name | `notifications` |
| `DB_USER` | Database user | `app` |
| `DB_PASSWORD` | Database password | `app` |

For Compose, copy `.env.example` to `.env` and set `DB_PASSWORD`. Do not commit `.env` or database backups.
