import { AlertTriangle } from 'lucide-react'

interface Props {
  message: string
  onConfirm: () => void
  onCancel: () => void
}

export default function ConfirmDialog({ message, onConfirm, onCancel }: Props) {
  return (
    <div className="modal-overlay">
      <div className="bg-[#1c1917] border border-red-800/40 rounded-2xl shadow-2xl w-full max-w-sm p-6 animate-slide-up">
        <div className="flex items-start gap-4 mb-5">
          <div className="w-10 h-10 rounded-full bg-red-900/30 flex items-center justify-center flex-shrink-0">
            <AlertTriangle size={20} className="text-red-400" />
          </div>
          <div>
            <h3 className="font-semibold text-[#f9edd8] mb-1">Confirm Deletion</h3>
            <p className="text-sm text-[#8a7560]">{message}</p>
          </div>
        </div>
        <div className="flex gap-3 justify-end">
          <button onClick={onCancel} className="btn-secondary text-sm">Cancel</button>
          <button onClick={onConfirm} className="btn-danger text-sm">Delete</button>
        </div>
      </div>
    </div>
  )
}
