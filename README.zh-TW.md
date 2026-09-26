[简体中文](README.md) | **繁體中文** | [English](README.en.md)

# 捕魚遊戲原始碼：多人街機捕魚與打魚遊戲平台

`fishing-master-arcade` 是一套包含真實遊戲截图和可运行后端骨架的多人街机捕魚项目。仓库覆盖 Lua 客戶端代码、C++ 捕魚结算与房間模块、Python FastAPI 房間介面、Node.js 运营介面、MySQL 資料結構、設定样例和測試，可用于研究捕魚遊戲、打鱼遊戲、鱼机玩法、多人房間以及伺服器端权威结算。

> 仓库中的生产能力、素材授权、概率設定和商业部署范围必须结合目前目錄、许可证和測試结果独立核验。README 不再把无法从仓库驗證的日活、付费率或留存目标当成已实现指标。

## 真實產品截图

| 遊戲大厅 | 經典捕魚场 | 多人比賽模式 |
|---|---|---|
| ![捕魚遊戲大厅原始碼真實界面](docs/assets/screenshots/lobby.png) | ![街机捕魚經典模式与砲台射击](docs/assets/screenshots/classic-mode.png) | ![多人捕魚比賽模式](docs/assets/screenshots/tournament-mode.png) |

| 海魔来袭 | 玉石大厅 | 捕魚战斗界面 |
|---|---|---|
| ![捕魚遊戲海魔Boss玩法](docs/assets/screenshots/haimo.png) | ![捕魚遊戲玉石大厅](docs/assets/screenshots/yushidating.png) | ![打鱼遊戲砲台战斗界面](docs/assets/screenshots/zhandou.jpg) |

## 產品功能

- **捕魚大厅与模式入口**：真實截图展示遊戲大厅、經典场、比賽场、玉石场、海魔来袭和小遊戲入口。
- **砲台射击与捕魚结算**：C++ `FishingEngine` 接收餘額、砲台成本和魚類参数，返回捕獲结果、獎勵和新餘額。
- **多人实时房間**：C++ `Room` 模块实现玩家加入、离开、容量和在线人数；FastAPI 提供房間列表与加入介面。
- **魚群与倍率設定**：`FishSpec` 包含鱼 ID、顯示名称、獎勵倍率和捕獲概率；示例設定定义不同場景和倍率范围。
- **比賽与排行**：設定中存在 tournament 模式和 `ranking_enabled`，真實截图展示比賽模式。
- **成长与运营界面**：线上圖片展示商城、升级、锻造、宠物和活动小遊戲等產品頁面。
- **运营 API**：Node.js/Express 服务提供模式目錄、健康檢查和输入校验骨架。
- **伺服器端权威方向**：概率設定刻意不写入公开示例，仓库說明生产概率应经过版本、审批、模拟、审计和合规檢查。

## 玩法流程

1. 玩家从捕魚大厅選擇經典、比賽或其他开放模式。
2. 房間服务根据模式返回可加入房間和会话信息。
3. 玩家選擇砲台并發射，系統扣除对应成本。
4. 伺服器端根据魚類参数和受控随机过程計算是否捕獲。
5. 捕獲后更新獎勵与餘額，客戶端播放击中、金币和魚群动画。
6. 比賽模式可结合排名規則统计结果；實際規則以完整設定和服务实现为准。

## 可驗證技術架构

| 层级 | 仓库内容 | 作用 |
|---|---|---|
| 客戶端 | `client/` 下 Lua UI、协议、登录、好友等模块 | 遊戲界面、交互与网络协议样本 |
| C++ 服务 | `server-cpp/`、CMake、FishingEngine、Room、測試 | 射击结算、餘額更新和房間成员管理 |
| Python API | FastAPI、`/v1/rooms`、health、pytest | 房間目錄、加入房間和服务健康檢查 |
| 运营介面 | Node.js 20、Express、Helmet、Zod | 模式目錄、介面安全头和参数校验 |
| 資料库 | `database/schema.sql`、开发种子資料 | 基础資料結構和本地开发样例 |
| 設定 | `config.example/fishing-modes.yaml` | 經典、比賽、玉石、海魔和刺激区模式样例 |
| 自动檢查 | C++、Python、Node 与仓库契约測試 | 驗證核心模块和目錄约定 |

## 仓库結構

```text
client/             Lua 客戶端与界面代码
server-cpp/         C++ 捕魚引擎、房間与測試
server-python/      FastAPI 房間介面与測試
admin/              Node.js 运营介面骨架
database/           MySQL 結構与开发种子資料
config.example/     脱敏模式設定样例
docs/               GitHub Pages 与真實截图
scripts/            构建、驗證和开发脚本
tests/              仓库集成檢查
```

## 图文专题

- [捕魚遊戲原始碼与项目結構](https://masterai-top.github.io/fishing-master-arcade/zh-cn/fishing-game-source-code.html)
- [街机捕魚与砲台玩法](https://masterai-top.github.io/fishing-master-arcade/zh-cn/arcade-fishing-game.html)
- [打鱼遊戲、魚群与 Boss 战](https://masterai-top.github.io/fishing-master-arcade/zh-cn/fish-shooting-game.html)
- [多人捕魚伺服器端架构](https://masterai-top.github.io/fishing-master-arcade/zh-cn/multiplayer-fishing-server.html)
- [English fishing game source overview](https://masterai-top.github.io/fishing-master-arcade/en/fishing-game-source-code.html)

## 取得原始碼与驗證

```bash
git clone https://github.com/masterai-top/fishing-master-arcade.git
cd fishing-master-arcade
```

请根据 [BACKEND-SCAFFOLD-README.md](BACKEND-SCAFFOLD-README.md)、`server-cpp/CMakeLists.txt`、`server-python/pyproject.toml` 和 `admin/package.json` 分别準備環境。仓库没有根目錄 `package.json` 或 `docker-compose.yml`，因此不应在根目錄直接執行旧版 README 中的 `npm install` 或 `docker-compose up`。

## 合规与安全

部署前需要核对素材许可证、概率与随机性、獎勵经济、支付与广告、年龄限制、隐私保护、日志审计、反作弊和当地遊戲法规。生产概率必须经过模拟和独立审计，严禁把开发种子或示例設定直接用于生产環境。

聯絡：Telegram `@xuzongbin001` · Email `masterai918@gmail.com` · [GitHub Issues](https://github.com/masterai-top/fishing-master-arcade/issues)
