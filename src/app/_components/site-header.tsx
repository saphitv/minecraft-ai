import { Button } from '@/components/ui/button'
import { StatusBadge } from './status-badge'
import { Suspense } from 'react'

export function SiteHeader() {
    return (
        <header className="relative z-10 flex items-center justify-between px-6 py-5 md:px-12">
            <div className="flex items-center gap-3">
                <div className="size-9 grid place-items-center rounded-md bg-gradient-to-br from-emerald-500 to-lime-600 shadow-lg shadow-emerald-500/30 border border-emerald-300/30">
                    <span className="text-sm font-black tracking-tight drop-shadow-sm">AI</span>
                </div>
                <div className="flex flex-col leading-tight">
                    <span className="font-semibold text-emerald-300 drop-shadow">Minecraft AI Chatbot</span>
                    <span className="text-[11px] uppercase tracking-[0.18em] text-neutral-400">Realtime Assistant</span>
                </div>
            </div>
            <div className="flex items-center gap-4">
                <Suspense fallback={<span className="text-xs text-neutral-400">status…</span>}>
                    <StatusBadge />
                </Suspense>
                <Button size="sm" className="bg-emerald-600 hover:bg-emerald-500 text-white shadow-lg shadow-emerald-500/30">
                    Launch Console
                </Button>
            </div>
        </header>
    )
}
