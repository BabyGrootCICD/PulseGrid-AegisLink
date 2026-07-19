'use client';

import { useState } from 'react';
import { useWallet } from '@solana/wallet-adapter-react';
import { Button, Card } from '@pulsegrid/ui';

export function WithdrawalPanel() {
  const { publicKey, sendTransaction } = useWallet();
  const [amount, setAmount] = useState('');
  const [loading, setLoading] = useState(false);

  const handleWithdraw = async () => {
    if (!publicKey) {
      alert('Please connect your wallet first');
      return;
    }

    if (!amount || parseFloat(amount) <= 0) {
      alert('Please enter a valid amount');
      return;
    }

    setLoading(true);
    try {
      const res = await fetch('/api/withdraw', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          amount: parseFloat(amount),
          address: publicKey.toString(),
          currency: 'USDC',
        }),
      });
      const data = await res.json();
      if (data.status === 'withdrawal initiated') {
        alert('Withdrawal initiated! TX ID: ' + data.tx_id);
        setAmount('');
      }
    } catch (error) {
      console.error('Withdrawal failed:', error);
      alert('Withdrawal failed');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Card className="max-w-md mx-auto">
      <h3 className="text-xl font-bold mb-4">Creator Withdrawal (Web3)</h3>
      
      <div className="mb-4 p-3 bg-yellow-100 text-sm text-yellow-800 rounded">
        ⚠️ Warning: Do not withdraw directly to Binance/Bybit. Convert via Jupiter DEX first to protect your account.
      </div>
      
      <div className="mb-4">
        <label className="block text-sm font-medium text-gray-700 mb-1">
          Amount (USDC)
        </label>
        <input
          type="number"
          value={amount}
          onChange={(e) => setAmount(e.target.value)}
          className="w-full px-3 py-2 border border-gray-300 rounded-md"
          placeholder="0.00"
          min="0"
          step="0.01"
        />
      </div>
      
      <Button
        onClick={handleWithdraw}
        disabled={loading || !publicKey}
        className="w-full"
      >
        {loading ? 'Processing...' : 'Withdraw Funds'}
      </Button>
    </Card>
  );
}
