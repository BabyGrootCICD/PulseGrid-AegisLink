
# 專案發展藍圖 Project Roadmap & Plan

## Phase 1: PoC 與架構驗證 Proof of Concept & Architecture Validation (1-2 個月 months)

* **目標 Goal:** 驗證 WebRTC 影音串流與 MQTT 硬體指令的低延遲同步。
  Validate low-latency synchronization between WebRTC audio/video streaming and MQTT hardware commands.

* **交付物 Deliverables:**
  * 基於 Go (Pion) 的單節點 SFU 伺服器。
    Single-node SFU server based on Go (Pion).
  * 簡易 Next.js 前端，能建立 P2P/SFU 房間。
    Simple Next.js frontend capable of creating P2P/SFU rooms.
  * 模擬 IoT 設備端，可接收 MQTT 指令並列印日誌 (暫無實體硬體)。
    Simulated IoT device that receives MQTT commands and prints logs (no physical hardware yet).

---

## Phase 2: 核心 SaaS 系統與合規整合 Core SaaS System & Compliance Integration (2-3 個月 months)

* **目標 Goal:** 完成雙軌制年齡驗證與創作者心理諮商模組。
  Complete dual-track age verification and creator psychological counseling module.

* **交付物 Deliverables:**
  * 整合 Yoti 與 World ID API。
    Integrate Yoti and World ID APIs.
  * 完成 E2EE (端到端加密) 諮商室功能 (WebRTC Data Channel 加密)。
    Complete E2EE (end-to-end encrypted) counseling room (WebRTC Data Channel encryption).
  * 建立創作者與諮商師的預約系統 (gRPC + 關聯式資料庫)。
    Build counselor-creator appointment system (gRPC + relational database).

---

## Phase 3: Web3 支付與智能合約 Web3 Payments & Smart Contracts (2 個月 months)

* **目標 Goal:** 建立抗審查的金流系統。
  Build a censorship-resistant payment system.

* **交付物 Deliverables:**
  * 部署打賞與隱私路由發放智能合約 (Solidity 或 Rust)。
    Deploy tip and privacy routing disbursement smart contracts (Solidity or Rust).
  * 前端整合 Phantom/MetaMask 錢包，實作安全出金教學流程。
    Frontend integration with Phantom/MetaMask wallets, implementing secure withdrawal tutorial flow.
  * 平台內 Redis 狀態同步與金流事件的一致性處理。
    Platform Redis state synchronization and payment event consistency handling.

---

## Phase 4: 韌體開發與資安審計 Firmware Development & Security Audit (3 個月 months)

* **目標 Goal:** 打造安全的硬體生態並進行全面審查。
  Build a secure hardware ecosystem and conduct comprehensive audits.

* **交付物 Deliverables:**
  * 實作硬體 Watchdog 與固態繼電器 (SSR) 斷電機制。
    Implement hardware Watchdog and Solid-State Relay (SSR) power-off mechanism.
  * 整合 Secure Element (SE) 進行憑證管理。
    Integrate Secure Element (SE) for certificate management.
  * 聘請外部資安公司進行 Web3 合約審計與 IoT 滲透測試 (Pen-testing)。
    Engage external security firms for Web3 contract audits and IoT penetration testing.

---

## Phase 5: Beta 測試與社群冷啟動 Beta Testing & Community Cold Start

* 邀請首批創作者與諮商師進行封閉測試 (Closed Beta)。
  Invite initial creators and counselors for closed beta testing.
* 建立 Cloudflare 邊緣路由機制，優化跨國延遲。
  Establish Cloudflare edge routing mechanism to optimize cross-border latency.
