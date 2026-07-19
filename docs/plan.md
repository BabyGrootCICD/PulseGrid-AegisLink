
# 專案發展藍圖 (Roadmap & Plan)

## Phase 1: PoC 與架構驗證 (1-2 個月)

* **目標:** 驗證 WebRTC 影音串流與 MQTT 硬體指令的低延遲同步。
* **交付物:**
  * 基於 Go (Pion) 的單節點 SFU 伺服器。
  * 簡易 Next.js 前端，能建立 P2P/SFU 房間。
  * 模擬 IoT 設備端，可接收 MQTT 指令並列印日誌 (暫無實體硬體)。

## Phase 2: 核心 SaaS 系統與合規整合 (2-3 個月)

* **目標:** 完成雙軌制年齡驗證與創作者心理諮商模組。
* **交付物:**
  * 整合 Yoti 與 World ID API。
  * 完成 E2EE (端到端加密) 諮商室功能 (WebRTC Data Channel 加密)。
  * 建立創作者與諮商師的預約系統 (gRPC + 關聯式資料庫)。

## Phase 3: Web3 支付與智能合約 (2 個月)

* **目標:** 建立抗審查的金流系統。
* **交付物:**
  * 部署打賞與隱私路由發放智能合約 (Solidity 或 Rust)。
  * 前端整合 Phantom/MetaMask 錢包，實作安全出金教學流程。
  * 平台內 Redis 狀態同步與金流事件的一致性處理。

## Phase 4: 韌體開發與資安審計 (3 個月)

* **目標:** 打造安全的硬體生態並進行全面審查。
* **交付物:**
  * 實作硬體 Watchdog 與固態繼電器 (SSR) 斷電機制。
  * 整合 Secure Element (SE) 進行憑證管理。
  * 聘請外部資安公司進行 Web3 合約審計與 IoT 滲透測試 (Pen-testing)。

## Phase 5: Beta 測試與社群冷啟動

* 邀請首批創作者與諮商師進行封閉測試 (Closed Beta)。
* 建立 Cloudflare 邊緣路由機制，優化跨國延遲。
