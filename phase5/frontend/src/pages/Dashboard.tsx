import { useEffect, useState } from 'react'
import { Users, CalendarDays, UserCircle, TrendingUp, ArrowRight, MapPin } from 'lucide-react'
import { getDashboard, type DashboardStats } from '../lib/api'
import LoadingSpinner from '../components/ui/LoadingSpinner'
import type { Page } from '../App'

interface Props { onNavigate: (page: Page) => void }

export default function Dashboard({ onNavigate }: Props) {
  const [stats, setStats] = useState<DashboardStats | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    getDashboard().then(setStats).finally(() => setLoading(false))
  }, [])

  if (loading) return <LoadingSpinner text="Loading dashboard..." />

  const statCards = [
    { label: 'Active Guides', value: stats?.activeGuides ?? 0, icon: <Users size={20} />, color: 'text-[#60a567]', bg: 'bg-[#3d8845]/10 border-[#3d8845]/20', page: 'guides' as Page },
    { label: 'Active Tours', value: stats?.activeTours ?? 0, icon: <CalendarDays size={20} />, color: 'text-[#e8c07e]', bg: 'bg-[#d08530]/10 border-[#d08530]/20', page: 'tours' as Page },
    { label: 'Total Customers', value: stats?.totalCustomers ?? 0, icon: <UserCircle size={20} />, color: 'text-blue-400', bg: 'bg-blue-900/10 border-blue-800/20', page: 'customers' as Page },
    { label: 'Revenue (Year)', value: `₪${(stats?.yearRevenue ?? 0).toLocaleString()}`, icon: <TrendingUp size={20} />, color: 'text-purple-400', bg: 'bg-purple-900/10 border-purple-800/20', page: 'payments' as Page },
  ]

  return (
    <div className="space-y-6 animate-fade-in">
      {/* Welcome banner */}
      <div className="relative overflow-hidden rounded-2xl bg-gradient-to-r from-[#1c1410] to-[#24201c] border border-[#3d2f20] p-6">
        <div className="relative z-10">
          <p className="text-[#8a7560] text-sm font-medium mb-1">Welcome back,</p>
          <h2 className="font-display text-3xl font-bold text-[#f9edd8] mb-2">Tour Guide Management</h2>
          <p className="text-[#c9b99a] text-sm max-w-lg">
            Your complete platform for managing guides, routes, tours, and customer registrations.
            All data synced live with your PostgreSQL database.
          </p>
        </div>
        <div className="absolute -right-8 -top-8 w-40 h-40 rounded-full bg-[#d08530]/5 border border-[#d08530]/10" />
        <div className="absolute -right-4 top-4 w-24 h-24 rounded-full bg-[#d08530]/5 border border-[#d08530]/10" />
      </div>

      {/* Stat cards */}
      <div className="grid grid-cols-2 xl:grid-cols-4 gap-4">
        {statCards.map((s, i) => (
          <button
            key={i}
            onClick={() => onNavigate(s.page)}
            className={`stat-card border card-hover text-left group ${s.bg}`}
            style={{ animationDelay: `${i * 80}ms` }}
          >
            <div className={`${s.color} mb-3`}>{s.icon}</div>
            <div className="text-2xl font-bold text-[#f9edd8] font-display">{s.value}</div>
            <div className="text-xs text-[#8a7560]">{s.label}</div>
            <div className="mt-2 flex items-center gap-1 text-xs text-[#8a7560] group-hover:text-[#d08530] transition-colors">
              <span>View all</span><ArrowRight size={12} />
            </div>
          </button>
        ))}
      </div>

      {/* Upcoming tours */}
      <div className="card p-5">
        <div className="flex items-center justify-between mb-4">
          <h3 className="section-title">Upcoming Tours</h3>
          <button onClick={() => onNavigate('tours')} className="text-xs text-[#d08530] hover:text-[#e8c07e] flex items-center gap-1 transition-colors">
            View all <ArrowRight size={12} />
          </button>
        </div>
        {!stats?.upcomingTours?.length ? (
          <p className="text-[#8a7560] text-sm py-6 text-center">No upcoming tours scheduled</p>
        ) : (
          <div className="space-y-2">
            {stats.upcomingTours.map((t) => (
              <div key={t.tourid} className="flex items-center gap-4 p-3 rounded-lg bg-[#1c1917] border border-[#3d2f20] hover:border-[#4d3a28] transition-colors">
                <div className="w-9 h-9 rounded-lg bg-[#d08530]/10 border border-[#d08530]/20 flex items-center justify-center flex-shrink-0">
                  <MapPin size={15} className="text-[#d08530]" />
                </div>
                <div className="flex-1 min-w-0">
                  <div className="font-medium text-[#f9edd8] text-sm truncate">{t.routename}</div>
                  <div className="text-xs text-[#8a7560]">Guide: {t.guidename}</div>
                </div>
                <div className="text-right flex-shrink-0">
                  <div className="text-sm font-medium text-[#e8c07e]">
                    {new Date(t.startdate).toLocaleDateString('en-IL', { day: 'numeric', month: 'short' })}
                  </div>
                  <div className="text-xs text-[#8a7560]">{t.maxparticipants} seats</div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Quick actions */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
        {[
          { label: 'Run Queries', desc: 'Phase 2 analytics', page: 'queries' as Page, color: 'border-[#d08530]/30 hover:border-[#d08530]/60' },
          { label: 'Run Programs', desc: 'Phase 4 functions', page: 'programs' as Page, color: 'border-[#3d8845]/30 hover:border-[#3d8845]/60' },
          { label: 'Add Guide', desc: 'Register new guide', page: 'guides' as Page, color: 'border-blue-800/30 hover:border-blue-700/60' },
          { label: 'New Tour', desc: 'Schedule a tour', page: 'tours' as Page, color: 'border-purple-800/30 hover:border-purple-700/60' },
        ].map((a, i) => (
          <button key={i} onClick={() => onNavigate(a.page)}
            className={`p-4 rounded-xl border bg-[#24201c] text-left transition-all duration-200 ${a.color}`}>
            <div className="font-semibold text-[#f9edd8] text-sm">{a.label}</div>
            <div className="text-xs text-[#8a7560] mt-0.5">{a.desc}</div>
          </button>
        ))}
      </div>
    </div>
  )
}
