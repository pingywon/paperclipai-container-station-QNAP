# paperai Docker App Stack for QNAP Container Station

A beginner-friendly, single-file Docker Compose stack for QNAP NAS Container Station.

> GitHub repository names cannot contain spaces. Use this slug:
> `paperai-container-station`
> and keep the human-readable title above in this README.

This stack deploys **three services together**:
1. **PostgreSQL 17 Alpine** (database)
2. **Paperclip AI** (app/UI)
3. **OpenClaw** (gateway/service)

---

## What this repo is for

This repository is intentionally opinionated for reliability on QNAP:
- Uses Compose **v3.8**
- Uses persistent named volumes
- Uses simple `depends_on` ordering
- Avoids custom OpenClaw startup command overrides (common crash-loop trigger)
- Keeps setup steps minimal for new users

---

## Files in this repo

- `docker-compose.yml` — main stack definition
- `.env.example` — optional env file template (if you later prefer Option A)
- `.gitignore` — keeps local secrets/files out of Git

---

## Prerequisites

- QNAP NAS with **Container Station** installed
- Internet access from NAS to pull images
- At least one AI API key (Anthropic and/or OpenAI)

---

## API keys: two valid methods (choose one)

You can provide keys to **both Paperclip and OpenClaw** in exactly two ways:

### Option A — inline in `docker-compose.yml`

Put keys directly in YAML:

```yaml
ANTHROPIC_API_KEY: "sk-ant-..."
OPENAI_API_KEY: "sk-proj-..."
```

### Option 2 — `.env` file next to compose file

1. Create `.env` in the same folder as `docker-compose.yml`
2. Add:

```env
ANTHROPIC_API_KEY=sk-ant-...
OPENAI_API_KEY=sk-proj-...
```

3. In `docker-compose.yml`, use variable syntax:

```yaml
ANTHROPIC_API_KEY: "${ANTHROPIC_API_KEY:-}"
OPENAI_API_KEY: "${OPENAI_API_KEY:-}"
```

> Recommendation: use **one method consistently** for both `paperclip` and `openclaw`.

---

## Quick start (current file defaults to Option A placeholders)

1. Open `docker-compose.yml`.
2. Replace these values in **both** `paperclip` and `openclaw` sections (Option A):
   - `PASTE_ANTHROPIC_KEY_HERE`
   - `PASTE_OPENAI_KEY_HERE`
3. Replace this value:
   - `BETTER_AUTH_SECRET: "CHANGE_ME_TO_A_LONG_RANDOM_SECRET"`
4. Keep this as-is for now (per your preference):
   - `PAPERCLIP_PUBLIC_URL: "http://localhost:3100"`
5. Deploy the compose stack in Container Station.

---

## Access URLs after deploy

- Paperclip: `http://<QNAP_HOST_OR_IP>:3100`
- OpenClaw: `http://<QNAP_HOST_OR_IP>:18789`

If using the NAS itself locally, `localhost` may work from the NAS shell.

---

## Timezone

The compose file is preconfigured to:

```yaml
TZ: "America/New_York"
```

This matches EST/EDT for New York.

---

## Security notes (important)

- Do **not** commit real API keys to public GitHub repos.
- Rotate any key that was ever pasted into chat, logs, screenshots, or public files.
- Use strong random `BETTER_AUTH_SECRET` (32+ chars recommended).

---

## Troubleshooting

### 1) OpenClaw keeps restarting

- Check logs first:
  - Container Station → Containers → `openclaw` → Logs
- Common causes:
  - Invalid API key
  - Port conflict (`18789` / `18790` already in use)
  - Corrupted old volume data

Try:
1. Stop stack
2. Start stack again
3. If still failing, inspect first error line in logs

### 2) Paperclip can't connect to database

Verify database env values are exactly:
- `POSTGRES_USER=paperclip`
- `POSTGRES_PASSWORD=paperclip`
- `POSTGRES_DB=paperclip`

### 3) Port already in use

Change left side of port mappings. Example:
- `"3101:3100"` (host 3101 to container 3100)

---

## Optional: switch to `.env` mode later (Option 2)

If you decide to move secrets out of compose:
1. Copy `.env.example` to `.env`
2. Fill values
3. Replace hardcoded keys in compose with env syntax in **both** services, e.g.:
   - `ANTHROPIC_API_KEY: "${ANTHROPIC_API_KEY:-}"`
   - `OPENAI_API_KEY: "${OPENAI_API_KEY:-}"`

---

## Can this assistant create the GitHub repo too?

Yes, I can scaffold everything and prepare it for push.
Creating the remote GitHub repo directly depends on your authentication/access in this environment.

Typical manual commands (from your machine) are:

```bash
git init
git add .
git commit -m "Initial commit: QNAP Paperclip/Postgres/OpenClaw stack"
git branch -M main
git remote add origin https://github.com/<your-user>/<your-repo>.git
git push -u origin main
```

If you use GitHub CLI and are authenticated:

```bash
gh repo create <your-repo> --public --source=. --remote=origin --push
```
