[简体中文](README.md) | [English](README.en.md) | [繁體中文](README.zh-TW.md)

A real-time arcade fishing game system featuring physics-based shooting and dynamic fish behavior.
# 捕鱼游戏源码|捕鱼玩法与前端演示 | fishing-master-arcade

本项目聚焦捕鱼玩法与前端演示，保留线上现有 README 的功能、架构、截图与使用说明，并以仓库实际代码为准。
> 项目功能、性能、运营记录与部署能力应结合当前版本独立验证；许可证和第三方素材范围以仓库文件为准。


Fishing Master Arcade 是一套街机捕鱼、打鱼游戏、多人实时捕鱼游戏源码项目，覆盖 100+ 鱼种、20 种炮台、BOSS 战、多人同屏、排行榜、装备成长、活动玩法和商业化系统，适合用于 Cocos、Unity、HTML5、移动端和私有化部署的二次开发。

## 核心卖点

- 100+ 鱼种与倍率体系：小鱼、稀有鱼、BOSS、龙王等多层级奖励设计
- 20 种炮台系统：散弹、追踪、穿透、冰冻、闪电、核弹、范围、连发、VIP、传说炮等
- 多人同屏竞技：支持 4-8 人实时房间、同步射击、奖励结算和排行
- BOSS 与活动玩法：巨型 BOSS、金币雨、幸运转盘、公会战、赛季皮肤
- 商业化模块：IAP、VIP、广告激励、新手礼包、排行奖励、赛季通行证
- 反作弊设计：服务器权威计算、行为频率检测、异常封禁、设备和 IP 风控

## 适用场景

- 街机捕鱼源码展示与商业合作
- 捕鱼达人、打鱼游戏、鱼机游戏、休闲竞技游戏二次开发
- iOS、Android、HTML5、PC、街机模拟器多端产品
- 游戏大厅、休闲游戏合集、运营后台和服务器架构参考
- 东南亚、欧美、南美等市场的捕鱼类产品技术评估

## 技术栈

- 客户端：Cocos Creator / Unity / HTML5 Canvas 可扩展方向
- 服务端：C++ 实时同步与结算逻辑
- 数据库：MySQL
- 部署：Docker、CDN、移动端打包与私有化部署

## 项目结构建议

```text
client/                 # 客户端源码或演示工程
server/                 # 实时房间、结算和反作弊服务
admin/                  # 运营后台与配置管理
database/               # 数据库结构与迁移说明
config.example/         # 脱敏配置示例
docs/                   # GitHub Pages 产品与技术文档
scripts/                # 构建、部署和维护脚本
tests/                  # 核心玩法、倍率、接口和风控测试
.github/workflows/      # CI 与 GitHub Pages 自动发布
```
## 🎯 一键运行 / Quick Start / 一鍵運行

```bash
# HTML5 Web版 (推荐)
npm install && npm run dev
# http://localhost:8080

# Unity版
UnityHub → 打开项目 → Build & Run

# Docker服务器版
docker-compose up -d
```

---

### **核心玩法**
| 系统 | 特色 | 商业价值 |
|------|------|----------|
| **100+鱼种** | 小鱼1倍 → 龙王1000倍 | 高倍率刺激 |
| **20种炮台** | 散弹/追踪/穿透/核弹 | 付费解锁 |
| **多人同屏** | 4-8人竞技场 | 社交留存 |
| **BOSS战** | 巨型BOSS群战 | 合作高潮 |
| **增加游戏趣味性** | 限时任务 | 增加游戏趣味性 |

### **app中的付费点**

💰 炮台付费解锁 (IAP)
🎁 新手礼包
💎 VIP月卡 (倍率加成)
🏆 排行奖励
📺 广告激励





---

## 🐟 鱼种与倍率 / Fish & Multipliers / 魚種與倍率

| 鱼种 | 倍率 | 稀有度 | 捕获难度 |
|------|------|--------|----------|
| 小丑鱼 | 2x | 常见 | ★☆☆ |
| 海豚 | 15x | 普通 | ★★☆ |
| 鲨鱼 | 80x | 稀有 | ★★★ |
| 巨鲸 | 500x | 传说 | ★★★★ |
| 龙王 | 1000x | 神话 | ★★★★★ |

## 🎯 20种炮台系统 / 20 Weapons / 20種炮台
基础炮 | 散弹炮 | 追踪炮 | 穿透炮
冰冻炮 | 闪电炮 | 核弹炮 | 范围炮
连发炮 | 爆破炮 | 毒液炮 | 减速炮
VIP炮 | 传说炮 | 神器炮 | 终极炮

## 🛡️ 反作弊系统 / Anti-Cheat / 反作弊系統

✅ 服务器权威计算
✅ 行为频率检测
✅ 设备指纹
✅ IP限制
✅ 异常封禁

## 💰 完整经济系统
IAP道具 | VIP订阅 | 广告激励
每日礼包 | 限时活动 | 赛季通行证
排行奖励 | 公会系统 | 直播打赏

## 🏗️ 专业技术栈 / Tech Stack / 專業技術棧
🎮 引擎: Cocos Creator 3.8 
🎨 UI: 美术资源全套
⚙️ 后端: c++
🗄️ 数据库:mysql

📱 适配: iOS/Android
🚀 部署: Docker + CDN

## 📱 完美多端适配 / Cross-Platform / 跨平台適配

📲 Android APK
🍎 iOS IPA
💻 PC客户端
🖥️ 街机模拟器


## 🎯 商业成功指标 / Business Metrics / 商業成功指標

| 指标 | 目标 | 实现 |
|------|------|------|
| 日活 | 10w+ | ✅ |
| ARPU | ¥2.5 | ✅ |
| 付费率 | 8% | ✅ |
| 留存D1 | 45% | ✅ |
| LTV | ¥35 | ✅ |

## 🏆 特色玩法 / Unique Features / 特色玩法
捕鱼达人 | 连杀奖励 | BOSS血条
炮台合成 | 技能释放 | 冰冻减速
金币雨 | 倍率卡 | 幸运转盘
公会战 | 排行竞技 | 赛季皮肤

## 📦 版本发布 / Releases / 版本發佈

### 🚀 v2.0 最新
✅ 20种炮台系统  
✅ 多人竞技场  
✅ 反作弊完善  
✅ 多端完美适配  


###  问题反馈与交流



📱 **Telegram：@xuzongbin001**  

📧 **Email：masterai918@gmail.com**





## 产品截图 / Product Screenshots

### 捕鱼游戏大厅 / Fishing Game Lobby

<img src="https://raw.githubusercontent.com/masterai-top/fishing-master-arcade/main/docs/assets/screenshots/lobby.png" alt="Fishing Master Arcade Game Lobby" width="860">

### 经典模式 / Classic Mode

<img src="https://raw.githubusercontent.com/masterai-top/fishing-master-arcade/main/docs/assets/screenshots/classic-mode.png" alt="Fishing Master Arcade Classic Mode" width="860">

### 海魔来袭 / Sea Demon Raid

<img src="https://raw.githubusercontent.com/masterai-top/fishing-master-arcade/main/docs/assets/screenshots/haimo.png" alt="Sea Demon Raid Fishing Game Mode" width="860">

### 玉石大厅 / Jade Lobby

<img src="https://raw.githubusercontent.com/masterai-top/fishing-master-arcade/main/docs/assets/screenshots/yushidating.png" alt="Fishing Game Jade Lobby" width="860">

### 玉石场 / Jade Arena

<img src="https://raw.githubusercontent.com/masterai-top/fishing-master-arcade/main/docs/assets/screenshots/jade-arena.jpg" alt="Fishing Game Jade Arena" width="860">

### 经典场景 / Classic Fishing Scene

<img src="https://raw.githubusercontent.com/masterai-top/fishing-master-arcade/main/docs/assets/screenshots/jingdian.png" alt="Classic Arcade Fishing Scene" width="860">

### 战斗界面 / Battle Gameplay

<img src="https://raw.githubusercontent.com/masterai-top/fishing-master-arcade/main/docs/assets/screenshots/zhandou.jpg" alt="Arcade Fishing Battle Gameplay" width="860">

### 比赛模式 / Tournament Mode

<img src="https://raw.githubusercontent.com/masterai-top/fishing-master-arcade/main/docs/assets/screenshots/tournament-mode.png" alt="Fishing Game Tournament Mode" width="860">

### 商城界面 / Shop

<img src="https://raw.githubusercontent.com/masterai-top/fishing-master-arcade/main/docs/assets/screenshots/shangchnag.jpg" alt="Fishing Game Shop Interface" width="860">

### 升级系统 / Upgrade System

<img src="https://raw.githubusercontent.com/masterai-top/fishing-master-arcade/main/docs/assets/screenshots/shengji.jpg" alt="Fishing Game Upgrade System" width="860">


### 宠物系统 / Pet System

<img src="https://raw.githubusercontent.com/masterai-top/fishing-master-arcade/main/docs/assets/screenshots/chongwu.jpg" alt="Fishing Game Pet System" width="860">

### 找刺激小游戏 / Mini Games

<img src="https://raw.githubusercontent.com/masterai-top/fishing-master-arcade/main/docs/assets/screenshots/xiaoyouxi1.png" alt="Fishing Master Arcade Mini Games" width="860">


## 🎮 Gameplay Preview

- Fish animation  
- Shooting effects  
- Coin explosion
## 🎯 Game Mechanics

- Dynamic fish spawning system  
- Bullet trajectory & collision  
- Reward probability system  
- Boss fish events
## 🎮 Player Experience

- Fast-paced arcade shooting  
- Reward-driven gameplay  
- High replayability
## 🧩 Architecture

- Client (UI rendering)  
- Game engine (logic)  
- Server (sync)  
- Economy system  


---





