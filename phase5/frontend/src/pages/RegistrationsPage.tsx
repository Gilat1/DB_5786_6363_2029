import { useEffect, useState } from 'react'
import { Plus, Pencil, Trash2, Search } from 'lucide-react'
import toast from 'react-hot-toast'
import { getRegistrations, createRegistration, updateRegistration, deleteRegistration, getCustomers, getTours, getRegistrationStatus, type Registration, type Customer, type Tour, type RegistrationStatus } from '../lib/api'
import Modal from '../components/ui/Modal'
import ConfirmDialog from '../components/ui/ConfirmDialog'
import LoadingSpinner from '../components/ui/LoadingSpinner'

export default function RegistrationsPage() {
  const [regs, setRegs] = useState<Registration[]>([])
  const [filtered, setFiltered] = useState<Registration[]>([])
  const [customers, setCustomers] = useState<Customer[]>([])
  const [tours, setTours] = useState<Tour[]>([])
  const [statuses, setStatuses] = useState<RegistrationStatus[]>([])
  const [loading, setLoading] = useState(true)
  const [search, setSearch] = useState('')
  const [showForm, setShowForm] = useState(false)
  const [editing, setEditing] = useState<Registration | null>(null)
  const [deleteTarget, setDeleteTarget] = useState<Registration | null>(null)
  const [form, setForm] = useState({ customerid: '', tourid: '', amounttopay: '', notes: '', registrationstatusid: '1' })

  const load = () => {
    setLoading(true)
    Promise.all([getRegistrations(), getCustomers(), getTours(), getRegistrationStatus()]).then(([r, c, t, s]) => {
      setRegs(r); setFiltered(r); setCustomers(c); setTours(t); setStatuses(s)
    }).finally(() => setLoading(false))
  }
  useEffect(() => { load() }, [])
  useEffect(() => {
    const q = search.toLowerCase()
    setFiltered(regs.filter(r => `${r.customername} ${r.routename} ${r.registrationstatus}`.toLowerCase().includes(q)))
  }, [search, regs])

  const openCreate = () => {
    setEditing(null)
    setForm({ customerid: String(customers[0]?.customerid || ''), tourid: String(tours[0]?.tourid || ''), amounttopay: '', notes: '', registrationstatusid: String(statuses[0]?.registrationstatusid || '1') })
    setShowForm(true)
  }

  const openEdit = (r: Registration) => {
    setEditing(r)
    setForm({ customerid: String(r.customerid), tourid: String(r.tourid), amounttopay: String(r.amounttopay), notes: r.notes || '', registrationstatusid: String(r.registrationstatusid) })
    setShowForm(true)
  }

  const handleSubmit = async () => {
    try {
      if (editing) {
        await updateRegistration(editing.registrationid, { AmountToPay: parseFloat(form.amounttopay), Notes: form.notes, RegistrationStatusID: parseInt(form.registrationstatusid) })
        toast.success('Registration updated')
      } else {
        await createRegistration({ CustomerID: parseInt(form.customerid), TourID: parseInt(form.tourid), AmountToPay: parseFloat(form.amounttopay), Notes: form.notes, RegistrationStatusID: parseInt(form.registrationstatusid) })
        toast.success('Registration created')
      }
      setShowForm(false); load()
    } catch (e: unknown) { toast.error((e as Error).message) }
  }

  const handleDelete = async () => {
    if (!deleteTarget) return
    try { await deleteRegistration(deleteTarget.registrationid); toast.success('Registration deleted'); setDeleteTarget(null); load() }
    catch (e: unknown) { toast.error((e as Error).message) }
  }

  const statusBadge = (s: string) => {
    if (!s) return 'badge-gray'
    const l = s.toLowerCase()
    if (l.includes('confirm') || l.includes('paid')) return 'badge-green'
    if (l.includes('cancel')) return 'badge-red'
    if (l.includes('pending')) return 'badge-gold'
    return 'badge-gray'
  }

  return (
    <div className="space-y-4 animate-fade-in">
      <div className="flex items-center justify-between">
        <div className="relative flex-1 max-w-sm">
          <Search size={15} className="absolute left-3 top-1/2 -translate-y-1/2 text-[#8a7560]" />
          <input className="input-field pl-9" placeholder="Search registrations..." value={search} onChange={e => setSearch(e.target.value)} />
        </div>
        <button onClick={openCreate} className="btn-primary flex items-center gap-2"><Plus size={16} /> Register</button>
      </div>

      {loading ? <LoadingSpinner /> : (
        <div className="table-container">
          <table className="data-table">
            <thead><tr><th>Customer</th><th>Route</th><th>Date</th><th>Amount</th><th>Status</th><th>Actions</th></tr></thead>
            <tbody>
              {filtered.length === 0 ? <tr><td colSpan={6} className="text-center py-10 text-[#8a7560]">No registrations found</td></tr>
              : filtered.map(r => (
                <tr key={r.registrationid} onClick={() => openEdit(r)}>
                  <td className="font-medium text-[#f9edd8]">{r.customername}</td>
                  <td>{r.routename}</td>
                  <td>{r.registrationdate ? new Date(r.registrationdate).toLocaleDateString('en-IL') : '—'}</td>
                  <td>₪{r.amounttopay?.toLocaleString()}</td>
                  <td><span className={`badge ${statusBadge(r.registrationstatus)}`}>{r.registrationstatus}</span></td>
                  <td onClick={e => e.stopPropagation()}>
                    <div className="flex gap-2">
                      <button onClick={() => openEdit(r)} className="p-1.5 rounded-lg text-[#8a7560] hover:text-[#d08530] hover:bg-[#d08530]/10 transition-colors"><Pencil size={14} /></button>
                      <button onClick={() => setDeleteTarget(r)} className="p-1.5 rounded-lg text-[#8a7560] hover:text-red-400 hover:bg-red-900/20 transition-colors"><Trash2 size={14} /></button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
          <div className="px-4 py-2 border-t border-[#3d2f20] text-xs text-[#8a7560]">{filtered.length} registrations</div>
        </div>
      )}

      {showForm && (
        <Modal title={editing ? 'Edit Registration' : 'New Registration'} onClose={() => setShowForm(false)}>
          <div className="space-y-3">
            {!editing && (
              <>
                <div>
                  <label className="label">Customer</label>
                  <select className="input-field" value={form.customerid} onChange={e => setForm(p => ({...p, customerid: e.target.value}))}>
                    {customers.map(c => <option key={c.customerid} value={c.customerid}>{c.fullname}</option>)}
                  </select>
                </div>
                <div>
                  <label className="label">Tour</label>
                  <select className="input-field" value={form.tourid} onChange={e => setForm(p => ({...p, tourid: e.target.value}))}>
                    {tours.map(t => <option key={t.tourid} value={t.tourid}>{t.routename} – {t.startdate ? new Date(t.startdate).toLocaleDateString('en-IL') : ''}</option>)}
                  </select>
                </div>
              </>
            )}
            <div><label className="label">Amount to Pay (₪)</label><input className="input-field" type="number" value={form.amounttopay} onChange={e => setForm(p => ({...p, amounttopay: e.target.value}))} /></div>
            <div>
              <label className="label">Status</label>
              <select className="input-field" value={form.registrationstatusid} onChange={e => setForm(p => ({...p, registrationstatusid: e.target.value}))}>
                {statuses.map(s => <option key={s.registrationstatusid} value={s.registrationstatusid}>{s.statusname}</option>)}
              </select>
            </div>
            <div><label className="label">Notes</label><textarea className="input-field h-16 resize-none" value={form.notes} onChange={e => setForm(p => ({...p, notes: e.target.value}))} /></div>
            <div className="flex gap-3 pt-2">
              <button onClick={() => setShowForm(false)} className="btn-secondary flex-1">Cancel</button>
              <button onClick={handleSubmit} className="btn-primary flex-1">{editing ? 'Update' : 'Create'}</button>
            </div>
          </div>
        </Modal>
      )}
      {deleteTarget && <ConfirmDialog message="Delete this registration? This cannot be undone." onConfirm={handleDelete} onCancel={() => setDeleteTarget(null)} />}
    </div>
  )
}
