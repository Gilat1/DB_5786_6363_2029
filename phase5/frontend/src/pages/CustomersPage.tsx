import { useEffect, useState } from 'react'
import { Plus, Pencil, Trash2, Search } from 'lucide-react'
import toast from 'react-hot-toast'
import { getCustomers, createCustomer, updateCustomer, deleteCustomer, type Customer } from '../lib/api'
import Modal from '../components/ui/Modal'
import ConfirmDialog from '../components/ui/ConfirmDialog'
import LoadingSpinner from '../components/ui/LoadingSpinner'

export default function CustomersPage() {
  const [customers, setCustomers] = useState<Customer[]>([])
  const [filtered, setFiltered] = useState<Customer[]>([])
  const [loading, setLoading] = useState(true)
  const [search, setSearch] = useState('')
  const [showForm, setShowForm] = useState(false)
  const [editing, setEditing] = useState<Customer | null>(null)
  const [deleteTarget, setDeleteTarget] = useState<Customer | null>(null)
  const [form, setForm] = useState({ fullname: '', email: '', phone: '', joindate: '' })

  const load = () => { setLoading(true); getCustomers().then(d => { setCustomers(d); setFiltered(d) }).finally(() => setLoading(false)) }
  useEffect(() => { load() }, [])
  useEffect(() => {
    const q = search.toLowerCase()
    setFiltered(customers.filter(c => `${c.fullname} ${c.email} ${c.phone}`.toLowerCase().includes(q)))
  }, [search, customers])

  const openCreate = () => { setEditing(null); setForm({ fullname: '', email: '', phone: '', joindate: new Date().toISOString().split('T')[0] }); setShowForm(true) }
  const openEdit = (c: Customer) => { setEditing(c); setForm({ fullname: c.fullname, email: c.email, phone: c.phone, joindate: c.joindate?.split('T')[0] || '' }); setShowForm(true) }

  const handleSubmit = async () => {
    const payload = { FullName: form.fullname, Email: form.email, Phone: form.phone, JoinDate: form.joindate }
    try {
      if (editing) { await updateCustomer(editing.customerid, payload); toast.success('Customer updated') }
      else { await createCustomer(payload); toast.success('Customer created') }
      setShowForm(false); load()
    } catch (e: unknown) { toast.error((e as Error).message) }
  }

  const handleDelete = async () => {
    if (!deleteTarget) return
    try { await deleteCustomer(deleteTarget.customerid); toast.success('Customer deleted'); setDeleteTarget(null); load() }
    catch (e: unknown) { toast.error((e as Error).message) }
  }

  return (
    <div className="space-y-4 animate-fade-in">
      <div className="flex items-center justify-between">
        <div className="relative flex-1 max-w-sm">
          <Search size={15} className="absolute left-3 top-1/2 -translate-y-1/2 text-[#8a7560]" />
          <input className="input-field pl-9" placeholder="Search customers..." value={search} onChange={e => setSearch(e.target.value)} />
        </div>
        <button onClick={openCreate} className="btn-primary flex items-center gap-2"><Plus size={16} /> Add Customer</button>
      </div>

      {loading ? <LoadingSpinner /> : (
        <div className="table-container">
          <table className="data-table">
            <thead><tr><th>Full Name</th><th>Email</th><th>Phone</th><th>Join Date</th><th>Actions</th></tr></thead>
            <tbody>
              {filtered.length === 0 ? <tr><td colSpan={5} className="text-center py-10 text-[#8a7560]">No customers found</td></tr>
              : filtered.map(c => (
                <tr key={c.customerid} onClick={() => openEdit(c)}>
                  <td className="font-medium text-[#f9edd8]">{c.fullname}</td>
                  <td>{c.email}</td>
                  <td>{c.phone}</td>
                  <td>{c.joindate ? new Date(c.joindate).toLocaleDateString('en-IL') : '—'}</td>
                  <td onClick={e => e.stopPropagation()}>
                    <div className="flex gap-2">
                      <button onClick={() => openEdit(c)} className="p-1.5 rounded-lg text-[#8a7560] hover:text-[#d08530] hover:bg-[#d08530]/10 transition-colors"><Pencil size={14} /></button>
                      <button onClick={() => setDeleteTarget(c)} className="p-1.5 rounded-lg text-[#8a7560] hover:text-red-400 hover:bg-red-900/20 transition-colors"><Trash2 size={14} /></button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
          <div className="px-4 py-2 border-t border-[#3d2f20] text-xs text-[#8a7560]">{filtered.length} customers</div>
        </div>
      )}

      {showForm && (
        <Modal title={editing ? 'Edit Customer' : 'New Customer'} onClose={() => setShowForm(false)}>
          <div className="space-y-3">
            <div><label className="label">Full Name</label><input className="input-field" value={form.fullname} onChange={e => setForm(p => ({...p, fullname: e.target.value}))} /></div>
            <div><label className="label">Email</label><input className="input-field" type="email" value={form.email} onChange={e => setForm(p => ({...p, email: e.target.value}))} /></div>
            <div><label className="label">Phone</label><input className="input-field" value={form.phone} onChange={e => setForm(p => ({...p, phone: e.target.value}))} /></div>
            <div><label className="label">Join Date</label><input className="input-field" type="date" value={form.joindate} onChange={e => setForm(p => ({...p, joindate: e.target.value}))} /></div>
            <div className="flex gap-3 pt-2">
              <button onClick={() => setShowForm(false)} className="btn-secondary flex-1">Cancel</button>
              <button onClick={handleSubmit} className="btn-primary flex-1">{editing ? 'Update' : 'Create'}</button>
            </div>
          </div>
        </Modal>
      )}
      {deleteTarget && <ConfirmDialog message={`Delete customer "${deleteTarget.fullname}"? This cannot be undone.`} onConfirm={handleDelete} onCancel={() => setDeleteTarget(null)} />}
    </div>
  )
}
