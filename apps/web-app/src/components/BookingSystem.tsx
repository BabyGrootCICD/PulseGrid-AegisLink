'use client';

import { useState, useEffect } from 'react';
import { Button, Card, Modal } from '@pulsegrid/ui';

interface Counselor {
  id: string;
  name: string;
  specialty: string;
  available: boolean;
}

interface BookingSystemProps {
  userId: string;
}

export function BookingSystem({ userId }: BookingSystemProps) {
  const [counselors, setCounselors] = useState<Counselor[]>([]);
  const [selectedCounselor, setSelectedCounselor] = useState<Counselor | null>(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [selectedDate, setSelectedDate] = useState('');
  const [selectedTime, setSelectedTime] = useState('');

  useEffect(() => {
    fetchCounselors();
  }, []);

  const fetchCounselors = async () => {
    try {
      const res = await fetch('/api/counselors');
      const data = await res.json();
      setCounselors(data.counselors || []);
    } catch (error) {
      console.error('Failed to fetch counselors:', error);
    }
  };

  const handleBook = async () => {
    if (!selectedCounselor || !selectedDate || !selectedTime) return;

    try {
      const res = await fetch('/api/bookings', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          counselorId: selectedCounselor.id,
          userId,
          date: selectedDate,
          time: selectedTime,
        }),
      });
      const data = await res.json();
      if (data.bookingId) {
        alert('Booking confirmed!');
        setIsModalOpen(false);
        setSelectedCounselor(null);
        setSelectedDate('');
        setSelectedTime('');
      }
    } catch (error) {
      console.error('Booking failed:', error);
      alert('Booking failed');
    }
  };

  return (
    <Card className="max-w-4xl mx-auto">
      <h3 className="text-xl font-bold mb-4">Book a Counseling Session</h3>
      
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {counselors.map((counselor) => (
          <div
            key={counselor.id}
            className="border rounded-lg p-4 cursor-pointer hover:border-blue-500"
            onClick={() => {
              setSelectedCounselor(counselor);
              setIsModalOpen(true);
            }}
          >
            <h4 className="font-semibold">{counselor.name}</h4>
            <p className="text-sm text-gray-600">{counselor.specialty}</p>
            <p className={`text-sm ${counselor.available ? 'text-green-600' : 'text-red-600'}`}>
              {counselor.available ? 'Available' : 'Unavailable'}
            </p>
          </div>
        ))}
      </div>
      
      <Modal isOpen={isModalOpen} onClose={() => setIsModalOpen(false)} title="Book Session">
        {selectedCounselor && (
          <div className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Date</label>
              <input
                type="date"
                value={selectedDate}
                onChange={(e) => setSelectedDate(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-md"
              />
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Time</label>
              <select
                value={selectedTime}
                onChange={(e) => setSelectedTime(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-md"
              >
                <option value="">Select a time</option>
                <option value="09:00">9:00 AM</option>
                <option value="10:00">10:00 AM</option>
                <option value="11:00">11:00 AM</option>
                <option value="14:00">2:00 PM</option>
                <option value="15:00">3:00 PM</option>
                <option value="16:00">4:00 PM</option>
              </select>
            </div>
            
            <Button onClick={handleBook} className="w-full">
              Confirm Booking
            </Button>
          </div>
        )}
      </Modal>
    </Card>
  );
}
