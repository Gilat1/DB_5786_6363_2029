import { useEffect, useState } from 'react'
import { Plus, Pencil, Trash2, Star, Search } from 'lucide-react'
import toast from 'react-hot-toast'
import { getGuides, createGuide, updateGuide, deleteGuide, type Guide } from '../lib/api'
import Modal from '../components/ui/Modal'
import ConfirmDialog from '../components/ui/ConfirmDialog'
import LoadingSpinner from '../components/ui/LoadingSpinner'

const EXPERTISE_LEVELS = ['Junior Tour Guide', 'General Tour Guide', 'Professional Tour Guide', 'Senior Tour Guide']

export default function GuidesPage() {
  const [guides, setGuides] = useState<Guide[]>([])
  const [filtered, setFiltered] = useState<Guide[]>([])
  const [loading, setLoading] = useState(true)
  const [search, setSearch] = useState('')
  const [showForm, setShowForm] = useState(false)
  const [editing, setEditing] = useState<Guide | null>(null)
  const [deleteTarget, setDeleteTarget] = useState<Guide | null>(null)
  const [form, setForm] = useState({
    firstname: '', lastname: '', email: '', phone: '',
    dailyrate: '', rating: '', experienceyears: '', expertise: 'General Tour Guide'
  })

  const load = () => { setLoading(true); getGuides().then(d => { setGuides(d); setFiltered(d) }).finally(() => setLoading(false)) }
  useEffect(() => { load() }, [])
  useEffect(() => {
    const q = search.toLowerCase()
    setFiltered(guides.filter(g =>
      `${g.firstname} ${g.lastname} ${g.email} ${g.expertise}`.toLowerCase().includes(q)
    ))
  }, [search, guides])

  const openCreate = () => {
    setEditing(null)
    setForm({ firstname: '', lastname: '', email: '', phone: '', dailyrate: '', rating: '', experienceyears: '', expertise: 'General Tour Guide' })
    setShowForm(true)
  }

  const openEdit = (g: Guide) => {
    setEditing(g)
    setForm({
      firstname: g.firstname, lastname: g.lastname, email: g.email, phone: g.phone,
      dailyrate: String(g.dailyrate), rating: String(g.rating),
      experienceyears: String(g.experienceyears), expertise: g.expertise || 'General Tour Guide'
    })
    setShowForm(true)
  }

  const handleSubmit = async () => {
    const payload = {
      FirstName: form.firstname, LastName: form.lastname, Email: form.email, Phone: form.phone,
      DailyRate: parseFloat(form.dailyrate), Rating: parseFloat(form.rating),
      ExperienceYears: parseInt(form.experienceyears), Expertise: form.expertise
    }
    try {
      if (editing) {
        await updateGuide(editing.guideid, payload)
        toast.success('Guide updated')
      } else {
        await createGuide(payload)
        toast.success('Guide created')
      }
      setShowForm(false); load()
    } catch (e: unknown) {
      toast.error((e as Error).message)
    }
  }

  const handleDelete = async () => {
    if (!deleteTarget) return
    try {
      await deleteGuide(deleteTarget.guideid)
      toast.success('Guide deleted')
      setDeleteTarget(null); load()
    } catch (e: unknown) { toast.error((e as Error).message) }
  }

  const ratingColor = (r: number) => r >= 4.5 ? 'badge-gold' : r >= 3.5 ? 'badge-green' : 'badge-gray'

  return (
    <div className="space-y-4 animate-fade-in">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="relative flex-1 max-w-sm">
          <Search size={15} className="absolute left-3 top-1/2 -translate-y-1/2 text-[#8a7560]" />
          <input className="input-field pl-9" placeholder="Search guides..." value={search} onChange={e => setSearch(e.target.value)} />
        </div>
        <button onClick={openCreate} className="btn-primary flex items-center gap-2">
          <Plus size={16} /> Add Guide
        </button>
      </div>

      {/* Table */}
      {loading ? <LoadingSpinner /> : (
        <div className="table-container">
          <table className="data-table">
            <thead>
              <tr>
                <th>Name</th><th>Email</th><th>Phone</th><th>Expertise</th>
                <th>Rating</th><th>Experience</th><th>Daily Rate</th><th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {filtered.length === 0 ? (
                <tr><td colSpan={8} className="text-center py-10 text-[#8a7560]">No guides found</td></tr>
              ) : filtered.map(g => (
                <tr key={g.guideid} onClick={() => openEdit(g)}>
                  <td className="font-medium text-[#f9edd8]">{g.firstname} {g.lastname}</td>
                  <td>{g.email}</td>
                  <td>{g.phone}</td>
                  <td><span className="badge badge-gold">{g.expertise || '—'}</span></td>
                  <td>
                    <span className={`badge ${ratingColor(g.rating)} flex items-center gap-1 w-fit`}>
                      <Star size={10} fill="currentColor" /> {Number(g.rating).toFixed(1)}                    </span>
                  </td>
                  <td>{g.experienceyears} yrs</td>
                  <td>₪{g.dailyrate?.toLocaleString()}</td>
                  <td onClick={e => e.stopPropagation()}>
                    <div className="flex gap-2">
                      <button onClick={() => openEdit(g)} className="p-1.5 rounded-lg text-[#8a7560] hover:text-[#d08530] hover:bg-[#d08530]/10 transition-colors">
                        <Pencil size={14} />
                      </button>
                      <button onClick={() => setDeleteTarget(g)} className="p-1.5 rounded-lg text-[#8a7560] hover:text-red-400 hover:bg-red-900/20 transition-colors">
                        <Trash2 size={14} />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
          <div className="px-4 py-2 border-t border-[#3d2f20] text-xs text-[#8a7560]">{filtered.length} guides</div>
        </div>
      )}

      {/* Form Modal */}
      {showForm && (
        <Modal title={editing ? 'Edit Guide' : 'New Guide'} onClose={() => setShowForm(false)}>
          <div className="space-y-3">
            <div className="grid grid-cols-2 gap-3">
              <div><label className="label">First Name</label><input className="input-field" value={form.firstname} onChange={e => setForm(p => ({ ...p, firstname: e.target.value }))} /></div>
              <div><label className="label">Last Name</label><input className="input-field" value={form.lastname} onChange={e => setForm(p => ({ ...p, lastname: e.target.value }))} /></div>
            </div>
            <div><label className="label">Email</label><input className="input-field" type="email" value={form.email} onChange={e => setForm(p => ({ ...p, email: e.target.value }))} /></div>
            <div><label className="label">Phone</label><input className="input-field" value={form.phone} onChange={e => setForm(p => ({ ...p, phone: e.target.value }))} /></div>
            <div className="grid grid-cols-3 gap-3">
              <div><label className="label">Daily Rate (₪)</label><input className="input-field" type="number" value={form.dailyrate} onChange={e => setForm(p => ({ ...p, dailyrate: e.target.value }))} /></div>
              <div><label className="label">Rating (0–5)</label><input className="input-field" type="number" min="0" max="5" step="0.1" value={form.rating} onChange={e => setForm(p => ({ ...p, rating: e.target.value }))} /></div>
              <div><label className="label">Exp. Years</label><input className="input-field" type="number" value={form.experienceyears} onChange={e => setForm(p => ({ ...p, experienceyears: e.target.value }))} /></div>
            </div>
            <div>
              <label className="label">Expertise</label>
              <select className="input-field" value={form.expertise} onChange={e => setForm(p => ({ ...p, expertise: e.target.value }))}>
                {EXPERTISE_LEVELS.map(l => <option key={l}>{l}</option>)}
              </select>
            </div>
            <div className="flex gap-3 pt-2">
              <button onClick={() => setShowForm(false)} className="btn-secondary flex-1">Cancel</button>
              <button onClick={handleSubmit} className="btn-primary flex-1">{editing ? 'Update' : 'Create'}</button>
            </div>
          </div>
        </Modal>
      )}

      {deleteTarget && (
        <ConfirmDialog
          message={`Delete guide "${deleteTarget.firstname} ${deleteTarget.lastname}"? This cannot be undone.`}
          onConfirm={handleDelete}
          onCancel={() => setDeleteTarget(null)}
        />
      )}
    </div>
  )
}
