[简体中文](README.md) | [繁體中文](README.zh-TW.md) | **English**

# Fishing Game Source Code: Multiplayer Arcade Fish Shooting Platform

`fishing-master-arcade` combines real product screenshots with a verifiable backend scaffold for an arcade fishing game. The repository includes Lua client modules, a C++ fishing settlement engine and room model, Python FastAPI room endpoints, a Node.js operations API, MySQL schema, example mode configuration and tests. It is useful for studying fish-shooting gameplay, multiplayer rooms and server-authoritative settlement.

> Production readiness, asset licensing, probability configuration and commercial deployment must be independently verified against the current files, license and tests. Unverifiable DAU, payment-rate and retention targets are not presented as achieved results.

## Real product screenshots

| Game lobby | Classic fishing | Tournament mode |
|---|---|---|
| ![Arcade fishing game source lobby](docs/assets/screenshots/lobby.png) | ![Classic fish shooting and cannon gameplay](docs/assets/screenshots/classic-mode.png) | ![Multiplayer fishing tournament mode](docs/assets/screenshots/tournament-mode.png) |

| Sea Demon event | Jade lobby | Battle screen |
|---|---|---|
| ![Sea Demon boss fishing mode](docs/assets/screenshots/haimo.png) | ![Fishing game Jade lobby](docs/assets/screenshots/yushidating.png) | ![Arcade fish shooting battle interface](docs/assets/screenshots/zhandou.jpg) |

## Product capabilities

- **Lobby and mode selection:** screenshots show the lobby, classic mode, tournament mode, Jade field, Sea Demon event and mini-game entrances.
- **Cannon shooting and settlement:** the C++ `FishingEngine` accepts balance, cannon cost and fish parameters, then returns capture status, reward and updated balance.
- **Multiplayer rooms:** the C++ `Room` implements join, leave, capacity and online players; FastAPI exposes room listing and room joining.
- **Fish and multiplier configuration:** `FishSpec` contains an ID, display name, reward multiplier and capture probability; example configuration defines scenes and multiplier ranges.
- **Tournament and ranking:** tournament mode and `ranking_enabled` are present in configuration, with a real tournament screenshot.
- **Progression and operations UI:** images show shop, upgrade, forging, pet and activity screens.
- **Operations API:** a Node.js/Express scaffold provides mode catalog and health endpoints with Helmet and Zod.
- **Server-authoritative direction:** public examples intentionally omit production capture probabilities, which require versioning, approval, simulation, audit and legal review.

## Gameplay flow

1. A player selects classic, tournament or another enabled mode from the lobby.
2. The room service returns an available room and session information.
3. The player selects a cannon and fires, consuming the configured cost.
4. The server evaluates the shot using fish parameters and controlled randomness.
5. A capture updates the reward and balance while the client renders hit, coin and fish animations.
6. Tournament mode can add ranking rules; complete behavior depends on production configuration and services.

## Verifiable architecture

| Layer | Repository content | Responsibility |
|---|---|---|
| Client | Lua UI, protocol, login and friend modules under `client/` | Interface, interaction and network-protocol samples |
| C++ server | CMake, FishingEngine, Room and tests under `server-cpp/` | Shot settlement, balance updates and room membership |
| Python API | FastAPI, `/v1/rooms`, health and pytest | Room catalog, join flow and health checks |
| Operations API | Node.js 20, Express, Helmet and Zod | Mode catalog, security headers and validation |
| Database | `database/schema.sql` and development seed | Base schema and local development examples |
| Configuration | `config.example/fishing-modes.yaml` | Classic, tournament, Jade, Sea Demon and thrill-zone examples |
| Automated checks | C++, Python, Node and repository contract tests | Core behavior and repository conventions |

## Illustrated pages

- [Fishing game source code](https://masterai-top.github.io/fishing-master-arcade/en/fishing-game-source-code.html)
- [Arcade fishing platform](https://masterai-top.github.io/fishing-master-arcade/en/arcade-fishing-platform.html)
- [Simplified Chinese fish-shooting gameplay](https://masterai-top.github.io/fishing-master-arcade/zh-cn/fish-shooting-game.html)
- [Simplified Chinese multiplayer server](https://masterai-top.github.io/fishing-master-arcade/zh-cn/multiplayer-fishing-server.html)

## Clone and verify

```bash
git clone https://github.com/masterai-top/fishing-master-arcade.git
cd fishing-master-arcade
```

Prepare each component with [BACKEND-SCAFFOLD-README.md](BACKEND-SCAFFOLD-README.md), `server-cpp/CMakeLists.txt`, `server-python/pyproject.toml` and `admin/package.json`. There is no root `package.json` or `docker-compose.yml`, so the old root-level `npm install` and `docker-compose up` instructions were removed.

## Responsible use

Before deployment, verify asset licenses, probability and randomness, reward economy, payments and ads, age controls, privacy, audit logs, anti-cheat and local gaming law. Production probabilities require simulation and independent audit; never use development seeds or example configuration in production.

Contact: Telegram `@xuzongbin001` · Email `masterai918@gmail.com` · [GitHub Issues](https://github.com/masterai-top/fishing-master-arcade/issues)
