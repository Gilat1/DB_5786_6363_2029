import { useEffect, useState } from 'react'
import { Plus, Pencil, Trash2, Search } from 'lucide-react'
import toast from 'react-hot-toast'
import { getTours, createTour, updateTour, deleteTour, getRoutes, getGuides, getTourStatus, type Tour, type Route, type Guide, type TourStatus } from '../lib/api'
import Modal from '../components/ui/Modal'
import ConfirmDialog from '../components/ui/ConfirmDialog'
import LoadingSpinner from '../components/ui/LoadingSpinner'

export default function ToursPage() {
  const [tours, setTours] = useState<Tour[]>([])
  const [filtered, setFiltered] = useState<Tour[]>([])
  const [routes, setRoutes] = useState<Route[]>([])
  const [guides, setGuides] = useState<Guide[]>([])
  const [statuses, setStatuses] = useState<TourStatus[]>([])
  const [loading, setLoading] = useState(true)
  const [search, setSearch] = useState('')
  const [showForm, setShowForm] = useState(false)
  const [editing, setEditing] = useState<Tour | null>(null)
  const [deleteTarget, setDeleteTarget] = useState<Tour | null>(null)
  const [form, setForm] = useState({ routeid: '', guideid: '', startdate: '', enddate: '', maxparticipants: '20', meetingpoint: '', price: '', tourstatusid: '1' })

  const load = () => {
    setLoading(true)
    Promise.all([getTours(), getRoutes(), getGuides(), getTourStatus()]).then(([t, r, g, s]) => {
      setTours(t); setFiltered(t); setRoutes(r); setGuides(g); setStatuses(s)
    }).finally(() => setLoading(false))
  }
  useEffect(() => { load() }, [])
  useEffect(() => {
    const q = search.toLowerCase()
    setFiltered(tours.filter(t => `${t.routename} ${t.guidename} ${t.tourstatus}`.toLowerCase().includes(q)))
  }, [search, tours])

  const openCreate = () => {
    setEditing(null)
    setForm({ routeid: String(routes[0]?.routeid || ''), guideid: String(guides[0]?.guideid || ''), startdate: '', enddate: '', maxparticipants: '20', meetingpoint: '', price: '', tourstatusid: String(statuses[0]?.tourstatusid || '1') })
    setShowForm(true)
  }

  const openEdit = (t: Tour) => {
    setEditing(t)
    setForm({ routeid: String(t.routeid), guideid: String(t.guideid), startdate: t.startdate?.split('T')[0] || '', enddate: t.enddate?.split('T')[0] || '', maxparticipants: String(t.maxparticipants), meetingpoint: t.meetingpoint, price: String(t.price), tourstatusid: String(t.tourstatusid) })
    setShowForm(true)
  }

  const handleSubmit = async () => {
    const payload = { RouteID: parseInt(form.routeid), GuideID: parseInt(form.guideid), StartDate: form.startdate, EndDate: form.enddate, MaxParticipants: parseInt(form.maxparticipants), MeetingPoint: form.meetingpoint, Price: parseFloat(form.price), TourStatusID: parseInt(form.tourstatusid) }
    try {
      if (editing) { await updateTour(editing.tourid, payload); toast.success('Tour updated') }
      else { await createTour(payload); toast.success('Tour created') }
      setShowForm(false); load()
    } catch (e: unknown) { toast.error((e as Error).message) }
  }

  const handleDelete = async () => {
    if (!deleteTarget) return
    try { await deleteTour(deleteTarget.tourid); toast.success('Tour deleted'); setDeleteTarget(null); load() }
    catch (e: unknown) { toast.error((e as Error).message) }
  }

  const statusBadge = (s: string) => {
    if (!s) return 'badge-gray'
    const l = s.toLowerCase()
    if (l.includes('complet')) return 'badge-green'
    if (l.includes('cancel')) return 'badge-red'
    return 'badge-gold'
  }

  return (
    <div className="space-y-4 animate-fade-in">
      <div className="flex items-center justify-between">
        <div className="relative flex-1 max-w-sm">
          <Search size={15} className="absolute left-3 top-1/2 -translate-y-1/2 text-[#8a7560]" />
          <input className="input-field pl-9" placeholder="Search tours..." value={search} onChange={e => setSearch(e.target.value)} />
        </div>
        <button onClick={openCreate} className="btn-primary flex items-center gap-2"><Plus size={16} /> New Tour</button>
      </div>

      {loading ? <LoadingSpinner /> : (
        <div className="table-container">
          <table className="data-table">
            <thead><tr><th>Route</th><th>Guide</th><th>Start Date</th><th>End Date</th><th>Participants</th><th>Price</th><th>Status</th><th>Actions</th></tr></thead>
            <tbody>
              {filtered.length === 0 ? <tr><td colSpan={8} className="text-center py-10 text-[#8a7560]">No tours found</td></tr>
              : filtered.map(t => (
                <tr key={t.tourid} onClick={() => openEdit(t)}>
                  <td className="font-medium text-[#f9edd8]">{t.routename}</td>
                  <td>{t.guidename}</td>
                  <td>{t.startdate ? new Date(t.startdate).toLocaleDateString('en-IL') : '—'}</td>
                  <td>{t.enddate ? new Date(t.enddate).toLocaleDateString('en-IL') : '—'}</td>
                  <td>{t.maxparticipants}</td>
                  <td>₪{t.price?.toLocaleString()}</td>
                  <td><span className={`badge ${statusBadge(t.tourstatus)}`}>{t.tourstatus}</span></td>
                  <td onClick={e => e.stopPropagation()}>
                    <div className="flex gap-2">
                      <button onClick={() => openEdit(t)} className="p-1.5 rounded-lg text-[#8a7560] hover:text-[#d08530] hover:bg-[#d08530]/10 transition-colors"><Pencil size={14} /></button>
                      <button onClick={() => setDeleteTarget(t)} className="p-1.5 rounded-lg text-[#8a7560] hover:text-red-400 hover:bg-red-900/20 transition-colors"><Trash2 size={14} /></button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
          <div className="px-4 py-2 border-t border-[#3d2f20] text-xs text-[#8a7560]">{filtered.length} tours</div>
        </div>
      )}

      {showForm && (
        <Modal title={editing ? 'Edit Tour' : 'New Tour'} onClose={() => setShowForm(false)}>
          <div className="space-y-3">
            <div className="grid grid-cols-2 gap-3">
              <div>
                <label className="label">Route</label>
                <select className="input-field" value={form.routeid} onChange={e => setForm(p => ({...p, routeid: e.target.value}))}>
                  {routes.map(r => <option key={r.routeid} value={r.routeid}>{r.name}</option>)}
                </select>
              </div>
              <div>
                <label className="label">Guide</label>
                <select className="input-field" value={form.guideid} onChange={e => setForm(p => ({...p, guideid: e.target.value}))}>
                  {guides.map(g => <option key={g.guideid} value={g.guideid}>{g.firstname} {g.lastname}</option>)}
                </select>
              </div>
            </div>
            <div className="grid grid-cols-2 gap-3">
              <div><label className="label">Start Date</label><input className="input-field" type="date" value={form.startdate} onChange={e => setForm(p => ({...p, startdate: e.target.value}))} /></div>
              <div><label className="label">End Date</label><input className="input-field" type="date" value={form.enddate} onChange={e => setForm(p => ({...p, enddate: e.target.value}))} /></div>
            </div>
            <div className="grid grid-cols-3 gap-3">
              <div><label className="label">Max Participants</label><input className="input-field" type="number" value={form.maxparticipants} onChange={e => setForm(p => ({...p, maxparticipants: e.target.value}))} /></div>
              <div><label className="label">Price (₪)</label><input className="input-field" type="number" value={form.price} onChange={e => setForm(p => ({...p, price: e.target.value}))} /></div>
              <div>
                <label className="label">Status</label>
                <select className="input-field" value={form.tourstatusid} onChange={e => setForm(p => ({...p, tourstatusid: e.target.value}))}>
                  {statuses.map(s => <option key={s.tourstatusid} value={s.tourstatusid}>{s.statusname}</option>)}
                </select>
              </div>
            </div>
            <div><label className="label">Meeting Point</label><input className="input-field" value={form.meetingpoint} onChange={e => setForm(p => ({...p, meetingpoint: e.target.value}))} /></div>
            <div className="flex gap-3 pt-2">
              <button onClick={() => setShowForm(false)} className="btn-secondary flex-1">Cancel</button>
              <button onClick={handleSubmit} className="btn-primary flex-1">{editing ? 'Update' : 'Create'}</button>
            </div>
          </div>
        </Modal>
      )}

      {deleteTarget && <ConfirmDialog message={`Delete this tour? This cannot be undone.`} onConfirm={handleDelete} onCancel={() => setDeleteTarget(null)} />}
    </div>
  )
}
