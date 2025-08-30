import { createOpenRouter } from '@openrouter/ai-sdk-provider'
import { generateText } from 'ai'
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

// --- Simple in-memory global rate limiter ----------------------------------
// NOTE: This only works reliably for a single server instance. In a serverless
// or horizontally scaled deployment each instance keeps its own counters, so
// you should replace this with a shared store (Redis, Upstash, Vercel KV, etc.)
// if you need stronger guarantees.
const RATE_LIMIT_MAX = 10; // max requests
const RATE_LIMIT_WINDOW_MS = 60 * 60 * 1000; // 1 hour
interface RateState { windowStart: number; count: number }
let rateState: RateState = { windowStart: Date.now(), count: 0 }

function rateLimited() {
    const now = Date.now()
    // Reset window if expired
    if (now - rateState.windowStart >= RATE_LIMIT_WINDOW_MS) {
        rateState = { windowStart: now, count: 0 }
    }
    if (rateState.count >= RATE_LIMIT_MAX) return true
    rateState.count += 1
    return false
}

// Simple stub AI endpoint.
// Accepts POST with JSON: { username, message, uuid, timestamp, ... }
// Returns structured AI-like response for the ComputerCraft client.
export async function POST(req: Request) {
    if (req.headers.get('secret-key') !== process.env.SECRET_KEY) {
        return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
    }

    // Apply rate limiting AFTER auth so only your own calls consume quota.
    if (rateLimited()) {
        const retryAfter = Math.ceil((rateState.windowStart + RATE_LIMIT_WINDOW_MS - Date.now()) / 1000)
        return new NextResponse(
            JSON.stringify({ error: 'Rate limit exceeded. Try again later.' }),
            {
                status: 429,
                headers: {
                    'Content-Type': 'application/json',
                    'Retry-After': String(retryAfter)
                }
            }
        )
    }

    const started = Date.now()
    let body: IncomingChat = {}
    try {
        const parsed = await req.json()
        if (parsed && typeof parsed === 'object') body = parsed as IncomingChat
    } catch {
        // ignore malformed JSON
    }

    const userMessage = typeof body.message === 'string' ? body.message : ''


    const { text: aiMessage } = await generateText({
        model: openrouter("google/gemini-2.0-flash-exp:free"),
        system: "You are a friendly and concise minecraft AI assistant. Answer user questions about minecraft.",
        prompt: userMessage
    })

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