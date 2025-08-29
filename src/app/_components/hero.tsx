import { Button } from '@/components/ui/button'

export function Hero() {
  return (
    <section className="mx-auto max-w-5xl pt-10 md:pt-20 flex flex-col items-center text-center gap-10">
      <h1 className="text-4xl md:text-6xl font-extrabold tracking-tight bg-gradient-to-br from-emerald-200 via-emerald-400 to-lime-300 bg-clip-text text-transparent drop-shadow-sm">
        Converse with Your Minecraft World
      </h1>
      <p className="max-w-2xl text-base md:text-lg text-neutral-300 leading-relaxed">
        A focused, server-side AI companion that listens to chat, understands player intent, and responds contextually. Built for administrators, modded networks, and immersive roleplay worlds.
      </p>
      <div className="flex flex-wrap items-center justify-center gap-4">
        <Button className="h-12 px-8 text-base bg-gradient-to-br from-emerald-600 to-lime-600 hover:from-emerald-500 hover:to-lime-500 shadow-xl shadow-emerald-600/30">Get Started</Button>
        <Button variant="outline" className="h-12 px-8 text-base border-emerald-500/40 bg-white/5 hover:bg-white/10 text-emerald-200">View Docs</Button>
      </div>
    </section>
  )
}
