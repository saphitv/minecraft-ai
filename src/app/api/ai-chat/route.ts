import { createOpenRouter } from '@openrouter/ai-sdk-provider'
import { NextResponse } from 'next/server'

interface IncomingChat {
    username?: string
    message?: string
    uuid?: string
    timestamp?: number | string
    formattedMessage?: string
    [key: string]: unknown
}

interface AiChatResponse {
    aiMessage: string
    id: string
    created: string
    model: string
    usage: {
        prompt_tokens: number
        completion_tokens: number
        total_tokens: number
    }
    latencyMs: number
    echo: {
        username?: string
        originalMessage: string
        uuid?: string
        timestamp?: number | string
    }
}

const openrouter = createOpenRouter({
    apiKey: process.env.OPENROUTER_KEY,
});

// Simple stub AI endpoint.
// Accepts POST with JSON: { username, message, uuid, timestamp, ... }
// Returns structured AI-like response for the ComputerCraft client.
export async function POST(req: Request) {
    const started = Date.now()
    let body: IncomingChat = {}
    try {
        const parsed = await req.json()
        if (parsed && typeof parsed === 'object') body = parsed as IncomingChat
    } catch {
        // ignore malformed JSON
    }

    const userMessage = typeof body.message === 'string' ? body.message : ''
    // Generate a pseudo AI reply (non-hardcoded logic: derives from length + random)
    const seed = Math.floor(Math.random() * 9000) + 1000
    const truncated = userMessage.slice(0, 60)
    const aiMessage = userMessage
        ? `Echo(${truncated.length}): ${truncated}${truncated.length < userMessage.length ? '…' : ''} :: ${seed}`
        : `Hello adventurer #${seed}`

    const latencyMs = Date.now() - started
    const response: AiChatResponse = {
        aiMessage,
        id: crypto.randomUUID(),
        created: new Date().toISOString(),
        model: 'stub-echo-0',
        usage: {
            prompt_tokens: userMessage.length,
            completion_tokens: aiMessage.length,
            total_tokens: userMessage.length + aiMessage.length
        },
        latencyMs,
        echo: {
            username: body.username,
            originalMessage: userMessage,
            uuid: body.uuid,
            timestamp: body.timestamp
        }
    }

    return NextResponse.json(response)
}

export async function GET() {
    return NextResponse.json({
        message: 'Use POST with a JSON body to receive an AI-style response.',
        example: { message: 'Hello world' }
    })
}