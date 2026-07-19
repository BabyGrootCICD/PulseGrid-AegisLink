
# 系統技術棧 (Tech Stack)

本文件定義了平台的微服務架構與相關技術選型，專注於高效能、低延遲以及最大化利用免費層（Free Tier）資源的第三方雲端服務。

## 1. 核心開發語言與框架 (Core Languages & Frameworks)

* **前端 (Frontend):** 採用 **React** 與 **Next.js** 進行伺服器端渲染 (SSR) 與靜態生成，提供極佳的 SEO 與使用者體驗。
* **後端微服務 (Backend Microservices):**
  * **Go:** 負責處理高併發的 API 網關 (API Gateway)、WebRTC SFU (如 Pion) 以及輕量級 MQTT Broker 的業務邏輯封裝。
  * **Rust:** 用於開發對記憶體安全與效能要求極高的模組，例如 Web3 隱私路由合約互動、以及 IoT 端的加密元件 (Secure Element) 邏輯。

## 2. 訊息佇列與狀態同步 (Messaging & Synchronization)

* **微服務通訊 (Service-to-Service):** 採用 **gRPC** (Protobuf) 確保內部服務間的高效能、強型別通訊。
* **事件驅動架構 (Event-Driven):** 引入 **Kafka** 處理非同步任務，例如金流審計日誌、用戶年齡驗證狀態的跨節點廣播，解耦系統架構。
* **即時狀態快取 (State Cache):** 採用 **Redis** (可選用 Upstash 的免費 Serverless Redis 方案)，專門處理房間狀態、打賞指令佇列與權限 Token，嚴格遵守不快取影音串流的原則。

## 3. 資料庫選型 (Database - Free Tier Focused)

* **關聯式資料庫 (SQL DB):**
  * **選型: Supabase (PostgreSQL)**
  * **用途:** 儲存具備強關聯性的核心業務資料（如創作者帳號、心理諮商預約紀錄、訂單狀態、RBAC 權限）。
  * **優勢:** 提供慷慨的免費層 (500MB 資料庫空間、每月 5GB 頻寬)，自帶 Row Level Security (RLS) 以及 Auth 功能，與 Next.js 整合極佳，可作為系統的核心資料主幹。
* **非關聯式資料庫 (NoSQL DB):**
  * **選型: MongoDB Atlas (M0 Free Cluster)**
  * **用途:** 處理無固定結構 (Schema-less) 的資料，例如 IoT 設備的歷史遙測日誌 (Telemetry Logs)、聊天室訊息紀錄、以及動態的內容審核 (Moderation) 標籤。
  * **優勢:** 提供 512MB 的永久免費儲存空間，叢集自動管理，適合初期 PoC 與海量非結構化日誌收集。

## 4. 第三方服務與基礎設施 (3rd Party Services & Infrastructure)

* **邊緣網路與防禦 (Edge & Security):**
  * **Cloudflare:** 提供 DNS 解析、DDoS 防護 (Anycast)、WAF 以及 CDN 加速。利用 Cloudflare Workers 處理邊緣端的 JWT 驗證與輕量級路由，阻擋惡意請求直達後端。
* **年齡驗證與隱私 (Age & Identity):**
  * **Yoti:** 提供面部年齡估算 API (Facial Age Estimation)，無須儲存證件即可完成 18+ 認證。
  * **World ID (Worldcoin):** 零知識證明身分驗證，完美契合 Web3 匿名需求。
* **Web3 金流基礎設施 (Web3 Infrastructure):**
  * **RPC 節點:** Alchemy 或 QuickNode (兩者皆有高額度免費層)，負責廣播智能合約交易。
  * **錢包整合:** Phantom (Solana 網路) 等非託管錢包。

---

### 資料來源與參考 (References)

* **Supabase Free Tier Specs:** [Supabase 官方定價與資源限制](https://supabase.com/pricing)
* **MongoDB Atlas M0 Free Cluster:** [MongoDB 官方免費層規格文件](https://www.mongodb.com/pricing)
* **Upstash Serverless Data:** [Upstash Redis 免費層方案](https://upstash.com/pricing)
* **Cloudflare Developer Docs:** 邊緣運算與 Anycast 架構技術白皮書
