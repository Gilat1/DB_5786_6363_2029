import { useEffect, useState } from 'react'
import { Plus, Pencil, Trash2, Search } from 'lucide-react'
import toast from 'react-hot-toast'
import { getRoutes, createRoute, updateRoute, deleteRoute, getDifficulty, type Route, type DifficultyLevel } from '../lib/api'
import Modal from '../components/ui/Modal'
import ConfirmDialog from '../components/ui/ConfirmDialog'
import LoadingSpinner from '../components/ui/LoadingSpinner'

export default function RoutesPage() {
  const [routes, setRoutes] = useState<Route[]>([])
  const [filtered, setFiltered] = useState<Route[]>([])
  const [difficulties, setDifficulties] = useState<DifficultyLevel[]>([])
  const [loading, setLoading] = useState(true)
  const [search, setSearch] = useState('')
  const [showForm, setShowForm] = useState(false)
  const [editing, setEditing] = useState<Route | null>(null)
  const [deleteTarget, setDeleteTarget] = useState<Route | null>(null)
  const [form, setForm] = useState({
    name: '', description: '', region: '', estimatedlength: '', estimatedduration: '', difficultyid: '1'
  })

  const load = () => {
    setLoading(true)
    Promise.all([getRoutes(), getDifficulty()]).then(([r, d]) => {
      setRoutes(r); setFiltered(r); setDifficulties(d)
      if (d.length) setForm(p => ({...p, difficultyid: String(d[0].difficultyid)}))
    }).finally(() => setLoading(false))
  }
  useEffect(() => { load() }, [])
  useEffect(() => {
    const q = search.toLowerCase()
    setFiltered(routes.filter(r => `${r.name} ${r.region} ${r.difficultyname}`.toLowerCase().includes(q)))
  }, [search, routes])

  const openCreate = () => {
    setEditing(null)
    setForm({ name: '', description: '', region: '', estimatedlength: '', estimatedduration: '', difficultyid: String(difficulties[0]?.difficultyid || 1) })
    setShowForm(true)
  }

  const openEdit = (r: Route) => {
    setEditing(r)
    setForm({ name: r.name, description: r.description, region: r.region, estimatedlength: String(r.estimatedlength), estimatedduration: String(r.estimatedduration), difficultyid: String(r.difficultyid) })
    setShowForm(true)
  }

  const handleSubmit = async () => {
    const payload = { Name: form.name, Description: form.description, Region: form.region, EstimatedLength: parseFloat(form.estimatedlength), EstimatedDuration: parseInt(form.estimatedduration), DifficultyID: parseInt(form.difficultyid) }
    try {
      if (editing) { await updateRoute(editing.routeid, payload); toast.success('Route updated') }
      else { await createRoute(payload); toast.success('Route created') }
      setShowForm(false); load()
    } catch (e: unknown) { toast.error((e as Error).message) }
  }

  const handleDelete = async () => {
    if (!deleteTarget) return
    try { await deleteRoute(deleteTarget.routeid); toast.success('Route deleted'); setDeleteTarget(null); load() }
    catch (e: unknown) { toast.error((e as Error).message) }
  }

  const diffColor = (name: string) => {
    if (!name) return 'badge-gray'
    const n = name.toLowerCase()
    if (n.includes('easy')) return 'badge-green'
    if (n.includes('hard') || n.includes('extreme')) return 'badge-red'
    return 'badge-gold'
  }

  return (
    <div className="space-y-4 animate-fade-in">
      <div className="flex items-center justify-between">
        <div className="relative flex-1 max-w-sm">
          <Search size={15} className="absolute left-3 top-1/2 -translate-y-1/2 text-[#8a7560]" />
          <input className="input-field pl-9" placeholder="Search routes..." value={search} onChange={e => setSearch(e.target.value)} />
        </div>
        <button onClick={openCreate} className="btn-primary flex items-center gap-2"><Plus size={16} /> Add Route</button>
      </div>

      {loading ? <LoadingSpinner /> : (
        <div className="table-container">
          <table className="data-table">
            <thead><tr><th>Name</th><th>Region</th><th>Difficulty</th><th>Length (km)</th><th>Duration (min)</th><th>Actions</th></tr></thead>
            <tbody>
              {filtered.length === 0 ? (
                <tr><td colSpan={6} className="text-center py-10 text-[#8a7560]">No routes found</td></tr>
              ) : filtered.map(r => (
                <tr key={r.routeid} onClick={() => openEdit(r)}>
                  <td className="font-medium text-[#f9edd8]">{r.name}</td>
                  <td>{r.region}</td>
                  <td><span className={`badge ${diffColor(r.difficultyname)}`}>{r.difficultyname}</span></td>
                  <td>{r.estimatedlength}</td>
                  <td>{r.estimatedduration}</td>
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
          <div className="px-4 py-2 border-t border-[#3d2f20] text-xs text-[#8a7560]">{filtered.length} routes</div>
        </div>
      )}

      {showForm && (
        <Modal title={editing ? 'Edit Route' : 'New Route'} onClose={() => setShowForm(false)}>
          <div className="space-y-3">
            <div><label className="label">Route Name</label><input className="input-field" value={form.name} onChange={e => setForm(p => ({...p, name: e.target.value}))} /></div>
            <div><label className="label">Description</label><textarea className="input-field h-20 resize-none" value={form.description} onChange={e => setForm(p => ({...p, description: e.target.value}))} /></div>
            <div><label className="label">Region</label><input className="input-field" value={form.region} onChange={e => setForm(p => ({...p, region: e.target.value}))} /></div>
            <div className="grid grid-cols-3 gap-3">
              <div><label className="label">Length (km)</label><input className="input-field" type="number" value={form.estimatedlength} onChange={e => setForm(p => ({...p, estimatedlength: e.target.value}))} /></div>
              <div><label className="label">Duration (min)</label><input className="input-field" type="number" value={form.estimatedduration} onChange={e => setForm(p => ({...p, estimatedduration: e.target.value}))} /></div>
              <div>
                <label className="label">Difficulty</label>
                <select className="input-field" value={form.difficultyid} onChange={e => setForm(p => ({...p, difficultyid: e.target.value}))}>
                  {difficulties.map(d => <option key={d.difficultyid} value={d.difficultyid}>{d.difficultyname}</option>)}
                </select>
              </div>
            </div>
            <div className="flex gap-3 pt-2">
              <button onClick={() => setShowForm(false)} className="btn-secondary flex-1">Cancel</button>
              <button onClick={handleSubmit} className="btn-primary flex-1">{editing ? 'Update' : 'Create'}</button>
            </div>
          </div>
        </Modal>
      )}

      {deleteTarget && (
        <ConfirmDialog message={`Delete route "${deleteTarget.name}"? This cannot be undone.`} onConfirm={handleDelete} onCancel={() => setDeleteTarget(null)} />
      )}
    </div>
  )
}
