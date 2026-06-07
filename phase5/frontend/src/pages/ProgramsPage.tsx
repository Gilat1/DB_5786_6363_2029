import { useState } from 'react'
import { Play, Zap } from 'lucide-react'
import toast from 'react-hot-toast'
import { fnCustomerPaymentStatus, fnToursByDifficulty, procAssignGuide, procApplyDiscount, type CustomerPaymentStatus, type TourByDifficulty } from '../lib/api'
import LoadingSpinner from '../components/ui/LoadingSpinner'

type ResultData = CustomerPaymentStatus | TourByDifficulty[] | { message: string } | null

export default function ProgramsPage() {
  const [results, setResults] = useState<Record<string, ResultData>>({})
  const [loading, setLoading] = useState<Record<string, boolean>>({})

  // Form state
  const [custId, setCustId] = useState('1')
  const [diffName, setDiffName] = useState('Easy')
  const [tourId, setTourId] = useState('1')
  const [expertise, setExpertise] = useState('Senior Tour Guide')
  const [discTourId, setDiscTourId] = useState('1')
  const [discPct, setDiscPct] = useState('10')

  const setLoad = (id: string, v: boolean) => setLoading(p => ({...p, [id]: v}))
  const setResult = (id: string, v: ResultData) => setResults(p => ({...p, [id]: v}))

  const runFn1 = async () => {
    setLoad('fn1', true)
    try {
      const data = await fnCustomerPaymentStatus(parseInt(custId))
      setResult('fn1', data)
      toast.success('Function executed successfully')
    } catch (e: unknown) { toast.error((e as Error).message) }
    finally { setLoad('fn1', false) }
  }

  const runFn2 = async () => {
    setLoad('fn2', true)
    try {
      const data = await fnToursByDifficulty(diffName)
      setResult('fn2', data)
      toast.success(`Found ${(data as TourByDifficulty[]).length} tours`)
    } catch (e: unknown) { toast.error((e as Error).message) }
    finally { setLoad('fn2', false) }
  }

  const runProc1 = async () => {
    setLoad('pr1', true)
    try {
      const data = await procAssignGuide(parseInt(tourId), expertise)
      setResult('pr1', data)
      toast.success('Guide assigned successfully!')
    } catch (e: unknown) { toast.error((e as Error).message) }
    finally { setLoad('pr1', false) }
  }

  const runProc2 = async () => {
    setLoad('pr2', true)
    try {
      const data = await procApplyDiscount(parseInt(discTourId), parseFloat(discPct))
      setResult('pr2', data)
      toast.success('Discount applied!')
    } catch (e: unknown) { toast.error((e as Error).message) }
    finally { setLoad('pr2', false) }
  }

  const statusColor = (desc: string) => {
    if (!desc) return 'badge-gray'
    if (desc.includes('SETTLED')) return 'badge-green'
    if (desc.includes('CRITICAL')) return 'badge-red'
    if (desc.includes('PARTIAL')) return 'badge-gold'
    return 'badge-gray'
  }

  return (
    <div className="space-y-4 animate-fade-in">
      <div className="p-3 rounded-lg bg-[#d08530]/10 border border-[#d08530]/20 flex items-center gap-2">
        <Zap size={14} className="text-[#d08530]" />
        <span className="text-xs text-[#c9b99a]">All PL/pgSQL functions, procedures, and triggers from Phase 4 are live. Results are real database operations.</span>
      </div>

      <div className="grid grid-cols-1 xl:grid-cols-2 gap-4">

        {/* Function 1 */}
        <div className="card p-5 space-y-3">
          <div>
            <span className="badge badge-gold text-xs mb-2">Function</span>
            <h3 className="section-title">fn_calculate_customer_payment_status</h3>
            <p className="text-xs text-[#8a7560] mt-1">Calculates full financial status for a customer: total cost, paid, debt, and classification.</p>
          </div>
          <div className="flex gap-3 items-end">
            <div className="flex-1">
              <label className="label">Customer ID</label>
              <input className="input-field" type="number" value={custId} onChange={e => setCustId(e.target.value)} />
            </div>
            <button onClick={runFn1} disabled={loading.fn1} className="btn-primary flex items-center gap-2">
              <Play size={14} /> Run
            </button>
          </div>
          {loading.fn1 ? <LoadingSpinner text="Calling function..." /> : results.fn1 && (() => {
            const r = results.fn1 as CustomerPaymentStatus
            return (
              <div className="space-y-2 animate-slide-up">
                <div className="flex justify-between text-sm py-1 border-b border-[#3d2f20]">
                  <span className="text-[#8a7560]">Customer</span>
                  <span className="font-medium text-[#f9edd8]">{r.o_customer_name}</span>
                </div>
                <div className="flex justify-between text-sm py-1 border-b border-[#3d2f20]">
                  <span className="text-[#8a7560]">Total Registered</span>
                  <span className="text-[#f9edd8]">₪{Number(r.o_total_registered).toLocaleString()}</span>
                </div>
                <div className="flex justify-between text-sm py-1 border-b border-[#3d2f20]">
                  <span className="text-[#8a7560]">Total Paid</span>
                  <span className="text-[#60a567]">₪{Number(r.o_total_paid).toLocaleString()}</span>
                </div>
                <div className="flex justify-between text-sm py-1 border-b border-[#3d2f20]">
                  <span className="text-[#8a7560]">Remaining Debt</span>
                  <span className={Number(r.o_debt) > 0 ? 'text-red-400' : 'text-[#60a567]'}>₪{Number(r.o_debt).toLocaleString()}</span>
                </div>
                <div className="pt-1">
                  <span className={`badge ${statusColor(r.o_status_description)} text-xs`}>{r.o_status_description}</span>
                </div>
              </div>
            )
          })()}
        </div>

        {/* Function 2 */}
        <div className="card p-5 space-y-3">
          <div>
            <span className="badge badge-gold text-xs mb-2">Function (refcursor)</span>
            <h3 className="section-title">fn_get_route_tour_details_by_difficulty</h3>
            <p className="text-xs text-[#8a7560] mt-1">Returns guided tours filtered by difficulty level via refcursor with summary statistics.</p>
          </div>
          <div className="flex gap-3 items-end">
            <div className="flex-1">
              <label className="label">Difficulty Name</label>
              <select className="input-field" value={diffName} onChange={e => setDiffName(e.target.value)}>
                {['Easy', 'Medium', 'Hard', 'Extreme', 'Beginner'].map(d => <option key={d}>{d}</option>)}
              </select>
            </div>
            <button onClick={runFn2} disabled={loading.fn2} className="btn-primary flex items-center gap-2">
              <Play size={14} /> Run
            </button>
          </div>
          {loading.fn2 ? <LoadingSpinner text="Fetching cursor..." /> : results.fn2 && (() => {
            const rows = results.fn2 as TourByDifficulty[]
            if (!rows.length) return <p className="text-xs text-[#8a7560] text-center py-4">No tours found for this difficulty</p>
            return (
              <div className="animate-slide-up overflow-x-auto">
                <table className="data-table text-xs">
                  <thead><tr><th>Route</th><th>Guide</th><th>Start</th><th>Price</th><th>Seats</th></tr></thead>
                  <tbody>
                    {rows.map(r => (
                      <tr key={r.tourid}>
                        <td className="text-[#f9edd8]">{r.routename}</td>
                        <td>{r.assignedguide}</td>
                        <td>{r.startdate ? new Date(r.startdate).toLocaleDateString('en-IL') : '—'}</td>
                        <td className="text-[#60a567]">₪{Number(r.price).toLocaleString()}</td>
                        <td>{r.maxparticipants}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
                <div className="text-xs text-[#8a7560] mt-2">{rows.length} tours found</div>
              </div>
            )
          })()}
        </div>

        {/* Procedure 1 */}
        <div className="card p-5 space-y-3">
          <div>
            <span className="badge badge-green text-xs mb-2">Procedure</span>
            <h3 className="section-title">pr_assign_optimal_guide_to_tour</h3>
            <p className="text-xs text-[#8a7560] mt-1">Finds the best available guide by expertise & rating and assigns them to the specified tour.</p>
          </div>
          <div className="space-y-2">
            <div>
              <label className="label">Tour ID</label>
              <input className="input-field" type="number" value={tourId} onChange={e => setTourId(e.target.value)} />
            </div>
            <div>
              <label className="label">Required Expertise</label>
              <select className="input-field" value={expertise} onChange={e => setExpertise(e.target.value)}>
                {['Junior Tour Guide', 'General Tour Guide', 'Professional Tour Guide', 'Senior Tour Guide'].map(x => <option key={x}>{x}</option>)}
              </select>
            </div>
          </div>
          <button onClick={runProc1} disabled={loading.pr1} className="btn-success w-full flex items-center justify-center gap-2">
            <Play size={14} /> {loading.pr1 ? 'Assigning...' : 'Execute Procedure'}
          </button>
          {!loading.pr1 && results.pr1 && (
            <div className="animate-slide-up p-3 rounded-lg bg-[#3d8845]/10 border border-[#3d8845]/20">
              <p className="text-xs text-[#60a567]">✓ {(results.pr1 as { message: string }).message}</p>
            </div>
          )}
        </div>

        {/* Procedure 2 */}
        <div className="card p-5 space-y-3">
          <div>
            <span className="badge badge-green text-xs mb-2">Procedure</span>
            <h3 className="section-title">pr_apply_discount_to_tour_participants</h3>
            <p className="text-xs text-[#8a7560] mt-1">Applies a percentage discount to all registrations of a specific tour and updates their notes.</p>
          </div>
          <div className="space-y-2">
            <div>
              <label className="label">Tour ID</label>
              <input className="input-field" type="number" value={discTourId} onChange={e => setDiscTourId(e.target.value)} />
            </div>
            <div>
              <label className="label">Discount %</label>
              <input className="input-field" type="number" min="0" max="100" value={discPct} onChange={e => setDiscPct(e.target.value)} placeholder="e.g. 10" />
            </div>
          </div>
          <button onClick={runProc2} disabled={loading.pr2} className="btn-success w-full flex items-center justify-center gap-2">
            <Play size={14} /> {loading.pr2 ? 'Applying...' : 'Apply Discount'}
          </button>
          {!loading.pr2 && results.pr2 && (
            <div className="animate-slide-up p-3 rounded-lg bg-[#3d8845]/10 border border-[#3d8845]/20">
              <p className="text-xs text-[#60a567]">✓ {(results.pr2 as { message: string }).message}</p>
            </div>
          )}
        </div>

      </div>

      {/* Trigger info */}
      <div className="card p-5 space-y-3">
        <h3 className="section-title">Active Triggers</h3>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
          {[
            { name: 'trg_update_registration_payment_status', table: 'PAYMENT', event: 'AFTER INSERT / UPDATE', desc: 'Automatically updates registration status when a payment is recorded. Active on Payments page.' },
            { name: 'trg_audit_tour_changes', table: 'GUIDEDTOUR', event: 'AFTER INSERT / UPDATE / DELETE', desc: 'Logs all guided tour modifications to TOUR_AUDIT table including price & guide changes.' },
          ].map(t => (
            <div key={t.name} className="p-4 rounded-lg bg-[#1c1917] border border-[#3d2f20]">
              <div className="font-mono text-xs text-[#d08530] mb-1">{t.name}</div>
              <div className="flex gap-2 mb-2">
                <span className="badge badge-blue text-xs">{t.table}</span>
                <span className="badge badge-gold text-xs">{t.event}</span>
              </div>
              <p className="text-xs text-[#8a7560]">{t.desc}</p>
            </div>
          ))}
        </div>
      </div>
    </div>
  )
}
