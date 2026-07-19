
# 系統技術棧 Tech Stack

本文件定義了平台的微服務架構與相關技術選型，專注於高效能、低延遲以及最大化利用免費層（Free Tier）資源的第三方雲端服務。

This document defines the platform's microservice architecture and technology selections, focusing on high performance, low latency, and maximizing free tier resources from third-party cloud services.

---

## 1. 核心開發語言與框架 Core Languages & Frameworks

* **前端 Frontend:** 採用 **React** 與 **Next.js** 進行伺服器端渲染 (SSR) 與靜態生成，提供極佳的 SEO 與使用者體驗。
  Uses **React** and **Next.js** for server-side rendering (SSR) and static generation, providing excellent SEO and user experience.

* **後端微服務 Backend Microservices:**
  * **Go:** 負責處理高併發的 API 網關 (API Gateway)、WebRTC SFU (如 Pion) 以及輕量級 MQTT Broker 的業務邏輯封裝。
    Handles high-concurrency API Gateway, WebRTC SFU (e.g., Pion), and lightweight MQTT Broker business logic.
  * **Rust:** 用於開發對記憶體安全與效能要求極高的模組，例如 Web3 隱私路由合約互動、以及 IoT 端的加密元件 (Secure Element) 邏輯。
    Used for modules requiring extreme memory safety and performance, such as Web3 privacy routing contract interactions and IoT-side Secure Element encryption logic.

---

## 2. 訊息佇列與狀態同步 Messaging & Synchronization

* **微服務通訊 Service-to-Service:** 採用 **gRPC** (Protobuf) 確保內部服務間的高效能、強型別通訊。
  Uses **gRPC** (Protobuf) for high-performance, strongly-typed communication between internal services.

* **事件驅動架構 Event-Driven:** 引入 **Kafka** 處理非同步任務，例如金流審計日誌、用戶年齡驗證狀態的跨節點廣播，解耦系統架構。
  Introduces **Kafka** for asynchronous tasks such as payment audit logs and cross-node broadcasting of user age verification status, decoupling system architecture.

* **即時狀態快取 Real-time State Cache:** 採用 **Redis** (可選用 Upstash 的免費 Serverless Redis 方案)，專門處理房間狀態、打賞指令佇列與權限 Token，嚴格遵守不快取影音串流的原則。
  Uses **Redis** (Upstash free Serverless Redis recommended) for room state, tip command queue, and permission tokens strictly—never caching media streams.

---

## 3. 資料庫選型 Database Selection (Free Tier Focused)

* **關聯式資料庫 SQL Database:**
  * **選型 Selection:** Supabase (PostgreSQL) + Drizzle ORM
  * **用途 Purpose:** 儲存具備強關聯性的核心業務資料（如創作者帳號、心理諮商預約紀錄、訂單狀態、RBAC 權限）。
    Stores strongly relational core business data (creator accounts, counseling appointment records, order status, RBAC permissions).
  * **優勢 Advantages:** 提供慷慨的免費層 (500MB 資料庫空間、每月 5GB 頻寬)，自帶 Row Level Security (RLS) 以及 Auth 功能，與 Next.js 整合極佳，可作為系統的核心資料主幹。
    Generous free tier (500MB database, 5GB bandwidth/month), built-in Row Level Security (RLS) and Auth, excellent Next.js integration, serves as the core data backbone.
  * **ORM:** Drizzle ORM for type-safe database queries and migrations.

* **非關聯式資料庫 NoSQL Database:**
  * **選型 Selection:** MongoDB Atlas (M0 Free Cluster) + Mongoose
  * **用途 Purpose:** 處理無固定結構 (Schema-less) 的資料，例如 IoT 設備的歷史遙測日誌 (Telemetry Logs)、聊天室訊息紀錄、以及動態的內容審核 (Moderation) 標籤。
    Handles schema-less data such as IoT device historical telemetry logs, chat room message records, and dynamic content moderation tags.
  * **優勢 Advantages:** 提供 512MB 的永久免費儲存空間，叢集自動管理，適合初期 PoC 與海量非結構化日誌收集。
    512MB permanent free storage, auto-managed clusters, ideal for initial PoC and massive unstructured log collection.
  * **ODM:** Mongoose for schema validation and model definitions.

---

## 4. 資料庫架構 Database Architecture

### PostgreSQL Schema (via Drizzle ORM)

核心資料表 Core Tables:
* `users` — 使用者帳號、錢包地址、RBAC 角色
* `rooms` — 直播/諮商房間設定、E2EE 狀態
* `room_participants` — 房間參與者與角色
* `counselors` — 諮商師資料、專長、費率
* `bookings` — 預約紀錄與狀態
* `tips` — 打賞託管交易紀錄
* `withdrawals` — 出金申請與區塊鏈交易
* `audit_logs` — 操作審計日誌
* `age_verifications` — 年齡驗證紀錄
* `devices` — IoT 設備註冊資料

### MongoDB Collections (via Mongoose)

非結構化資料 Unstructured Data:
* `telemetry_logs` — IoT 設備遙測日誌 (高頻寫入)
* `chat_messages` — 房間聊天紀錄 (加密)
* `moderation_tags` — 內容審核標籤

---

## 5. 容器化與部署 Containerization & Deployment

* **Dockerfiles:**
  * `Dockerfile.go` — Go 服務共用多階段建構 (Builder → Alpine Runtime)
  * `Dockerfile.rust` — Rust 韌體多階段建構 (Builder → Debian Slim Runtime)
  * `Dockerfile.web` — Next.js 多階段建構 (Node Builder → Alpine Runtime + Standalone Output)

* **Docker Compose:** 本地開發環境，包含所有服務與基礎設施容器。
  Local development environment with all services and infrastructure containers.

* **Health Checks:** 所有容器皆設定健康檢查，確保服務可用性。
  All containers configured with health checks for service availability.

---

## 6. 基礎設施即程式碼 Infrastructure as Code (IaC)

* **Terraform:** 跨雲供應商基礎設施管理。
  Cross-cloud infrastructure management.
  * `modules/cloudflare` — DNS、DDoS 防護、Workers
  * `modules/supabase` — PostgreSQL 資料庫與 Auth
  * `modules/mongodb-atlas` — MongoDB 叢集

* **Pulumi:** 程式化基礎設施部署 (TypeScript)。
  Programmatic infrastructure deployment (TypeScript).
  * 支援 Dev/Prod 環境隔離
  * 自動化 Secret 管理

* **Choreo.dev:** 雲端服務部署與監控。
  Cloud service deployment and monitoring.
  * 微服務元件定義
  * 自動 CI/CD 管線

---

## 7. 反向代理與路由 Reverse Proxy & Routing

* **Nginx:** 反向代理、負載平衡、SSL 終止。
  Reverse proxy, load balancing, SSL termination.
  * 路由規則: `/api/*` → API Gateway, `/ws/*` → SFU Server
  * 速率限制與安全標頭
  * 靜態資源快取

---

## 8. 第三方服務與基礎設施 3rd Party Services & Infrastructure

* **邊緣網路與防禦 Edge Network & Security:**
  * **Cloudflare:** 提供 DNS 解析、DDoS 防護 (Anycast)、WAF 以及 CDN 加速。利用 Cloudflare Workers 處理邊緣端的 JWT 驗證與輕量級路由，阻擋惡意請求直達後端。
    Provides DNS resolution, DDoS protection (Anycast), WAF, and CDN acceleration. Uses Cloudflare Workers for edge-side JWT verification and lightweight routing, blocking malicious requests before they reach the backend.

* **年齡驗證與隱私 Age & Identity Verification:**
  * **Yoti:** 提供面部年齡估算 API (Facial Age Estimation)，無須儲存證件即可完成 18+ 認證。
    Provides Facial Age Estimation API for 18+ verification without storing identity documents.
  * **World ID (Worldcoin):** 零知識證明身分驗證，完美契合 Web3 匿名需求。
    Zero-knowledge proof identity verification, perfectly suited for Web3 anonymity requirements.

* **Web3 金流基礎設施 Web3 Payment Infrastructure:**
  * **RPC 節點 RPC Nodes:** Alchemy 或 QuickNode (兩者皆有高額度免費層)，負責廣播智能合約交易。
    Alchemy or QuickNode (both with generous free tiers) for broadcasting smart contract transactions.
  * **錢包整合 Wallet Integration:** Phantom (Solana 網路) 等非託管錢包。
    Phantom (Solana network) and other non-custodial wallets.

---

### 資料來源與參考 References

* **Supabase Free Tier Specs:** [Supabase 官方定價與資源限制](https://supabase.com/pricing)
* **MongoDB Atlas M0 Free Cluster:** [MongoDB 官方免費層規格文件](https://www.mongodb.com/pricing)
* **Upstash Serverless Data:** [Upstash Redis 免費層方案](https://upstash.com/pricing)
* **Cloudflare Developer Docs:** 邊緣運算與 Anycast 架構技術白皮書
* **Drizzle ORM:** [Type-safe database queries](https://orm.drizzle.team/)
* **Terraform:** [Infrastructure as Code](https://www.terraform.io/)
* **Pulumi:** [Programmatic IaC](https://www.pulumi.com/)
* **Choreo.dev:** [Cloud service deployment](https://choreo.dev/)
