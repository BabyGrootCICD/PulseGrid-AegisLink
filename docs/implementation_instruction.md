
# 實作指南 (Implementation Instructions)

本指南專注於前端核心模組的串接，特別是「雙軌制年齡驗證」與「Web3 錢包出金」流程。

## 1. 雙軌制年齡驗證 (Age Verification)

### 前端流程 (UX Workflow)

1. 使用者註冊或嘗試進入 18+ 房間時，彈出驗證 Modal。
2. 提供兩個選項：`Verify with Yoti (Camera)` 或 `Verify with World ID (Crypto)`。
3. **World ID (Track A):**
   * 整合 `@worldcoin/idkit`。
   * 呼叫 ZKP，確認使用者為真實人類且符合條件。
4. **Yoti (Track B):**
   * 呼叫 Yoti Client SDK，開啟前置鏡頭進行面部年齡估算。
   * 獲取 `is_adult: true` 狀態。
5. 前端取得驗證 Token 後，透過 RPC 傳遞給後端，後端發放含有效期的 JWT (不含任何個資)。

### 實作範例 (Next.js - World ID)

```javascript
import { IDKitWidget } from '@worldcoin/idkit';

export default function AgeVerification() {
  const handleVerify = async (proof) => {
    const res = await fetch('/api/verify', {
      method: 'POST',
      body: JSON.stringify(proof)
    });
    // 處理 JWT 核發
  };

  return (
    <IDKitWidget
      app_id="app_your_worldcoin_id"
      action="verify-adult"
      onSuccess={handleVerify}
    >
      {({ open }) => <button onClick={open}>Verify with World ID</button>}
    </IDKitWidget>
  );
}
```

## 2. Web3 錢包整合與出金流程

### 前端流程 (Creator Dashboard)

1. 創作者進入「收入管理」頁面，提示綁定 Web3 錢包 (例如 Phantom 或 MetaMask)。
2. 使用者點擊「Withdraw (出金)」。
3. **隱私提示 (Crucial):** 前端 UI 必須顯示警告，建議將 USDC/USDT 提領至非託管錢包，並透過 DEX 轉換後再入金 CEX，避免 AML 凍結。
4. 呼叫智能合約進行款項轉移。

### 實作範例 (React - Phantom/Solana)

```javascript
import { useWallet } from '@solana/wallet-adapter-react';
import { WalletMultiButton } from '@solana/wallet-adapter-react-ui';

export function WithdrawalPanel() {
  const { publicKey, sendTransaction } = useWallet();

  const handleWithdraw = async () => {
    if (!publicKey) return alert("請先連接錢包");
    // 1. 取得後端簽名授權
    // 2. 構建並發送合約交易 (透過 Privacy Relay 路由)
    console.log("Initiating withdrawal to:", publicKey.toString());
  };

  return (
    <div className="p-4 border rounded">
      <h3>創作者出金 (Web3)</h3>
      <WalletMultiButton />
      <div className="mt-4 p-2 bg-yellow-100 text-sm text-yellow-800">
        ⚠️ 建議：請勿直接提現至 Binance/Bybit。建議先透過 Jupiter DEX 轉換幣種，以保護您的帳戶安全。
      </div>
      <button onClick={handleWithdraw} className="mt-2 bg-blue-600 text-white p-2 rounded">
        Withdraw Funds
      </button>
    </div>
  );
}
```

## 3. WebRTC 與 MQTT 同步

* 建立 `webrtc-sdk`，監聽 RTP 時間戳。
* 接收到影音串流時，根據 Timestamp 從 Redis 佇列中提取對應的 IoT 控制指令，並透過 gRPC 發送給 Broker。
