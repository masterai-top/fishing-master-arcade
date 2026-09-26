[简体中文](README.md) | [繁體中文](README.zh-TW.md) | [English](README.en.md)

# 捕鱼游戏源码：多人街机捕鱼与打鱼游戏平台

`fishing-master-arcade` 是一套包含真实游戏截图和可运行后端骨架的多人街机捕鱼项目。仓库覆盖 Lua 客户端代码、C++ 捕鱼结算与房间模块、Python FastAPI 房间接口、Node.js 运营接口、MySQL 数据结构、配置样例和测试，可用于研究捕鱼游戏、打鱼游戏、鱼机玩法、多人房间以及服务端权威结算。

> 仓库中的生产能力、素材授权、概率配置和商业部署范围必须结合当前目录、许可证和测试结果独立核验。README 不再把无法从仓库验证的日活、付费率或留存目标当成已实现指标。

## 真实产品截图

| 游戏大厅 | 经典捕鱼场 | 多人比赛模式 |
|---|---|---|
| ![捕鱼游戏大厅源码真实界面](docs/assets/screenshots/lobby.png) | ![街机捕鱼经典模式与炮台射击](docs/assets/screenshots/classic-mode.png) | ![多人捕鱼比赛模式](docs/assets/screenshots/tournament-mode.png) |

| 海魔来袭 | 玉石大厅 | 捕鱼战斗界面 |
|---|---|---|
| ![捕鱼游戏海魔Boss玩法](docs/assets/screenshots/haimo.png) | ![捕鱼游戏玉石大厅](docs/assets/screenshots/yushidating.png) | ![打鱼游戏炮台战斗界面](docs/assets/screenshots/zhandou.jpg) |

## 产品功能

- **捕鱼大厅与模式入口**：真实截图展示游戏大厅、经典场、比赛场、玉石场、海魔来袭和小游戏入口。
- **炮台射击与捕鱼结算**：C++ `FishingEngine` 接收余额、炮台成本和鱼类参数，返回捕获结果、奖励和新余额。
- **多人实时房间**：C++ `Room` 模块实现玩家加入、离开、容量和在线人数；FastAPI 提供房间列表与加入接口。
- **鱼群与倍率配置**：`FishSpec` 包含鱼 ID、显示名称、奖励倍率和捕获概率；示例配置定义不同场景和倍率范围。
- **比赛与排行**：配置中存在 tournament 模式和 `ranking_enabled`，真实截图展示比赛模式。
- **成长与运营界面**：线上图片展示商城、升级、锻造、宠物和活动小游戏等产品页面。
- **运营 API**：Node.js/Express 服务提供模式目录、健康检查和输入校验骨架。
- **服务端权威方向**：概率配置刻意不写入公开示例，仓库说明生产概率应经过版本、审批、模拟、审计和合规检查。

## 玩法流程

1. 玩家从捕鱼大厅选择经典、比赛或其他开放模式。
2. 房间服务根据模式返回可加入房间和会话信息。
3. 玩家选择炮台并发射，系统扣除对应成本。
4. 服务端根据鱼类参数和受控随机过程计算是否捕获。
5. 捕获后更新奖励与余额，客户端播放击中、金币和鱼群动画。
6. 比赛模式可结合排名规则统计结果；实际规则以完整配置和服务实现为准。

## 可验证技术架构

| 层级 | 仓库内容 | 作用 |
|---|---|---|
| 客户端 | `client/` 下 Lua UI、协议、登录、好友等模块 | 游戏界面、交互与网络协议样本 |
| C++ 服务 | `server-cpp/`、CMake、FishingEngine、Room、测试 | 射击结算、余额更新和房间成员管理 |
| Python API | FastAPI、`/v1/rooms`、health、pytest | 房间目录、加入房间和服务健康检查 |
| 运营接口 | Node.js 20、Express、Helmet、Zod | 模式目录、接口安全头和参数校验 |
| 数据库 | `database/schema.sql`、开发种子数据 | 基础数据结构和本地开发样例 |
| 配置 | `config.example/fishing-modes.yaml` | 经典、比赛、玉石、海魔和刺激区模式样例 |
| 自动检查 | C++、Python、Node 与仓库契约测试 | 验证核心模块和目录约定 |

## 仓库结构

```text
client/             Lua 客户端与界面代码
server-cpp/         C++ 捕鱼引擎、房间与测试
server-python/      FastAPI 房间接口与测试
admin/              Node.js 运营接口骨架
database/           MySQL 结构与开发种子数据
config.example/     脱敏模式配置样例
docs/               GitHub Pages 与真实截图
scripts/            构建、验证和开发脚本
tests/              仓库集成检查
```

## 图文专题

- [捕鱼游戏源码与项目结构](https://masterai-top.github.io/fishing-master-arcade/zh-cn/fishing-game-source-code.html)
- [街机捕鱼与炮台玩法](https://masterai-top.github.io/fishing-master-arcade/zh-cn/arcade-fishing-game.html)
- [打鱼游戏、鱼群与 Boss 战](https://masterai-top.github.io/fishing-master-arcade/zh-cn/fish-shooting-game.html)
- [多人捕鱼服务端架构](https://masterai-top.github.io/fishing-master-arcade/zh-cn/multiplayer-fishing-server.html)
- [English fishing game source overview](https://masterai-top.github.io/fishing-master-arcade/en/fishing-game-source-code.html)

## 获取源码与验证

```bash
git clone https://github.com/masterai-top/fishing-master-arcade.git
cd fishing-master-arcade
```

请根据 [BACKEND-SCAFFOLD-README.md](BACKEND-SCAFFOLD-README.md)、`server-cpp/CMakeLists.txt`、`server-python/pyproject.toml` 和 `admin/package.json` 分别准备环境。仓库没有根目录 `package.json` 或 `docker-compose.yml`，因此不应在根目录直接执行旧版 README 中的 `npm install` 或 `docker-compose up`。

## 合规与安全

部署前需要核对素材许可证、概率与随机性、奖励经济、支付与广告、年龄限制、隐私保护、日志审计、反作弊和当地游戏法规。生产概率必须经过模拟和独立审计，严禁把开发种子或示例配置直接用于生产环境。

联系：Telegram `@xuzongbin001` · Email `masterai918@gmail.com` · [GitHub Issues](https://github.com/masterai-top/fishing-master-arcade/issues)
