import { NextResponse } from 'next/server';

export async function POST(request: Request) {
  try {
    const body = await request.json();
    const { amount, address, currency } = body;

    if (!amount || amount <= 0) {
      return NextResponse.json(
        { error: 'Invalid amount' },
        { status: 400 }
      );
    }

    if (!address) {
      return NextResponse.json(
        { error: 'Invalid address' },
        { status: 400 }
      );
    }

    // TODO: Execute smart contract withdrawal
    const txId = 'mock-tx-' + Date.now();

    return NextResponse.json({
      status: 'withdrawal initiated',
      txId,
      amount,
      address,
      currency,
    });
  } catch (error) {
    return NextResponse.json(
      { error: 'Withdrawal failed' },
      { status: 500 }
    );
  }
}
