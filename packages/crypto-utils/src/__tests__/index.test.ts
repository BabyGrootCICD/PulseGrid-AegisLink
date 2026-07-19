import { CryptoUtils } from '../index';

describe('CryptoUtils', () => {
  it('verifies signature', async () => {
    const result = await CryptoUtils.verifySignature(
      'test message',
      'test-signature',
      'test-public-key'
    );
    
    expect(result).toBe(true);
  });

  it('signs message', async () => {
    const signature = await CryptoUtils.signMessage(
      'test message',
      'test-private-key'
    );
    
    expect(signature).toBe('mock-signature');
  });

  it('validates address', async () => {
    const result = await CryptoUtils.validateAddress('test-address');
    
    expect(result).toBe(true);
  });

  it('generates checksum', () => {
    const checksum = CryptoUtils.generateChecksum('test-data');
    
    expect(typeof checksum).toBe('string');
    expect(checksum.length).toBeGreaterThan(0);
  });
});
