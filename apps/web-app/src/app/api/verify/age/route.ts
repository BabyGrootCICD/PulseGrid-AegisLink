import { NextResponse } from 'next/server';

export async function POST(request: Request) {
  try {
    const body = await request.json();
    const { method, proof } = body;

    if (method === 'worldid') {
      // TODO: Verify World ID proof
      return NextResponse.json({
        verified: true,
        token: 'mock-worldid-token',
      });
    }

    if (method === 'yoti') {
      // TODO: Verify Yoti age estimation
      return NextResponse.json({
        verified: true,
        token: 'mock-yoti-token',
      });
    }

    return NextResponse.json(
      { error: 'Invalid verification method' },
      { status: 400 }
    );
  } catch (error) {
    return NextResponse.json(
      { error: 'Verification failed' },
      { status: 500 }
    );
  }
}
