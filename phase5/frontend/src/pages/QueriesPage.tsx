import { useState } from 'react'
import { Play, ChevronDown } from 'lucide-react'
import toast from 'react-hot-toast'
import {
  queryHighEarningGuides, queryMonthlyRevenue, queryVIPCustomers,
  queryEliteGuides, queryPopularRoutes,
  type HighEarningGuide, type MonthlyRevenue, type VIPCustomer, type EliteGuide, type PopularRoute
} from '../lib/api'
import LoadingSpinner from '../components/ui/LoadingSpinner'

type QueryResult = HighEarningGuide[] | MonthlyRevenue[] | VIPCustomer[] | EliteGuide[] | PopularRoute[] | null

const QUERIES = [
  {
    id: 'high-earning',
    title: 'Query 1 – High-Earning Guides',
    description: 'Guides who generated the most revenue in a given month (JOIN approach, Phase 2 Q1).',
    badge: 'Phase 2 Q1',
    color: 'badge-gold',
  },
  {
    id: 'monthly-revenue',
    title: 'Query 2 – Monthly Revenue Analysis',
    description: 'Total revenue and transaction count broken down by month for a given year (Phase 2 Q2).',
    badge: 'Phase 2 Q2',
    color: 'badge-green',
  },
  {
    id: 'vip-customers',
    title: 'Query 3 – VIP Customer Loyalty',
    description: 'Customers who spent over ₪2,000 in the last year — ideal for loyalty campaigns (Phase 2 Q6).',
    badge: 'Phase 2 Q6',
    color: 'badge-blue',
  },
  {
    id: 'elite-guides',
    title: 'Query 4 – Elite Guides',
    description: 'Guides with above-average rating AND more than 3 tours (Phase 2 Q4).',
    badge: 'Phase 2 Q4',
    color: 'badge-gold',
  },
  {
    id: 'popular-routes',
    title: 'Query 5 – Popular Routes',
    description: 'Routes used in 2+ guided tours, ranked by total capacity (Phase 2 Q7).',
    badge: 'Phase 2 Q7',
    color: 'badge-green',
  },
]

export default function QueriesPage() {
  const [activeQuery, setActiveQuery] = useState<string | null>(null)
  const [results, setResults] = useState<QueryResult>(null)
  const [loading, setLoading] = useState(false)
  const [params, setParams] = useState({ month: '3', year: '2026' })

  const run = async (id: string) => {
    setLoading(true); setResults(null); setActiveQuery(id)
    try {
      let data: QueryResult = null
      switch (id) {
        case 'high-earning': data = await queryHighEarningGuides(parseInt(params.month), parseInt(params.year)); break
        case 'monthly-revenue': data = await queryMonthlyRevenue(parseInt(params.year)); break
        case 'vip-customers': data = await queryVIPCustomers(); break
        case 'elite-guides': data = await queryEliteGuides(); break
        case 'popular-routes': data = await queryPopularRoutes(); break
      }
      setResults(data)
      toast.success(`Query returned ${(data as unknown[])?.length ?? 0} results`)
    } catch (e: unknown) {
      toast.error((e as Error).message)
    } finally { setLoading(false) }
  }

  const renderTable = () => {
    if (!results || !(results as unknown[]).length) return <p className="text-center py-8 text-[#8a7560]">No results returned</p>
    const keys = Object.keys((results as Record<string, unknown>[])[0])
    return (
      <div className="table-container mt-4 animate-slide-up">
        <table className="data-table">
          <thead>
            <tr>{keys.map(k => <th key={k}>{k.replace(/_/g, ' ').toUpperCase()}</th>)}</tr>
          </thead>
          <tbody>
            {(results as Record<string, unknown>[]).map((row, i) => (
              <tr key={i}>
                {keys.map(k => (
                  <td key={k} className={k.includes('total') || k.includes('income') || k.includes('spent') || k.includes('earned') ? 'text-[#60a567] font-semibold' : ''}>
                    {k.includes('date') || k.includes('Date') ? (row[k] ? new Date(row[k] as string).toLocaleDateString('en-IL') : '—')
                      : k.includes('total') || k.includes('income') || k.includes('spent') || k.includes('earned') ? `₪${Number(row[k]).toLocaleString()}`
                      : String(row[k] ?? '—')}
                  </td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
        <div className="px-4 py-2 border-t border-[#3d2f20] text-xs text-[#8a7560]">
          {(results as unknown[]).length} rows returned
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-4 animate-fade-in">
      <div className="p-4 rounded-xl bg-[#1c1917] border border-[#3d2f20]">
        <h3 className="text-sm font-semibold text-[#f9edd8] mb-3">Query Parameters</h3>
        <div className="flex gap-4">
          <div>
            <label className="label">Month</label>
            <input className="input-field w-24" type="number" min="1" max="12" value={params.month} onChange={e => setParams(p => ({...p, month: e.target.value}))} />
          </div>
          <div>
            <label className="label">Year</label>
            <input className="input-field w-28" type="number" value={params.year} onChange={e => setParams(p => ({...p, year: e.target.value}))} />
          </div>
        </div>
        <p className="text-xs text-[#8a7560] mt-2">Used by Queries 1 & 2. Other queries ignore these parameters.</p>
      </div>

      <div className="space-y-3">
        {QUERIES.map(q => (
          <div key={q.id} className="card overflow-hidden">
            <div className="p-4">
              <div className="flex items-start justify-between gap-4">
                <div className="flex-1">
                  <div className="flex items-center gap-2 mb-1">
                    <span className={`badge ${q.color} text-xs`}>{q.badge}</span>
                    <h3 className="font-semibold text-[#f9edd8] text-sm">{q.title}</h3>
                  </div>
                  <p className="text-xs text-[#8a7560]">{q.description}</p>
                </div>
                <button
                  onClick={() => run(q.id)}
                  disabled={loading}
                  className="btn-primary flex items-center gap-2 text-sm flex-shrink-0"
                >
                  <Play size={14} /> Run
                </button>
              </div>
            </div>

            {activeQuery === q.id && (
              <div className="border-t border-[#3d2f20] p-4 bg-[#1c1917]">
                {loading ? <LoadingSpinner text="Executing query..." />
                  : results ? renderTable()
                  : null}
              </div>
            )}
          </div>
        ))}
      </div>

      <div className="p-3 rounded-lg bg-[#1c1917] border border-[#3d2f20] flex items-center gap-2">
        <ChevronDown size={14} className="text-[#8a7560]" />
        <span className="text-xs text-[#8a7560]">All queries run live against the PostgreSQL database. Results reflect the current data state.</span>
      </div>
    </div>
  )
}
