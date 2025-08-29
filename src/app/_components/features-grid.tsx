export interface FeatureItem { title: string; body: string }

const FEATURES: FeatureItem[] = [
  { title: 'Real-Time Monitoring', body: 'Low-latency ingestion of chat events with structured AI-ready context enrichment.' },
  { title: 'Contextual Replies', body: 'Embeds server events + player memory for responses that feel grounded and helpful.' },
  { title: 'Plug & Play', body: 'Drop in the supplied ComputerCraft script or bridge adapter and go.' },
  { title: 'Privacy First', body: 'Process only what you need. Hooks ready for on-prem inference.' },
  { title: 'Extensible', body: 'Event bus + middleware pipeline for custom classifiers or tools.' },
  { title: 'Open Source', body: 'Transparent codebase you can fork, audit, and extend.' },
]

export function FeaturesGrid() {
  return (
    <section className="mx-auto mt-20 max-w-5xl grid gap-8 md:grid-cols-3">
      {FEATURES.map(f => (
        <div key={f.title} className="group relative overflow-hidden rounded-xl border border-white/10 bg-gradient-to-b from-white/5 to-white/[0.02] p-5 backdrop-blur-sm shadow-sm hover:shadow-emerald-500/20 transition-shadow">
          <div className="absolute inset-px rounded-[11px] bg-gradient-to-br from-emerald-400/15 via-transparent to-lime-400/10 opacity-0 group-hover:opacity-100 transition-opacity" />
          <h3 className="relative z-10 mb-2 font-semibold text-emerald-200 tracking-wide text-sm">{f.title}</h3>
          <p className="relative z-10 text-[13px] leading-relaxed text-neutral-300">{f.body}</p>
        </div>
      ))}
    </section>
  )
}
