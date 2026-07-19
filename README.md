# PulseGrid-AegisLink (Repository) / AuraSync (Product)

> **Repository**: PulseGrid-AegisLink  
> **Product**: AuraSync — A B2B2C platform combining interactive adult entertainment broadcasting with privacy-first sexual health/psychological counseling.

---

## 專案概述 Project Overview

**AuraSync** 是一個結合「互動式成人娛樂轉播」與「隱私優先性健康/心理諮商」的 B2B2C 平台。專為創作者與專業諮商師設計，旨在解決成人產業中創作者的高心理消耗與職災問題，同時提供端到端加密的互動體驗。

**AuraSync** is a B2B2C platform that combines "interactive adult entertainment broadcasting" with "privacy-first sexual health/psychological counseling." Designed for creators and professional counselors, it aims to address the high psychological burnout and occupational hazards faced by adult industry creators while providing end-to-end encrypted interactive experiences.

## 核心技術骨幹 Core Technology Stack

* **前端框架 Frontend:** Next.js, React (完美契合高效能 SSR 與 SEO 需求 / Perfect for high-performance SSR and SEO)
* **影音與低延遲通訊 Audio/Video & Low-Latency:** WebRTC, SFU 架構 (Go/Pion 或 Rust/Mediasoup / Go/Pion or Rust/Mediasoup)
* **物聯網與設備同步 IoT & Device Sync:** MQTT (狀態遙測 / State telemetry), gRPC (高吞吐量指令 / High-throughput commands)
* **快取與房間狀態 Cache & Room State:** Redis (專司房間狀態、打賞佇列與權限 Token，不快取影音 / Room state, tip queue & permission tokens only, no media caching)
* **邊緣運算與路由 Edge Computing & Routing:** Cloudflare (Anycast UDP 流量優化 / Anycast UDP traffic optimization)
* **Web3 金流與驗證 Web3 Payments & Verification:** Solana/Ethereum 智能合約 Smart Contracts, Phantom 錢包整合 Wallet Integration, Yoti / World ID (零知識年齡驗證 / Zero-knowledge age verification)
* **資料庫 Database:** PostgreSQL (Supabase + Drizzle ORM), MongoDB (Atlas + Mongoose), Redis
* **基礎設施即程式碼 IaC:** Terraform, Pulumi, Choreo.dev
* **容器化 Containerization:** Docker (Go/Rust/Web multi-stage builds), Docker Compose, Nginx reverse proxy

## 資安與合規防護 Security & Compliance (The Grill 解決方案 Solutions)

1. **硬體 Fail-safe Hardware Fail-safe:** 採用固態繼電器 (SSR) 與 MCU 硬體看門狗 (Hardware Watchdog)，防止 DDoS 導致設備失控。
   Uses Solid-State Relays (SSR) and MCU Hardware Watchdog to prevent device malfunction caused by DDoS attacks.

2. **防逆向與身分偽造 Anti-Reverse Engineering & Identity Spoofing:** 結合安全元件 (Secure Element, SE) 隔離憑證，防止遠程代碼執行 (RCE) 與重放攻擊。
   Combines Secure Element (SE) to isolate credentials, preventing Remote Code Execution (RCE) and replay attacks.

3. **隱私與年齡驗證 Privacy & Age Verification:** 全面摒棄傳統身分證上傳。採用 World ID (ZK) 與 Yoti (Facial Age Estimation) 雙軌制。
   Completely eliminates traditional ID card uploads. Uses dual-track system: World ID (Zero-Knowledge) and Yoti (Facial Age Estimation).

4. **金流反洗錢防護 Anti-Money Laundering Protection:** 實作 Web3 非託管錢包與 Privacy Relay，引導創作者透過 DEX (如 Jupiter/Uniswap) 路由 USDC/USDT，避免中心化交易所 (CEX) 帳號因關聯性遭凍結。
   Implements Web3 non-custodial wallets and Privacy Relay, guiding creators to route USDC/USDT through DEXs (e.g., Jupiter/Uniswap) to prevent centralized exchange (CEX) account freezing due to association.

## 資料來源與參考 References

* [RFC 3550] RTP: A Transport Protocol for Real-Time Applications
* Yoti Age Verification Whitepaper (Privacy & GDPR compliance)
* Chainalysis Crypto Crime Report (CEX AML guidelines)

---

## Repository 結構 Structure (Monorepo)

本專案採用 Turborepo 進行 Monorepo 管理，將前後端、智能合約與韌體代碼統一管控。

This project uses Turborepo for monorepo management, unifying frontend, backend, smart contracts, and firmware code.

```text
pulsegrid-aegislink/
├── apps/
│   ├── web-app/               # Next.js 前端 (觀眾端、創作者控制台、諮商室) / Next.js Frontend
│   ├── sfu-server/            # WebRTC SFU 伺服器 (Go/Pion) / WebRTC SFU Server
│   ├── api-gateway/           # gRPC / REST API 網關 / API Gateway
│   └── mqtt-broker/           # MQTT 輕量級 Broker / MQTT Lightweight Broker
├── packages/
│   ├── ui/                    # 共用 React 元件庫 / Shared React Component Library
│   ├── rpc-schema/            # Protobuf 檔案 / Protobuf Files
│   ├── webrtc-sdk/            # WebRTC 連線邏輯 / WebRTC Connection Logic
│   └── crypto-utils/          # Web3 加密工具 / Web3 Crypto Utilities
├── contracts/                 # 智能合約 / Smart Contracts
│   ├── payment-router/        # 隱私路由發放合約 / Privacy Routing Contract
│   └── tip-escrow/            # 打賞託管合約 / Tip Escrow Contract
├── firmware/                  # IoT 設備韌體 / IoT Device Firmware
│   ├── core/                  # 硬體看門狗與 SSR 控制 / Hardware Watchdog & SSR
│   └── secure-element/        # SE 晶片加密通訊 / SE Chip Encryption
├── database/                  # 資料庫架構與迁移 / Database Schema & Migrations
│   ├── postgres/              # PostgreSQL schema, migrations, seeds
│   ├── mongodb/               # MongoDB schemas (Mongoose)
│   ├── redis/                 # Redis configuration
│   └── drizzle/               # Drizzle ORM schema & config
├── infrastructure/            # 基礎設施即程式碼 / Infrastructure as Code
│   ├── terraform/             # Terraform modules (Cloudflare, Supabase, MongoDB Atlas)
│   ├── pulumi/                # Pulumi programs (TypeScript)
│   ├── choreo/                # Choreo.dev service definitions
│   └── nginx/                 # Nginx reverse proxy config
├── config/                    # 服務配置文件 / Service Configurations
├── docs/                      # 開發者文檔 / Developer Documentation
├── Dockerfile.go              # Go 服務共用 Dockerfile / Shared Go Dockerfile
├── Dockerfile.rust            # Rust 韌體 Dockerfile / Rust Firmware Dockerfile
├── Dockerfile.web             # Next.js Dockerfile / Next.js Dockerfile
├── docker-compose.yml         # 本地開發環境 / Local Development Environment
└── README.md
```

---

## 快速開始 Quick Start

```bash
# 安裝依賴 Install dependencies
npm install

# 啟動本地開發環境 (含資料庫容器) Start local dev (with DB containers)
docker-compose up -d
npm run dev

# 執行資料庫迁移 Run database migrations
npm run db:migrate

# 執行測試 Run tests
npm test

# Robot Framework 整合測試 Run integration tests
robot tests/

# 建構生產版本 Build for production
npm run build

# Docker 建構 Build Docker images
docker build -f Dockerfile.go -t pulsegrid-go .
docker build -f Dockerfile.rust -t pulsegrid-rust .
docker build -f Dockerfile.web -t pulsegrid-web .
```

---

## 資料庫 Database

### PostgreSQL Tables (Drizzle ORM)

| 資料表 Table | 用途 Purpose |
|-------------|-------------|
| `users` | 使用者帳號、錢包地址、RBAC 角色 |
| `rooms` | 直播/諮商房間設定、E2EE 狀態 |
| `room_participants` | 房間參與者與角色 |
| `counselors` | 諮商師資料、專長、費率 |
| `bookings` | 預約紀錄與狀態 |
| `tips` | 打賞託管交易紀錄 |
| `withdrawals` | 出金申請與區塊鏈交易 |
| `audit_logs` | 操作審計日誌 |
| `age_verifications` | 年齡驗證紀錄 |
| `devices` | IoT 設備註冊資料 |

### MongoDB Collections (Mongoose)

| 集合 Collection | 用途 Purpose |
|----------------|-------------|
| `telemetry_logs` | IoT 設備遙測日誌 (高頻寫入) |
| `chat_messages` | 房間聊天紀錄 (加密) |
| `moderation_tags` | 內容審核標籤 |

---

## 基礎設施 Infrastructure

### Terraform Modules

| 模組 Module | 用途 Purpose |
|------------|-------------|
| `cloudflare` | DNS、DDoS 防護、Workers |
| `supabase` | PostgreSQL 資料庫與 Auth |
| `mongodb-atlas` | MongoDB 叢集 |

### Docker Services

| 服務 Service | 連接埠 Port | 用途 Purpose |
|-------------|------------|-------------|
| redis | 6379 | 快取與房間狀態 / Cache & Room State |
| postgres | 5432 | 關聯式資料庫 / SQL Database |
| mongodb | 27017 | 非結構化資料 / NoSQL Database |
| mosquitto | 1883, 9001 | MQTT Broker |
| nginx | 80, 443 | 反向代理 / Reverse Proxy |

---

## 授權條款 License

MIT License - Copyright (c) 2026 Dennislee:)
