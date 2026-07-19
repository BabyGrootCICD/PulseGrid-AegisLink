'use client';

import { useEffect, useRef, useState } from 'react';
import { WebRTCManager } from '@pulsegrid/webrtc-sdk';
import { Button, Card } from '@pulsegrid/ui';

interface CounselingRoomProps {
  roomId: string;
  userId: string;
  counselorId: string;
}

export function CounselingRoom({ roomId, userId, counselorId }: CounselingRoomProps) {
  const [isConnected, setIsConnected] = useState(false);
  const [isMuted, setIsMuted] = useState(false);
  const [isVideoOff, setIsVideoOff] = useState(false);
  const localVideoRef = useRef<HTMLVideoElement>(null);
  const remoteVideoRef = useRef<HTMLVideoElement>(null);
  const managerRef = useRef<WebRTCManager | null>(null);

  useEffect(() => {
    const manager = new WebRTCManager({ roomId, userId });
    managerRef.current = manager;

    return () => {
      manager.leave();
    };
  }, [roomId, userId]);

  const handleJoin = async () => {
    if (!managerRef.current) return;

    try {
      const stream = await managerRef.current.getLocalStream();
      if (localVideoRef.current) {
        localVideoRef.current.srcObject = stream;
      }
      await managerRef.current.join();
      setIsConnected(true);
    } catch (error) {
      console.error('Failed to join room:', error);
    }
  };

  const handleLeave = async () => {
    if (!managerRef.current) return;
    
    await managerRef.current.leave();
    setIsConnected(false);
    if (localVideoRef.current) {
      localVideoRef.current.srcObject = null;
    }
  };

  const toggleMute = () => {
    setIsMuted(!isMuted);
  };

  const toggleVideo = () => {
    setIsVideoOff(!isVideoOff);
  };

  return (
    <Card className="max-w-4xl mx-auto">
      <h3 className="text-xl font-bold mb-4">E2EE Counseling Room</h3>
      
      <div className="grid grid-cols-2 gap-4 mb-4">
        <div className="aspect-video bg-gray-900 rounded-lg overflow-hidden">
          <video
            ref={localVideoRef}
            autoPlay
            muted
            playsInline
            className="w-full h-full object-cover"
          />
        </div>
        <div className="aspect-video bg-gray-900 rounded-lg overflow-hidden">
          <video
            ref={remoteVideoRef}
            autoPlay
            playsInline
            className="w-full h-full object-cover"
          />
        </div>
      </div>
      
      <div className="flex justify-center gap-4">
        {!isConnected ? (
          <Button onClick={handleJoin}>Join Session</Button>
        ) : (
          <>
            <Button variant="secondary" onClick={toggleMute}>
              {isMuted ? 'Unmute' : 'Mute'}
            </Button>
            <Button variant="secondary" onClick={toggleVideo}>
              {isVideoOff ? 'Turn On Video' : 'Turn Off Video'}
            </Button>
            <Button variant="danger" onClick={handleLeave}>
              Leave Session
            </Button>
          </>
        )}
      </div>
    </Card>
  );
}
