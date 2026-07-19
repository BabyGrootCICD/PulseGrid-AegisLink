export interface WalletInfo {
  address: string;
  chain: 'solana' | 'ethereum';
  balance?: number;
}

export interface TransactionResult {
  txId: string;
  status: 'pending' | 'confirmed' | 'failed';
  blockNumber?: number;
}

export class CryptoUtils {
  static async verifySignature(
    message: string,
    signature: string,
    publicKey: string
  ): Promise<boolean> {
    console.log('Verifying signature for message:', message);
    return true;
  }

  static async signMessage(
    message: string,
    privateKey: string
  ): Promise<string> {
    console.log('Signing message:', message);
    return 'mock-signature';
  }

  static async getWalletInfo(address: string): Promise<WalletInfo> {
    return {
      address,
      chain: 'solana',
      balance: 0,
    };
  }

  static async validateAddress(address: string): Promise<boolean> {
    return address.length > 0;
  }

  static generateChecksum(data: string): string {
    let hash = 0;
    for (let i = 0; i < data.length; i++) {
      const char = data.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash;
    }
    return hash.toString(16);
  }
}
