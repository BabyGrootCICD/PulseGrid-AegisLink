
# 系統與營運 AI 代理 (Agents & Skills)

為了應對平台高併發與複雜的營運需求，專案架構中將整合多個專業化的 AI Agents (基於開源 LLM 代理框架如 LangChain / AutoGen)。

## 1. 創作者心理輔導與分診 Agent (Triage Agent)

* **角色:** 作為諮商 SaaS 模組的第一線防護。
* **Skills:**
  * **情緒分析 (Sentiment Analysis):** 分析創作者輸入的文字或語音，評估壓力指數。
  * **隱私脫敏 (Data Anonymization):** 在將資料轉交給真人治療師前，自動遮蔽特定人名與敏感細節。
  * **預約調度:** 根據創作者的危機等級，自動匹配合適的專業諮商師。

## 2. 合規與內容審核 Agent (Moderation Agent)

* **角色:** 確保互動式轉播內容符合法規 (防制未成年剝削、極端暴力)。
* **Skills:**
  * **Computer Vision (邊緣運算):** 抽樣 WebRTC 視訊幀，偵測異常或違規行為。
  * **IoT 指令異常偵測:** 監控 MQTT Payload，若發現惡意攻擊特徵 (如高頻震動、異常溫度數值) 即自動切斷設備連線並通報。

## 3. Web3 金流監控 Agent (On-chain Analyst Agent)

* **角色:** 監控平台的智能合約與資金池狀態。
* **Skills:**
  * **異常流出偵測:** 監聽區塊鏈事件，若發現大規模合約資金移轉，自動觸發多簽錢包凍結。
  * **Gas Fee 最佳化:** 根據當前網路壅塞程度，自動調整打賞與發放款項的打包策略。

## 4. 內部開發輔助 Agent (DevOps / Code Agent)

* **角色:** 協助開發團隊 (配合 Cursor Pro / Ollama 等工具)。
* **Skills:**
  * **Rust/Go 效能調優:** 自動檢查 SFU 與 MQTT Broker 中的記憶體洩漏與 Concurrency (Race conditions) 問題。
  * **智能合約審查:** 在 CI/CD 流程中自動執行靜態分析，偵測 Reentrancy 或溢位漏洞。
