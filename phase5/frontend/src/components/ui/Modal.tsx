import { X } from 'lucide-react'

interface Props {
  title: string
  onClose: () => void
  children: React.ReactNode
}

export default function Modal({ title, onClose, children }: Props) {
  return (
    <div className="modal-overlay" onClick={(e) => { if (e.target === e.currentTarget) onClose() }}>
      <div className="modal-content">
        <div className="flex items-center justify-between p-5 border-b border-[#3d2f20]">
          <h2 className="section-title">{title}</h2>
          <button onClick={onClose} className="text-[#8a7560] hover:text-[#f9edd8] transition-colors">
            <X size={20} />
          </button>
        </div>
        <div className="p-5">
          {children}
        </div>
      </div>
    </div>
  )
}
