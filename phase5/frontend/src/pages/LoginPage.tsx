import { useState } from 'react'
import { Compass, Lock, User, Eye, EyeOff } from 'lucide-react'

interface Props {
  onLogin: () => void
}

export default function LoginPage({ onLogin }: Props) {
  const [username, setUsername] = useState('')
  const [password, setPassword] = useState('')
  const [showPassword, setShowPassword] = useState(false)
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)

  const handleLogin = () => {
    setError('')
    setLoading(true)

    setTimeout(() => {
      if (username === 'admin' && password === 'admin123') {
        onLogin()
      } else {
        setError('Invalid username or password')
        setLoading(false)
      }
    }, 800)
  }

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter') handleLogin()
  }

  return (
    <div className="min-h-screen bg-[#0f0d0b] flex items-center justify-center p-4">
      {/* Background circles */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div className="absolute -top-40 -right-40 w-96 h-96 rounded-full bg-[#d08530]/5 border border-[#d08530]/10" />
        <div className="absolute -bottom-40 -left-40 w-96 h-96 rounded-full bg-[#3d8845]/5 border border-[#3d8845]/10" />
      </div>

      <div className="relative w-full max-w-sm animate-slide-up">
        {/* Logo */}
        <div className="flex flex-col items-center mb-8">
          <div className="w-16 h-16 rounded-2xl bg-[#d08530] flex items-center justify-center mb-4 shadow-lg shadow-[#d08530]/20">
            <Compass size={32} className="text-[#0f0d0b]" />
          </div>
          <h1 className="font-display text-3xl font-bold text-[#f9edd8]">TourGuide Pro</h1>
          <p className="text-sm text-[#8a7560] mt-1">Management System</p>
        </div>

        {/* Card */}
        <div className="bg-[#1c1917] border border-[#3d2f20] rounded-2xl p-6 shadow-2xl">
          <h2 className="font-display text-lg font-bold text-[#f9edd8] mb-5">Sign In</h2>

          <div className="space-y-4">
            {/* Username */}
            <div>
              <label className="label">Username</label>
              <div className="relative">
                <User size={15} className="absolute left-3 top-1/2 -translate-y-1/2 text-[#8a7560]" />
                <input
                  className="input-field pl-9"
                  placeholder="Enter username"
                  value={username}
                  onChange={e => setUsername(e.target.value)}
                  onKeyDown={handleKeyDown}
                  autoFocus
                />
              </div>
            </div>

            {/* Password */}
            <div>
              <label className="label">Password</label>
              <div className="relative">
                <Lock size={15} className="absolute left-3 top-1/2 -translate-y-1/2 text-[#8a7560]" />
                <input
                  className="input-field pl-9 pr-10"
                  type={showPassword ? 'text' : 'password'}
                  placeholder="Enter password"
                  value={password}
                  onChange={e => setPassword(e.target.value)}
                  onKeyDown={handleKeyDown}
                />
                <button
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute right-3 top-1/2 -translate-y-1/2 text-[#8a7560] hover:text-[#f9edd8] transition-colors"
                >
                  {showPassword ? <EyeOff size={15} /> : <Eye size={15} />}
                </button>
              </div>
            </div>

            {/* Error */}
            {error && (
              <div className="p-3 rounded-lg bg-red-900/20 border border-red-800/30 text-sm text-red-400">
                {error}
              </div>
            )}

            {/* Button */}
            <button
              onClick={handleLogin}
              disabled={loading || !username || !password}
              className="btn-primary w-full mt-2 flex items-center justify-center gap-2 py-2.5"
            >
              {loading ? (
                <>
                  <div className="w-4 h-4 border-2 border-[#0f0d0b]/30 border-t-[#0f0d0b] rounded-full animate-spin" />
                  Signing in...
                </>
              ) : 'Sign In'}
            </button>
          </div>

          {/* Hint */}
          <div className="mt-4 p-3 rounded-lg bg-[#0f0d0b] border border-[#3d2f20]">
            <p className="text-xs text-[#8a7560] text-center">
              Username: <span className="text-[#e8c07e] font-mono">admin</span>
              {' · '}
              Password: <span className="text-[#e8c07e] font-mono">admin123</span>
            </p>
          </div>
        </div>

        <p className="text-center text-xs text-[#8a7560] mt-4">
          Tour Guide Management System · Phase 5
        </p>
      </div>
    </div>
  )
}
