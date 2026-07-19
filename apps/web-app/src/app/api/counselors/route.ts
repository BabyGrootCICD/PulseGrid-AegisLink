import { NextResponse } from 'next/server';

export async function GET() {
  // TODO: Fetch from database
  const counselors = [
    {
      id: '1',
      name: 'Dr. Sarah Johnson',
      specialty: 'Sexual Health',
      available: true,
    },
    {
      id: '2',
      name: 'Dr. Michael Chen',
      specialty: 'Mental Health',
      available: true,
    },
    {
      id: '3',
      name: 'Dr. Emily Rodriguez',
      specialty: 'Relationship Counseling',
      available: false,
    },
  ];

  return NextResponse.json({ counselors });
}
