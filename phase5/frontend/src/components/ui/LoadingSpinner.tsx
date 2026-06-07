export default function LoadingSpinner({ text = 'Loading...' }: { text?: string }) {
  return (
    <div className="flex flex-col items-center justify-center py-16 gap-4">
      <div className="w-10 h-10 border-2 border-[#3d2f20] border-t-[#d08530] rounded-full animate-spin" />
      <span className="text-sm text-[#8a7560]">{text}</span>
    </div>
  )
}
