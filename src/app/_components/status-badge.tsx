'use client'
import { useEffect, useState } from 'react'

export function StatusBadge() {
  const [data, setData] = useState<any>(null)
  useEffect(() => {
    let active = true
    const load = async () => {
      try {
        const res = await fetch('/api/chat-status', { cache: 'no-store' })
        const json = await res.json()
        if (active) setData(json)
      } catch (e) {
        if (active) setData({ status: 'offline' })
      }
    }
    load()
    const id = setInterval(load, 10000)
    return () => { active = false; clearInterval(id) }
  }, [])
  const status = data?.status || 'loading'
  const color = status === 'online' ? 'bg-emerald-500/80 shadow-emerald-500/40' : status === 'loading' ? 'bg-yellow-500/60 shadow-yellow-500/30' : 'bg-red-600/70 shadow-red-600/40'
  return (
    <span className={`inline-flex items-center gap-2 rounded-full px-4 py-1.5 text-xs font-medium tracking-wide shadow-md backdrop-blur border border-white/10 ${color}`}>
      <span className="relative flex size-2.5">
        <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-current opacity-40" />
        <span className="relative inline-flex size-2.5 rounded-full bg-current" />
      </span>
      <span className="capitalize">{status}</span>
    </span>
  )
}
