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

export async function POST(request: Request) {
  try {
    const body = await request.json()

    // Log the received data (you could store this in a database)
    console.log('Chat data received:', body)

    return NextResponse.json({
      success: true,
      message: "Chat data processed successfully",
      received: body
    })
  } catch {
    return NextResponse.json({
      success: false,
      message: "Error processing chat data"
    }, { status: 400 })
  }
}
