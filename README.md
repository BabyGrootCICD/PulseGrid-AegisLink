## 專案概述
AuraSync 是一個結合「互動式成人娛樂轉播」與「隱私優先性健康/心理諮商」的 B2B2C 平台。專為創作者與專業諮商師設計，旨在解決成人產業中創作者的高心理消耗與職災問題，同時提供端到端加密的互動體驗。

## 核心技術骨幹
* **前端框架:** Next.js, React (完美契合高效能 SSR 與 SEO 需求)
* **影音與低延遲通訊:** WebRTC, SFU 架構 (Go/Pion 或 Rust/Mediasoup)
* **物聯網與設備同步:** MQTT (狀態遙測), gRPC (高吞吐量指令)
* **快取與房間狀態:** Redis (專司房間狀態、打賞佇列與權限 Token，不快取影音)
* **邊緣運算與路由:** Cloudflare (Anycast UDP 流量優化)
* **Web3 金流與驗證:** Solana/Ethereum 智能合約, Phantom 錢包整合, Yoti / World ID (零知識年齡驗證)

## 資安與合規防護 (The Grill 解決方案)
1. **硬體 Fail-safe:** 採用固態繼電器 (SSR) 與 MCU 硬體看門狗 (Hardware Watchdog)，防止 DDoS 導致設備失控。
2. **防逆向與身分偽造:** 結合安全元件 (Secure Element, SE) 隔離憑證，防止遠程代碼執行 (RCE) 與重放攻擊。
3. **隱私與年齡驗證:** 全面摒棄傳統身分證上傳。採用 World ID (ZK) 與 Yoti (Facial Age Estimation) 雙軌制。
4. **金流反洗錢防護:** 實作 Web3 非託管錢包與 Privacy Relay，引導創作者透過 DEX (如 Jupiter/Uniswap) 路由 USDC/USDT，避免中心化交易所 (CEX) 帳號因關聯性遭凍結。

## 資料來源與參考
* [RFC 3550] RTP: A Transport Protocol for Real-Time Applications
* Yoti Age Verification Whitepaper (Privacy & GDPR compliance)
* Chainalysis Crypto Crime Report (CEX AML guidelines)
"""

repo_structure_md = """# Repository 結構 (Monorepo)

本專案建議採用 Turborepo 或 Nx 進行 Monorepo 管理，將前後端、智能合約與韌體代碼統一管控。

```text
aurasync-monorepo/
├── apps/
│   ├── web-app/               # Next.js 前端 (觀眾端、創作者控制台、諮商室)
│   ├── sfu-server/            # WebRTC SFU 伺服器 (Go/Pion 或 Rust/Mediasoup)
│   ├── api-gateway/           # gRPC / REST API 網關 (處理業務邏輯)
│   └── mqtt-broker/           # MQTT 輕量級 Broker (處理 IoT 心跳與遙測)
├── packages/
│   ├── ui/                    # 共用 React 元件庫 (Tailwind CSS)
│   ├── rpc-schema/            # Protobuf 檔案 (定義前後端與硬體通訊協議)
│   ├── webrtc-sdk/            # 封裝 WebRTC 連線與 Data Channel 邏輯
│   └── crypto-utils/          # Web3 錢包互動、簽章驗證與 ZK 驗證模組
├── contracts/                 # 智能合約 (Solidity / Rust for Solana)
│   ├── payment-router/        # 隱私路由發放合約
│   └── tip-escrow/            # 打賞託管合約
├── firmware/                  # IoT 設備韌體 (C / Rust)
│   ├── core/                  # 硬體看門狗 (WDT) 與 SSR 控制邏輯
│   └── secure-element/        # SE 晶片憑證管理與加密通訊
├── docs/                      # 系統架構圖與開發者文檔
├── docker-compose.yml         # 本地端快速啟動環境 (Redis, Postgres, Local Broker)
└── README.md
"""