'use client';

import { useState } from 'react';
import { IDKitWidget } from '@worldcoin/idkit';
import { Button, Modal } from '@pulsegrid/ui';

interface AgeVerificationProps {
  onVerified: (method: string, token: string) => void;
}

export function AgeVerification({ onVerified }: AgeVerificationProps) {
  const [isOpen, setIsOpen] = useState(false);
  const [method, setMethod] = useState<'yoti' | 'worldid' | null>(null);

  const handleWorldIDVerify = async (proof: any) => {
    try {
      const res = await fetch('/api/verify/age', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ method: 'worldid', ...proof }),
      });
      const data = await res.json();
      if (data.verified) {
        onVerified('worldid', data.token);
        setIsOpen(false);
      }
    } catch (error) {
      console.error('Verification failed:', error);
    }
  };

  const handleYotiVerify = async () => {
    try {
      const res = await fetch('/api/verify/age', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ method: 'yoti' }),
      });
      const data = await res.json();
      if (data.verified) {
        onVerified('yoti', data.token);
        setIsOpen(false);
      }
    } catch (error) {
      console.error('Verification failed:', error);
    }
  };

  return (
    <>
      <Button onClick={() => setIsOpen(true)}>Verify Age</Button>
      
      <Modal isOpen={isOpen} onClose={() => setIsOpen(false)} title="Age Verification">
        <div className="space-y-4">
          <p className="text-gray-600">
            Please verify your age to access this content.
          </p>
          
          <div className="space-y-2">
            <Button
              variant="secondary"
              className="w-full"
              onClick={() => setMethod('worldid')}
            >
              Verify with World ID (Crypto)
            </Button>
            
            <Button
              variant="secondary"
              className="w-full"
              onClick={() => setMethod('yoti')}
            >
              Verify with Yoti (Camera)
            </Button>
          </div>
          
          {method === 'worldid' && (
            <IDKitWidget
              app_id={process.env.NEXT_PUBLIC_WORLDCOIN_APP_ID || ''}
              action="verify-adult"
              onSuccess={handleWorldIDVerify}
            >
              {({ open }) => (
                <Button className="w-full" onClick={open}>
                  Continue with World ID
                </Button>
              )}
            </IDKitWidget>
          )}
          
          {method === 'yoti' && (
            <Button className="w-full" onClick={handleYotiVerify}>
              Continue with Yoti
            </Button>
          )}
        </div>
      </Modal>
    </>
  );
}
