import { Button } from '@/components/ui/button'

export function ScriptTeaser() {
  return (
    <section className="mx-auto mt-24 max-w-5xl rounded-2xl border border-white/10 bg-neutral-900/70 p-8 md:p-12 backdrop-blur-md flex flex-col md:flex-row gap-10 items-center">
      <div className="flex-1 space-y-5">
        <h2 className="text-2xl md:text-3xl font-bold text-emerald-300 tracking-tight">Drop in the Script & Go</h2>
        <p className="text-neutral-300 text-sm md:text-base leading-relaxed">Install the bundled ComputerCraft / CC:Tweaked script to forward chat events directly to the AI pipeline. No fragile RCON scraping, just structured JSON POSTs and resilient retries.</p>
        <div className="rounded-lg border border-emerald-400/30 bg-black/40 p-4 text-left font-mono text-xs text-emerald-200 overflow-x-auto">
{`-- chat_forward.lua (excerpt)\nlocal url = "http://your-host/api/chat-status"\n-- capture & send chat events...`}
        </div>
        <div className="flex gap-3 pt-2">
          <Button size="sm" className="bg-emerald-600 hover:bg-emerald-500">Copy Script</Button>
          <Button size="sm" variant="outline" className="border-emerald-500/40 bg-white/5 text-emerald-200 hover:bg-white/10">GitHub Repo</Button>
        </div>
      </div>
      <div className="flex-1 w-full relative">
        <div className="relative isolate aspect-[4/3] w-full overflow-hidden rounded-xl border border-white/10 bg-gradient-to-br from-emerald-500/10 via-transparent to-lime-500/10 p-6 shadow-inner">
          <div className="absolute inset-0 bg-[linear-gradient(45deg,rgba(255,255,255,0.06)_0%,transparent_60%)] mix-blend-overlay" />
          <div className="h-full w-full grid place-items-center">
            <p className="text-center text-sm text-neutral-300 leading-relaxed max-w-xs">Live dashboard components (player sentiment, intent clusters, tool triggers) plug in here next.</p>
          </div>
        </div>
      </div>
    </section>
  )
}
