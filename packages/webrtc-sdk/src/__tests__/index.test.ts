import { WebRTCManager } from '../index';

describe('WebRTCManager', () => {
  it('creates an instance', () => {
    const manager = new WebRTCManager({
      roomId: 'test-room',
      userId: 'test-user',
    });
    
    expect(manager).toBeDefined();
  });

  it('has join method', () => {
    const manager = new WebRTCManager({
      roomId: 'test-room',
      userId: 'test-user',
    });
    
    expect(typeof manager.join).toBe('function');
  });

  it('has leave method', () => {
    const manager = new WebRTCManager({
      roomId: 'test-room',
      userId: 'test-user',
    });
    
    expect(typeof manager.leave).toBe('function');
  });

  it('has createPeerConnection method', () => {
    const manager = new WebRTCManager({
      roomId: 'test-room',
      userId: 'test-user',
    });
    
    expect(typeof manager.createPeerConnection).toBe('function');
  });
});
