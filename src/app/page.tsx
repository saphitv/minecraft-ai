import { SiteHeader } from './_components/site-header'
import { Hero } from './_components/hero'
import { FeaturesGrid } from './_components/features-grid'
import { ScriptTeaser } from './_components/script-teaser'
import { SiteFooter } from './_components/site-footer'


export default function Home() {
  return (
    <div className="relative min-h-dvh overflow-hidden bg-[#0c0f10] text-neutral-100 font-sans">
      <div aria-hidden className="pointer-events-none absolute inset-0 [background:radial-gradient(circle_at_center,rgba(46,255,123,0.08),transparent_70%),repeating-linear-gradient(0deg,rgba(255,255,255,0.04)_0_1px,transparent_1px_40px),repeating-linear-gradient(90deg,rgba(255,255,255,0.04)_0_1px,transparent_1px_40px)]" />
      <div aria-hidden className="absolute inset-0 bg-[radial-gradient(ellipse_at_bottom,rgba(30,130,70,0.35),transparent_70%)] mix-blend-screen" />
      <SiteHeader />
      <main className="relative z-10 px-6 md:px-12 pb-24">
        <Hero />
        <FeaturesGrid />
        <ScriptTeaser />
      </main>
      <SiteFooter />
      <div aria-hidden className="pointer-events-none absolute -top-32 left-1/2 h-64 w-[70rem] -translate-x-1/2 bg-[radial-gradient(circle_at_center,rgba(72,255,164,0.25),transparent_70%)] blur-2xl" />
    </div>
  )
}
