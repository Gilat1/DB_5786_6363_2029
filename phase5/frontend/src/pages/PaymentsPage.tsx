import { useEffect, useState } from 'react'
import { Plus, Trash2, Search } from 'lucide-react'
import toast from 'react-hot-toast'
import { getPayments, createPayment, deletePayment, getRegistrations, getPaymentStatus, type Payment, type Registration, type PaymentStatus } from '../lib/api'
import Modal from '../components/ui/Modal'
import ConfirmDialog from '../components/ui/ConfirmDialog'
import LoadingSpinner from '../components/ui/LoadingSpinner'

export default function PaymentsPage() {
  const [payments, setPayments] = useState<Payment[]>([])
  const [filtered, setFiltered] = useState<Payment[]>([])
  const [registrations, setRegistrations] = useState<Registration[]>([])
  const [statuses, setStatuses] = useState<PaymentStatus[]>([])
  const [loading, setLoading] = useState(true)
  const [search, setSearch] = useState('')
  const [showForm, setShowForm] = useState(false)
  const [deleteTarget, setDeleteTarget] = useState<Payment | null>(null)
  const [form, setForm] = useState({ registrationid: '', amount: '', paymentstatusid: '3' })

  const load = () => {
    setLoading(true)
    Promise.all([getPayments(), getRegistrations(), getPaymentStatus()]).then(([p, r, s]) => {
      setPayments(p); setFiltered(p); setRegistrations(r); setStatuses(s)
    }).finally(() => setLoading(false))
  }
  useEffect(() => { load() }, [])
  useEffect(() => {
    const q = search.toLowerCase()
    setFiltered(payments.filter(p => `${p.customername} ${p.paymentstatus}`.toLowerCase().includes(q)))
  }, [search, payments])

  const handleSubmit = async () => {
    try {
      await createPayment({ RegistrationID: parseInt(form.registrationid), Amount: parseFloat(form.amount), PaymentStatusID: parseInt(form.paymentstatusid) })
      toast.success('Payment recorded — registration status auto-updated by trigger!')
      setShowForm(false); load()
    } catch (e: unknown) { toast.error((e as Error).message) }
  }

  const handleDelete = async () => {
    if (!deleteTarget) return
    try { await deletePayment(deleteTarget.paymentid); toast.success('Payment deleted'); setDeleteTarget(null); load() }
    catch (e: unknown) { toast.error((e as Error).message) }
  }

  const statusBadge = (s: string) => {
    if (!s) return 'badge-gray'
    const l = s.toLowerCase()
    if (l.includes('paid') || l.includes('full')) return 'badge-green'
    if (l.includes('fail') || l.includes('refund')) return 'badge-red'
    return 'badge-gold'
  }

  return (
    <div className="space-y-4 animate-fade-in">
      <div className="flex items-center justify-between">
        <div className="relative flex-1 max-w-sm">
          <Search size={15} className="absolute left-3 top-1/2 -translate-y-1/2 text-[#8a7560]" />
          <input className="input-field pl-9" placeholder="Search payments..." value={search} onChange={e => setSearch(e.target.value)} />
        </div>
        <button onClick={() => { setForm({ registrationid: String(registrations[0]?.registrationid || ''), amount: '', paymentstatusid: '3' }); setShowForm(true) }} className="btn-primary flex items-center gap-2">
          <Plus size={16} /> Add Payment
        </button>
      </div>

      <div className="p-3 rounded-lg bg-[#3d8845]/10 border border-[#3d8845]/20 text-sm text-[#60a567]">
        💡 <strong>Trigger active:</strong> Adding a payment automatically updates the corresponding registration status via <code className="font-mono text-xs bg-black/20 px-1 rounded">trg_update_registration_payment_status</code>
      </div>

      {loading ? <LoadingSpinner /> : (
        <div className="table-container">
          <table className="data-table">
            <thead><tr><th>Customer</th><th>Amount</th><th>Date</th><th>Status</th><th>Actions</th></tr></thead>
            <tbody>
              {filtered.length === 0 ? <tr><td colSpan={5} className="text-center py-10 text-[#8a7560]">No payments found</td></tr>
              : filtered.map(p => (
                <tr key={p.paymentid}>
                  <td className="font-medium text-[#f9edd8]">{p.customername}</td>
                  <td className="text-[#60a567] font-semibold">₪{p.amount?.toLocaleString()}</td>
                  <td>{p.paymentdate ? new Date(p.paymentdate).toLocaleDateString('en-IL') : '—'}</td>
                  <td><span className={`badge ${statusBadge(p.paymentstatus)}`}>{p.paymentstatus}</span></td>
                  <td>
                    <button onClick={() => setDeleteTarget(p)} className="p-1.5 rounded-lg text-[#8a7560] hover:text-red-400 hover:bg-red-900/20 transition-colors"><Trash2 size={14} /></button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
          <div className="px-4 py-2 border-t border-[#3d2f20] text-xs text-[#8a7560]">{filtered.length} payments</div>
        </div>
      )}

      {showForm && (
        <Modal title="Record Payment" onClose={() => setShowForm(false)}>
          <div className="space-y-3">
            <div>
              <label className="label">Registration</label>
              <select className="input-field" value={form.registrationid} onChange={e => setForm(p => ({...p, registrationid: e.target.value}))}>
                {registrations.map(r => <option key={r.registrationid} value={r.registrationid}>#{r.registrationid} – {r.customername} ({r.routename})</option>)}
              </select>
            </div>
            <div><label className="label">Amount (₪)</label><input className="input-field" type="number" value={form.amount} onChange={e => setForm(p => ({...p, amount: e.target.value}))} /></div>
            <div>
              <label className="label">Payment Status</label>
              <select className="input-field" value={form.paymentstatusid} onChange={e => setForm(p => ({...p, paymentstatusid: e.target.value}))}>
                {statuses.map(s => <option key={s.paymentstatusid} value={s.paymentstatusid}>{s.statusname}</option>)}
              </select>
            </div>
            <div className="flex gap-3 pt-2">
              <button onClick={() => setShowForm(false)} className="btn-secondary flex-1">Cancel</button>
              <button onClick={handleSubmit} className="btn-primary flex-1">Record</button>
            </div>
          </div>
        </Modal>
      )}
      {deleteTarget && <ConfirmDialog message="Delete this payment record?" onConfirm={handleDelete} onCancel={() => setDeleteTarget(null)} />}
    </div>
  )
}
