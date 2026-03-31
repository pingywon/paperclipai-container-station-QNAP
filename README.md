# PaperclipAI Container Station Stack for QNAP

A beginner-friendly, single-file Docker Compose stack for QNAP NAS Container Station.

Official GitHub repository: <https://github.com/pingywon/paperclipai-container-station-QNAP>

This stack deploys three services together:
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

This stack has a global DNS section in `docker-compose.yml` that is enabled by default and applies to all three services (`db`, `paperclip`, `openclaw`).

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
4. Set `PAPERCLIP_PUBLIC_URL` to the NAS LAN URL users will open in a browser, for example:
   - `PAPERCLIP_PUBLIC_URL: "http://192.168.1.50:3100"`
5. Keep `HOST` as:
   - `HOST: "0.0.0.0"`
6. Deploy the compose stack in Container Station.
7. If you get a hostname-allowed error on first login, run:
   - `docker exec -it paperclip pnpm paperclipai allowed-hostname <QNAP_HOST_OR_IP>`

---

## Access URLs after deploy

- Paperclip: `http://<QNAP_HOST_OR_IP>:3100`
- OpenClaw: `http://<QNAP_HOST_OR_IP>:18789`

`localhost` may work from the NAS itself, but other LAN devices must use the NAS IP/hostname URL.

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
- Use a strong random `BETTER_AUTH_SECRET` (32+ chars recommended).

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

### 4) OpenClaw `EACCES: permission denied` on QNAP

If logs show errors like:
- `EACCES: permission denied, open '/home/node/.openclaw/...tmp'`

Cause: QNAP can create mounted volumes with ownership that the default OpenClaw runtime user cannot write to.

This compose file sets:
- `user: "0:0"` for the `openclaw` service

If you deployed before this fix, do this once:
1. Stop the stack
2. Remove/recreate `openclaw-config` and `openclaw-workspace` volumes
3. Redeploy the stack

### 5) `EADDRNOTAVAIL` when Paperclip starts

If logs show errors like:
- `listen EADDRNOTAVAIL: address not available 192.168.13.13:3100`

Cause: Paperclip is trying to bind to an IP that does not exist inside the container network namespace.

Fix:
1. Keep `HOST: "0.0.0.0"` (bind all interfaces in the container).
2. Do **not** set `HOST` to your NAS/VLAN IP (for example `192.168.x.x`).
3. Set `PAPERCLIP_PUBLIC_URL` to the NAS URL clients open (for example `http://192.168.13.13:3100`).
4. Ensure the compose port mapping remains `"3100:3100"`.
5. In QNAP Container Station, check **Environment** and remove any extra `HOST=192.168...` override that may have been added manually.
6. Fully recreate/redeploy the `paperclip` container after env changes (stop + delete container, then deploy again) so old env values are not reused.

Known-good `paperclip` env baseline:
```yaml
PORT: "3100"
HOST: "0.0.0.0"
PAPERCLIP_PUBLIC_URL: "http://<QNAP_HOST_OR_IP>:3100"
```

Rule of thumb:
- `HOST` = where the app listens **inside the container**
- `PAPERCLIP_PUBLIC_URL` = what users type in browser **on LAN**


### 6) `Hostname "<IP_OR_NAME>" is not allowed for this Paperclip instance`

If you see an error like:
- `Hostname '192.168.13.13' is not allowed for this Paperclip instance`

Add the LAN hostname/IP to Paperclip's allowed-hostname list inside the running container:

```bash
docker exec -it paperclip pnpm paperclipai allowed-hostname 192.168.13.13
```

If users access Paperclip via multiple names, add each one (examples):

```bash
docker exec -it paperclip pnpm paperclipai allowed-hostname qnap.local
docker exec -it paperclip pnpm paperclipai allowed-hostname paperclip.local
```

Then restart the `paperclip` container.

Tip:
- Prefer one canonical URL in `PAPERCLIP_PUBLIC_URL` and have all users use that same URL.

