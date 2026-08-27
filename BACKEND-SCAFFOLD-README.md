# OceanRaid Backend Scaffold

This package provides a development scaffold for the non-client parts of OceanRaid. It is not a complete commercial game server and contains no production credentials, payment integrations, personal data, proprietary assets, or revenue-control logic.

## Included directories

- `server-python/`: FastAPI gateway, room catalog, and tournament endpoints
- `server-cpp/`: C++17 fishing engine and room-state foundation
- `admin/`: Node.js operations API with audit-friendly configuration routes
- `database/`: MySQL-compatible schema and development seed data
- `config.example/`: sanitized application and game-mode configuration
- `scripts/`: local build and validation helpers
- `docs/backend/`: architecture, API, and deployment notes
- `tests/`: cross-service integration guidance
- `.github/workflows/`: CI checks for all three server stacks

Review all game rules, probability settings, payments, rewards, privacy, age protection, and regional requirements before deployment.
