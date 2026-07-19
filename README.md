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

本專案建議採用 Turborepo 或 Nx 進行 Monorepo 管理，將前後端、智能合約與韌體代碼統一管控。

This project uses Turborepo or Nx for monorepo management, unifying frontend, backend, smart contracts, and firmware code.

```text
aurasync-monorepo/
├── apps/
│   ├── web-app/               # Next.js 前端 (觀眾端、創作者控制台、諮商室) / Next.js Frontend (Audience, Creator Console, Counseling Room)
│   ├── sfu-server/            # WebRTC SFU 伺服器 (Go/Pion 或 Rust/Mediasoup) / WebRTC SFU Server
│   ├── api-gateway/           # gRPC / REST API 網關 (處理業務邏輯) / API Gateway (Business Logic)
│   └── mqtt-broker/           # MQTT 輕量級 Broker (處理 IoT 心跳與遙測) / MQTT Lightweight Broker (IoT Heartbeat & Telemetry)
├── packages/
│   ├── ui/                    # 共用 React 元件庫 (Tailwind CSS) / Shared React Component Library
│   ├── rpc-schema/            # Protobuf 檔案 (定義前後端與硬體通訊協議) / Protobuf Files (Communication Protocol)
│   ├── webrtc-sdk/            # 封裝 WebRTC 連線與 Data Channel 邏輯 / WebRTC Connection & Data Channel Logic
│   └── crypto-utils/          # Web3 錢包互動、簽章驗證與 ZK 驗證模組 / Web3 Wallet, Signature & ZK Verification
├── contracts/                 # 智能合約 (Solidity / Rust for Solana) / Smart Contracts
│   ├── payment-router/        # 隱私路由發放合約 / Privacy Routing Disbursement Contract
│   └── tip-escrow/            # 打賞託管合約 / Tip Escrow Contract
├── firmware/                  # IoT 設備韌體 (C / Rust) / IoT Device Firmware
│   ├── core/                  # 硬體看門狗 (WDT) 與 SSR 控制邏輯 / Hardware Watchdog & SSR Control Logic
│   └── secure-element/        # SE 晶片憑證管理與加密通訊 / SE Chip Certificate Management & Encrypted Communication
├── docs/                      # 系統架構圖與開發者文檔 / System Architecture & Developer Documentation
├── docker-compose.yml         # 本地端快速啟動環境 (Redis, Postgres, Local Broker) / Local Dev Environment
└── README.md
```

---

## 快速開始 Quick Start

```bash
# 安裝依賴 Install dependencies
npm install

# 啟動本地開發環境 Start local development
npm run dev

# 執行測試 Run tests
npm test

# 建構生產版本 Build for production
npm run build
```

## 授權條款 License

MIT License - Copyright (c) 2026 Dennislee:)
