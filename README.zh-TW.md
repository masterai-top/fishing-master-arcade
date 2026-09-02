# 捕魚遊戲源碼|捕魚玩法與前端演示 | fishing-master-arcade


[簡體中文](README.md) | [English](README.en.md) | [繁體中文](README.zh-TW.md)

本專案聚焦捕魚玩法與前端演示，保留線上現有 README 的功能、架構、截圖與使用說明，並以倉庫實際程式碼為準。

> 專案功能、效能、營運記錄與部署能力應結合目前版本獨立驗證；授權與第三方素材範圍以倉庫檔案為準。

Fishing Master Arcade 是一套街機捕魚、打魚遊戲、多人即時捕魚遊戲源碼項目，覆蓋 100+ 魚種、20 種炮台、BOSS 戰、多人同屏、排行榜、裝備成長、活動玩法與商業化系統，適合用於 Cocos、Unity、HTML5、移動端與私有化部署的二次開發。

## 核心賣點

- 100+ 魚種與倍率體系：小魚、稀有魚、BOSS、龍王等多層級獎勵設計
- 20 種炮台系統：散彈、追蹤、穿透、冰凍、閃電、核彈、範圍、連發、VIP、傳說炮等
- 多人同屏競技：支援 4-8 人即時房間、同步射擊、獎勵結算與排行
- BOSS 與活動玩法：巨型 BOSS、金幣雨、幸運轉盤、公會戰、賽季皮膚
- 商業化模組：IAP、VIP、廣告激勵、新手禮包、排行獎勵、賽季通行證
- 反作弊設計：服務器權威計算、行為頻率檢測、異常封禁、設備與 IP 風控

## 適用場景

- 街機捕魚源碼展示與商業合作
- 捕魚達人、打魚遊戲、魚機遊戲、休閒競技遊戲二次開發
- iOS、Android、HTML5、PC、街機模擬器多端產品
- 遊戲大廳、休閒遊戲合集、營運後台與服務器架構參考
- 東南亞、歐美、南美等市場的捕魚類產品技術評估

## 技術棧

- 客戶端：Cocos Creator / Unity / HTML5 Canvas 可擴展方向
- 服務端：C++ 即時同步與結算邏輯
- 數據庫：MySQL
- 部署：Docker、CDN、移動端打包與私有化部署

## 項目結構建議

```text
client/                 # 客戶端源碼或演示工程
server/                 # 即時房間、結算與反作弊服務
admin/                  # 營運後台與配置管理
database/               # 數據庫結構與遷移說明
config.example/         # 脫敏配置示例
docs/                   # GitHub Pages 產品與技術文檔
scripts/                # 構建、部署與維護腳本
tests/                  # 核心玩法、倍率、接口與風控測試
.github/workflows/      # CI 與 GitHub Pages 自動發布
```

## 合規公開建議

公開倉庫適合展示產品結構、核心玩法說明、部分源碼示例、截圖與部署文檔。不要公開真實用戶數據、支付密鑰、後台帳號、生產配置、渠道數據、私有素材授權文件或線上營運數據。

## 文檔

- [項目主頁](docs/index.html)
- [功能介紹](docs/features.html)
- [架構說明](docs/architecture.html)
- [部署指南](docs/deployment.html)
- [商業化與合規說明](docs/responsible-use.html)

## 聯繫方式

Telegram：`@xuzongbin001`  
Email：`masterai918@gmail.com`

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

## License

僅限技術評估、商務溝通與授權合作，具體以倉庫 License 文件為準。
