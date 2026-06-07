import { useEffect, useState } from 'react'
import { Plus, Pencil, Trash2, Search } from 'lucide-react'
import toast from 'react-hot-toast'
import { getLocations, createLocation, updateLocation, deleteLocation, type Location } from '../lib/api'
import Modal from '../components/ui/Modal'
import ConfirmDialog from '../components/ui/ConfirmDialog'
import LoadingSpinner from '../components/ui/LoadingSpinner'

export default function LocationsPage() {
  const [locations, setLocations] = useState<Location[]>([])
  const [filtered, setFiltered] = useState<Location[]>([])
  const [loading, setLoading] = useState(true)
  const [search, setSearch] = useState('')
  const [showForm, setShowForm] = useState(false)
  const [editing, setEditing] = useState<Location | null>(null)
  const [deleteTarget, setDeleteTarget] = useState<Location | null>(null)
  const [form, setForm] = useState({ locationname: '', category: '', description: '' })

  const load = () => { setLoading(true); getLocations().then(d => { setLocations(d); setFiltered(d) }).finally(() => setLoading(false)) }
  useEffect(() => { load() }, [])
  useEffect(() => {
    const q = search.toLowerCase()
    setFiltered(locations.filter(l => `${l.locationname} ${l.category}`.toLowerCase().includes(q)))
  }, [search, locations])

  const openCreate = () => { setEditing(null); setForm({ locationname: '', category: '', description: '' }); setShowForm(true) }
  const openEdit = (l: Location) => { setEditing(l); setForm({ locationname: l.locationname, category: l.category, description: l.description }); setShowForm(true) }

  const handleSubmit = async () => {
    const payload = { LocationName: form.locationname, Category: form.category, Description: form.description }
    try {
      if (editing) { await updateLocation(editing.locationid, payload); toast.success('Location updated') }
      else { await createLocation(payload); toast.success('Location created') }
      setShowForm(false); load()
    } catch (e: unknown) { toast.error((e as Error).message) }
  }

  const handleDelete = async () => {
    if (!deleteTarget) return
    try { await deleteLocation(deleteTarget.locationid); toast.success('Location deleted'); setDeleteTarget(null); load() }
    catch (e: unknown) { toast.error((e as Error).message) }
  }

  return (
    <div className="space-y-4 animate-fade-in">
      <div className="flex items-center justify-between">
        <div className="relative flex-1 max-w-sm">
          <Search size={15} className="absolute left-3 top-1/2 -translate-y-1/2 text-[#8a7560]" />
          <input className="input-field pl-9" placeholder="Search locations..." value={search} onChange={e => setSearch(e.target.value)} />
        </div>
        <button onClick={openCreate} className="btn-primary flex items-center gap-2"><Plus size={16} /> Add Location</button>
      </div>

      {loading ? <LoadingSpinner /> : (
        <div className="table-container">
          <table className="data-table">
            <thead><tr><th>Location Name</th><th>Category</th><th>Description</th><th>Actions</th></tr></thead>
            <tbody>
              {filtered.length === 0 ? <tr><td colSpan={4} className="text-center py-10 text-[#8a7560]">No locations found</td></tr>
              : filtered.map(l => (
                <tr key={l.locationid} onClick={() => openEdit(l)}>
                  <td className="font-medium text-[#f9edd8]">{l.locationname}</td>
                  <td><span className="badge badge-blue">{l.category}</span></td>
                  <td className="max-w-xs truncate">{l.description}</td>
                  <td onClick={e => e.stopPropagation()}>
                    <div className="flex gap-2">
                      <button onClick={() => openEdit(l)} className="p-1.5 rounded-lg text-[#8a7560] hover:text-[#d08530] hover:bg-[#d08530]/10 transition-colors"><Pencil size={14} /></button>
                      <button onClick={() => setDeleteTarget(l)} className="p-1.5 rounded-lg text-[#8a7560] hover:text-red-400 hover:bg-red-900/20 transition-colors"><Trash2 size={14} /></button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
          <div className="px-4 py-2 border-t border-[#3d2f20] text-xs text-[#8a7560]">{filtered.length} locations</div>
        </div>
      )}

      {showForm && (
        <Modal title={editing ? 'Edit Location' : 'New Location'} onClose={() => setShowForm(false)}>
          <div className="space-y-3">
            <div><label className="label">Location Name</label><input className="input-field" value={form.locationname} onChange={e => setForm(p => ({...p, locationname: e.target.value}))} /></div>
            <div><label className="label">Category</label><input className="input-field" value={form.category} onChange={e => setForm(p => ({...p, category: e.target.value}))} placeholder="e.g. City, Nature, Historical" /></div>
            <div><label className="label">Description</label><textarea className="input-field h-20 resize-none" value={form.description} onChange={e => setForm(p => ({...p, description: e.target.value}))} /></div>
            <div className="flex gap-3 pt-2">
              <button onClick={() => setShowForm(false)} className="btn-secondary flex-1">Cancel</button>
              <button onClick={handleSubmit} className="btn-primary flex-1">{editing ? 'Update' : 'Create'}</button>
            </div>
          </div>
        </Modal>
      )}
      {deleteTarget && <ConfirmDialog message={`Delete location "${deleteTarget.locationname}"?`} onConfirm={handleDelete} onCancel={() => setDeleteTarget(null)} />}
    </div>
  )
}
