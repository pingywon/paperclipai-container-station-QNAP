# PaperclipAI Container Station Stack for QNAP

A beginner-friendly, single-file Docker Compose stack for QNAP NAS Container Station.

Official target GitHub repository:
`https://github.com/pingywon/paperclipai-container-station-QNAP`

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

## Prerequisites

- QNAP NAS with **Container Station** installed
- Internet access from NAS to pull images
- At least one AI API key (Anthropic and/or OpenAI)

---

## DNS resolution toggle (enabled by default)

This stack has a global DNS section in `docker-compose.yml` that is **enabled by default** and applies to all three services (`db`, `paperclip`, `openclaw`).

Default DNS servers:
- `1.1.1.1`
- `8.8.8.8`

In `docker-compose.yml`, look for:

```yaml
x-dns-settings: &dns_settings
  dns:
    - 1.1.1.1
    - 8.8.8.8
```

To disable custom DNS, replace that block with:

```yaml
x-dns-settings: &dns_settings {}
```

(Alternative: remove `<<: *dns_settings` from each service.)

---

## API keys (recommended: inline in `docker-compose.yml`)

For the easiest setup, put keys directly in YAML for **both** services:

```yaml
ANTHROPIC_API_KEY: "sk-ant-..."
OPENAI_API_KEY: "sk-proj-..."
```

---

## Quick start

1. Open `docker-compose.yml`.
2. Replace these values in **both** `paperclip` and `openclaw` sections:
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


### 4) OpenClaw "EACCES: permission denied" on QNAP

If logs show errors like:
- `EACCES: permission denied, open '/home/node/.openclaw/...tmp'`

Cause: QNAP can create mounted volumes with ownership that the default OpenClaw runtime user cannot write to.

This compose file now sets:
- `user: "0:0"` for the `openclaw` service

If you deployed before this fix, do this once:
1. Stop the stack
2. Remove/recreate `openclaw-config` and `openclaw-workspace` volumes
3. Redeploy the stack

### 2) Paperclip can't connect to database

Verify database env values are exactly:
- `POSTGRES_USER=paperclip`
- `POSTGRES_PASSWORD=paperclip`
- `POSTGRES_DB=paperclip`

### 3) Port already in use

Change left side of port mappings. Example:
- `"3101:3100"` (host 3101 to container 3100)
