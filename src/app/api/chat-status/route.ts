import { NextResponse } from 'next/server'

export async function GET() {
  // Static response that the Lua script can consume
  const response = {
    status: "online",
    message: "Chat monitoring system is active and processing messages",
    server: "ComputerCraft Chat Monitor",
    version: "1.0.0",
    timestamp: new Date().toISOString()
  }

  return NextResponse.json(response)
}
