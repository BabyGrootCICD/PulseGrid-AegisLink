import { NextResponse } from 'next/server';

export async function POST(request: Request) {
  try {
    const body = await request.json();
    const { counselorId, userId, date, time } = body;

    if (!counselorId || !userId || !date || !time) {
      return NextResponse.json(
        { error: 'Missing required fields' },
        { status: 400 }
      );
    }

    // TODO: Save to database
    const bookingId = 'booking-' + Date.now();

    return NextResponse.json({
      bookingId,
      counselorId,
      userId,
      date,
      time,
      status: 'confirmed',
    });
  } catch (error) {
    return NextResponse.json(
      { error: 'Booking failed' },
      { status: 500 }
    );
  }
}

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const userId = searchParams.get('userId');

  if (!userId) {
    return NextResponse.json(
      { error: 'Missing userId' },
      { status: 400 }
    );
  }

  // TODO: Fetch from database
  const bookings = [];

  return NextResponse.json({ bookings });
}
