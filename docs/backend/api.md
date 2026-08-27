# API Outline

## Python gateway

### `GET /health`

Returns the gateway health state.

### `GET /v1/rooms?mode=classic`

Lists available rooms, capacity, online count, and configured multiplier range.

### `POST /v1/rooms/join`

Development request:

```json
{"player_id":"local-player","mode":"classic"}
```

Returns a room identifier, short-lived session ticket, and real-time endpoint. A production ticket must be signed, expire quickly, bind to the authenticated player, and be single-use.

## Node.js operations API

All `/v1/admin/*` requests require `x-admin-api-key` in this scaffold. Replace API keys with enterprise identity, MFA, roles, and network controls in production.

- `GET /v1/admin/modes`
- `POST /v1/admin/configuration-drafts`

Configuration drafts are not automatically activated. Add persistence, approval, audit, validation, simulation, and scheduled rollout before production use.
